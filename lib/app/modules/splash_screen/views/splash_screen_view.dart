import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:customer/theme/app_them_data.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashScreenController>(
        init: SplashScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppThemData.black,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemData.black,
                    AppThemData.primary500.withValues(alpha: 0.22),
                    AppThemData.black,
                  ],
                ),
              ),
              child: Center(
                child: SvgPicture.asset("assets/icon/InMotionLogo.svg"),
              ),
            ),
          );
        });
  }
}
