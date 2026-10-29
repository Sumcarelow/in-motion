import 'dart:developer';

import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/currencies_model.dart';
import 'package:customer/app/models/language_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/moving_experience.dart';
import 'package:customer/extension/hax_color_extension.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();
    getLanguage();
    getInterCityService();
    getVehicleTypeList();
    // getTax();
    super.onInit();
  }

  getCurrentCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      if (value != null) {
        Constant.currencyModel = value;
      } else {
        Constant.currencyModel = CurrencyModel(
            id: "",
            code: "USD",
            decimalDigits: 2,
            active: true,
            name: "US Dollar",
            symbol: "\$",
            symbolAtRight: false);
      }
    });
    await FireStoreUtils().getSettings();
    await FireStoreUtils().getPayment();
    AppThemData.primary500 = HexColor.fromHex(Constant.appColor.toString());
  }

  getVehicleTypeList() async {
    await FireStoreUtils.getVehicleType().then((value) {
      if (value != null) {
        Constant.vehicleTypeList = MovingExperience.movingVehiclesOnly(value);
      }
    });
    update();
  }

  getInterCityService() async {
    await FireStoreUtils.fetchIntercityService();
    List<VehicleTypeModel> allCabs = await FireStoreUtils.fetchAllCabServices();
    Constant.cabTimeSlotList.clear();
    Constant.cabTimeSlotList.addAll(
      MovingExperience.movingVehiclesOnly(allCabs),
    );
    log('===================> moving vehicle services ${Constant.cabTimeSlotList.length}');
    update();
  }

  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");
      if (FirebaseAuth.instance.currentUser != null) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
            .then((value) {
          if (value != null) {
            UserModel userModel = value;
            userModel.fcmToken = token;
            Constant.userModel = value;
            FireStoreUtils.updateUser(userModel);
          }
        });
      }
    });
  }

  getLanguage() async {
    if (Preferences.getString(Preferences.languageCodeKey)
        .toString()
        .isNotEmpty) {
      LanguageModel languageModel = await Constant.getLanguage();
      LocalizationService().changeLocale(languageModel.code.toString());
    } else {
      LanguageModel languageModel = LanguageModel(
        id: "CcrGiUvJbPTXaU31s5l8",
        name: "English",
        code: "en",
      );
      LocalizationService().changeLocale(languageModel.code.toString());
    }
  }
  // getTax() async {
  //   await FireStoreUtils().getTaxList().then((value) {
  //     if (value != null) {
  //       Constant.taxList = value;
  //     }
  //   });
  // }
}
