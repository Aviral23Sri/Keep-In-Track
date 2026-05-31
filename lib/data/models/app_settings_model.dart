import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

@HiveType(typeId: AppConstants.appSettingsTypeId)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  late String themeMode; // 'light' | 'dark' | 'system'

  @HiveField(1)
  late bool isPinEnabled;

  @HiveField(2)
  String? pinHash;

  @HiveField(3)
  late bool isBiometricEnabled;

  @HiveField(4)
  late int monthStartDay; // 1–28

  @HiveField(5)
  late bool budgetAlerts;

  @HiveField(6)
  late bool recurringReminders;

  @HiveField(7)
  late String reminderTime; // e.g. "09:00"

  @HiveField(8)
  late bool seedDone;

  // NEW fields — daily/weekly budgets stored in settings for simplicity
  @HiveField(9)
  double? dailyBudget;

  @HiveField(10)
  double? weeklyBudget;

  @HiveField(11)
  bool subcategorySeedDone;

  AppSettingsModel({
    this.themeMode = 'system',
    this.isPinEnabled = false,
    this.pinHash,
    this.isBiometricEnabled = false,
    this.monthStartDay = 1,
    this.budgetAlerts = true,
    this.recurringReminders = true,
    this.reminderTime = '09:00',
    this.seedDone = false,
    this.dailyBudget,
    this.weeklyBudget,
    this.subcategorySeedDone = false,
  });

  AppSettingsModel copyWith({
    String? themeMode,
    bool? isPinEnabled,
    String? pinHash,
    bool? isBiometricEnabled,
    int? monthStartDay,
    bool? budgetAlerts,
    bool? recurringReminders,
    String? reminderTime,
    bool? seedDone,
    double? dailyBudget,
    double? weeklyBudget,
    bool? subcategorySeedDone,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pinHash: pinHash ?? this.pinHash,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      monthStartDay: monthStartDay ?? this.monthStartDay,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      recurringReminders: recurringReminders ?? this.recurringReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      seedDone: seedDone ?? this.seedDone,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      subcategorySeedDone: subcategorySeedDone ?? this.subcategorySeedDone,
    );
  }

  // Helper to clear daily/weekly budgets (can't use null in copyWith due to ?? logic)
  AppSettingsModel clearDailyBudget() => AppSettingsModel(
        themeMode: themeMode, isPinEnabled: isPinEnabled, pinHash: pinHash,
        isBiometricEnabled: isBiometricEnabled, monthStartDay: monthStartDay,
        budgetAlerts: budgetAlerts, recurringReminders: recurringReminders,
        reminderTime: reminderTime, seedDone: seedDone,
        dailyBudget: null, weeklyBudget: weeklyBudget,
        subcategorySeedDone: subcategorySeedDone,
      );

  AppSettingsModel clearWeeklyBudget() => AppSettingsModel(
        themeMode: themeMode, isPinEnabled: isPinEnabled, pinHash: pinHash,
        isBiometricEnabled: isBiometricEnabled, monthStartDay: monthStartDay,
        budgetAlerts: budgetAlerts, recurringReminders: recurringReminders,
        reminderTime: reminderTime, seedDone: seedDone,
        dailyBudget: dailyBudget, weeklyBudget: null,
        subcategorySeedDone: subcategorySeedDone,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'isPinEnabled': isPinEnabled,
        'pinHash': pinHash,
        'isBiometricEnabled': isBiometricEnabled,
        'monthStartDay': monthStartDay,
        'budgetAlerts': budgetAlerts,
        'recurringReminders': recurringReminders,
        'reminderTime': reminderTime,
        'seedDone': seedDone,
        'dailyBudget': dailyBudget,
        'weeklyBudget': weeklyBudget,
        'subcategorySeedDone': subcategorySeedDone,
      };

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      AppSettingsModel(
        themeMode: json['themeMode'] as String? ?? 'system',
        isPinEnabled: json['isPinEnabled'] as bool? ?? false,
        pinHash: json['pinHash'] as String?,
        isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
        monthStartDay: json['monthStartDay'] as int? ?? 1,
        budgetAlerts: json['budgetAlerts'] as bool? ?? true,
        recurringReminders: json['recurringReminders'] as bool? ?? true,
        reminderTime: json['reminderTime'] as String? ?? '09:00',
        seedDone: json['seedDone'] as bool? ?? false,
        dailyBudget: (json['dailyBudget'] as num?)?.toDouble(),
        weeklyBudget: (json['weeklyBudget'] as num?)?.toDouble(),
        subcategorySeedDone: json['subcategorySeedDone'] as bool? ?? false,
      );
}
