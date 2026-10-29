import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/theme/app_them_data.dart';

import '../app/modules/pre_booking/controllers/pre_booking_controller.dart';

class PreBookingConfirmBottomSheet extends GetView<PreBookingController> {
  final ScrollController scrollController;
  const PreBookingConfirmBottomSheet(
      {super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemData.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: AppThemData.primary500.withValues(alpha: .15),
            offset: const Offset(0, -2),
            blurRadius: 8,
          )
        ],
      ),
      child: Obx(() => ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppThemData.primary500.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Confirm Scheduled Move",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppThemData.primary500,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _infoTile("From: ", controller.pickupController.text),
              _infoTile("To: ", controller.dropoffController.text),
              _infoTile("Distance: ", controller.distanceText.value),
              _infoTile("Duration: ", controller.durationText.value),
              _infoTile("Vehicle: ", controller.selectedVehicleName.value),
              _infoTile(
                "Scheduled for: ",
                controller.selectedPickupDateTime.value?.toLocal().toString() ??
                    '',
              ),
              /*_infoTile("Estimated Fare",
              "R${controller.estimatedFare.value.toStringAsFixed(2)}")*/
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text("Confirm Scheduled Move",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: controller.savePreBooking,
              ),
            ],
          )),
    );
  }

  Widget _infoTile(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Expanded(
              child: Text(value,
                  maxLines: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppThemData.primary500,
                      fontSize: 15)),
            ),
          ],
        ),
      );
}
