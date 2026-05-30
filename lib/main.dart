import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/hive_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local database and seed data if needed
  await HiveDatabase.initialize();
  await HiveDatabase.seedIfNeeded();

  runApp(
    const ProviderScope(
      child: KeepInTrackApp(),
    ),
  );
}
