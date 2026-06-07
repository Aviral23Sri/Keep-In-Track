import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/settings_providers.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../data/repositories/backup_repository.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import '../../shared/widgets/confirmation_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck || isSupported;
      });
    } catch (e) {
      setState(() {
        _canCheckBiometrics = false;
      });
    }
  }

  Future<void> _exportBackup() async {
    try {
      final json = await BackupRepository().exportBackupToJson();
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/keep_in_track_backup_${DateTime.now().toIso8601String().split('T')[0]}.json');
      await file.writeAsString(json);

      // ignore: deprecated_member_use
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Keep in Track Backup',
      );
      if (result.status == ShareResultStatus.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup exported successfully!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to export: $e')));
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        if (!mounted) return;

        final confirm = await ConfirmationDialog.show(
          context: context,
          title: 'Restore Backup',
          content: 'This will replace all current data. Proceed?',
          isDestructive: true,
          confirmText: 'Restore',
        );

        if (confirm) {
          await BackupRepository()
              .importBackupFromJson(jsonString, replaceAll: true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text('Backup restored successfully! Restarting app...')));
            context.go('/splash');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to restore: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: const GradientAppBar(
        title: Text('Settings'),
        centerTitle: false,
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildSectionHeader('General'),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Theme'),
                trailing: DropdownButton<String>(
                  value: settings.themeMode,
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateSettings(
                            settings.copyWith(themeMode: val),
                          );
                    }
                  },
                ),
              ),
              const ListTile(
                leading: Icon(Icons.currency_rupee),
                title: Text('Currency'),
                trailing: Text('₹ (INR)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Start of Month'),
                trailing: DropdownButton<int>(
                  value: settings.monthStartDay,
                  items: List.generate(28, (index) => index + 1)
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.toString())))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateSettings(
                            settings.copyWith(monthStartDay: val),
                          );
                    }
                  },
                ),
              ),
              const Divider(),
              _buildSectionHeader('Security'),
              SwitchListTile(
                secondary: const Icon(Icons.pin),
                title: const Text('PIN Lock'),
                value: settings.isPinEnabled,
                onChanged: (val) {
                  if (val) {
                    context.push('/pin-setup');
                  } else {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateSettings(
                          settings.copyWith(isPinEnabled: false, pinHash: null),
                        );
                  }
                },
              ),
              if (_canCheckBiometrics)
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Unlock'),
                  subtitle: const Text('Use fingerprint or face to unlock'),
                  value: settings.isBiometricEnabled,
                  onChanged: (val) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateSettings(
                          settings.copyWith(isBiometricEnabled: val),
                        );
                  },
                ),
              const Divider(),
              _buildSectionHeader('Data Management'),
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Merchant Memory'),
                subtitle: const Text('Manage auto-fill payee details'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/merchant-manager'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: const Text('Import Bank Statement'),
                subtitle: const Text('Parse SBI statement PDF'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/import-statement'),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('Backup to File'),
                subtitle: const Text('Export JSON data'),
                onTap: _exportBackup,
              ),
              ListTile(
                leading: const Icon(Icons.settings_backup_restore),
                title: const Text('Restore from File'),
                subtitle: const Text('Import JSON data'),
                onTap: _importBackup,
              ),
              const Divider(),
              _buildSectionHeader('Danger Zone'),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text('Clear All Transactions', style: TextStyle(color: AppColors.error)),
                subtitle: const Text('Delete all transactions and reset balance'),
                onTap: () => _showClearDataDialog(context, ref),
              ),
              const Divider(),
              _buildSectionHeader('About'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(AppConstants.appName),
                subtitle: Text(AppConstants.appTagline),
                trailing: Text('v1.0.0'),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showClearDataDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Transactions?'),
        content: const Text(
            'This will permanently delete ALL transactions. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(transactionsControllerProvider.notifier).clearAllTransactions();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All transactions deleted.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
