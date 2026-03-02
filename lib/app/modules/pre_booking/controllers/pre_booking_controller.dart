// ignore_for_file: depend_on_referenced_packages, deprecated_member_use
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/utils.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../constant/constant.dart';
import '../../../models/vehicle_type_model.dart';

class PreBookingController extends GetxController {
  // UI and map state
  RxBool isLoading = true.obs;
  RxInt popupIndex = 0.obs;
  List<VehicleTypeModel> vehicleTypeList = [];
  RxBool isLoadingVehicles = false.obs;

  GoogleMapController? mapController;
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  Position? currentPosition;

  final pickupController = TextEditingController();
  final dropoffController = TextEditingController();
  FocusNode pickupFocus = FocusNode();
  FocusNode dropoffFocus = FocusNode();

  RxString distanceText = ''.obs;
  RxString durationText = ''.obs;
  RxDouble estimatedFare = 0.0.obs;

  BitmapDescriptor? pickIcon;
  BitmapDescriptor? dropIcon;

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();

  // Fare settings
  final double baseFare = 20.0;
  final double perKmRate = 10.0;
  final double perMinuteRate = 1.5;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    _initMap();
    super.onInit();
    loadVehicleTypes();
  }

  Future<void> loadVehicleTypes() async {
    try {
      isLoadingVehicles.value = true;

      // Use Constant if it's already loaded
      if (Constant.vehicleTypeList != null && Constant.vehicleTypeList!.isNotEmpty) {
        vehicleTypeList = Constant.vehicleTypeList!;
        if (kDebugMode) {
          print("Loaded vehicles: ${vehicleTypeList.length}");
        }
      } else {
        // If Constant.vehicleTypeList is empty, try to fetch it again
        // This depends on your API service or static data
        // Example:
        // vehicleTypeList = await ApiService.getVehicleTypeList();
        if (kDebugMode) {
          print("⚠️ Constant.vehicleTypeList is empty");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading vehicles: $e");
      }
    } finally {
      isLoadingVehicles.value = false;
      update();
    }
  }



  Future<void> _initMap() async {
    currentPosition = await Utils.getCurrentLocation();
    pickupLocation = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    await _setCustomIcons();
    addMarker(latitude: pickupLocation!.latitude, longitude: pickupLocation!.longitude, id: "pickup", descriptor: pickIcon!);
    isLoading.value = false;
  }

  Future<void> _setCustomIcons() async {
    final Uint8List pickBytes = await Constant().getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
    final Uint8List dropBytes = await Constant().getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
    pickIcon = BitmapDescriptor.fromBytes(pickBytes);
    dropIcon = BitmapDescriptor.fromBytes(dropBytes);
  }

  void addMarker({required double latitude, required double longitude, required String id, required BitmapDescriptor descriptor}) {
    final marker = Marker(markerId: MarkerId(id), position: LatLng(latitude, longitude), icon: descriptor);
    markers[MarkerId(id)] = marker;
  }

  // inside PreBookingController class
  RxString selectedVehicleType = ''.obs; // chosen vehicle ID or name
  RxString selectedVehicleName = ''.obs; // optional readable label


  /// Called after both pickup and drop-off are selected
  Future<void> calculateRoute() async {
    if (pickupLocation == null || dropoffLocation == null) return;

    try {
      const apiKey = 'AIzaSyBYOAMfn9hEgiJiz2HJGQ5wnl3fIO8qg9o';
      Dio dio = Dio();
      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation!.latitude},${pickupLocation!.longitude}&destination=${dropoffLocation!.latitude},${dropoffLocation!.longitude}&key=$apiKey';

      final response = await dio.get(url);
      if (response.data["routes"].isEmpty) return;

      final leg = response.data["routes"][0]["legs"][0];
      distanceText.value = leg["distance"]["text"];
      durationText.value = leg["duration"]["text"];

      final km = leg["distance"]["value"] / 1000;
      final mins = leg["duration"]["value"] / 60;
      estimatedFare.value = baseFare + (km * perKmRate) + (mins * perMinuteRate);

      final encodedPoints = response.data["routes"][0]["overview_polyline"]["points"];
      _drawPolyline(encodedPoints);

      _fitToBounds();

      // ✅ Move to Confirm bottom sheet
      popupIndex.value = 1;
      update();

    } catch (e) {
      Get.snackbar("Route Error", e.toString());
    }
  }


  void _drawPolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    final polylineId = const PolylineId('route');
    polyLines[polylineId] = Polyline(
      polylineId: polylineId,
      color: AppThemData.primary500,
      width: 5,
      points: polylineCoordinates,
    );
  }

  void _fitToBounds() {
    if (mapController == null || pickupLocation == null || dropoffLocation == null) return;

    final southwestLat =
    pickupLocation!.latitude < dropoffLocation!.latitude ? pickupLocation!.latitude : dropoffLocation!.latitude;
    final southwestLng =
    pickupLocation!.longitude < dropoffLocation!.longitude ? pickupLocation!.longitude : dropoffLocation!.longitude;
    final northeastLat =
    pickupLocation!.latitude > dropoffLocation!.latitude ? pickupLocation!.latitude : dropoffLocation!.latitude;
    final northeastLng =
    pickupLocation!.longitude > dropoffLocation!.longitude ? pickupLocation!.longitude : dropoffLocation!.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );

    // Animate the camera to include both points with padding
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }


  Future<void> savePreBooking() async {
    if (pickupLocation == null || dropoffLocation == null) return;
    isLoading.value = true;
    try {
      await _firestore.collection('pre_bookings').add({
        'userId': _auth.currentUser?.uid ?? 'guest',
        'pickup': pickupController.text,
        'dropoff': dropoffController.text,
        'pickupLat': pickupLocation!.latitude,
        'pickupLng': pickupLocation!.longitude,
        'dropLat': dropoffLocation!.latitude,
        'dropLng': dropoffLocation!.longitude,
        'distance': distanceText.value,
        'duration': durationText.value,
        'fare': estimatedFare.value,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      popupIndex.value = 2;
    } finally {
      isLoading.value = false;
    }
  }

  void selectPickup(LatLng pos, String address) {
    pickupLocation = pos;
    pickupController.text = address;
    addMarker(latitude: pos.latitude, longitude: pos.longitude, id: "pickup", descriptor: pickIcon!);
  }

  void selectDropoff(LatLng pos, String address) {
    dropoffLocation = pos;
    dropoffController.text = address;
    addMarker(latitude: pos.latitude, longitude: pos.longitude, id: "drop", descriptor: dropIcon!);
    calculateRoute();
  }

  void onBackPressed() {
    if (popupIndex.value > 0) {
      popupIndex.value--;
    } else {
      Get.back();
    }
  }

  void setLocation({required bool isPickup, required LatLng pos, required String address}) {
    final markerId = isPickup ? const MarkerId('pickup') : const MarkerId('dropoff');
    final color = isPickup
        ? BitmapDescriptor.hueGreen
        : BitmapDescriptor.hueRed;

    markers[markerId] = Marker(
      markerId: markerId,
      position: pos,
      infoWindow: InfoWindow(title: isPickup ? 'Pickup' : 'Drop-off'),
      icon: BitmapDescriptor.defaultMarkerWithHue(color),
    );

    if (isPickup) {
      pickupLocation = pos;
      pickupController.text = address;
    } else {
      dropoffLocation = pos;
      dropoffController.text = address;
    }

    if (pickupLocation != null && dropoffLocation != null) {
      calculateRoute();
    }

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
  }

}
