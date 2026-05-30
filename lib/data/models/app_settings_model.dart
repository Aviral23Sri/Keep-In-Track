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
    );
  }

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
      };

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) => AppSettingsModel(
        themeMode: json['themeMode'] as String? ?? 'system',
        isPinEnabled: json['isPinEnabled'] as bool? ?? false,
        pinHash: json['pinHash'] as String?,
        isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
        monthStartDay: json['monthStartDay'] as int? ?? 1,
        budgetAlerts: json['budgetAlerts'] as bool? ?? true,
        recurringReminders: json['recurringReminders'] as bool? ?? true,
        reminderTime: json['reminderTime'] as String? ?? '09:00',
        seedDone: json['seedDone'] as bool? ?? false,
      );
}
