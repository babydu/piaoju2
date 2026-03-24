class AppConstants {
  static const String appName = '票夹管家';
  static const String appVersion = '1.0.0';

  static const int maxStorageTotal = 1024 * 1024 * 1024; // 1GB
  static const int maxImageCount = 9;
  static const int maxImageSize = 20 * 1024 * 1024; // 20MB
  static const int maxBillCount = 10000;
  static const int maxCollectionCount = 100;
  static const int maxTitleLength = 100;
  static const int maxRemarkLength = 500;
  static const int maxTagNameLength = 20;
  static const int maxCollectionNameLength = 30;

  static const int smsCodeValidMinutes = 5;
  static const int maxSmsPerDay = 10;
  static const int maxLoginAttemptsPerDay = 20;
  static const int maxWrongCodeAttempts = 5;

  static const int recycleBinRetentionDays = 30;
  static const int recycleBinReminderDays = 7;

  static const int searchHistoryMaxCount = 10;
  static const int pageSize = 20;
}
