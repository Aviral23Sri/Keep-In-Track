import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sms_detector_service.dart';
import '../../core/services/sms_parser.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

/// Holds the in-memory list of pending (detected but unconfirmed) SMS transactions.
/// Synced with Hive via [SmsDetectorService].
final pendingSmsProvider =
    AsyncNotifierProvider<PendingSmsNotifier, List<ParsedSmsTransaction>>(
  PendingSmsNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class PendingSmsNotifier extends AsyncNotifier<List<ParsedSmsTransaction>> {
  @override
  Future<List<ParsedSmsTransaction>> build() =>
      SmsDetectorService.getPendingList();

  /// Reload from Hive (call after [SmsDetectorService.checkPending]).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => SmsDetectorService.getPendingList());
  }

  /// Remove a single item (after user logs or dismisses it).
  Future<void> dismiss(String id) async {
    await SmsDetectorService.removePending(id);
    await refresh();
  }
}

// ── Convenience ───────────────────────────────────────────────────────────────

/// Count of pending SMS transactions — drives the dashboard badge.
final pendingSmsCountProvider = Provider<int>((ref) {
  return ref.watch(pendingSmsProvider).maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});
