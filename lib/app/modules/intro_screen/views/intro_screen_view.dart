import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/modules/intro_screen/views/widgets/intro_screen_page.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/dependency_packages/circular_percent_indicator.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/intro_screen_controller.dart';

class IntroScreenView extends StatelessWidget {
  const IntroScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IntroScreenController>(
        init: IntroScreenController(),
        builder: (controller) {
          return Obx(
            () => Scaffold(
              backgroundColor: const Color(0xFF101214),
              appBar: AppBar(
                forceMaterialTransparency: true,
                backgroundColor: Colors.transparent,
                leading: Visibility(
                  visible: controller.currentPage.value != 0,
                  child: IconButton(
                      onPressed: () {
                        controller.currentPage.value =
                            controller.currentPage.value - 1;
                        controller.pageController
                            .jumpToPage(controller.currentPage.value);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 15,
                        color: Colors.white70,
                      )),
                ),
                actions: [
                  Visibility(
                    visible: controller.currentPage.value != 2,
                    child: TextButton(
                        onPressed: () {
                          Preferences.setBoolean(
                              Preferences.isFinishOnBoardingKey, true);
                          Get.offAllNamed(Routes.LOGIN);
                        },
                        child: Row(
                          children: [
                            Text(
                              "Skip".tr,
                              style: GoogleFonts.inter(
                                  fontSize: 16.0,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 15,
                              color: AppThemData.primary500,
                            )
                          ],
                        )),
                  ),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        controller.currentPage.value = index;
                      },
                      children: [
                        IntroScreenPage(
                          title: "Move with In Motione".tr,
                          body:
                              "Book mini trucks and vans for home, office, furniture, appliance, and boxed-item moves."
                                  .tr,
                          primaryIcon: Icons.local_shipping_rounded,
                          secondaryIcon: Icons.airport_shuttle_rounded,
                          badge: 'VANS + MINI TRUCKS',
                        ),
                        IntroScreenPage(
                          title: "The right vehicle for every load".tr,
                          body:
                              "Choose a moving vehicle that fits your load, route, and schedule before you confirm."
                                  .tr,
                          primaryIcon: Icons.inventory_2_rounded,
                          secondaryIcon: Icons.straighten_rounded,
                          badge: 'RIGHT SIZE FOR YOUR LOAD',
                        ),
                        IntroScreenPage(
                          title: "Track every move".tr,
                          body:
                              "Follow your driver, keep move details together, and pay securely from pickup to delivery."
                                  .tr,
                          primaryIcon: Icons.route_rounded,
                          secondaryIcon: Icons.location_on_rounded,
                          badge: 'TRACK EVERY MOVE',
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: controller.currentPage.value != 2,
                    child: CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 5.0,
                      percent: controller.currentPage.value == 0
                          ? 0.33
                          : controller.currentPage.value == 1
                              ? 0.66
                              : 1.0,
                      center: InkWell(
                        onTap: () {
                          controller.currentPage.value =
                              controller.currentPage.value + 1;
                          controller.pageController
                              .jumpToPage(controller.currentPage.value);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: AppThemData.primary500,
                              borderRadius: BorderRadius.circular(50)),
                          child: const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                      progressColor: AppThemData.primary500,
                      backgroundColor: const Color(0xFF292D30),
                    ),
                  ),
                  Visibility(
                    visible: controller.currentPage.value == 2,
                    child: RoundShapeButton(
                        size: const Size(200, 45),
                        title: "Get Started".tr,
                        buttonColor: AppThemData.primary500,
                        buttonTextColor: AppThemData.black,
                        onTap: () {
                          Preferences.setBoolean(
                              Preferences.isFinishOnBoardingKey, true);
                          Get.offAllNamed(Routes.LOGIN);
                        }),
                  ),
                  SizedBox(height: Responsive.width(16, context))
                ],
              ),
            ),
          );
        });
  }
}
