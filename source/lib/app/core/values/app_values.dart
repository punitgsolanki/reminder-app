abstract class AppValues {
  static const String appName = "Reminder";

  static const String dbName = "reminder_db";

  // All date time format
  static const String serverDateTimeFormat = "yyyy-MM-ddTHH:mm:ssZ";
  static const String formatToDMMM = "d MMM";
  static const String inr = "INR\$";

  static const int loggerLineLength = 120;
  static const int loggerErrorMethodCount = 8;
  static const int loggerMethodCount = 2;

  // Each task should have: id, title, description, due_date, is_completed, is_synced, last_modified_at
  static const String keyId = "key";
  static const String keyTitle = "title";
  static const String keyDescription = "description";
  static const String keyDueDate = "due_date";
  static const String keyIsCompleted = "is_completed";
  static const String keyIsSynced = "is_synced";
  static const String keyLastModifiedAt = "last_modified_at";

  static const String collectionReminder = "reminder";
}
