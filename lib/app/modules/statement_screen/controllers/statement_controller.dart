import 'dart:developer';

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/intercity_model.dart';
import 'package:customer/app/models/parcel_model.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/language_model.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class StatementController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<LanguageModel> languageList = <LanguageModel>[].obs;
  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;

  RxString selectedSearchType = "Cab".obs;
  RxString selectedSearchTypeForData = "slug".obs;
  List<String> searchType = [
    "Cab",
    "Intercity",
    "Parcel",
  ];
  RxString selectedDateOption = "All".obs;
  List<String> dateOption = ["All", "Last Month", "Last 6 Months", "Last Year", "Custom"];
  RxBool isCustomVisible = false.obs;
  RxBool isHistoryDownload = false.obs;

  DateTime? startDateForPdf;
  DateTime? endDateForPdf;


  RxBool isDatePickerEnableForPdf = true.obs;
  Rx<DateTimeRange> selectedDateRangeForPdf = (DateTimeRange(start: DateTime(DateTime.now().year, DateTime.january, 1), end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 0, 0))).obs;

  List<IntercityModel> interCityDataList = [];
  List<ParcelModel> parcelDataList = [];
  List<BookingModel> bookingDataList = [];

  dataGetForPdf() async {
    ShowToastDialog.showLoader("Please wait".tr);
    if (selectedSearchType.value == 'Cab') {
      bookingDataList = await FireStoreUtils.getDataForPdfCab(selectedDateRangeForPdf.value);
      log('-==========================> booking data list of ride bookingDataList ${bookingDataList.length}');
      await generateAndDownloadPdfMobileCab(bookingDataList, selectedDateRangeForPdf.value);

      ShowToastDialog.closeLoader();
    } else if (selectedSearchType.value == 'InterCity') {
      interCityDataList = await FireStoreUtils.getDataForPdfInterCity(selectedDateRangeForPdf.value);
      log('=============================> select intercity data get interCityDataList ${interCityDataList.length}');
      await generateAndDownloadPdfMobileInterCity(interCityDataList, selectedDateRangeForPdf.value);
      ShowToastDialog.closeLoader();
    } else {
      parcelDataList = await FireStoreUtils.getDataForPdfParcel(selectedDateRangeForPdf.value);
      log('=============================> select intercity data get parcelDataList ${parcelDataList.length}');
      await generateAndDownloadPdfParcel(parcelDataList, selectedDateRangeForPdf.value);
      ShowToastDialog.closeLoader();
    }
    // await generateInterCityAndDownloadPdfWeb(currentPageBookingData , selectedDateRangeForPdf.value );
  }



Future<void> generateAndDownloadPdfMobileInterCity(
    List<IntercityModel> bookingList, DateTimeRange selectedRange) async {
  if (bookingList.isEmpty) {
    debugPrint("❌ No data found for the selected date range.");
    return;
  }

  String formattedStartDate =
  DateFormat('dd-MM-yyyy').format(selectedRange.start);
  String formattedEndDate =
  DateFormat('dd-MM-yyyy').format(selectedRange.end);

  var excel = Excel.createExcel();
  Sheet sheet = excel['CabBooking_History'];
  excel.setDefaultSheet('CabBooking_History');

  sheet.appendRow([
    TextCellValue("ID"),
    TextCellValue("Pickup"),
    TextCellValue("Drop"),
    TextCellValue("Distance"),
    TextCellValue("Status"),
    TextCellValue("Booking Date"),
    TextCellValue("Price"),
    TextCellValue("Drop Time"),
    TextCellValue("Pickup Time"),
    TextCellValue("Payment Type"),
    TextCellValue("Reason For Cancel"),
    TextCellValue("Cab Name"),
  ]);

  String getReadableBookingStatus(String? status) {
    switch (status) {
      case "booking_placed":
        return "Placed";
      case "booking_accepted":
        return "Accepted";
      case "booking_ongoing":
        return "Ongoing";
      case "booking_cancelled":
        return "Cancelled";
      case "booking_completed":
        return "Completed";
      case "booking_rejected":
        return "Rejected";
      default:
        return "-";
    }
  }

  for (var e in bookingList) {
    sheet.appendRow([
      TextCellValue(e.id?.substring(0, 5) ?? '-'),
      TextCellValue(e.pickUpLocationAddress ?? '-'),
      TextCellValue(e.dropLocationAddress ?? '-'),
      TextCellValue(e.distance?.distance?.toString() ?? '-'),
      TextCellValue(getReadableBookingStatus(e.bookingStatus)),
      TextCellValue(e.createAt != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(e.createAt!.toDate())
          : '-'),
      TextCellValue(e.subTotal?.toString() ?? '-'),
      TextCellValue(e.dropTime != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(e.dropTime!.toDate())
          : '-'),
      TextCellValue(e.pickupTime != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(e.pickupTime!.toDate())
          : '-'),
      TextCellValue(e.paymentType ?? '-'),
      TextCellValue(e.cancelledReason?.toString() ?? '-'),
      TextCellValue(e.vehicleType?.title ?? '-'),
    ]);
  }

  // Save file to local storage
  List<int>? fileBytes = excel.encode();
  if (fileBytes != null) {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath =
        '${directory.path}/Cab_Bookings_${formattedStartDate}_to_$formattedEndDate.xlsx';

    final File file = File(filePath);
    await file.writeAsBytes(fileBytes, flush: true);

    debugPrint("✅ Excel file saved at: $filePath");

    // Open the file
    await OpenFile.open(filePath);
  }
}

