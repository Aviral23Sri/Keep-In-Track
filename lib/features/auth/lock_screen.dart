import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../data/models/app_settings_model.dart';
import '../../shared/providers/settings_providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  bool _hasError = false;
  bool _biometricAvailable = false;
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback so the widget tree is fully built and
    // the settings provider has had a chance to emit its first value.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkBiometricAvailability();
      await _triggerBiometricIfEnabled();
    });
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (mounted) {
        setState(() => _biometricAvailable = canCheck || isSupported);
      }
    } catch (_) {
      // biometric not available
    }
  }

  Future<void> _triggerBiometricIfEnabled() async {
    // Wait until settings are loaded (retry a few times)
    AppSettingsModel? settings;
    for (int i = 0; i < 10; i++) {
      settings = ref.read(settingsControllerProvider).value;
      if (settings != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (settings == null || !settings.isBiometricEnabled) return;
    if (!_biometricAvailable) return;

    await _triggerBiometric();
  }

  Future<void> _triggerBiometric() async {
    if (!_biometricAvailable) return;
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Unlock Keep in Track',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow PIN fallback inside OS dialog
          sensitiveTransaction: false,
        ),
      );
      if (authenticated && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      // silently fall through to PIN entry
      debugPrint('Biometric error: $e');
    }
  }

  void _onKeypadPressed(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _hasError = false;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _hasError = false;
      });
    }
  }

  void _verifyPin() {
    final settings = ref.read(settingsControllerProvider).value;
    if (settings?.pinHash != null) {
      final inputHash = sha256.convert(utf8.encode(_pin)).toString();
      if (inputHash == settings!.pinHash) {
        context.go('/dashboard');
      } else {
        setState(() {
          _hasError = true;
          _pin = '';
        });
      }
    } else {
      // No PIN set yet — shouldn't happen, but failsafe navigate to dashboard
      context.go('/dashboard');
    }
  }

  Widget _buildDot(int index) {
    bool isFilled = index < _pin.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled
            ? (_hasError ? AppColors.error : AppColors.primary)
            : Colors.transparent,
        border: Border.all(
          color: isFilled
              ? (_hasError ? AppColors.error : AppColors.primary)
              : Colors.grey.shade400,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return TextButton(
      onPressed: () => _onKeypadPressed(digit),
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).value;
    final pinEnabled = settings?.isPinEnabled ?? false;
    final biometricEnabled = settings?.isBiometricEnabled ?? false;

    // ── Biometric-only mode (no PIN) ─────────────────────────────────────────
    if (!pinEnabled && biometricEnabled) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.lock_outline, size: 72, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Keep in Track',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Verify your identity to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _triggerBiometric,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tap to use biometric',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    }

    // ── PIN mode (with optional biometric button) ─────────────────────────────
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Enter PIN',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _hasError
                  ? const Text(
                      'Incorrect PIN, try again',
                      key: ValueKey('error'),
                      style: TextStyle(color: AppColors.error),
                    )
                  : const SizedBox(height: 16, key: ValueKey('empty')),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDot(index)),
            ),
            const Spacer(),
            // Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        ['1', '2', '3'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        ['4', '5', '6'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        ['7', '8', '9'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Biometric button — only shown if available AND enabled
                      if (_biometricAvailable && biometricEnabled)
                        TextButton(
                          onPressed: _triggerBiometric,
                          style: TextButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(24),
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      _buildKeypadButton('0'),
                      TextButton(
                        onPressed: _onBackspace,
                        style: TextButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          foregroundColor: Colors.grey.shade600,
                        ),
                        child: const Icon(Icons.backspace_outlined, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


