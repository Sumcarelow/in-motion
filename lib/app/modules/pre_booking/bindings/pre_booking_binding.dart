import 'package:get/get.dart';
import '../controllers/pre_booking_controller.dart';

class PreBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreBookingController>(() => PreBookingController());
  }
}
