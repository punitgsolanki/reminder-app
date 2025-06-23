import 'package:flutter/material.dart';
import 'package:reminder_app/app/core/values/app_values.dart';
import 'package:reminder_app/app/module/splash/controller/splash_controller.dart';

import '../../../core/base/base_view.dart';

class SplashView extends BaseView<SplashController> {
  SplashView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return null;
  }

  @override
  Widget body(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF063334), Color(0xFF0a4c4e)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppValues.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFa2cdce),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
