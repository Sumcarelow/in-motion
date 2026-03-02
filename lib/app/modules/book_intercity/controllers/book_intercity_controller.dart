// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/distance_model.dart';
import 'package:customer/app/models/time_slots_charges_model.dart';
import 'package:customer/app/models/intercity_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/map_model.dart';
import 'package:customer/app/models/person_model.dart';
import 'package:customer/app/models/positions.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/vehicle_model_model.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class BookIntercityController extends GetxController {
  RxInt selectedRideType = 1.obs;
  RxInt selectedPersons = 1.obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;
  Rx<IntercityModel> interCityModel = IntercityModel().obs;
  Rx<PersonModel> personModel = PersonModel().obs;

  FocusNode pickUpFocusNode = FocusNode();
  FocusNode dropFocusNode = FocusNode();

  RxString selectedPaymentMethod = 'Cash'.obs;
  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;
  RxList<PersonModel> sharingPersonsList = <PersonModel>[].obs;

  TextEditingController dropLocationController = TextEditingController();

  Rx<TextEditingController> addPriceController = TextEditingController().obs;
  Rx<TextEditingController> enterNameController = TextEditingController().obs;
  Rx<TextEditingController> enterNumberController = TextEditingController().obs;

  RxList<PersonModel> totalAddPersonShare = <PersonModel>[].obs;
  RxList<PersonModel> addInSharing = <PersonModel>[].obs;
  TextEditingController pickupLocationController = TextEditingController();
  LatLng? sourceLocation;
  LatLng? destination;
  Position? currentLocationPosition;
  Rx<MapModel?> mapModel = MapModel().obs;
  RxBool isLoading = true.obs;

  RxString pikUpAddress = ''.obs;
  RxString dropAddress = ''.obs;
  RxDouble estimatePrice = 0.0.obs;
  RxBool isEstimatePriceVisible = false.obs;

  Rx<DistanceModel> distanceOfKm = DistanceModel().obs;

  Rx<VehicleTypeModel> vehicleTypeModel = VehicleTypeModel(
      id: "",
      image: "",
      isActive: false,
      timeSlots: [],
      title: "",
      persons: "0",
      charges: Charges(
        fareMinimumChargesWithinKm: "0",
        farMinimumCharges: "0",
        farePerKm: "0",
      )).obs;
  RxList<VehicleModelModel> vehicleModelList = <VehicleModelModel>[].obs;
  List<VehicleTypeModel> vehicleTypeList = Constant.vehicleTypeList ?? [];

  @override
  void onInit() {
    vehicleTypeModel.value = vehicleTypeList[0];
    getData();
    super.onInit();
  }

  RxString selectedTime = "Select Time".obs;

  void pickTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedTime.value = pickedTime.format(context);
      ChargesModel? intercityModel = calculationOfEstimatePrice();

      if (intercityModel != null) {
        if (double.parse(distanceOfKm.value.distance!) < double.parse(intercityModel.fareMinimumChargesWithinKm)) {
          log("Distance is less than the minimum charge threshold");
          estimatePrice.value = double.parse(intercityModel.farMinimumCharges);
          isEstimatePriceVisible.value = true;

          log('================================> 11111111 =>${estimatePrice.value}');
        } else {
          estimatePrice.value =
              double.parse((double.parse(intercityModel.farePerKm) * double.parse(distanceOfKm.value.distance!)).toStringAsFixed(2));
          addPriceController.value.text = double.parse(estimatePrice.value.toString()).toString();
          isEstimatePriceVisible.value = true;

          log('================================> 2222222=> ${estimatePrice.value}');

          log("Distance is greater than or equal to the minimum charge threshold");
        }

        log("Matched InterCityServiceModel: ${intercityModel.timeSlot}");
        log("Matched minimumCharges: ${intercityModel.farMinimumCharges}");
      } else {
        log("No matching time slot found.");
      }
    }
  }

  updateData() async {
    if (destination != null && sourceLocation != null) {
      ShowToastDialog.showLoader("Please wait".tr);
      mapModel.value = await Constant.getDurationDistance(sourceLocation!, destination!);

      distanceOfKm.value = DistanceModel(
        distance: distanceCalculate(mapModel.value),
        distanceType: Constant.distanceType,
      );
      updateCalculation();
    }

    log('=====================> get distance od totlae $distanceOfKm');
    log('=====================> get distanceOfKm ${distanceOfKm.value.distance}');
    ShowToastDialog.closeLoader();
  }

  updateCalculation() {
    if (selectedTime.value != 'Select Time' && selectedTime.value.isNotEmpty) {
      // if (pickedTime != null) {
      //   selectedTime.value = pickedTime.format(context);
      ChargesModel? intercityModel = calculationOfEstimatePrice();

      if (intercityModel != null) {
        log('--------------------.>');

        // if(selectedRideType.value == 1) {

        if (double.parse(distanceOfKm.value.distance!) < double.parse(intercityModel.fareMinimumChargesWithinKm)) {
          log("Distance is less than the minimum charge threshold");
          estimatePrice.value = double.parse(intercityModel.farMinimumCharges);
          isEstimatePriceVisible.value = true;
          log('================================> 11111111 =>${estimatePrice.value}');
        } else {
          estimatePrice.value =
              double.parse((double.parse(intercityModel.farePerKm) * double.parse(distanceOfKm.value.distance!)).toStringAsFixed(2));
          addPriceController.value.text = double.parse(estimatePrice.value.toString()).toString();
          isEstimatePriceVisible.value = true;

          log('================================> 2222222=> ${estimatePrice.value}');

          log("Distance is greater than or equal to the minimum charge threshold");
        }

        log("Matched InterCityServiceModel: ${intercityModel.timeSlot}");
        log("Matched minimumCharges: ${intercityModel.farMinimumCharges}");
      } else {
        log("----------------> No matching time slot found.");
      }
    }
  }

  // calculationOfEstimatePrice() {
  //
  //   if (selectedTime.value != 'Select Time' && selectedTime.value != '') {
  //     log('====--------> selected time of ride ${selectedTime.value}');
  //
  //     for(var i in Constant.intercityPersonalDocuments.first.timeSlots){
  //       log('----------------> time solte ${i.timeSlot}');
  //     }
  //
  //
  //   }
  // }

  // RxList<IntercityDocumentModel> intercitySharingList = <IntercityDocumentModel>[].obs;
  RxList<ChargesModel> intercitySharingList = <ChargesModel>[].obs;

  ChargesModel? calculationOfEstimatePrice() {
    log('===============> select time ${selectedTime.value}');
    if (selectedTime.value != 'Select Time' && selectedTime.value.isNotEmpty) {
      log('====> Selected time of ride: ${selectedTime.value}');

      DateTime selectedDateTime = convertToDateTime(selectedTime.value);

      if (selectedRideType.value == 1) {
        intercitySharingList.value = Constant.intercitySharingDocuments.first.timeSlots;
      } else {
        intercitySharingList.value = Constant.intercityPersonalDocuments.first.timeSlots;
      }
      for (var model in intercitySharingList) {
        log('Checking time slot: ${model.timeSlot}');

        if (isTimeInRange(selectedDateTime, model.timeSlot)) {
          log('✅ Matched time slot: ${model.timeSlot}');
          log('✅ Matched time slot: ${model.fareMinimumChargesWithinKm}');

          return model;
        }
      }
    }
    log("❌ No matching time slot found.");
    return null;
  }

  bool isTimeInRange(DateTime selectedTime, String timeSlot) {
    log("Checking time slot: $timeSlot");
    RegExp fullRangeRegEx = RegExp(r"(\d+)\s*(AM|PM)?\s*-\s*(\d+)\s*(AM|PM)", caseSensitive: false);
    Match? match = fullRangeRegEx.firstMatch(timeSlot);

    if (match == null) {
      log("❌ Could not extract numeric range from: $timeSlot");
      return false;
    }

    int startHour = int.parse(match.group(1)!);
    String startPeriod = (match.group(2) ?? match.group(4))!.toUpperCase();
    int endHour = int.parse(match.group(3)!);
    String endPeriod = match.group(4)!.toUpperCase();

    if (timeSlot.toLowerCase().contains("morning") && endHour == 12 && startPeriod == "AM") {
      endPeriod = "PM";
    }

    int startMinutes = convertToMinutes(startHour, startPeriod);
    int endMinutes = convertToMinutes(endHour, endPeriod);
    int selectedMinutes = selectedTime.hour * 60 + selectedTime.minute;

    bool inRange;
    if (startMinutes < endMinutes) {
      inRange = (selectedMinutes >= startMinutes && selectedMinutes < endMinutes);
    } else {
      inRange = (selectedMinutes >= startMinutes || selectedMinutes < endMinutes);
    }

    log("Extracted range: '$startHour $startPeriod - $endHour $endPeriod'");
    log("Comparing: selected time ${selectedTime.hour}:${selectedTime.minute} ($selectedMinutes minutes) with range $startMinutes-$endMinutes -> Result: $inRange");

    return inRange;
  }

  int convertToMinutes(int hour, String period) {
    if (period == "PM" && hour != 12) {
      hour += 12;
    }
    if (period == "AM" && hour == 12) {
      hour = 0;
    }
    return hour * 60;
  }

  DateTime convertToDateTime(String time) {
    final format = DateFormat("h:mm a");
    DateTime dateTime = format.parse(time);
    return dateTime;
  }

  getData() async {
    // currentLocationPosition = await Utils.getCurrentLocation();
    getTax();
    // Constant.country =
    //     (await placemarkFromCoordinates(currentLocationPosition!.latitude, currentLocationPosition!.longitude))[0].country ?? 'Unknown';
    // sourceLocation = LatLng(currentLocationPosition!.latitude, currentLocationPosition!.longitude);
    listenForLiveUpdates();

    if (Constant.intercityPersonalDocuments.first.isAvailable == false) {
      selectedRideType.value = 2;
    }

    isLoading.value = false;
  }

  void listenForLiveUpdates() {
    FireStoreUtils.getSharingPersonsList((updatedList) {
      totalAddPersonShare.value = updatedList;
      log('===============> log your get total sharing person list ${sharingPersonsList.length}');
    });
  }

  void toggleSelection(PersonModel person) {
    if (addInSharing.any((p) => p.id == person.id)) {
      addInSharing.removeWhere((p) => p.id == person.id);
    } else {
      addInSharing.add(person);
    }
    selectedPersons.value = 1 + addInSharing.length; // Default 1 + selected count
  }

  void deletePerson(String personId) async {
    bool isDeleted = await FireStoreUtils.deleteSharingPerson(personId);
    if (isDeleted) {
      totalAddPersonShare.removeWhere((person) => person.id == personId);
      addInSharing.removeWhere((id) => id.id == personId);
      selectedPersons.value = 1 + addInSharing.length; // Update count
    }
  }

  getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
        taxList.value = value;
      }
    });
  }

  bookInterCity() async {
    ShowToastDialog.showLoader('Please Wait');

    if (sourceLocation == null || destination == null) {
      ShowToastDialog.toast("Please select both pickup and drop locations.".tr);
      return;
    }
    // mapModel.value = await Constant.getDurationDistance(sourceLocation!, destination!);
    // interCityModel.value.dropLocationAddress = mapModel.value!.destinationAddresses!.first;
    // interCityModel.value.pickUpLocationAddress = mapModel.value!.originAddresses!.first;
    interCityModel.value.dropLocationAddress = dropAddress.value;
    interCityModel.value.pickUpLocationAddress = pikUpAddress.value;
    interCityModel.value.customerId = FireStoreUtils.getCurrentUid();
    interCityModel.value.bookingStatus = BookingStatus.bookingPlaced;
    interCityModel.value.id = Constant.getUuid();
    interCityModel.value.createAt = Timestamp.now();
    interCityModel.value.updateAt = Timestamp.now();
    interCityModel.value.bookingTime = Timestamp.now();
    interCityModel.value.type = 'Intercity Ride';
    interCityModel.value.rideStartTime = selectedTime.value;
    interCityModel.value.vehicleType = vehicleTypeModel.value;
    interCityModel.value.vehicleTypeID = vehicleTypeModel.value.id;
    interCityModel.value.pickUpLocation = LocationLatLng(latitude: sourceLocation!.latitude, longitude: sourceLocation!.longitude);
    interCityModel.value.dropLocation = LocationLatLng(latitude: destination!.latitude, longitude: destination!.longitude);
    GeoFirePoint position = GeoFlutterFire().point(latitude: sourceLocation!.latitude, longitude: sourceLocation!.longitude);
    interCityModel.value.sharingPersonList = addInSharing;
    interCityModel.value.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);

    interCityModel.value.distance = DistanceModel(
      distance: distanceCalculate(mapModel.value),
      distanceType: Constant.distanceType,
    );
    // interCityModel.value.subTotal = amountShow(Constant.vehicleTypeList![selectVehicleTypeIndex.value], mapModel.value!);
    interCityModel.value.otp = Constant.getOTPCode();
    interCityModel.value.paymentType = selectedPaymentMethod.value;
    interCityModel.value.paymentStatus = false;
    // selectedPersons.value = 1 + addInSharing.length;
    interCityModel.value.persons = selectedPersons.value.toString();
    interCityModel.value.taxList = taxList;
    interCityModel.value.isPersonalRide = selectedRideType.value == 1 ? true : false;
    interCityModel.value.adminCommission = Constant.adminCommission!;
    interCityModel.value.startDate = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
    interCityModel.value.subTotal = addPriceController.value.text;
    interCityModel.value.setPrice = addPriceController.value.text;
    interCityModel.value.recommendedPrice = double.parse(estimatePrice.value.toString()).toString();
    interCityModel.value = IntercityModel.fromJson(interCityModel.value.toJson());

    await FireStoreUtils.setInterCity(interCityModel.value);
    ShowToastDialog.closeLoader();
    Get.back();
    Get.back();
    Get.back();
  }

  String distanceCalculate(MapModel? value) {
    if (Constant.distanceType == "Km") {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toString();
    } else {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toString();
    }
  }

