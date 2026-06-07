import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/settings_providers.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _hasError = false;
  bool _isSaving = false; // guard to prevent double-save

  void _onKeypadPressed(String digit) {
    if (_isSaving) return; // block input while saving
    setState(() {
      _hasError = false;
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += digit;
        }
        // Move to confirm step AFTER setState so the dot animates first
        if (_pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _isConfirming = true);
          });
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
        }
        if (_confirmPin.length == 4) {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) _verifyAndSave();
          });
        }
      }
    });
  }

  void _onBackspace() {
    if (_isSaving) return;
    setState(() {
      _hasError = false;
      if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (_isConfirming && _confirmPin.isEmpty) {
        // Go back to create step
        _isConfirming = false;
        _pin = '';
      }
    });
  }

  Future<void> _verifyAndSave() async {
    if (_isSaving) return;
    if (_pin == _confirmPin) {
      setState(() => _isSaving = true);
      final hash = sha256.convert(utf8.encode(_pin)).toString();
      final settings = ref.read(settingsControllerProvider).value;
      if (settings == null) {
        setState(() => _isSaving = false);
        return;
      }

      // Wait for the settings write to complete before popping
      await ref.read(settingsControllerProvider.notifier).updateSettings(
        settings.copyWith(
          isPinEnabled: true,
          pinHash: hash,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PIN set successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      setState(() {
        _hasError = true;
        _confirmPin = '';
        _isConfirming = true; // stay on confirm step so user re-enters
      });
    }
  }

  Widget _buildDot(int index, String currentPin) {
    bool isFilled = index < currentPin.length;
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
    final title = _isConfirming ? 'Confirm PIN' : 'Create PIN';
    final subtitle = _isConfirming
        ? 'Re-enter your 4-digit PIN'
        : 'Choose a 4-digit PIN to protect the app';
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isConfirming) {
              setState(() {
                _isConfirming = false;
                _pin = '';
                _confirmPin = '';
                _hasError = false;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.dialpad,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 8),
            if (_hasError)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'PINs do not match. Try again.',
                  style: TextStyle(color: AppColors.error),
                ),
              )
            else
              const SizedBox(height: 20),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => _buildDot(i, currentPin)),
            ),
            const Spacer(),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else
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
