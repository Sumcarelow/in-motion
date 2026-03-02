import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constant_widgets/pre_booking_confirm_bottom_sheet.dart';
import '../../../../constant_widgets/pre_booking_form_bottom_sheet.dart';
import '../../../../constant_widgets/pre_booking_success_bottom_sheet.dart';
import '../../../../constant_widgets/pre_booking_vehicle_type_bottom_sheet.dart';
import '../../select_location/views/widgets/select_vehicle_type_bottom_sheet.dart';
import '../controllers/pre_booking_controller.dart';

class PreBookingView extends StatelessWidget {
  const PreBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: PreBookingController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.white,
            body: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Stack(
              children: [
                SizedBox(
                  height: Responsive.height(80, context),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: controller.pickupLocation ??
                          const LatLng(-26.2041, 28.0473),
                      zoom: 14,
                    ),
                    onMapCreated: (mapCtrl) =>
                    controller.mapController = mapCtrl,
                    markers: Set<Marker>.of(controller.markers.values),
                    polylines:
                    Set<Polyline>.of(controller.polyLines.values),
                    myLocationEnabled: true,
                  ),
                ),

                // 🔹 0 - Form bottom sheet
                if (controller.popupIndex.value == 0)
                  DraggableScrollableSheet(
                    initialChildSize: 0.70,
                    minChildSize: 0.70,
                    snap: true,
                    builder: (_, scroll) =>
                        PreBookingFormBottomSheet(scrollController: scroll),
                  ),

                // 🔹 1 - Vehicle type bottom sheet
                if (controller.popupIndex.value == 1)
                  DraggableScrollableSheet(
                    initialChildSize: 0.50,
                    snapSizes: const [
                      0.31,
                      0.35,
                      0.40,
                      0.45,
                      0.50,
                      0.55,
                      0.60
                    ],
                    minChildSize: 0.31,
                    maxChildSize: 0.60,
                    snap: true,
                    expand: true,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return PreBookingVehicleTypeBottomSheet(
                        scrollController: scrollController,
                      );
                    },
                  ),

                // 🔹 2 - Confirm bottom sheet
                if (controller.popupIndex.value == 2)
                  DraggableScrollableSheet(
                    initialChildSize: 0.45,
                    snap: true,
                    builder: (_, scroll) =>
                        PreBookingConfirmBottomSheet(scrollController: scroll),
                  ),

                // 🔹 3 - Success bottom sheet
                if (controller.popupIndex.value == 3)
                  DraggableScrollableSheet(
                    initialChildSize: 0.35,
                    snap: true,
                    builder: (_, scroll) =>
                        PreBookingSuccessBottomSheet(scrollController: scroll),
                  ),

                // 🔙 Back button
                InkWell(
                  onTap: controller.onBackPressed,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeChange.isDarkTheme()
                          ? AppThemData.black
                          : AppThemData.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin:
                    const EdgeInsets.fromLTRB(20, 55, 20, 30),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back,
                      color: themeChange.isDarkTheme()
                          ? AppThemData.white
                          : AppThemData.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
