// ignore_for_file: unnecessary_overrides

import 'dart:developer';

import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  RxString profilePic =
      "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503"
          .obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  RxList<BannerModel> bannerList = <BannerModel>[].obs;
  PageController pageController = PageController();
  RxInt curPage = 0.obs;
  RxInt drawerIndex = 0.obs;
  RxBool isLoading = false.obs;

  RxInt suggestionView = 3.obs;

  @override
  void onInit() {
    getUserData();
    updateCurrentLocation();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  getUserData() async {
    isLoading.value = true;

    UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    await checkActiveStatus();
    if (userModel != null) {
      profilePic.value = (userModel.profilePic ?? "").isNotEmpty
          ? userModel.profilePic ??
              "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503"
          : "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503";
      name.value = userModel.fullName ?? '';
      phoneNumber.value = (userModel.countryCode ?? '') + (userModel.phoneNumber ?? '');
      userModel.fcmToken = await NotificationService.getToken();
      await FireStoreUtils.updateUser(userModel);
      await FireStoreUtils.getBannerList().then((value) {
        bannerList.value = value ?? [];
      });

      await Utils.getCurrentLocation();
    }
  }

  checkActiveStatus() async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    if (userModel!.isActive == false) {
      Get.defaultDialog(
          titlePadding: const EdgeInsets.only(top: 16),
          title: "Account Disabled",
          middleText: "Your account has been disabled. Please contact the administrator.",
          titleStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          barrierDismissible: false,
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          });
    }
  }

  Location location = Location();

  updateCurrentLocation() async {
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      location.enableBackgroundMode(enable: true);
      location.changeSettings(
          accuracy: LocationAccuracy.high, distanceFilter: double.parse(Constant.driverLocationUpdate.toString()), interval: 2000);
      location.onLocationChanged.listen((locationData) {
        log("------>");
        log(locationData.toString());
        Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
        // FireStoreUtils
        //     .getDriverUserProfile(FireStoreUtils.getCurrentUid())
        //     .then((value) {
        //   // DriverUserModel driverUserModel = value!;
        //   // if (driverUserModel.isOnline == true) {
        //   //   driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
        //   //   GeoFirePoint position = GeoFlutterFire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);
        //
        //   // driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
        //   // driverUserModel.rotation = locationData.heading;
        //   // FireStoreUtils.updateDriverUser(driverUserModel);
        // // }
        //     });
        log("------>1");
      });
    } else {
      location.requestPermission().then((permissionStatus) {
        log("------>3");
        if (permissionStatus == PermissionStatus.granted) {
          location.enableBackgroundMode(enable: true);
          location.changeSettings(
              accuracy: LocationAccuracy.high, distanceFilter: double.parse(Constant.driverLocationUpdate.toString()), interval: 2000);
          location.onLocationChanged.listen((locationData) async {
            Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
            log("------>4");

            // FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
            //   DriverUserModel driverUserModel = value!;
            //   if (driverUserModel.isOnline == true) {
            //     driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
            //     driverUserModel.rotation = locationData.heading;
            //     GeoFirePoint position = GeoFlutterFire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);
            //
            //     driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
            //
            //     FireStoreUtils.updateDriverUser(driverUserModel);
            //   }
            // });
          });
        }
        log("------>5");
      });
      log("------>6");
    }

    if (Constant.isInterCitySharingBid == true && Constant.isParcelBid == true && Constant.isInterCitySharingBid == true) {
      suggestionView.value = 3;
    } else if (Constant.isInterCitySharingBid == false && Constant.isInterCitySharingBid == false) {
      suggestionView.value = 2;
    } else {
      suggestionView.value = 1;
    }
    isLoading.value = false;
    update();
  }

  Future<void> deleteUserAccount() async {
    try {
      await FirebaseFirestore.instance.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).delete();

      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (error) {
      log("Firebase Auth Exception : $error");
    } catch (error) {
      log("Error : $error");
    }
  }
}
