import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/constant/constant.dart';

import '../app/modules/pre_booking/controllers/pre_booking_controller.dart';

class PreBookingFormBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  const PreBookingFormBottomSheet({super.key, required this.scrollController});

  @override
  State<PreBookingFormBottomSheet> createState() =>
      _PreBookingFormBottomSheetState();
}

class _PreBookingFormBottomSheetState extends State<PreBookingFormBottomSheet> {
  final controller = Get.find<PreBookingController>();
  final Dio _dio = Dio();

  final List<Map<String, dynamic>> _pickupPredictions = [];
  final List<Map<String, dynamic>> _dropoffPredictions = [];

  DateTime? selectedDateTime;

  Future<void> _getSuggestions(String input, bool isPickup) async {
    if (input.isEmpty) {
      setState(() {
        if (isPickup)
          _pickupPredictions.clear();
        else
          _dropoffPredictions.clear();
      });
      return;
    }

    final apiKey = Constant.mapAPIKey;
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&components=country:za&key=$apiKey';

    final res = await _dio.get(url);
    if (res.data['status'] == 'OK') {
      final predictions =
          List<Map<String, dynamic>>.from(res.data['predictions']);
      setState(() {
        if (isPickup) {
          _pickupPredictions
            ..clear()
            ..addAll(predictions);
        } else {
          _dropoffPredictions
            ..clear()
            ..addAll(predictions);
        }
      });
    }
  }

  Future<void> _selectPlace(
      String placeId, String description, bool isPickup) async {
    final apiKey = Constant.mapAPIKey;
    final detailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final res = await _dio.get(detailsUrl);
    if (res.data['status'] == 'OK') {
      final location = res.data['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      controller.setLocation(
          isPickup: isPickup, pos: latLng, address: description);

      setState(() {
        _pickupPredictions.clear();
        _dropoffPredictions.clear();
      });

      // ✅ Automatically draw route and navigate placeholder when both filled
      if (controller.pickupController.text.isNotEmpty &&
          controller.dropoffController.text.isNotEmpty) {
        controller.calculateRoute();

        // TODO: Navigate to Trip Summary / Confirmation screen
        // Get.to(() => TripSummaryView());
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppThemData.primary500),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppThemData.primary500),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(pickedDate.year, pickedDate.month,
          pickedDate.day, pickedTime.hour, pickedTime.minute);
      controller.selectedPickupDateTime.value = selectedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemData.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: AppThemData.primary500.withValues(alpha: .15),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: widget.scrollController,
        children: [
          Center(
            child: Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: AppThemData.primary500.withValues(alpha: .3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Schedule a Move",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: AppThemData.primary500, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // 🔹 Pickup
          TextField(
            controller: controller.pickupController,
            onChanged: (val) => _getSuggestions(val, true),
            decoration: InputDecoration(
              labelText: 'Moving from',
              prefixIcon:
                  Icon(Icons.my_location, color: AppThemData.primary500),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppThemData.primary500, width: 1)),
            ),
          ),
          if (_pickupPredictions.isNotEmpty)
            ..._pickupPredictions
                .map((p) => ListTile(
                      leading: Icon(Icons.location_on,
                          color: AppThemData.primary500),
                      title: Text(p['description']),
                      onTap: () =>
                          _selectPlace(p['place_id'], p['description'], true),
                    ))
                .toList(),

          const SizedBox(height: 12),

          // 🔹 Drop-off
          TextField(
            controller: controller.dropoffController,
            onChanged: (val) => _getSuggestions(val, false),
            decoration: InputDecoration(
              labelText: 'Moving to',
              prefixIcon: Icon(Icons.flag, color: AppThemData.primary500),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppThemData.primary500, width: 1)),
            ),
          ),
          if (_dropoffPredictions.isNotEmpty)
            ..._dropoffPredictions
                .map((p) => ListTile(
                      leading: Icon(Icons.place, color: AppThemData.primary500),
                      title: Text(p['description']),
                      onTap: () =>
                          _selectPlace(p['place_id'], p['description'], false),
                    ))
                .toList(),

          const SizedBox(height: 16),

          // 🔹 Pickup Date & Time
          InkWell(
            onTap: () => _selectDateTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppThemData.primary500),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppThemData.primary500),
                  const SizedBox(width: 12),
                  Text(
                    selectedDateTime == null
                        ? "Select moving date & time"
                        : "${selectedDateTime!.toLocal()}".split('.')[0],
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedDateTime == null
                          ? Colors.black54
                          : AppThemData.primary500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ⚠️ Removed “Calculate Route” button — handled automatically
        ],
      ),
    );
  }
}
