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
import 'package:customer/constant_widgets/in_motione_background.dart';
import 'package:customer/constant_widgets/no_rides_view.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../pre_booking/views/pre_booking_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: InMotioneBackground.canvas,
            appBar: const _CustomerAppBar(),
            drawer: const DrawerView(),
            body: Obx(() => _bodyForIndex(controller)),
            bottomNavigationBar: Obx(() => _bottomNavigation(controller)),
          );
        });
  }

  Widget _bodyForIndex(HomeController controller) {
    switch (controller.drawerIndex.value) {
      case 1:
        return const CabRideView();
      case 2:
        return const MyWalletView();
      case 3:
        return const SupportScreenView();
      case 4:
        return HtmlViewScreenView(
            title: 'Privacy & Policy'.tr, htmlData: Constant.privacyPolicy);
      case 5:
        return HtmlViewScreenView(
            title: 'Terms & Condition'.tr,
            htmlData: Constant.termsAndConditions);
      case 6:
        return const LanguageView();
      case 7:
        return PreBookingView();
      case 8:
        return ParcelRidesView();
      case 9:
        return const InterCityRidesView();
      case 10:
        return StatementView();
      default:
        return HomeScreenView();
    }
  }

  Widget _bottomNavigation(HomeController controller) {
    const pages = <int>[0, 1, 9, 8];
    final page = controller.drawerIndex.value;
    if (!pages.contains(page)) {
      return const SizedBox.shrink();
    }
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: const Color(0xFF17191B),
        indicatorColor: AppThemData.primary500.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          return GoogleFonts.inter(
            color: states.contains(WidgetState.selected)
                ? AppThemData.primary500
                : Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppThemData.primary500
                : Colors.white54,
            size: 24,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: pages.indexOf(page),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          controller.drawerIndex.value = pages[index];
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping_rounded),
            label: 'Local',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Long-distance',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Small-load',
          ),
        ],
      ),
    );
  }
}

