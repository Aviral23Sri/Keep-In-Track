import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import 'sms_parser.dart';

/// Orchestrates: reading native SMS queue → parsing → dedup → notifying.
/// Call [checkPending] on app resume and at startup.
class SmsDetectorService {
  SmsDetectorService._();

  static const _channel  = MethodChannel(AppConstants.smsChannel);
  static const _notifChannel = AndroidNotificationChannel(
    'sms_detection',
    'Transaction Alerts',
    description: 'Alerts when a bank transaction SMS is detected.',
    importance: Importance.high,
  );

  static final _notifPlugin = FlutterLocalNotificationsPlugin();

  /// Call once in [main()] before [runApp].
  static Future<void> init() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    );
    await _notifPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handled via [getNotificationAppLaunchDetails] in app.dart
      },
    );

    // Create the Android notification channel
    await _notifPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_notifChannel);
  }

  // ── Enabled/disabled state via native SharedPreferences ───────────────────

  static Future<bool> isEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('getSmsEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setEnabled(bool value) async {
    try {
      await _channel.invokeMethod('setSmsEnabled', {'enabled': value});
    } catch (_) {}
  }

  // ── Main entry point — call on app resume ─────────────────────────────────

  /// Reads the native SMS queue, parses each message, checks for duplicates,
  /// saves new items to Hive, and fires a notification for each.
  static Future<void> checkPending() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    String rawJson;
    try {
      rawJson =
          await _channel.invokeMethod<String>('getPendingSmsList') ?? '[]';
    } catch (_) {
      return;
    }

    final List<dynamic> list;
    try {
      list = jsonDecode(rawJson) as List<dynamic>;
    } catch (_) {
      return;
    }

    if (list.isEmpty) return;

    final box = await Hive.openBox<String>(AppConstants.pendingSmsBox);

    for (int i = 0; i < list.length; i++) {
      final entry = list[i] as Map<String, dynamic>;
      final body   = entry['body'] as String? ?? '';
      final sender = entry['sender'] as String? ?? '';
      final ts     = entry['timestamp'] as int? ?? 0;
      // SmsReceiver.kt sets this to true when it shows the immediate native
      // notification. We skip _showNotification() to avoid a duplicate pop-up.
      final alreadyNotified = entry['notified'] as bool? ?? false;

      final parsed = SmsParser.parse(
        body,
        sender,
        DateTime.fromMillisecondsSinceEpoch(ts),
      );
      if (parsed == null) continue;

      // Dedup: skip if same amount+type was already saved within 5 minutes
      if (_isDuplicate(box, parsed)) continue;

      // Save to Hive pending queue
      await box.put(parsed.id, parsed.toJsonString());

      // Only show notification if Kotlin didn't already fire one
      if (!alreadyNotified) {
        await _showNotification(parsed);
      }
    }

    // Clear native queue after processing
    try {
      await _channel.invokeMethod('clearPendingSmsList');
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool _isDuplicate(Box<String> box, ParsedSmsTransaction txn) {
    for (final json in box.values) {
      try {
        final existing = ParsedSmsTransaction.fromJsonString(json);
        final diff = txn.detectedAt.difference(existing.detectedAt).abs();
        if ((existing.amount - txn.amount).abs() < 0.01 &&
            existing.type == txn.type &&
            diff.inMinutes <= 5) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  static Future<void> _showNotification(ParsedSmsTransaction txn) async {
    final symbol  = txn.type == 'expense' ? '💸' : '💰';
    final verb    = txn.type == 'expense' ? 'Debited' : 'Credited';
    final amount  = '₹${txn.amount.toStringAsFixed(0)}';
    final merchant = txn.merchant != null ? ' at ${txn.merchant}' : '';
    final body    = '$verb $amount$merchant. Tap to log.';

    await _notifPlugin.show(
      AppConstants.smsDetectNotifId + txn.hashCode % 1000,
      '$symbol Transaction Detected',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _notifChannel.id,
          _notifChannel.name,
          channelDescription: _notifChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      payload: txn.id, // Used to open the right transaction on tap
    );
  }

  /// Removes a processed pending SMS from Hive.
  static Future<void> removePending(String id) async {
    final box = await Hive.openBox<String>(AppConstants.pendingSmsBox);
    await box.delete(id);
  }

  /// Returns all current pending SMS transactions.
  static Future<List<ParsedSmsTransaction>> getPendingList() async {
    final box = await Hive.openBox<String>(AppConstants.pendingSmsBox);
    final results = <ParsedSmsTransaction>[];
    for (final json in box.values) {
      try {
        results.add(ParsedSmsTransaction.fromJsonString(json));
      } catch (_) {}
    }
    results.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return results;
  }
}
