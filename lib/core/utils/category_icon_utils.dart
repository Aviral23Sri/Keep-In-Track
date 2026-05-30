import 'package:flutter/material.dart';

/// Helpers for storing and rendering category Material icons.
class CategoryIconUtils {
  CategoryIconUtils._();

  static String code(IconData icon) => icon.codePoint.toRadixString(16);

  static IconData fromHex(String iconHex, {IconData fallback = Icons.category}) {
    final normalized = iconHex.trim().toLowerCase().replaceFirst('0x', '');
    if (normalized.isEmpty) return fallback;

    try {
      return IconData(
        int.parse(normalized, radix: 16),
        fontFamily: 'MaterialIcons',
      );
    } catch (_) {
      return fallback;
    }
  }
}