class _CustomerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomerAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF17191B),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF17191B),
        systemNavigationBarColor: InMotioneBackground.canvas,
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            MovingExperience.brandShortName,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: InMotioneBackground.lime,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'VANS  •  MINI TRUCKS  •  BAKKIES',
                style: GoogleFonts.inter(
                  color: InMotioneBackground.lime,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'Notifications'.tr,
          onPressed: () => Get.to(const NotificationView()),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
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
    return InMotioneBackground(
      child: Obx(
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
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _MovingMapHero(
                            onDestinationTap: () =>
                                Get.to(const SelectLocationView()),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 218),
                            child: _MovingRequestSheet(
                              onRouteTap: () => _openWhenAvailable(
                                Constant.vehicleTypeList?.isNotEmpty ?? false,
                                () => Get.to(const SelectLocationView()),
                              ),
                              onLocalTap: () => _openWhenAvailable(
                                Constant.vehicleTypeList?.isNotEmpty ?? false,
                                () => Get.to(const SelectLocationView()),
                              ),
                              onScheduledTap: () => _openWhenAvailable(
                                Constant.vehicleTypeList?.isNotEmpty ?? false,
                                () => Get.to(const PreBookingView()),
                              ),
                              onLongDistanceTap: () => _openWhenAvailable(
                                (Constant.vehicleTypeList?.isNotEmpty ??
                                        false) &&
                                    Constant.intercityPersonalDocuments
                                        .isNotEmpty &&
                                    Constant.intercityPersonalDocuments.first
                                        .isAvailable,
                                () => Get.to(const StartIntercityView()),
                              ),
                              onSmallLoadTap: () => _openWhenAvailable(
                                (Constant.vehicleTypeList?.isNotEmpty ??
                                        false) &&
                                    Constant.parcelDocuments.isNotEmpty &&
                                    Constant.parcelDocuments.first.isAvailable,
                                () => Get.to(const BookParcelView()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your Moves'.tr,
                        style: GoogleFonts.inter(
                          color: Colors.white,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          CabRideDetailsController
                                              detailsController = Get.put(
                                                  CabRideDetailsController());
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
                                                        : bookingModelList[
                                                                index]
                                                            .bookingTime!
                                                            .toDate()
                                                            .dateMonthYear(),
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
                                                            ? AppThemData
                                                                .grey400
                                                            : AppThemData
                                                                .grey500,
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    bottom: 12),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                            style: GoogleFonts
                                                                .inter(
                                                              color: themeChange
                                                                      .isDarkTheme()
                                                                  ? AppThemData
                                                                      .grey25
                                                                  : AppThemData
                                                                      .grey950,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                                    fontSize:
                                                                        14,
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
                                                                    fontSize:
                                                                        16,
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
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          Constant.amountToShow(
                                                              amount: Constant.calculateFinalAmount(
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
                                                        const SizedBox(
                                                            height: 2),
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

class _MovingMapHero extends StatelessWidget {
  const _MovingMapHero({required this.onDestinationTap});

  final VoidCallback onDestinationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF24282B),
            Color(0xFF141719),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _MovingMapPainter()),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 14,
            child: Material(
              color: InMotioneBackground.surfaceRaised,
              borderRadius: BorderRadius.circular(18),
              elevation: 8,
              shadowColor: Colors.black54,
              child: InkWell(
                onTap: onDestinationTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppThemData.primary500.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: AppThemData.primary500,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Where are you moving?'.tr,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Enter pickup and destination'.tr,
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 92,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xE817191B),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: InMotioneBackground.lime,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Moving vehicles nearby'.tr,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 56,
            top: 135,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppThemData.primary500,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Colors.black45, blurRadius: 12),
                ],
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Color(0xFF17191B),
                size: 22,
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 72,
            child: Material(
              color: InMotioneBackground.surfaceRaised,
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                onTap: onDestinationTap,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.my_location_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovingRequestSheet extends StatelessWidget {
  const _MovingRequestSheet({
    required this.onRouteTap,
    required this.onLocalTap,
    required this.onScheduledTap,
    required this.onLongDistanceTap,
    required this.onSmallLoadTap,
  });

  final VoidCallback onRouteTap;
  final VoidCallback onLocalTap;
  final VoidCallback onScheduledTap;
  final VoidCallback onLongDistanceTap;
  final VoidCallback onSmallLoadTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E21),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'Book a moving vehicle'.tr,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Set your route and choose the right vehicle for the load.'.tr,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onRouteTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: InMotioneBackground.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 52,
                    child: Column(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: InMotioneBackground.lime,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.white24,
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppThemData.primary500,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current location'.tr,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Where are you moving to?'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppThemData.primary500,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choose a service'.tr,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'VANS • MINI TRUCKS'.tr,
                style: GoogleFonts.inter(
                  color: InMotioneBackground.lime,
                  fontSize: 9,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _MoveModeOption(
                  title: 'Local'.tr,
                  subtitle: 'Nearby'.tr,
                  icon: Icons.local_shipping_outlined,
                  selected: true,
                  onTap: onLocalTap,
                ),
                _MoveModeOption(
                  title: 'Schedule'.tr,
                  subtitle: 'Book ahead'.tr,
                  icon: Icons.calendar_month_outlined,
                  onTap: onScheduledTap,
                ),
                _MoveModeOption(
                  title: 'Long-distance'.tr,
                  subtitle: 'Between cities'.tr,
                  icon: Icons.route_outlined,
                  onTap: onLongDistanceTap,
                ),
                _MoveModeOption(
                  title: 'Small-load'.tr,
                  subtitle: 'Boxes & items'.tr,
                  icon: Icons.inventory_2_outlined,
                  onTap: onSmallLoadTap,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: onRouteTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppThemData.primary500,
                foregroundColor: const Color(0xFF17191B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.near_me_rounded, size: 19),
              label: Text(
                'Set pickup & destination'.tr,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveModeOption extends StatelessWidget {
  const _MoveModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 132,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: selected
                ? AppThemData.primary500.withValues(alpha: 0.12)
                : InMotioneBackground.surfaceRaised,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? AppThemData.primary500 : Colors.white10,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? AppThemData.primary500 : Colors.white70,
                size: 24,
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovingMapPainter extends CustomPainter {
  const _MovingMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final minorRoad = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final roadEdge = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round;

    final roadCore = Paint()
      ..color = const Color(0xFF202427)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final route = Paint()
      ..color = AppThemData.primary500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final minorOne = Path()
      ..moveTo(-20, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.35,
        size.width * 0.48,
        size.height * 0.54,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.74,
        size.width + 24,
        size.height * 0.46,
      );
    canvas.drawPath(minorOne, minorRoad);

    final minorTwo = Path()
      ..moveTo(size.width * 0.18, size.height + 16)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.62,
        size.width * 0.2,
        -12,
      );
    canvas.drawPath(minorTwo, minorRoad);

    final mainRoad = Path()
      ..moveTo(size.width * 0.7, -18)
      ..quadraticBezierTo(
        size.width * 0.54,
        size.height * 0.4,
        size.width * 0.8,
        size.height + 24,
      );
    canvas.drawPath(mainRoad, roadEdge);
    canvas.drawPath(mainRoad, roadCore);

    final activeRoute = Path()
      ..moveTo(size.width * 0.18, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.55,
        size.width * 0.58,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.68,
        size.width * 0.79,
        size.height * 0.5,
      );
    canvas.drawPath(activeRoute, route);

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.72),
      7,
      Paint()..color = InMotioneBackground.lime,
    );
    canvas.drawCircle(
      Offset(size.width * 0.79, size.height * 0.5),
      8,
      Paint()..color = AppThemData.primary500,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          color: InMotioneBackground.surface,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                height: 1.15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white60,
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
