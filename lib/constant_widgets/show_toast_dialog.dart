import 'dart:ui';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowToastDialog {
  static showToast(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    EasyLoading.showToast(message!, toastPosition: position);
  }

  static showLoader(String message) {
    EasyLoading.show(status: message);
  }

  static closeLoader() {
    EasyLoading.dismiss();
  }
  static void toast(
      String? value, {
        ToastGravity? gravity,
        length = Toast.LENGTH_SHORT,
        Color? bgColor,
        Color? textColor,
        bool log = false,
      }) {
    if (value!.isEmpty) {
    } else {
      Fluttertoast.showToast(
        msg: value,
        gravity: gravity,
        toastLength: length,
        backgroundColor: bgColor,
        textColor: textColor,
      );
    }
  }
}
