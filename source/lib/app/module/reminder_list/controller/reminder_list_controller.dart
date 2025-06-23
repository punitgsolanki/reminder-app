import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/app/core/extension/empty_padding.dart';
import 'package:reminder_app/app/core/theme/app_colors.dart';
import 'package:reminder_app/app/core/utils/utility.dart';
import 'package:reminder_app/app/core/values/app_values.dart';

import '../../../core/base/base_controller.dart';

class ReminderListController extends BaseController {
  final RxList<Map<String, dynamic>> _reminderItems = RxList.empty();

  List<Map<String, dynamic>> get reminderItems => _reminderItems.toList();

  final _databaseBox = Hive.box(AppValues.dbName);

  // TextFields' controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  DateTime? _selectedDateTime;

  final RxBool _isSyncing = false.obs;

  bool get isSyncing => _isSyncing.value;

  Timer? _notificationTimer;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();

    _initializeNotifications();
    _refreshReminderItems();
    _startNotificationTimer();

    Future.delayed(const Duration(seconds: 1), () {
      syncUnsyncedReminders();
    });

    Future.delayed(const Duration(seconds: 2), () {
      _markPastRemindersAsCompleted();
    });
  }

  @override
  void onClose() {
    _notificationTimer?.cancel();
    super.onClose();
  }

  void _setReminderItems(List<Map<String, dynamic>> value) {
    _reminderItems.clear();

    printLog("SIZE: ${value.length}");
    _reminderItems.value = value.reversed.toList();
  }

  Future<void> _markPastRemindersAsCompleted() async {
    final now = DateTime.now();

    for (var reminder in reminderItems) {
      final reminderTime = reminder[AppValues.keyDueDate];
      // final DateTime reminderDateTime = DateTime.parse(reminderTime);
      final DateTime reminderDateTime = DateFormat("dd/MM/yyyy HH:mm").parse(reminderTime);

      if (reminderDateTime.isBefore(now) && reminder[AppValues.keyIsCompleted] == false) {
        _updateReminderItem(reminder[AppValues.keyId], {
          AppValues.keyTitle: reminder[AppValues.keyTitle],
          AppValues.keyDescription: reminder[AppValues.keyDescription],
          AppValues.keyDueDate: reminder[AppValues.keyDueDate],
          AppValues.keyLastModifiedAt: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          AppValues.keyIsSynced: false,
          AppValues.keyIsCompleted: true,
        });
      }
    }

    update(); // Refresh the UI
  }

  // Get all items from the database
  Future<void> _refreshReminderItems() async {
    final List<Map<String, dynamic>> data =
        _databaseBox.keys.map((key) {
          final value = _databaseBox.get(key);
          return {
            AppValues.keyId: key,
            AppValues.keyTitle: value[AppValues.keyTitle],
            AppValues.keyDescription: value[AppValues.keyDescription],
            AppValues.keyDueDate: value[AppValues.keyDueDate],
            AppValues.keyIsCompleted: value[AppValues.keyIsCompleted],
            AppValues.keyIsSynced: value[AppValues.keyIsSynced],
            AppValues.keyLastModifiedAt: value[AppValues.keyLastModifiedAt],
          };
        }).toList();

    logger.d(data);
    _setReminderItems(data);

    if (await _isNetworkConnected()) {
      syncUnsyncedReminders();
    } else {
      showToast("Item created locally, will sync when online");
    }
  }

  Future<void> syncUnsyncedReminders() async {
    try {
      _isSyncing.value = true;

      // Get all unsynced items
      final unsyncedItems =
          reminderItems.where((item) => item[AppValues.keyIsSynced] == false || item[AppValues.keyIsSynced] == null).toList();

      if (unsyncedItems.isEmpty) {
        _isSyncing.value = false;
        return;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final item in unsyncedItems) {
        final docRef = firestore.collection(AppValues.collectionReminder).doc();

        batch.set(docRef, {
          AppValues.keyId: item[AppValues.keyId],
          AppValues.keyTitle: item[AppValues.keyTitle],
          AppValues.keyDescription: item[AppValues.keyDescription],
          AppValues.keyDueDate: item[AppValues.keyDueDate],
          AppValues.keyIsCompleted: item[AppValues.keyIsCompleted],
          AppValues.keyLastModifiedAt: item[AppValues.keyLastModifiedAt],
          'firebaseId': docRef.id,
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      // Execute batch write
      await batch.commit();

      // Update local database to mark items as synced
      for (final item in unsyncedItems) {
        final updatedItem = Map<String, dynamic>.from(_databaseBox.get(item[AppValues.keyId]));
        updatedItem[AppValues.keyIsSynced] = true;
        await _databaseBox.put(item[AppValues.keyId], updatedItem);
      }

      _refreshReminderItems();
      showToast("${unsyncedItems.length} items synced successfully");
    } catch (e) {
      logger.e("Error syncing reminders: $e");
      showErrorToast("Failed to sync reminders: ${e.toString()}");
    } finally {
      _isSyncing.value = false;
    }

    Future.delayed(const Duration(seconds: 2), () {
      _markPastRemindersAsCompleted();
    });
  }

  // Create new item
  Future<void> _createReminderItem(Map<String, dynamic> newItem) async {
    await _databaseBox.add(newItem);

    _refreshReminderItems(); // update the UI
  }

  // Map<String, dynamic> _readReminderItem(int key) {
  //   final item = _databaseBox.get(key);
  //   return item;
  // }

  // Update a single item
  Future<void> _updateReminderItem(int itemKey, Map<String, dynamic> item) async {
    await _databaseBox.put(itemKey, item);

    _refreshReminderItems(); // Update the UI
  }

  // Delete a single item
  Future<void> deleteReminderItem(int itemKey) async {
    await _databaseBox.delete(itemKey);
    _refreshReminderItems(); // update the UI

    showToast("Item has been deleted");
  }

  void showReminderForm(BuildContext context, {int? itemKey}) async {
    if (itemKey != null) {
      final existingItem = reminderItems.firstWhere((element) => element[AppValues.keyId] == itemKey);
      _titleController.text = existingItem[AppValues.keyTitle];
      _descriptionController.text = existingItem[AppValues.keyDescription];
      _dueDateController.text = existingItem[AppValues.keyDueDate];

      if (existingItem[AppValues.keyDueDate] != null && existingItem[AppValues.keyDueDate].isNotEmpty) {
        try {
          final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
          _selectedDateTime = formatter.parse(existingItem[AppValues.keyDueDate]);
        } catch (e) {
          _selectedDateTime = null;
        }
      }
    } else {
      _titleController.text = '';
      _descriptionController.text = '';
      _dueDateController.text = '';
      _selectedDateTime = null;
    }

    Get.bottomSheet(
      SafeArea(
        child: Container(
          color: AppColors.accent,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 15, left: 15, right: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Fill the Details:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                      onPressed: () {
                        _titleController.text = '';
                        _descriptionController.text = '';
                        _dueDateController.text = '';
                        Get.back();
                      },
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  ],
                ),

                TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Title')),
                8.sizeH,
                TextField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                8.sizeH,
                GestureDetector(
                  onTap: () => _selectDateTime(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(hintText: 'Select Due Date & Time', suffixIcon: Icon(Icons.calendar_today)),
                    ),
                  ),
                ),
                8.sizeH,
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty) {
                      showErrorToast("Please enter title");
                      return;
                    }
                    if (_descriptionController.text.isEmpty) {
                      showErrorToast("Please enter description");
                      return;
                    }
                    if (_dueDateController.text.isEmpty) {
                      showErrorToast("Please select due date");
                      return;
                    }

                    if (itemKey != null) {
                      _updateReminderItem(itemKey, {
                        AppValues.keyTitle: _titleController.text,
                        AppValues.keyDescription: _descriptionController.text,
                        AppValues.keyDueDate: _dueDateController.text,
                        AppValues.keyLastModifiedAt: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                        AppValues.keyIsSynced: false,
                        AppValues.keyIsCompleted: false,
                      });
                    } else {
                      _createReminderItem({
                        AppValues.keyTitle: _titleController.text,
                        AppValues.keyDescription: _descriptionController.text,
                        AppValues.keyDueDate: _dueDateController.text,
                        AppValues.keyLastModifiedAt: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                        AppValues.keyIsSynced: false,
                        AppValues.keyIsCompleted: false,
                      });
                    }
                    // Clear the text fields
                    _titleController.text = '';
                    _descriptionController.text = '';
                    _dueDateController.text = '';
                    _selectedDateTime = null;
                    Get.back();
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(itemKey == null ? 'Create New' : 'Update')]),
                ),
                16.sizeH,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add this method to show date time picker
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        _selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);

        // Format the date and time for display
        final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
        _dueDateController.text = formatter.format(_selectedDateTime!);
      }
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: _onNotificationTapped);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      final parts = payload.split('|');
      if (parts.length >= 2) {
        final action = parts[0]; // 'dismiss' or 'snooze'
        final itemId = int.tryParse(parts[1]);

        if (itemId != null) {
          if (action == 'dismiss') {
            _dismissReminder(itemId);
          } else if (action == 'snooze') {
            _snoozeReminder(itemId);
          }
        }
      }
    }
  }

  // Start timer to check for due reminders
  void _startNotificationTimer() {
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForDueReminders();
    });
  }

  // Check for due reminders
  void _checkForDueReminders() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    for (final item in reminderItems) {
      if (item[AppValues.keyIsCompleted] == true) continue;

      final dueDateStr = item[AppValues.keyDueDate];
      if (dueDateStr == null || dueDateStr.isEmpty) continue;

      try {
        final dueDate = formatter.parse(dueDateStr);
        final difference = dueDate.difference(now).inMinutes;

        // Show notification if due time is within 1 minute (accounting for timer interval)
        if (difference <= 1 && difference >= 0) {
          _showReminderNotification(item);
        }
      } catch (e) {
        logger.e("Error parsing due date: $e");
      }
    }
  }

  // Show reminder notification
  Future<void> _showReminderNotification(Map<String, dynamic> item) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications for due reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('dismiss', 'Dismiss', showsUserInterface: true),
        AndroidNotificationAction('snooze', 'Snooze (10 min)', showsUserInterface: true),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.show(
      item[AppValues.keyId].hashCode,
      'Reminder Due: ${item[AppValues.keyTitle]}',
      item[AppValues.keyDescription],
      notificationDetails,
      payload: 'reminder|${item[AppValues.keyId]}',
    );
  }

  // Dismiss reminder
  Future<void> _dismissReminder(int itemId) async {
    try {
      final existingItem = Map<String, dynamic>.from(_databaseBox.get(itemId));
      existingItem[AppValues.keyIsCompleted] = true;
      existingItem[AppValues.keyLastModifiedAt] = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      existingItem[AppValues.keyIsSynced] = false;

      await _databaseBox.put(itemId, existingItem);
      _refreshReminderItems();

      // Try to sync if network is available
      if (await _isNetworkConnected()) {
        await _syncSingleItem(existingItem);
      }

      showToast("Reminder marked as completed");
    } catch (e) {
      logger.e("Error dismissing reminder: $e");
    }
  }

  // Snooze reminder
  Future<void> _snoozeReminder(int itemId) async {
    try {
      final existingItem = Map<String, dynamic>.from(_databaseBox.get(itemId));
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      final currentDueDate = formatter.parse(existingItem[AppValues.keyDueDate]);
      final newDueDate = currentDueDate.add(const Duration(minutes: 10));

      existingItem[AppValues.keyDueDate] = formatter.format(newDueDate);
      existingItem[AppValues.keyLastModifiedAt] = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      existingItem[AppValues.keyIsSynced] = false;

      await _databaseBox.put(itemId, existingItem);
      _refreshReminderItems();

      // Try to sync if network is available
      if (await _isNetworkConnected()) {
        await _syncSingleItem(existingItem);
      }

      showToast("Reminder snoozed for 10 minutes");
    } catch (e) {
      logger.e("Error snoozing reminder: $e");
    }
  }

  // Check network connectivity
  Future<bool> _isNetworkConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _syncSingleItem(Map<String, dynamic> item) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection(AppValues.collectionReminder).doc();

      await docRef.set({
        AppValues.keyId: item[AppValues.keyId],
        AppValues.keyTitle: item[AppValues.keyTitle],
        AppValues.keyDescription: item[AppValues.keyDescription],
        AppValues.keyDueDate: item[AppValues.keyDueDate],
        AppValues.keyIsCompleted: item[AppValues.keyIsCompleted],
        AppValues.keyLastModifiedAt: item[AppValues.keyLastModifiedAt],
        'firebaseId': docRef.id,
        'syncedAt': FieldValue.serverTimestamp(),
      });

      // Update local database to mark item as synced
      final updatedItem = Map<String, dynamic>.from(_databaseBox.get(item[AppValues.keyId]));
      updatedItem[AppValues.keyIsSynced] = true;
      await _databaseBox.put(item[AppValues.keyId], updatedItem);

      _refreshReminderItems();
    } catch (e) {
      logger.e("Error syncing single item: $e");
    }
  }
}
