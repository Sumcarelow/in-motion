import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/modules/pre_booking/controllers/pre_booking_controller.dart';
import '../../app/models/vehicle_type_model.dart';

class PreBookingVehicleTypeBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const PreBookingVehicleTypeBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<PreBookingController>(
      init: PreBookingController(),
      builder: (controller) {
        return Container(
          height: Responsive.height(100, context),
          decoration: BoxDecoration(
            color: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding:
          const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: ShapeDecoration(
                          color: themeChange.isDarkTheme()
                              ? AppThemData.grey700
                              : AppThemData.grey200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Text(
                        'Choose a Vehicle'.tr,
                        style: GoogleFonts.inter(
                          color: themeChange.isDarkTheme()
                              ? AppThemData.white
                              : AppThemData.grey950,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (controller.vehicleTypeList.isEmpty)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator()))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.vehicleTypeList.length,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemBuilder: (context, index) {
                            final VehicleTypeModel vehicle =
                            controller.vehicleTypeList[index];
                            final isSelected = controller
                                .selectedVehicleType.value ==
                                vehicle.id;

                            // 🔹 Calculate estimated fare
                            final distanceText = controller.distanceText.value;
                            double distanceKm = 0;
                            try {
                              distanceKm = double.parse(
                                distanceText
                                    .replaceAll(RegExp('[^0-9\\.]'), ''),
                              );
                            } catch (_) {}

                            final farePerKm =
                                double.tryParse(vehicle.charges.farePerKm) ??
                                    0.0;
                            final minFare = double.tryParse(
                                vehicle.charges.farMinimumCharges) ??
                                0.0;
                            final withinKm = double.tryParse(vehicle
                                .charges.fareMinimumChargesWithinKm) ??
                                0.0;

                            double totalFare = 0.0;
                            if (distanceKm <= withinKm) {
                              totalFare = minFare;
                            } else {
                              totalFare =
                                  minFare + ((distanceKm - withinKm) * farePerKm);
                            }

                            return GestureDetector(
                              onTap: () {
                                controller.selectedVehicleType.value = vehicle.id;
                                controller.selectedVehicleName.value =
                                    vehicle.title;
                                controller.estimatedFare.value = totalFare;
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: themeChange.isDarkTheme()
                                      ? AppThemData.grey900
                                      : AppThemData.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppThemData.primary500
                                        : AppThemData.grey200,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          vehicle.image,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.directions_car),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicle.title,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                themeChange.isDarkTheme()
                                                    ? AppThemData.white
                                                    : AppThemData.grey950,
                                              ),
                                            ),
                                            Text(
                                              "We will arrive in 30 mins",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppThemData.grey500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "R${totalFare.toStringAsFixed(2)}",
                                          style: GoogleFonts.inter(
                                            color: AppThemData.primary500,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.people,
                                                color: Colors.orange, size: 14),
                                            const SizedBox(width: 3),
                                            Text(
                                              vehicle.persons,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.orange),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // 🔹 Bottom bar
              Container(
                width: Responsive.width(100, context),
                decoration: BoxDecoration(
                  color: themeChange.isDarkTheme()
                      ? AppThemData.black
                      : AppThemData.white,
                  border: Border(
                    top: BorderSide(
                      width: 1.0,
                      color: themeChange.isDarkTheme()
                          ? AppThemData.grey800
                          : AppThemData.grey100,
                    ),
                  ),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Fare'.tr,
                          style: GoogleFonts.inter(
                            color: themeChange.isDarkTheme()
                                ? AppThemData.grey25
                                : AppThemData.grey950,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'R${controller.estimatedFare.value.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            color: AppThemData.primary500,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    RoundShapeButton(
                      size: const Size(150, 45),
                      title: "Continue".tr,
                      buttonColor: AppThemData.primary500,
                      buttonTextColor: AppThemData.black,
                      onTap: () {
                        controller.popupIndex.value = 2;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
