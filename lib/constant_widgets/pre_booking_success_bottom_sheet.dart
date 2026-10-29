import 'package:flutter/material.dart';
import 'package:customer/theme/app_them_data.dart';

class PreBookingSuccessBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  const PreBookingSuccessBottomSheet(
      {super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemData.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: AppThemData.primary500.withValues(alpha: .15),
            offset: const Offset(0, -2),
            blurRadius: 8,
          )
        ],
      ),
      child: ListView(
        controller: scrollController,
        children: [
          const SizedBox(height: 20),
          Icon(Icons.check_circle, size: 90, color: AppThemData.primary500),
          const SizedBox(height: 20),
          Text("Move Scheduled!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppThemData.primary500, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "A moving vehicle and driver will be assigned closer to your loading time.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemData.primary500,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Done",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
