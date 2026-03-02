// ignore_for_file: unnecessary_overrides

import 'dart:io';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  RxString profileImage =
      "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503".obs;
  TextEditingController countryCodeController = TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  RxInt selectedGender = 1.obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void onInit() {
    getUserData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getUserData() async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    if (userModel != null) {
      profileImage.value = (userModel.profilePic ?? "").isNotEmpty
          ? userModel.profilePic ??
              "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503"
          : "https://firebasestorage.googleapis.com/v0/b/go-motion-56f36.firebasestorage.app/o/new_app_-removebg-preview%201.png?alt=media&token=f55b8cd3-ae20-471c-8f39-660e151b4503";
      name.value = userModel.fullName ?? '';
      nameController.text = userModel.fullName ?? '';
      phoneNumber.value = (userModel.countryCode ?? '') + (userModel.phoneNumber ?? '');
      phoneNumberController.text = (userModel.phoneNumber ?? '');
      emailController.text = (userModel.email ?? '');
    }
  }

  saveUserData() async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    userModel!.gender = selectedGender.value == 1 ? "Male" : "Female";
    userModel.fullName = nameController.text;
    userModel.slug = nameController.text.toSlug(delimiter: "-");
    ShowToastDialog.showLoader("Please wait".tr);
    if (profileImage.value.isNotEmpty && Constant().hasValidUrl(profileImage.value) == false) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }
    userModel.profilePic = profileImage.value;
    await FireStoreUtils.updateUser(userModel);
    ShowToastDialog.closeLoader();
    Get.back(result: true);
  }

  Future<void> pickFile({required ImageSource source}) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;

      Get.back();

      // Compress the image using flutter_image_compress
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 50,
      );

      // Save the compressed image to a new file
      File compressedFile = File(image.path);
      await compressedFile.writeAsBytes(compressedBytes!);

      profileImage.value = compressedFile.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }
}
