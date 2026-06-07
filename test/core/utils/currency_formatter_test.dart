import 'package:flutter_test/flutter_test.dart';
import 'package:keep_in_track/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('format returns full currency format', () {
      expect(CurrencyFormatter.format(1234.56), '₹1,234.56');
      expect(CurrencyFormatter.format(0), '₹0.00');
      expect(CurrencyFormatter.format(-50.0), '-₹50.00');
    });

    test('formatCompact returns K and L/Cr notations', () {
      expect(CurrencyFormatter.formatCompact(500), '₹500');
      expect(CurrencyFormatter.formatCompact(1500), '₹1.5K');
      expect(CurrencyFormatter.formatCompact(1500000), '₹15L');
      expect(CurrencyFormatter.formatCompact(-2500), '-₹2.5K');
    });

    test('formatNumber strips symbol', () {
      expect(CurrencyFormatter.formatNumber(1234.56), '1,234.56');
    });
  });
}
