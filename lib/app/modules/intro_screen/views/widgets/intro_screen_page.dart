import 'package:flutter/material.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreenPage extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const IntroScreenPage({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: AppThemData.primary500.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 92,
              color: AppThemData.primary500,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 22,
                color: AppThemData.black,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14,
                color: AppThemData.black,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
