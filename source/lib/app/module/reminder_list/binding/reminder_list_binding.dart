import 'package:get/get.dart';
import 'package:reminder_app/app/module/reminder_list/controller/reminder_list_controller.dart';

class ReminderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReminderListController>(
          () => ReminderListController(),
      fenix: true,
    );
  }
}