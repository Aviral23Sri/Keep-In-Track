import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'shared/providers/settings_providers.dart';

class KeepInTrackApp extends ConsumerWidget {
  const KeepInTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
