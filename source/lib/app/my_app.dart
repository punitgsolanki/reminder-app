import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/app/routes/app_pages.dart';
import 'package:toastification/toastification.dart';

import 'binding/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/values/app_values.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the app with activity tracking
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: AppValues.appName,
        initialRoute: AppPages.INITIAL,
        initialBinding: InitialBinding(),
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}