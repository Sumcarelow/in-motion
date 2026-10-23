// ignore_for_file: unnecessary_overrides

// ignore_for_file: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/chat_model/chat_model.dart';
import 'package:customer/app/models/chat_model/inbox_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/utils/fire_store_utils.dart';

class ChatScreenController extends GetxController {
  Rx<UserModel> senderUserModel = UserModel().obs;
  Rx<DriverUserModel> receiverUserModel = DriverUserModel().obs;
  final messageTextEditorController = TextEditingController().obs;
  RxString message = "".obs;
  RxBool isLoading = true.obs;
  String bookingId = '';
  String rideCollection = '';

  @override
  void onInit() {
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

  getData(String receiverId, String bookingId, String rideCollection) async {
    this.bookingId = bookingId;
    this.rideCollection = rideCollection;
    await FireStoreUtils.getDriverUserProfile(receiverId).then((value) {
      receiverUserModel.value = value!;
    });
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      senderUserModel.value = value!;
    });
    isLoading.value = false;
  }

  sendMessage() async {
    InboxModel inboxModel = InboxModel(
        archive: false,
        lastMessage: messageTextEditorController.value.text.trim(),
        mediaUrl: "",
        receiverId: receiverUserModel.value.id.toString(),
        seen: false,
        senderId: senderUserModel.value.id.toString(),
        timestamp: Timestamp.now(),
        type: "text");

    final Map<String, dynamic> inboxData = inboxModel.toJson()
      ..addAll(<String, dynamic>{
        'bookingId': bookingId,
        'rideCollection': rideCollection,
      });

    await FireStoreUtils.fireStore
        .collection(CollectionName.chat)
        .doc(senderUserModel.value.id.toString())
        .collection("inbox")
        .doc(receiverUserModel.value.id.toString())
        .set(inboxData);

    await FireStoreUtils.fireStore
        .collection(CollectionName.chat)
        .doc(receiverUserModel.value.id.toString())
        .collection("inbox")
        .doc(senderUserModel.value.id.toString())
        .set(inboxData);

    ChatModel chatModel = ChatModel(
        type: "text",
        timestamp: Timestamp.now(),
        senderId: senderUserModel.value.id.toString(),
        seen: false,
        receiverId: receiverUserModel.value.id.toString(),
        mediaUrl: "",
        chatID: Constant.getUuid(),
        message: messageTextEditorController.value.text.trim());

    final Map<String, dynamic> chatData = chatModel.toJson()
      ..addAll(<String, dynamic>{
        'bookingId': bookingId,
        'rideCollection': rideCollection,
      });

    message.value = messageTextEditorController.value.text;
    messageTextEditorController.value.clear();

    await FireStoreUtils.fireStore
        .collection(CollectionName.chat)
        .doc(senderUserModel.value.id.toString())
        .collection(receiverUserModel.value.id.toString())
        .doc(chatModel.chatID)
        .set(chatData);
    await FireStoreUtils.fireStore
        .collection(CollectionName.chat)
        .doc(receiverUserModel.value.id.toString())
        .collection(senderUserModel.value.id.toString())
        .doc(chatModel.chatID)
        .set(chatData);

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "chat",
      "senderId": senderUserModel.value.id.toString(),
      "receiverId": receiverUserModel.value.id.toString(),
      "bookingId": bookingId,
    };

    await SendNotification.sendOneNotification(
      type: "chat",
      token: receiverUserModel.value.fcmToken.toString(),
      title: senderUserModel.value.fullName.toString(),
      body: message.value,
      bookingId: bookingId,
      driverId: receiverUserModel.value.id.toString(),
      customerId: senderUserModel.value.id.toString(),
      senderId: senderUserModel.value.id.toString(),
      payload: playLoad,
    );

    message.value = "";
  }
}
