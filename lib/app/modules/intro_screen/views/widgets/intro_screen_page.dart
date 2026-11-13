import 'package:flutter/material.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreenPage extends StatelessWidget {
  final String title;
  final String body;
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final String badge;

  const IntroScreenPage({
    super.key,
    required this.title,
    required this.body,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D20),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  right: -32,
                  top: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppThemData.primary500.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 42,
                  child: Container(height: 2, color: Colors.white12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Icon(primaryIcon, size: 86, color: AppThemData.primary500),
                    const SizedBox(width: 8),
                    Icon(secondaryIcon,
                        size: 58, color: const Color(0xFFD9FF43)),
                  ],
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9FF43).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFD9FF43).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD9FF43),
                        fontSize: 10,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white60,
                height: 1.5,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
