import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _indianFormatNoDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 1,
  );

  /// Format as ₹1,23,456.78
  static String format(double amount, {bool showDecimal = true}) {
    return showDecimal
        ? _indianFormat.format(amount)
        : _indianFormatNoDecimal.format(amount.round());
  }

  /// Format as ₹1.2L or ₹45K (compact for small spaces)
  static String formatCompact(double amount) {
    return _compactFormat.format(amount);
  }

  /// Format just the number without symbol: 1,23,456.78
  static String formatNumber(double amount) {
    return NumberFormat('#,##,###.##', 'en_IN').format(amount);
  }

  /// Parse ₹ formatted string back to double
  static double? parse(String text) {
    try {
      final cleaned = text
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(',', '')
          .trim();
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Get sign-prefixed string: +₹500 or -₹200
  static String formatWithSign(double amount, String type) {
    final formatted = format(amount.abs());
    if (type == 'income' || type == 'savings') return '+$formatted';
    return '-$formatted';
  }
}
