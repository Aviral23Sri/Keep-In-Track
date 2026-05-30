import 'package:flutter/material.dart';

/// Helpers for storing and rendering category colors as hex strings.
class CategoryColorUtils {
  CategoryColorUtils._();

  static String code(Color color) =>
      color.toARGB32().toRadixString(16).toUpperCase();

  static Color fromHex(String colorHex, {Color fallback = Colors.grey}) {
    var normalized = colorHex.trim().toUpperCase();
    if (normalized.startsWith('#')) {
      normalized = normalized.substring(1);
    }
    if (normalized.startsWith('0X')) {
      normalized = normalized.substring(2);
    }
    if (normalized.length == 6) {
      normalized = 'FF$normalized';
    }
    if (normalized.isEmpty) return fallback;

    try {
      return Color(int.parse(normalized, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
