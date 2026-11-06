import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/sms_detector_service.dart';
import 'shared/providers/settings_providers.dart';
import 'shared/providers/pending_sms_providers.dart';

class KeepInTrackApp extends ConsumerStatefulWidget {
  const KeepInTrackApp({super.key});

  @override
  ConsumerState<KeepInTrackApp> createState() => _KeepInTrackAppState();
}

class _KeepInTrackAppState extends ConsumerState<KeepInTrackApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check for any queued SMS on startup
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSms());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes to foreground, process any SMS queued by native receiver
    if (state == AppLifecycleState.resumed) {
      _checkSms();
    }
  }

  Future<void> _checkSms() async {
    final settings = ref.read(settingsControllerProvider).value;
    if (settings?.smsAutoDetect != true) return;
    await SmsDetectorService.checkPending();
    // Refresh the in-memory provider so badge/count updates
    ref.invalidate(pendingSmsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final router = ref.watch(appRouterProvider);

    return settingsAsync.when(
      data: (settings) {
        ThemeMode themeMode;
        if (settings.themeMode == 'light') {
          themeMode = ThemeMode.light;
        } else if (settings.themeMode == 'dark') {
          themeMode = ThemeMode.dark;
        } else {
          themeMode = ThemeMode.system;
        }

        return MaterialApp.router(
          title: 'Keep in Track',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
