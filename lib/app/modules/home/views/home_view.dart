// ignore_for_file: must_be_immutable, deprecated_member_use
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/modules/book_parcel/views/book_parcel_view.dart';
import 'package:customer/app/modules/cab_ride_details/controllers/cab_ride_details_controller.dart';
import 'package:customer/app/modules/cab_ride_details/views/cab_ride_details_view.dart';
import 'package:customer/app/modules/cab_rides/views/cab_ride_view.dart';
import 'package:customer/app/modules/home/views/widgets/drawer_view.dart';
import 'package:customer/app/modules/html_view_screen/views/html_view_screen_view.dart';
import 'package:customer/app/modules/intercity_rides/views/intercity_rides_view.dart';
import 'package:customer/app/modules/language/views/language_view.dart';
import 'package:customer/app/modules/my_wallet/views/my_wallet_view.dart';
import 'package:customer/app/modules/notification/views/notification_view.dart';
import 'package:customer/app/modules/parcel_rides/views/parcel_rides_view.dart';
import 'package:customer/app/modules/select_location/views/select_location_view.dart';
import 'package:customer/app/modules/start_intercity/views/start_intercity_view.dart';
import 'package:customer/app/modules/statement_screen/views/statement_view.dart';
import 'package:customer/app/modules/support_screen/views/support_screen_view.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/moving_experience.dart';
import 'package:customer/constant_widgets/no_rides_view.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../pre_booking/views/pre_booking_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return SafeArea(
            child: Scaffold(
                backgroundColor: themeChange.isDarkTheme()
                    ? Color(0xff1D1D21)
                    : AppThemData.grey50,
                appBar: AppBar(
                  backgroundColor: themeChange.isDarkTheme()
                      ? AppThemData.black
                      : AppThemData.white,
                  shape: Border(
                      bottom: BorderSide(
                          color: themeChange.isDarkTheme()
                              ? AppThemData.grey800
                              : AppThemData.grey100,
                          width: 1)),
                  title: Text(
                    MovingExperience.brandName,
                    style: GoogleFonts.inter(
                      color: themeChange.isDarkTheme()
                          ? AppThemData.white
                          : AppThemData.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                        onPressed: () {
                          Get.to(const NotificationView());
                        },
                        icon: const Icon(Icons.notifications_none_rounded))
                  ],
                ),
                drawer: const DrawerView(),
                body: Obx(() => controller.drawerIndex.value == 1
                    ? const CabRideView()
                    : controller.drawerIndex.value == 2
                        ? const MyWalletView()
                        : controller.drawerIndex.value == 3
                            ? const SupportScreenView()
                            : controller.drawerIndex.value == 4
                                ? HtmlViewScreenView(
                                    title: "Privacy & Policy".tr,
                                    htmlData: Constant.privacyPolicy)
                                : controller.drawerIndex.value == 5
                                    ? HtmlViewScreenView(
                                        title: "Terms & Condition".tr,
                                        htmlData: Constant.termsAndConditions)
                                    : controller.drawerIndex.value == 6
                                        ? const LanguageView()
                                        : controller.drawerIndex.value == 0
                                            ? HomeScreenView()
                                            : controller.drawerIndex.value == 7
                                                ? PreBookingView()
                                                : controller.drawerIndex
                                                            .value ==
                                                        8
                                                    ? ParcelRidesView()
                                                    : controller.drawerIndex
                                                                .value ==
                                                            9
                                                        ? const InterCityRidesView()
                                                        : StatementView())),
          );
        });
  }
}

