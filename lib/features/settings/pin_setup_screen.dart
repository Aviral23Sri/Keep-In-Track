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

  void _onKeypadPressed(String digit) {
    setState(() {
      _hasError = false;
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += digit;
          if (_pin.length == 4) {
            _isConfirming = true;
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
          if (_confirmPin.length == 4) {
            _verifyAndSave();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _hasError = false;
      if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (_isConfirming && _confirmPin.isEmpty) {
        _isConfirming = false;
      }
    });
  }

  void _verifyAndSave() {
    if (_pin == _confirmPin) {
      final hash = sha256.convert(utf8.encode(_pin)).toString();
      final settings = ref.read(settingsControllerProvider).value!;
      
      ref.read(settingsControllerProvider.notifier).updateSettings(
        settings.copyWith(
          isPinEnabled: true,
          pinHash: hash,
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN setup successful')));
      context.pop();
    } else {
      setState(() {
        _hasError = true;
        _confirmPin = '';
      });
    }
  }

  Widget _buildDot(int index, String currentPin) {
    bool isFilled = index < currentPin.length;
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
    final title = _isConfirming ? 'Confirm PIN' : 'Create PIN';
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.dialpad, size: 64, color: AppColors.primary.withOpacity(0.8)),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (_hasError)
              const Text('PINs do not match. Try again.', style: TextStyle(color: AppColors.error))
            else
              const SizedBox(height: 16),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDot(index, currentPin)),
            ),
            const Spacer(),
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
                      const SizedBox(width: 80), // spacer
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
