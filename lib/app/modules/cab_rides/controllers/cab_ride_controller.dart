// ignore_for_file: unnecessary_overrides

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class CabRideController extends GetxController {
  var selectedType = 0.obs;

  @override
  void onInit() {
    getData(isOngoingDataFetch: true, isCompletedDataFetch: true, isRejectedDataFetch: true);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  RxBool isLoading = true.obs;
  RxList<BookingModel> ongoingRides = <BookingModel>[].obs;
  RxList<BookingModel> completedRides = <BookingModel>[].obs;
  RxList<BookingModel> rejectedRides = <BookingModel>[].obs;

  getData({required bool isOngoingDataFetch, required bool isCompletedDataFetch, required bool isRejectedDataFetch}) async {
    // if (isOngoingDataFetch) ongoingRides.value = (await FireStoreUtils.getOngoingRides()) ?? [];
    if (isOngoingDataFetch) {
      FireStoreUtils.getOngoingRides((List<BookingModel> updatedList) {
        ongoingRides.value = updatedList;
      });
    }
    // if (isCompletedDataFetch) completedRides.value = (await FireStoreUtils.getCompletedRides()) ?? [];
    if (isCompletedDataFetch) {
      FireStoreUtils.getCompletedRides((List<BookingModel> completeList) {
        completedRides.value = completeList;
      });
    }

    // if (isRejectedDataFetch) rejectedRides.value = (await FireStoreUtils.getRejectedRides()) ?? [];
    if (isRejectedDataFetch) {
      FireStoreUtils.getRejectedRides((List<BookingModel> rejectList) {
        rejectedRides.value = rejectList;
      });
    }
    isLoading.value = false;
  }

  getVehicleDetails({required String vehicleID}) async {

  }
}