class HomeScreenView extends StatelessWidget {
  HomeScreenView({
    super.key,
  });

  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Obx(
      () => controller.isLoading.value
          ? Constant.loader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(const SelectLocationView());
                      },
                      child: Container(
                        width: Responsive.width(100, context),
                        height: 56,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: themeChange.isDarkTheme()
                              ? AppThemData.black
                              : AppThemData.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: themeChange.isDarkTheme()
                                    ? AppThemData.grey900
                                    : AppThemData.grey50),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: themeChange.isDarkTheme()
                                  ? AppThemData.grey400
                                  : AppThemData.grey500,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Where are you moving to?'.tr,
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme()
                                      ? AppThemData.grey400
                                      : AppThemData.grey500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'What are you moving?'.tr,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme()
                            ? AppThemData.grey25
                            : AppThemData.grey950,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose the move that best fits your load and distance.'
                          .tr,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme()
                            ? AppThemData.grey400
                            : AppThemData.grey600,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        MovingServiceCard(
                          themeChange: themeChange,
                          title: MovingExperience.localMove.tr,
                          description: 'Mini trucks and vans nearby'.tr,
                          icon: Icons.local_shipping_outlined,
                          onClick: () => _openWhenAvailable(
                            Constant.vehicleTypeList?.isNotEmpty ?? false,
                            () => Get.to(const SelectLocationView()),
                          ),
                        ),
                        MovingServiceCard(
                          themeChange: themeChange,
                          title: MovingExperience.scheduledMove.tr,
                          description: 'Reserve a vehicle for later'.tr,
                          icon: Icons.calendar_month_outlined,
                          onClick: () => _openWhenAvailable(
                            Constant.vehicleTypeList?.isNotEmpty ?? false,
                            () => Get.to(const PreBookingView()),
                          ),
                        ),
                        MovingServiceCard(
                          themeChange: themeChange,
                          title: MovingExperience.longDistanceMove.tr,
                          description: 'Dedicated moves between cities'.tr,
                          icon: Icons.route_outlined,
                          onClick: () => _openWhenAvailable(
                            (Constant.vehicleTypeList?.isNotEmpty ?? false) &&
                                Constant
                                    .intercityPersonalDocuments.isNotEmpty &&
                                Constant.intercityPersonalDocuments.first
                                    .isAvailable,
                            () => Get.to(const StartIntercityView()),
                          ),
                        ),
                        MovingServiceCard(
                          themeChange: themeChange,
                          title: MovingExperience.smallLoadMove.tr,
                          description: 'Furniture, appliances and boxes'.tr,
                          icon: Icons.inventory_2_outlined,
                          onClick: () => _openWhenAvailable(
                            (Constant.vehicleTypeList?.isNotEmpty ?? false) &&
                                Constant.parcelDocuments.isNotEmpty &&
                                Constant.parcelDocuments.first.isAvailable,
                            () => Get.to(const BookParcelView()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Moves'.tr,
                      style: GoogleFonts.inter(
                        color: themeChange.isDarkTheme()
                            ? AppThemData.grey25
                            : AppThemData.grey950,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<BookingModel>>(
                        stream: FireStoreUtils().getHomeOngoingBookings(),
                        builder: (context, snapshot) {
                          log("State : ${snapshot.connectionState}");
                          log("State : ${snapshot.data}");
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Constant.loader();
                          }
                          if (!snapshot.hasData ||
                              (snapshot.data?.isEmpty ?? true)) {
                            return NoRidesView(
                              themeChange: themeChange,
                              height: Responsive.height(40, context),
                              onTap: () {
                                Get.to(const SelectLocationView());
                              },
                            );
                          } else {
                            List<BookingModel> bookingModelList =
                                snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: bookingModelList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        CabRideDetailsController
                                            detailsController =
                                            Get.put(CabRideDetailsController());
                                        detailsController.bookingId.value =
                                            bookingModelList[index].id ?? '';
                                        detailsController.bookingModel.value =
                                            bookingModelList[index];
                                        Get.to(const CabRideDetailsView());
                                      },
                                      child: Container(
                                        width: Responsive.width(100, context),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: themeChange.isDarkTheme()
                                              ? AppThemData.black
                                              : AppThemData.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        // ShapeDecoration(
                                        //   shape: RoundedRectangleBorder(
                                        //     side: BorderSide(width: 1, color: themeChange.isDarkTheme() ? AppThemData.grey800 : AppThemData.grey100),
                                        //     borderRadius: BorderRadius.circular(12),
                                        //   ),
                                        // ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  bookingModelList[index]
                                                              .bookingTime ==
                                                          null
                                                      ? ""
                                                      : bookingModelList[index]
                                                          .bookingTime!
                                                          .toDate()
                                                          .dateMonthYear(),
                                                  style: GoogleFonts.inter(
                                                    color: themeChange
                                                            .isDarkTheme()
                                                        ? AppThemData.grey400
                                                        : AppThemData.grey500,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  height: 15,
                                                  decoration: ShapeDecoration(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        strokeAlign: BorderSide
                                                            .strokeAlignCenter,
                                                        color: themeChange
                                                                .isDarkTheme()
                                                            ? AppThemData
                                                                .grey800
                                                            : AppThemData
                                                                .grey100,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    bookingModelList[index]
                                                                .bookingTime ==
                                                            null
                                                        ? ""
                                                        : bookingModelList[
                                                                index]
                                                            .bookingTime!
                                                            .toDate()
                                                            .time(),
                                                    style: GoogleFonts.inter(
                                                      color: themeChange
                                                              .isDarkTheme()
                                                          ? AppThemData.grey400
                                                          : AppThemData.grey500,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  BookingStatus
                                                      .getBookingStatusTitle(
                                                          bookingModelList[
                                                                      index]
                                                                  .bookingStatus ??
                                                              ''),
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.inter(
                                                    color: BookingStatus
                                                        .getBookingStatusTitleColor(
                                                            bookingModelList[
                                                                        index]
                                                                    .bookingStatus ??
                                                                ''),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl: bookingModelList[
                                                                    index]
                                                                .vehicleType ==
                                                            null
                                                        ? Constant
                                                            .profileConstant
                                                        : bookingModelList[
                                                                index]
                                                            .vehicleType!
                                                            .image,
                                                    height: 50,
                                                    width: 50,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          bookingModelList[
                                                                          index]
                                                                      .vehicleType ==
                                                                  null
                                                              ? ""
                                                              : bookingModelList[
                                                                      index]
                                                                  .vehicleType!
                                                                  .title,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: themeChange
                                                                    .isDarkTheme()
                                                                ? AppThemData
                                                                    .grey25
                                                                : AppThemData
                                                                    .grey950,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        if (bookingModelList[
                                                                    index]
                                                                .bookingStatus ==
                                                            BookingStatus
                                                                .bookingAccepted)
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'OTP : '.tr,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: themeChange.isDarkTheme()
                                                                      ? AppThemData
                                                                          .grey25
                                                                      : AppThemData
                                                                          .grey950,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                              Text(
                                                                bookingModelList[
                                                                            index]
                                                                        .otp ??
                                                                    '',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: AppThemData
                                                                      .primary500,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        Constant.amountToShow(
                                                            amount: Constant
                                                                    .calculateFinalAmount(
                                                                        bookingModelList[
                                                                            index])
                                                                .toStringAsFixed(
                                                                    2)),
                                                        textAlign:
                                                            TextAlign.right,
                                                        style:
                                                            GoogleFonts.inter(
                                                          color: themeChange
                                                                  .isDarkTheme()
                                                              ? AppThemData
                                                                  .grey25
                                                              : AppThemData
                                                                  .grey950,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Moving vehicle'.tr,
                                                        style:
                                                            GoogleFonts.inter(
                                                          color: themeChange
                                                                  .isDarkTheme()
                                                              ? AppThemData
                                                                  .grey400
                                                              : AppThemData
                                                                  .grey500,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                );
                              },
                            );
                          }
                        }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
    );
  }

  void _openWhenAvailable(bool isAvailable, VoidCallback openFlow) {
    if (isAvailable) {
      openFlow();
      return;
    }
    ShowToastDialog.showToast(
      'This moving service is not available right now.'.tr,
    );
  }
}

class MovingServiceCard extends StatelessWidget {
  const MovingServiceCard({
    super.key,
    required this.themeChange,
    required this.title,
    required this.description,
    required this.icon,
    required this.onClick,
  });

  final DarkThemeProvider themeChange;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
          border: Border.all(
            color: themeChange.isDarkTheme()
                ? AppThemData.grey800
                : AppThemData.grey100,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppThemData.primary500.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppThemData.primary500, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme()
                    ? AppThemData.white
                    : AppThemData.grey950,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme()
                    ? AppThemData.grey400
                    : AppThemData.grey600,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionWidget extends StatelessWidget {
  const SuggestionWidget({
    super.key,
    required this.themeChange,
    required this.title,
    required this.gifPath,
    required this.onClick,
  });

  final DarkThemeProvider themeChange;
  final String title;
  final String gifPath;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: (Responsive.width(100, context) - 52) / 3,
        // width: 100,
        height: ((Responsive.width(100, context) - 21) / 3) - 4,
        // margin: EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color:
              themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1,
                color: themeChange.isDarkTheme()
                    ? AppThemData.grey900
                    : AppThemData.grey50),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(gifPath),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme()
                    ? AppThemData.grey25
                    : AppThemData.grey950,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerView extends StatelessWidget {
  BannerView({
    super.key,
  });

  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Responsive.height(22, context),
            child: PageView.builder(
              itemCount: controller.bannerList.length,
              controller: controller.pageController,
              onPageChanged: (value) {
                controller.curPage.value = value;
              },
              itemBuilder: (context, index) {
                return Container(
                  width: Responsive.width(100, context),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            controller.bannerList[index].image ?? ""),
                        fit: BoxFit.cover),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Container(
                    width: Responsive.width(100, context),
                    padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
                    decoration: ShapeDecoration(
                      color: AppThemData.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.bannerList[index].bannerName ?? '',
                          style: GoogleFonts.inter(
                            color: AppThemData.grey50,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: Responsive.width(100, context),
                          margin: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Text(
                            controller.bannerList[index].bannerDescription ??
                                '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppThemData.grey50,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: controller.bannerList[index].isOfferBanner ??
                              false,
                          child: Text(
                            controller.bannerList[index].offerText ?? '',
                            style: GoogleFonts.inter(
                              color: AppThemData.primary500,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: SizedBox(
              height: 8,
              child: ListView.builder(
                itemCount: controller.bannerList.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Obx(
                    () => Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == controller.curPage.value
                            ? AppThemData.primary500
                            : AppThemData.grey200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
