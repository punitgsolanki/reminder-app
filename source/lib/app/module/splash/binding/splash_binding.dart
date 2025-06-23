import 'package:get/get.dart';
import 'package:reminder_app/app/module/splash/controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
          () => SplashController(),
      fenix: true,
    );
  }
}