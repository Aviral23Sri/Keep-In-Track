import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/hive_database.dart';
import 'core/services/sms_detector_service.dart';
import 'core/services/quick_save_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database and seed data if needed
  await HiveDatabase.initialize();
  await HiveDatabase.seedIfNeeded();

  // Initialize SMS detection notification channel
  await SmsDetectorService.init();

  // Import transactions saved from the quick-save notification and push the
  // category list it shows to native code.
  await QuickSaveService.init();

  runApp(
    const ProviderScope(
      child: KeepInTrackApp(),
    ),
  );
}
