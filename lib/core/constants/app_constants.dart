class AppConstants {
  AppConstants._();

  static const String appName = 'Keep in Track';
  static const String appTagline = 'Your finances, beautifully tracked';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String monthYearFormat = 'MMM yyyy';
  static const String backupFilePrefix = 'keep_in_track_backup';
  static const String backupFileExtension = '.json';

  // Hive Box Names
  static const String transactionBox = 'transactions';
  static const String categoryBox = 'categories';
  static const String budgetBox = 'budgets';
  static const String merchantBox = 'merchants';
  static const String settingsBox = 'settings';
  static const String seedBox = 'seed_flags';
  static const String subcategoryBox = 'subcategories';

  // Hive Type IDs
  static const int transactionTypeId = 0;
  static const int categoryTypeId = 1;
  static const int budgetTypeId = 2;
  static const int merchantTypeId = 3;
  static const int appSettingsTypeId = 4;
  static const int transactionTypeEnumId = 5;
  static const int paymentModeEnumId = 6;
  static const int recurringFrequencyEnumId = 7;
  static const int subcategoryTypeId = 8;

  // Budget thresholds
  static const double budgetWarningThreshold = 0.80; // 80%
  static const double budgetCriticalThreshold = 1.00; // 100%
  static const double budgetAmberThreshold = 0.60;   // 60%

  // UI
  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double pageHorizontalPadding = 20.0;
  static const double sectionSpacing = 24.0;
  static const int maxRecentTransactions = 10;
  static const int maxMerchantSuggestions = 5;

  // Animation durations
  static const int splashDurationMs = 2000;
  static const int pageTransitionMs = 300;
  static const int countUpDurationMs = 1200;
  static const int chartAnimationMs = 800;

  // Notification IDs
  static const int budgetAlertNotifId = 1001;
  static const int recurringNotifId = 2001;

  // Settings keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyIsPinEnabled = 'is_pin_enabled';
  static const String keyPinHash = 'pin_hash';
  static const String keyIsBiometricEnabled = 'is_biometric_enabled';
  static const String keyMonthStartDay = 'month_start_day';
  static const String keyBudgetAlerts = 'budget_alerts';
  static const String keyRecurringReminders = 'recurring_reminders';
  static const String keyReminderTime = 'reminder_time';
  static const String keySeedDone = 'seed_done';
}
