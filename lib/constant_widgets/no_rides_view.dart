import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/in_motione_background.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class NoRidesView extends StatelessWidget {
  final double? height;
  final DarkThemeProvider themeChange;
  final VoidCallback onTap;

  const NoRidesView({
    super.key,
    required this.themeChange,
    this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? Responsive.height(75, context),
      child: Center(
        child: InMotioneSurface(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppThemData.primary500.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 32,
                  color: AppThemData.primary500,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No Moves Found'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 4, bottom: 24),
                child: Text(
                  'Your move history is empty. Book your first mini truck or van now!'
                      .tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Center(
                child: RoundShapeButton(
                  size: const Size(200, 45),
                  title: "Book a Move".tr,
                  buttonColor: AppThemData.primary500,
                  buttonTextColor: AppThemData.black,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