Future<void> generateAndDownloadPdfMobileCab(List<BookingModel> bookingList, DateTimeRange selectedRange) async {
    if (bookingList.isEmpty) {
      debugPrint("❌ No data found for the selected date range.");
      return;
    }

    String formattedStartDate = DateFormat('dd-MM-yyyy').format(selectedRange.start);
    String formattedEndDate = DateFormat('dd-MM-yyyy').format(selectedRange.end);

    var excel = Excel.createExcel();
    Sheet sheet = excel['CabBooking_History'];
    excel.setDefaultSheet('CabBooking_History');

    sheet.appendRow([
      TextCellValue("ID"),
      TextCellValue("Pickup"),
      TextCellValue("Drop"),
      TextCellValue("Distance"),
      TextCellValue("Status"),
      TextCellValue("Booking Date"),
      TextCellValue("Price"),
      TextCellValue("Drop Time"),
      TextCellValue("Pickup Time"),
      TextCellValue("Payment Type"),
      TextCellValue("Reason For Cancel"),
      TextCellValue("Cab Name"),
    ]);

    String getReadableBookingStatus(String? status) {
      switch (status) {
        case "booking_placed":
          return "Placed";
        case "booking_accepted":
          return "Accepted";
        case "booking_ongoing":
          return "Ongoing";
        case "booking_cancelled":
          return "Cancelled";
        case "booking_completed":
          return "Completed";
        case "booking_rejected":
          return "Rejected";
        default:
          return "-";
      }
    }

    for (var e in bookingList) {
      sheet.appendRow([
        TextCellValue(e.id?.substring(0, 5) ?? '-'),
        TextCellValue(e.pickUpLocationAddress ?? '-'),
        TextCellValue(e.dropLocationAddress ?? '-'),
        TextCellValue(e.distance?.distance?.toString() ?? '-'),
        TextCellValue(getReadableBookingStatus(e.bookingStatus)),
        TextCellValue(e.createAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(e.createAt!.toDate()) : '-'),
        TextCellValue(e.subTotal?.toString() ?? '-'),
        TextCellValue(e.dropTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(e.dropTime!.toDate()) : '-'),
        TextCellValue(e.pickupTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(e.pickupTime!.toDate()) : '-'),
        TextCellValue(e.paymentType ?? '-'),
        TextCellValue(e.cancelledReason?.toString() ?? '-'),
        TextCellValue(e.vehicleType?.title ?? '-'),
      ]);
    }

    // Save file to local storage
    List<int>? fileBytes = excel.encode();
    if (fileBytes != null) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/Cab_Bookings_${formattedStartDate}_to_$formattedEndDate.xlsx';

      final File file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      debugPrint("✅ Excel file saved at: $filePath");

      // Open the file
      await OpenFile.open(filePath);
    }
  }
Future<void> generateAndDownloadPdfParcel(List<ParcelModel> bookingList, DateTimeRange selectedRange) async {
    if (bookingList.isEmpty) {
      debugPrint("❌ No data found for the selected date range.");
      return;
    }

    String formattedStartDate = DateFormat('dd-MM-yyyy').format(selectedRange.start);
    String formattedEndDate = DateFormat('dd-MM-yyyy').format(selectedRange.end);

    var excel = Excel.createExcel();
    Sheet sheet = excel['CabBooking_History'];
    excel.setDefaultSheet('CabBooking_History');

    sheet.appendRow([
      TextCellValue("ID"),
      TextCellValue("Pickup"),
      TextCellValue("Drop"),
      TextCellValue("Distance"),
      TextCellValue("Status"),
      TextCellValue("Booking Date"),
      TextCellValue("Price"),
      TextCellValue("Drop Time"),
      TextCellValue("Pickup Time"),
      TextCellValue("Payment Type"),
      TextCellValue("Reason For Cancel"),
      TextCellValue("Cab Name"),
    ]);

    String getReadableBookingStatus(String? status) {
      switch (status) {
        case "booking_placed":
          return "Placed";
        case "booking_accepted":
          return "Accepted";
        case "booking_ongoing":
          return "Ongoing";
        case "booking_cancelled":
          return "Cancelled";
        case "booking_completed":
          return "Completed";
        case "booking_rejected":
          return "Rejected";
        default:
          return "-";
      }
    }

    for (var e in bookingList) {
      sheet.appendRow([
        TextCellValue(e.id?.substring(0, 5) ?? '-'),
        TextCellValue(e.pickUpLocationAddress ?? '-'),
        TextCellValue(e.dropLocationAddress ?? '-'),
        TextCellValue(e.distance?.distance?.toString() ?? '-'),
        TextCellValue(getReadableBookingStatus(e.bookingStatus)),
        TextCellValue(e.createAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(e.createAt!.toDate()) : '-'),
        TextCellValue(e.subTotal?.toString() ?? '-'),
        TextCellValue(e.dropTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(e.dropTime!.toDate()) : '-'),
        TextCellValue(e.pickupTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(e.pickupTime!.toDate()) : '-'),
        TextCellValue(e.paymentType ?? '-'),
        TextCellValue(e.cancelledReason?.toString() ?? '-'),
        TextCellValue(e.vehicleType?.title ?? '-'),
      ]);
    }

    // Save file to local storage
    List<int>? fileBytes = excel.encode();
    if (fileBytes != null) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/Cab_Bookings_${formattedStartDate}_to_$formattedEndDate.xlsx';

      final File file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      debugPrint("✅ Excel file saved at: $filePath");

      // Open the file
      await OpenFile.open(filePath);
    }
  }

}
