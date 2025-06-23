import 'package:get/get.dart';
import 'package:reminder_app/app/routes/app_pages.dart';

import '../../../core/base/base_controller.dart';

class SplashController extends BaseController {
  @override
  void onInit() {
    super.onInit();

    _moveToNextScreen();
  }

  void _moveToNextScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(Routes.REMINDER_LIST_VIEW);
    });
  }
}
