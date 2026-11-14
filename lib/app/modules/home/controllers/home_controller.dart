// ignore_for_file: unnecessary_overrides, depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/services/secure_backend_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  RxString profilePic =
      "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503"
          .obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  RxList<BannerModel> bannerList = <BannerModel>[].obs;
  PageController pageController = PageController();
  RxInt curPage = 0.obs;
  RxInt drawerIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxBool hasLocationPermission = false.obs;
  Rxn<LatLng> currentMapLocation = Rxn<LatLng>();
  RxMap<MarkerId, Marker> nearbyDriverMarkers = <MarkerId, Marker>{}.obs;
  RxInt nearbyDriverCount = 0.obs;
  RxString nearbyDriverStatus = 'Finding moving vehicles nearby'.obs;

  GoogleMapController? homeMapController;
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<List<DocumentSnapshot>>? _nearbyDriverSubscription;
  LatLng? _nearbyQueryCenter;
  BitmapDescriptor _movingVehicleMarker =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  bool _hasCentredHomeMap = false;

  RxInt suggestionView = 3.obs;

  @override
  void onInit() {
    super.onInit();
    getUserData();
    updateCurrentLocation();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _nearbyDriverSubscription?.cancel();
    homeMapController?.dispose();
    pageController.dispose();
    super.onClose();
  }

  Future<void> getUserData() async {
    isLoading.value = true;

    UserModel? userModel =
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    await checkActiveStatus();
    if (userModel != null) {
      profilePic.value = (userModel.profilePic ?? "").isNotEmpty
          ? userModel.profilePic ??
              "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503"
          : "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503";
      name.value = userModel.fullName ?? '';
      phoneNumber.value =
          (userModel.countryCode ?? '') + (userModel.phoneNumber ?? '');
      userModel.fcmToken = await NotificationService.getToken();
      await FireStoreUtils.updateUser(userModel);
      await FireStoreUtils.getBannerList().then((value) {
        bannerList.value = value ?? [];
      });

      await Utils.getCurrentLocation();
    }
  }

  Future<void> checkActiveStatus() async {
    UserModel? userModel =
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    if (userModel!.isActive == false) {
      Get.defaultDialog(
          titlePadding: const EdgeInsets.only(top: 16),
          title: "Account Disabled",
          middleText:
              "Your account has been disabled. Please contact the administrator.",
          titleStyle:
              GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          barrierDismissible: false,
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          });
    }
  }

  Location location = Location();

  Future<void> updateCurrentLocation() async {
    try {
      await _prepareMovingVehicleMarker();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }

      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus != PermissionStatus.granted) {
        permissionStatus = await location.requestPermission();
      }

      hasLocationPermission.value =
          serviceEnabled && permissionStatus == PermissionStatus.granted;

      if (hasLocationPermission.value) {
        await location.enableBackgroundMode(enable: true);
        await location.changeSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter:
              double.parse(Constant.driverLocationUpdate.toString()),
          interval: 2000,
        );

        _handleLocationUpdate(await location.getLocation());
        await _locationSubscription?.cancel();
        _locationSubscription =
            location.onLocationChanged.listen(_handleLocationUpdate);
      } else {
        nearbyDriverStatus.value = 'Location access is required';
      }
    } catch (error, stackTrace) {
      log('Unable to initialise live home map: $error', stackTrace: stackTrace);
      nearbyDriverStatus.value = 'Live vehicle locations are unavailable';
    }

    _configureSuggestionCount();
    isLoading.value = false;
    update();
  }

  void onHomeMapCreated(GoogleMapController controller) {
    homeMapController = controller;
    if (currentMapLocation.value != null) {
      centerHomeMap();
    }
  }

  Future<void> centerHomeMap() async {
    final target = currentMapLocation.value;
    final controller = homeMapController;
    if (target == null || controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.5),
      ),
    );
    _hasCentredHomeMap = true;
  }

  void _handleLocationUpdate(LocationData locationData) {
    final latitude = locationData.latitude;
    final longitude = locationData.longitude;
    if (latitude == null || longitude == null) return;

    final nextLocation = LatLng(latitude, longitude);
    currentMapLocation.value = nextLocation;
    Constant.currentLocation = LocationLatLng(
      latitude: latitude,
      longitude: longitude,
    );

    if (!_hasCentredHomeMap && homeMapController != null) {
      centerHomeMap();
    }

    if (_shouldRefreshNearbyQuery(nextLocation)) {
      _startNearbyDriverStream(nextLocation);
    }
  }

  bool _shouldRefreshNearbyQuery(LatLng nextLocation) {
    final previous = _nearbyQueryCenter;
    if (previous == null) return true;
    return (previous.latitude - nextLocation.latitude).abs() > 0.002 ||
        (previous.longitude - nextLocation.longitude).abs() > 0.002;
  }

  void _startNearbyDriverStream(LatLng centerLocation) {
    _nearbyQueryCenter = centerLocation;
    _nearbyDriverSubscription?.cancel();
    nearbyDriverStatus.value = 'Finding moving vehicles nearby';

    final center = GeoFlutterFire().point(
      latitude: centerLocation.latitude,
      longitude: centerLocation.longitude,
    );
    final Query query =
        FirebaseFirestore.instance.collection(CollectionName.driverUsers);
    final radius = double.tryParse(Constant.radius) ?? 10;

    _nearbyDriverSubscription = GeoFlutterFire()
        .collection(collectionRef: query)
        .within(
          center: center,
          radius: radius,
          field: 'position',
          strictMode: true,
        )
        .listen(
      (documents) {
        final markers = <MarkerId, Marker>{};
        for (final document in documents) {
          final rawData = document.data();
          if (rawData is! Map<String, dynamic>) continue;

          final driver = DriverUserModel.fromJson(rawData);
          final driverLocation = driver.location;
          if (driver.isOnline != true ||
              driver.isActive == false ||
              driver.isVerified == false ||
              driverLocation?.latitude == null ||
              driverLocation?.longitude == null) {
            continue;
          }

          final markerId = MarkerId('driver_${driver.id ?? document.id}');
          markers[markerId] = Marker(
            markerId: markerId,
            position: LatLng(
              driverLocation!.latitude!,
              driverLocation.longitude!,
            ),
            rotation: double.tryParse('${driver.rotation ?? 0}') ?? 0,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            icon: _movingVehicleMarker,
            infoWindow: InfoWindow(
              title: driver.driverVehicleDetails?.vehicleTypeName ??
                  'Moving vehicle',
              snippet: driver.fullName,
            ),
          );
        }

        nearbyDriverMarkers.assignAll(markers);
        nearbyDriverCount.value = markers.length;
        nearbyDriverStatus.value = markers.isEmpty
            ? 'No moving vehicles nearby right now'
            : markers.length == 1
                ? '1 moving vehicle nearby'
                : '${markers.length} moving vehicles nearby';
      },
      onError: (Object error, StackTrace stackTrace) {
        log('Nearby moving vehicle stream failed: $error',
            stackTrace: stackTrace);
        nearbyDriverMarkers.clear();
        nearbyDriverCount.value = 0;
        nearbyDriverStatus.value = 'Unable to load nearby moving vehicles';
      },
    );
  }

  Future<void> _prepareMovingVehicleMarker() async {
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(size / 2, size / 2);

    canvas.drawCircle(center, 46, Paint()..color = Colors.white);
    canvas.drawCircle(center, 41, Paint()..color = const Color(0xFFFFA726));

    final icon = Icons.local_shipping_rounded;
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: const Color(0xFF17191B),
          fontSize: 43,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        (size - iconPainter.width) / 2,
        (size - iconPainter.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(96, 96);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes != null) {
      _movingVehicleMarker = BitmapDescriptor.bytes(bytes.buffer.asUint8List());
    }
  }

  void _configureSuggestionCount() {
    if (Constant.isInterCitySharingBid == true &&
        Constant.isParcelBid == true &&
        Constant.isInterCitySharingBid == true) {
      suggestionView.value = 3;
    } else if (Constant.isInterCitySharingBid == false &&
        Constant.isInterCitySharingBid == false) {
      suggestionView.value = 2;
    } else {
      suggestionView.value = 1;
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      await SecureBackendService.requestCustomerAccountDeletion();
    } catch (error) {
      log("Error : $error");
      rethrow;
    }
  }
}
