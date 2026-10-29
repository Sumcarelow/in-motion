// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/distance_model.dart';
import 'package:customer/app/models/time_slots_charges_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/map_model.dart';
import 'package:customer/app/models/parcel_model.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/positions.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/vehicle_model_model.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class BookParcelController extends GetxController {
  FocusNode pickUpFocusNode = FocusNode();
  FocusNode dropFocusNode = FocusNode();
  TextEditingController dropLocationController = TextEditingController();
  TextEditingController pickupLocationController = TextEditingController();
  LatLng? sourceLocation;
  LatLng? destination;
  Position? currentLocationPosition;
  Rx<DateTime?> selectedDate = DateTime.now().obs;
  RxBool isLoading = true.obs;

  Rx<PaymentModel> paymentModel = PaymentModel().obs;

  Rx<TextEditingController> addPriceController = TextEditingController().obs;
  Rx<TextEditingController> weightController = TextEditingController().obs;
  Rx<TextEditingController> dimensionController = TextEditingController().obs;

  final ImagePicker imagePicker = ImagePicker();
  Rxn<File> selectedImage = Rxn<File>();

  RxString parcelImage = ''.obs;

  Rx<ParcelModel> parcelModel = ParcelModel().obs;
  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;

  RxString pikUpAddress = ''.obs;
  RxString dropAddress = ''.obs;
  Rx<MapModel?> mapModel = MapModel().obs;

  RxString selectedPaymentMethod = 'Cash'.obs;

  RxString mimeType = 'image/png'.obs;

  Rx<VehicleTypeModel> vehicleTypeModel = VehicleTypeModel(
      timeSlots: [],
      id: "",
      image: "",
      isActive: false,
      title: "",
      persons: "0",
      charges: Charges(
        fareMinimumChargesWithinKm: "0",
        farMinimumCharges: "0",
        farePerKm: "0",
      )).obs;
  RxList<VehicleModelModel> vehicleModelList = <VehicleModelModel>[].obs;
  List<VehicleTypeModel> vehicleTypeList = Constant.vehicleTypeList ?? [];

  RxDouble estimatePrice = 0.0.obs;
  RxBool isEstimatePriceVisible = false.obs;

  Rx<DistanceModel> distanceOfKm = DistanceModel().obs;

  @override
  void onInit() {
    if (vehicleTypeList.isNotEmpty) {
      vehicleTypeModel.value = vehicleTypeList.first;
    }
    getTax();
    super.onInit();
  }

  updateData() async {
    if (destination != null && sourceLocation != null) {
      ShowToastDialog.showLoader("Please wait".tr);
      mapModel.value =
          await Constant.getDurationDistance(sourceLocation!, destination!);

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

        if (double.parse(distanceOfKm.value.distance!) <
            double.parse(intercityModel.fareMinimumChargesWithinKm)) {
          log("Distance is less than the minimum charge threshold");
          estimatePrice.value = double.parse(intercityModel.farMinimumCharges);
          isEstimatePriceVisible.value = true;
          log('================================> 11111111 =>${estimatePrice.value}');
        } else {
          estimatePrice.value = double.parse(
              (double.parse(intercityModel.farePerKm) *
                      double.parse(distanceOfKm.value.distance!))
                  .toStringAsFixed(2));
          addPriceController.value.text =
              double.parse(estimatePrice.value.toString()).toString();
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

  ChargesModel? calculationOfEstimatePrice() {
    log('===============> select time ${selectedTime.value}');
    if (selectedTime.value != 'Select Time' && selectedTime.value.isNotEmpty) {
      log('====> Selected time of ride: ${selectedTime.value}');

      DateTime selectedDateTime = convertToDateTime(selectedTime.value);

      // if(selectedRideType.value == 1 ){
      //   intercitySharingList.value = Constant.intercitySharingDocuments.first.timeSlots;
      // } else{
      //   intercitySharingList.value = Constant.intercityPersonalDocuments.first.timeSlots;
      //
      // }
      if (Constant.parcelDocuments.isEmpty) return null;
      for (var model in Constant.parcelDocuments.first.timeSlots) {
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
    RegExp fullRangeRegEx =
        RegExp(r"(\d+)\s*(AM|PM)?\s*-\s*(\d+)\s*(AM|PM)", caseSensitive: false);
    Match? match = fullRangeRegEx.firstMatch(timeSlot);

    if (match == null) {
      log("❌ Could not extract numeric range from: $timeSlot");
      return false;
    }

    int startHour = int.parse(match.group(1)!);
    String startPeriod = (match.group(2) ?? match.group(4))!.toUpperCase();
    int endHour = int.parse(match.group(3)!);
    String endPeriod = match.group(4)!.toUpperCase();

    if (timeSlot.toLowerCase().contains("morning") &&
        endHour == 12 &&
        startPeriod == "AM") {
      endPeriod = "PM";
    }

    int startMinutes = convertToMinutes(startHour, startPeriod);
    int endMinutes = convertToMinutes(endHour, endPeriod);
    int selectedMinutes = selectedTime.hour * 60 + selectedTime.minute;

    bool inRange;
    if (startMinutes < endMinutes) {
      inRange =
          (selectedMinutes >= startMinutes && selectedMinutes < endMinutes);
    } else {
      inRange =
          (selectedMinutes >= startMinutes || selectedMinutes < endMinutes);
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

  getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
        taxList.value = value;
      }
    });
    isLoading.value = false;
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
        if (double.parse(distanceOfKm.value.distance!) <
            double.parse(intercityModel.fareMinimumChargesWithinKm)) {
          log("Distance is less than the minimum charge threshold");
          estimatePrice.value = double.parse(intercityModel.farMinimumCharges);
          isEstimatePriceVisible.value = true;

          log('================================> 11111111 =>${estimatePrice.value}');
        } else {
          estimatePrice.value = double.parse(
              (double.parse(intercityModel.farePerKm) *
                      double.parse(distanceOfKm.value.distance!))
                  .toStringAsFixed(2));
          addPriceController.value.text = estimatePrice.value.toString();
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

  getData() async {
    currentLocationPosition = await Utils.getCurrentLocation();
    Constant.country = (await placemarkFromCoordinates(
                currentLocationPosition!.latitude,
                currentLocationPosition!.longitude))[0]
            .country ??
        'Unknown';
    sourceLocation = LatLng(
        currentLocationPosition!.latitude, currentLocationPosition!.longitude);

    isLoading.value = false;
  }

  saveParcelData() async {
    log('-------------------> ${selectedImage.value.toString()}');

    ShowToastDialog.showLoader('Please Wait');
    // parcelImage.value = await Constant.uploadUserImageToFireStorage(
    //   File(selectedImage.value.toString()),
    //   "parcelImages/${FireStoreUtils.getCurrentUid()}",
    //   File(selectedImage.value!.path).split('/').last,
    // );
    parcelModel.value.id = Constant.getUuid();

    if (selectedImage.value!.path.isNotEmpty) {
      mimeType.value = 'image/png';
      String docId = parcelModel.value.id.toString();

      String url = await Constant.uploadPic(
        PickedFile(selectedImage.value!.path),
        "parcelImage/${FireStoreUtils.getCurrentUid()}",
        docId,
        mimeType.value,
      );
      parcelModel.value.parcelImage = url;
      log('=================> image url in update  $url');
    }

    log('---=-=-==================> upload imge of parcel data ${parcelImage.value}');

    // if (sourceLocation == null || destination == null) {
    //   ShowToastDialog.toast("Please select both pickup and drop locations.");
    //   return;
    // }
    // mapModel.value = await Constant.getDurationDistance(sourceLocation!, destination!);co

    parcelModel.value.dropLocationAddress = dropAddress.value;
    parcelModel.value.pickUpLocationAddress = pikUpAddress.value;
    parcelModel.value.customerId = FireStoreUtils.getCurrentUid();
    parcelModel.value.bookingStatus = BookingStatus.bookingPlaced;
    parcelModel.value.vehicleType = vehicleTypeModel.value;
    parcelModel.value.vehicleTypeID = vehicleTypeModel.value.id;
    parcelModel.value.createAt = Timestamp.now();
    parcelModel.value.updateAt = Timestamp.now();
    parcelModel.value.bookingTime = Timestamp.now();
    parcelModel.value.rideStartTime = selectedTime.value;
    parcelModel.value.pickUpLocation = LocationLatLng(
        latitude: sourceLocation!.latitude,
        longitude: sourceLocation!.longitude);
    parcelModel.value.dropLocation = LocationLatLng(
        latitude: destination!.latitude, longitude: destination!.longitude);
    GeoFirePoint position = GeoFlutterFire().point(
        latitude: sourceLocation!.latitude,
        longitude: sourceLocation!.longitude);
    parcelModel.value.position =
        Positions(geoPoint: position.geoPoint, geohash: position.hash);
    parcelModel.value.distance = DistanceModel(
      distance: distanceCalculate(mapModel.value),
      distanceType: Constant.distanceType,
    );
    parcelModel.value.otp = Constant.getOTPCode();
    parcelModel.value.paymentType = selectedPaymentMethod.value;
    parcelModel.value.paymentStatus = false;
    parcelModel.value.taxList = taxList;
    parcelModel.value.adminCommission = Constant.adminCommission!;
    parcelModel.value.startDate =
        DateFormat('yyyy-MM-dd').format(selectedDate.value!);
    parcelModel.value.subTotal = addPriceController.value.text;
    parcelModel.value.setPrice = addPriceController.value.text;
    parcelModel.value.weight = weightController.value.text;
    parcelModel.value.dimension = dimensionController.value.text;
    parcelModel.value.recommendedPrice =
        double.parse(estimatePrice.value.toString()).toString();

    parcelModel.value = ParcelModel.fromJson(parcelModel.value.toJson());

    await FireStoreUtils.setParcelBooking(parcelModel.value);
    ShowToastDialog.closeLoader();

    Get.back();
    Get.back();
  }

  // Future<void> pickFile({required ImageSource source}) async {
  //   try {
  //     XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100);
  //     if (image == null) return;
  //     Get.back();
  //
  //     Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
  //       image.path,
  //       quality: 50,
  //     );
  //
  //     File compressedFile = File(image.path);
  //     await compressedFile.writeAsBytes(compressedBytes!);
  //       log('==========> compressedFile $compressedFile');
  //     selectedImage.value = compressedFile;
  //   } on PlatformException catch (e) {
  //     Get.snackbar("Error", "Failed to pick image: $e");
  //   }
  // }

  Future<void> pickFile({required ImageSource source}) async {
    try {
      XFile? image =
          await imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;
      Get.back();

      final tempDir = await getTemporaryDirectory();
      final compressedFilePath = '${tempDir.path}/compressed_${image.name}';

      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 50,
      );

      if (compressedBytes == null) {
        Get.snackbar("Error", "Failed to compress image.");
        return;
      }

      File compressedFile = File(compressedFilePath);
      await compressedFile.writeAsBytes(compressedBytes);

      log('==========> compressedFile ${compressedFile.path}');
      selectedImage.value =
          compressedFile; // Store the File object, not a string
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  String distanceCalculate(MapModel? value) {
    if (Constant.distanceType == "Km") {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() /
              1000)
          .toString();
    } else {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() /
              1609.34)
          .toString();
    }
  }
}
