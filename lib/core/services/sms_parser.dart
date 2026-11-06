import 'dart:convert';
import 'package:uuid/uuid.dart';

/// A transaction parsed from an Indian bank SMS.
class ParsedSmsTransaction {
  final String id;
  final double amount;
  final String type;        // 'expense' | 'income'
  final String? merchant;
  final String paymentMode; // 'upi' | 'card' | 'cash' | 'bankTransfer'
  final DateTime detectedAt;
  final String rawBody;
  final String sender;

  const ParsedSmsTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.merchant,
    required this.paymentMode,
    required this.detectedAt,
    required this.rawBody,
    required this.sender,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type,
        'merchant': merchant,
        'paymentMode': paymentMode,
        'detectedAt': detectedAt.toIso8601String(),
        'rawBody': rawBody,
        'sender': sender,
      };

  factory ParsedSmsTransaction.fromJson(Map<String, dynamic> json) =>
      ParsedSmsTransaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String,
        merchant: json['merchant'] as String?,
        paymentMode: json['paymentMode'] as String,
        detectedAt: DateTime.parse(json['detectedAt'] as String),
        rawBody: json['rawBody'] as String,
        sender: json['sender'] as String,
      );

  factory ParsedSmsTransaction.fromJsonString(String s) =>
      ParsedSmsTransaction.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}

// ─────────────────────────────────────────────────────────────────────────────

/// Parses raw SMS text from Indian banks and UPI apps into [ParsedSmsTransaction].
class SmsParser {
  SmsParser._();

  // ── Amount patterns ────────────────────────────────────────────────────────
  static final _amountRe = RegExp(
    r'(?:INR|Rs\.?|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // ── Transaction direction ──────────────────────────────────────────────────
  static final _debitRe = RegExp(
    r'\b(debited|debit|sent|paid|spent|used|withdrawn|charged|purchase|payment|transferred|dr\.?)\b',
    caseSensitive: false,
  );
  static final _creditRe = RegExp(
    r'\b(credited|credit|received|deposited|refund|cr\.?|cashback)\b',
    caseSensitive: false,
  );

  // ── Spam / OTP / promo filter — skip these ────────────────────────────────
  static final _skipRe = RegExp(
    r'\b(otp|one.?time.?password|password|login|verify|authentication|offer|discount|cashback offer|validity|recharge)\b',
    caseSensitive: false,
  );

  // ── Merchant extraction: text after these keywords ────────────────────────
  static final _merchantKeyRe = RegExp(
    r'\b(?:at|to|for|merchant|info:?|via|towards|from|tran[a-z]*:?)\s+([A-Za-z0-9][A-Za-z0-9 &.\-_/@]{2,40})',
    caseSensitive: false,
  );

  // ── Payment mode detection ─────────────────────────────────────────────────
  static final _upiRe    = RegExp(r'\b(upi|gpay|phonepe|paytm|bhim|neft/upi)\b', caseSensitive: false);
  static final _cardRe   = RegExp(r'\b(card|pos|swipe|credit card|debit card|cc|dc)\b', caseSensitive: false);
  static final _neftRe   = RegExp(r'\b(neft|rtgs|imps|bank transfer|netbanking)\b', caseSensitive: false);

  // ── Merchant clean-up: stop words to strip ────────────────────────────────
  static const _stopWords = {
    'your', 'account', 'acct', 'ac', 'no', 'is', 'has', 'been', 'the',
    'a', 'an', 'on', 'in', 'of', 'with', 'and', 'or', 'from', 'by',
    'ref', 'txn', 'id', 'number', 'upi', 'neft', 'imps', 'hdfc', 'sbi',
    'icici', 'axis', 'kotak', 'rbl', 'yes', 'bank', 'ltd', 'pvt',
  };

  /// Returns a [ParsedSmsTransaction] if [body] looks like a financial SMS,
  /// otherwise returns null.
  static ParsedSmsTransaction? parse(
    String body,
    String sender,
    DateTime timestamp,
  ) {
    // 1. Skip obvious non-financial / OTP messages
    if (_skipRe.hasMatch(body) && !_amountRe.hasMatch(body)) return null;

    // 2. Must have an amount
    final amountMatch = _amountRe.firstMatch(body);
    if (amountMatch == null) return null;

    final rawAmt = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(rawAmt);
    if (amount == null || amount <= 0) return null;

    // 3. Determine type (default = expense)
    final isCredit  = _creditRe.hasMatch(body);
    final isDebit   = _debitRe.hasMatch(body);
    if (!isCredit && !isDebit) return null; // can't determine direction

    final type = isCredit && !isDebit ? 'income' : 'expense';

    // 4. Payment mode
    final paymentMode = _upiRe.hasMatch(body)
        ? 'upi'
        : _cardRe.hasMatch(body)
            ? 'card'
            : _neftRe.hasMatch(body)
                ? 'bankTransfer'
                : 'bankTransfer'; // default for bank SMS

    // 5. Merchant name
    final merchant = _extractMerchant(body);

    return ParsedSmsTransaction(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      merchant: merchant,
      paymentMode: paymentMode,
      detectedAt: timestamp,
      rawBody: body,
      sender: sender,
    );
  }

  static String? _extractMerchant(String body) {
    // Try keyword-based extraction first
    final match = _merchantKeyRe.firstMatch(body);
    if (match != null) {
      final raw = match.group(1)?.trim() ?? '';
      final cleaned = _cleanMerchant(raw);
      if (cleaned.isNotEmpty) return cleaned;
    }

    // Fallback: look for ALL-CAPS word sequences (common in Indian bank SMS)
    final capsRe = RegExp(r'\b([A-Z][A-Z0-9 ]{3,30})\b');
    for (final m in capsRe.allMatches(body)) {
      final candidate = m.group(1)?.trim() ?? '';
      if (candidate.split(' ').length <= 5) {
        final cleaned = _cleanMerchant(candidate);
        if (cleaned.length >= 3) return cleaned;
      }
    }
    return null;
  }

  static String _cleanMerchant(String raw) {
    // Remove trailing junk like account numbers, dates
    final noDigits = raw.replaceAll(RegExp(r'\b\d{4,}\b'), '').trim();
    // Remove stop words
    final words = noDigits
        .split(RegExp(r'\s+'))
        .where((w) => !_stopWords.contains(w.toLowerCase()) && w.length > 1)
        .toList();
    return words.join(' ').trim();
  }
}
