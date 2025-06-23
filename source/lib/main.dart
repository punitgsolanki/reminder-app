import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import 'app/core/values/app_values.dart';
import 'app/my_app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Logger
  await _initLogger();

  // Initialized the hive
  await Hive.initFlutter();
  await Hive.openBox(AppValues.dbName);

  await _requestNotificationPermissions();

  runApp(const MyApp());
}

late final Logger mainLogger;

Future<void> _initLogger() async {
  mainLogger = Logger(
    printer: PrettyPrinter(
      methodCount: AppValues.loggerMethodCount,
      // number of method calls to be displayed
      errorMethodCount: AppValues.loggerErrorMethodCount,
      // number of method calls if stacktrace is provided
      lineLength: AppValues.loggerLineLength,
      // width of the output
      colors: true,
      // Colorful log messages
      printEmojis: true,
      // Print an emoji for each log message
      printTime: false, // Should each log print contain a timestamp
    ),
  );
}

Future<void> _requestNotificationPermissions() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Request permissions for iOS
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Request permissions for Android 13+ (API level 33+)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}
