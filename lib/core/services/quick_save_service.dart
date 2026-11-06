import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/hive_database.dart';
import '../../data/models/transaction_model.dart';
import 'sms_parser.dart';

/// Bridge for the native quick-save notification (android/.../QuickSave.kt).
///
/// The notification lets the user pick a category, then a subcategory, then
/// Save, without opening the app. Native code can't write Hive, so:
///  * [syncCatalog] pushes categories, subcategories and merchant hints to
///    native SharedPreferences (kept fresh by watching the Hive boxes);
///  * [importSaved] moves transactions saved from the notification into Hive.
class QuickSaveService {
  QuickSaveService._();

  static const _channel = MethodChannel(AppConstants.smsChannel);
  static Timer? _debounce;
  static final List<StreamSubscription> _subs = [];

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Call once after Hive is initialised.
  static Future<void> init() async {
    if (!_isAndroid) return;
    await importSaved();
    await syncCatalog();

    // Re-sync whenever categories, subcategories or merchants change.
    for (final box in [
      HiveDatabase.categories,
      HiveDatabase.subcategories,
      HiveDatabase.merchants,
    ]) {
      _subs.add(box.watch().listen((_) => _scheduleSync()));
    }
  }

  static void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), syncCatalog);
  }

  /// Writes the category catalog the notification shows. Categories are
  /// ordered by how often they were used in the last 90 days.
  static Future<void> syncCatalog() async {
    if (!_isAndroid) return;
    try {
      final since = DateTime.now().subtract(const Duration(days: 90));
      final usage = <String, int>{};
      final subUsage = <String, int>{};
      for (final t in HiveDatabase.transactions.values) {
        if (t.date.isBefore(since)) continue;
        usage[t.categoryId] = (usage[t.categoryId] ?? 0) + 1;
        if (t.subcategoryId != null) {
          subUsage[t.subcategoryId!] = (subUsage[t.subcategoryId!] ?? 0) + 1;
        }
      }

      final subsByCat = <String, List<Map<String, String>>>{};
      final allSubs = HiveDatabase.subcategories.values.toList()
        ..sort((a, b) => (subUsage[b.id] ?? 0).compareTo(subUsage[a.id] ?? 0));
      for (final s in allSubs) {
        subsByCat.putIfAbsent(s.categoryId, () => []).add({
          'id': s.id,
          'name': s.name,
        });
      }

      final cats = HiveDatabase.categories.values
          .where((c) => !c.isHidden)
          .toList()
        ..sort((a, b) => (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0));

      final hints = <Map<String, String?>>[];
      for (final m in HiveDatabase.merchants.values) {
        for (final name in {m.name, ...m.nameVariants}) {
          final k = name.trim().toLowerCase();
          if (k.length < 3) continue;
          hints.add({'k': k, 'c': m.categoryId, 's': m.subcategoryId});
        }
      }
      // Longest names first, so "amazon prime" wins over "amazon".
      hints.sort((a, b) => b['k']!.length.compareTo(a['k']!.length));

      final catalog = {
        'categories': [
          for (final c in cats)
            {
              'id': c.id,
              'name': c.name,
              'type': c.type,
              'color': c.color,
              'subs': subsByCat[c.id] ?? const [],
            },
        ],
        'hints': hints,
      };
      await _channel.invokeMethod(
          'setQuickSaveCatalog', {'json': jsonEncode(catalog)});
    } catch (e) {
      debugPrint('QuickSaveService.syncCatalog failed: $e');
    }
  }

  /// Moves transactions saved from the notification into Hive.
  /// Returns how many were imported.
  static Future<int> importSaved() async {
    if (!_isAndroid) return 0;
    try {
      final raw = await _channel.invokeMethod<String>('getQuickSaved') ?? '[]';
      final list = jsonDecode(raw) as List<dynamic>;
      if (list.isEmpty) return 0;

      final imported = <String>[];
      for (final e in list) {
        final m = e as Map<String, dynamic>;
        final id = m['id'] as String;
        final date =
            DateTime.fromMillisecondsSinceEpoch((m['date'] as num).toInt());
        final txn = TransactionModel(
          id: id,
          type: m['type'] as String? ?? 'expense',
          amount: (m['amount'] as num).toDouble(),
          categoryId: m['categoryId'] as String,
          subcategoryId: m['subcategoryId'] as String?,
          title: m['title'] as String?,
          date: date,
          paymentMode: m['paymentMode'] as String? ?? 'bankTransfer',
          isRecurring: false,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
              (m['createdAt'] as num?)?.toInt() ??
                  DateTime.now().millisecondsSinceEpoch),
        );
        // put() with the same id is idempotent if a previous ack failed.
        await HiveDatabase.transactions.put(id, txn);
        await _removeMatchingPending(txn);
        imported.add(id);
      }

      await _channel.invokeMethod('ackQuickSaved', {'ids': imported});
      return imported.length;
    } catch (e) {
      debugPrint('QuickSaveService.importSaved failed: $e');
      return 0;
    }
  }

  /// If the app already moved this SMS into the "Pending review" queue before
  /// it was saved from the notification, drop it so it isn't logged twice.
  static Future<void> _removeMatchingPending(TransactionModel txn) async {
    final box = await Hive.openBox<String>(AppConstants.pendingSmsBox);
    final toDelete = <dynamic>[];
    for (final key in box.keys) {
      try {
        final p = ParsedSmsTransaction.fromJsonString(box.get(key)!);
        if ((p.amount - txn.amount).abs() < 0.01 &&
            p.type == txn.type &&
            p.detectedAt.difference(txn.date).abs().inMinutes <= 2) {
          toDelete.add(key);
        }
      } catch (_) {}
    }
    if (toDelete.isNotEmpty) await box.deleteAll(toDelete);
  }
}
