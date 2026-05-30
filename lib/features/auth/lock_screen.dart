import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/settings_providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  bool _hasError = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _triggerBiometric();
  }

  Future<void> _triggerBiometric() async {
    final settings = ref.read(settingsControllerProvider).value;
    if (settings != null && settings.isBiometricEnabled) {
      try {
        final canCheckBiometrics = await auth.canCheckBiometrics;
        final isDeviceSupported = await auth.isDeviceSupported();
        
        if (canCheckBiometrics || isDeviceSupported) {
          final authenticated = await auth.authenticate(
            localizedReason: 'Unlock Keep in Track',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: false,
            ),
          );
          if (authenticated && mounted) {
            context.go('/dashboard');
          }
        }
      } catch (e) {
        // Fallback to PIN
      }
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
    }
  }

  Widget _buildDot(int index) {
    bool isFilled = index < _pin.length;
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isFilled ? AppColors.primary : Colors.grey.shade400,
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
            if (_hasError)
              const Text(
                'Incorrect PIN, try again',
                style: TextStyle(color: AppColors.error),
              )
            else
              const SizedBox(height: 16),
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
                    children: ['1', '2', '3'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['4', '5', '6'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['7', '8', '9'].map((d) => _buildKeypadButton(d)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _triggerBiometric,
                        style: TextButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                        ),
                        child: const Icon(Icons.fingerprint, size: 32, color: AppColors.primary),
                      ),
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
