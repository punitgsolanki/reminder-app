
import 'package:get/get.dart';
import 'package:reminder_app/app/module/reminder_list/binding/reminder_list_binding.dart';
import 'package:reminder_app/app/module/reminder_list/view/reminder_list_view.dart';
import 'package:reminder_app/app/module/splash/binding/splash_binding.dart';
import 'package:reminder_app/app/module/splash/view/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_VIEW;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH_VIEW,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.REMINDER_LIST_VIEW,
      page: () => ReminderListView(),
      binding: ReminderListBinding(),
    ),
  ];
}
