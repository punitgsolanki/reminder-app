import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/app/core/extension/empty_padding.dart';
import 'package:reminder_app/app/core/values/app_values.dart';

import '../../../core/base/base_view.dart';
import '../../../core/widget/custom_app_bar.dart';
import '../controller/reminder_list_controller.dart';

class ReminderListView extends BaseView<ReminderListController> {
  ReminderListView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return CustomAppBar(
      appBarTitleText: "Reminder",
      actions: [
        Obx(
          () => IconButton(
            icon: AnimatedRotation(
              turns: controller.isSyncing ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Icon(Icons.sync, color: Colors.white),
            ),
            onPressed:
                controller.isSyncing
                    ? null
                    : () {
                      controller.syncUnsyncedReminders();
                    },
          ),
        ),
      ],
    );
  }

  @override
  Widget body(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(child: _bodyView(context)));
  }

  @override
  Widget? floatingActionButton(BuildContext context) {
    return FloatingActionButton(onPressed: () => controller.showReminderForm(context, itemKey: null), child: const Icon(Icons.add));
  }

  Widget _bodyView(BuildContext context) {
    return controller.reminderItems.isEmpty ? _noDataFoundView() : _reminderListView(context);
  }

  Widget _noDataFoundView() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [16.sizeH, const Center(child: Text('No Data'))]);
  }

  Widget _reminderListView(BuildContext context) {
    return Obx(
      () => ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.reminderItems.length,
        shrinkWrap: true,
        itemBuilder: (_, index) {
          final Map<String, dynamic> currentItem = controller.reminderItems[index];

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 15, left: 15, bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentItem[AppValues.keyTitle],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          InkWell(
                            child: const Icon(Icons.edit, color: Colors.blue),
                            onTap: () => controller.showReminderForm(context, itemKey: currentItem[AppValues.keyId]),
                          ),
                          const SizedBox(width: 10),
                          // Delete button
                          InkWell(
                            child: const Icon(Icons.delete, color: Colors.red),
                            onTap: () => controller.deleteReminderItem(currentItem[AppValues.keyId]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Title: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Expanded(
                        child: Text(currentItem[AppValues.keyTitle], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Description: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Expanded(
                        child: Text(
                          currentItem[AppValues.keyDescription] ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text("Due Date: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Expanded(
                        child: Text(
                          currentItem[AppValues.keyDueDate] ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.deepOrange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Status: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (currentItem[AppValues.keyIsCompleted] ?? false) ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (currentItem[AppValues.keyIsCompleted] ?? false) ? "Completed" : "Pending",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Sync Status: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Icon(
                        (currentItem[AppValues.keyIsSynced] ?? false) ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: (currentItem[AppValues.keyIsSynced] ?? false) ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (currentItem[AppValues.keyIsSynced] ?? false) ? "Synced" : "Not Synced",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: (currentItem[AppValues.keyIsSynced] ?? false) ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