// String amountShow(VehicleTypeModel vehicleType, MapModel value) {
//   if (Constant.distanceType == "Km") {
//     var distance = (value.rows!.first.elements!.first.distance!.value!.toInt() / 1000);
//     if (distance > double.parse(vehicleType.charges.fareMinimumChargesWithinKm)) {
//       return Constant.amountCalculate(vehicleType.charges.farePerKm.toString(), distance.toString())
//           .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
//     } else {
//       return Constant.amountCalculate(vehicleType.charges.farMinimumCharges.toString(), distance.toString())
//           .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
//     }
//   } else {
//     var distance = (value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34);
//     if (distance > double.parse(vehicleType.charges.fareMinimumChargesWithinKm)) {
//       return Constant.amountCalculate(vehicleType.charges.farePerKm.toString(), distance.toString())
//           .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
//     } else {
//       return Constant.amountCalculate(vehicleType.charges.farMinimumCharges.toString(), distance.toString())
//           .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
//     }
//   }
// }

  addPerson() async {
    ShowToastDialog.showLoader('Please wait'.tr);
    // getSharingPersonsList
    personModel.value.id = Constant.getUuid();
    personModel.value.mobileNumber = enterNumberController.value.text;
    personModel.value.name = enterNameController.value.text;

    log('=-------------> your use id ${FireStoreUtils.getCurrentUid()}');

    await FireStoreUtils.addSharingPerson(personModel.value);
    enterNameController.value.clear();
    enterNumberController.value.clear();
    ShowToastDialog.closeLoader();
  }
}
