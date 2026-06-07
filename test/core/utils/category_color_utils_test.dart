import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keep_in_track/core/utils/category_color_utils.dart';

void main() {
  group('CategoryColorUtils', () {
    test('fromHex parses standard RRGGBB strings correctly', () {
      final color = CategoryColorUtils.fromHex('FF0000');
      expect(color.value, const Color(0xFFFF0000).value);
    });

    test('fromHex handles # prefix', () {
      final color = CategoryColorUtils.fromHex('#00FF00');
      expect(color.value, const Color(0xFF00FF00).value);
    });

    test('fromHex parses AARRGGBB correctly', () {
      final color = CategoryColorUtils.fromHex('800000FF');
      expect(color.value, const Color(0x800000FF).value);
    });

    test('code returns AARRGGBB hex string', () {
      final color = const Color(0xFF123456);
      expect(CategoryColorUtils.code(color), 'FF123456');
    });

  });
}
