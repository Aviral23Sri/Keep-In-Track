import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../data/models/merchant_model.dart';
import 'parsed_transaction.dart';

/// Parses SBI bank statement PDFs and returns a list of [ParsedTransaction].
class SbiParser {
  final List<MerchantModel> merchants;

  SbiParser({required this.merchants});

  /// Main entry point: pass raw PDF bytes, get back parsed transactions.
  Future<List<ParsedTransaction>> parse(List<int> pdfBytes) async {
    // Step 1: Extract text from all PDF pages
    final text = _extractText(pdfBytes);

    // Step 2: Parse rows
    final rows = _parseRows(text);

    // Step 3: Match merchants and assign categories
    return rows.map((row) => _assignCategory(row)).toList();
  }

  // ── PDF Text Extraction ────────────────────────────────────────────────────

  String _extractText(List<int> pdfBytes) {
    final document = PdfDocument(inputBytes: pdfBytes);
    final buffer = StringBuffer();
    for (int i = 0; i < document.pages.count; i++) {
      buffer.write(
        PdfTextExtractor(document).extractText(
          startPageIndex: i,
          endPageIndex: i,
        ),
      );
      buffer.write('\n');
    }
    document.dispose();
    return buffer.toString();
  }

  // ── Row Parsing ────────────────────────────────────────────────────────────

  static final _datePattern = RegExp(r'(\d{2}/\d{2}/\d{4})');
  // Matches: date  date  description  debit?  credit?  balance
  // SBI format has tab-separated or whitespace-aligned columns
  static final _rowPattern = RegExp(
    r'(\d{2}/\d{2}/\d{4})\s+(\d{2}/\d{2}/\d{4})\s+(.+?)\s+([\d,]+\.\d{2})?\s*-?\s*([\d,]+\.\d{2})?\s*-?\s*([\d,]+\.\d{2})',
    multiLine: true,
  );

  List<_RawRow> _parseRows(String text) {
    final rows = <_RawRow>[];
    double? previousBalance;

    // Try structured row matching first
    for (final match in _rowPattern.allMatches(text)) {
      try {
        final txnDate = _parseDate(match.group(1)!);
        final description = match.group(3)!.trim();
        
        final amounts = <double>[];
        for (int i = 4; i <= 6; i++) {
          final str = match.group(i);
          if (str != null) {
            amounts.add(double.parse(str.replaceAll(',', '')));
          }
        }

        if (amounts.length < 2) continue;

        final currentBalance = amounts.last;
        final amount = amounts.first;

        double? debit;
        double? credit;

        if (previousBalance != null) {
          if (currentBalance > previousBalance) {
            credit = amount;
          } else {
            debit = amount;
          }
        } else {
          // First row fallback
          if (description.contains('/CR') || description.contains('CDM') || description.contains('Self Transfer') || description.contains('Refund')) {
            credit = amount;
          } else {
            debit = amount;
          }
        }

        previousBalance = currentBalance;

        rows.add(_RawRow(
          date: txnDate,
          description: description,
          debit: debit,
          credit: credit,
        ));
      } catch (_) {
        continue;
      }
    }

    // Fallback: line-by-line parsing if structured parse got nothing
    if (rows.isEmpty) {
      rows.addAll(_parseLineByLine(text));
    }

    return rows;
  }

  List<_RawRow> _parseLineByLine(String text) {
    final rows = <_RawRow>[];
    final lines = text.split('\n');
    double? previousBalance;

    for (final line in lines) {
      if (!_datePattern.hasMatch(line)) continue;
      final parts = line.trim().split(RegExp(r'\s{2,}|\t'));
      if (parts.length < 4) continue;

      try {
        final date = _parseDate(parts[0].trim());
        final description = parts[2].trim();

        final amountPattern = RegExp(r'[\d,]+\.\d{2}');
        final amounts = parts
            .skip(3)
            .where((p) => amountPattern.hasMatch(p.trim()))
            .map((p) => double.tryParse(p.trim().replaceAll(',', '')))
            .whereType<double>()
            .toList();

        if (amounts.length < 2) continue;

        final currentBalance = amounts.last;
        final amount = amounts.first;

        double? debit;
        double? credit;

        if (previousBalance != null) {
          if (currentBalance > previousBalance) {
            credit = amount;
          } else {
            debit = amount;
          }
        } else {
          if (description.contains('/CR') || description.contains('CDM') || description.contains('Self Transfer') || description.contains('Refund')) {
            credit = amount;
          } else {
            debit = amount;
          }
        }

        previousBalance = currentBalance;

        rows.add(_RawRow(
          date: date,
          description: description,
          debit: debit,
          credit: credit,
        ));
      } catch (_) {
        continue;
      }
    }
    return rows;
  }

  DateTime _parseDate(String s) {
    // DD/MM/YYYY
    final parts = s.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  // ── UPI Description Parsing ────────────────────────────────────────────────

  _ParsedDescription _parseDescription(String description) {
    // UPI format: UPI/DR/123456789012/MERCHANT/BANKCODE/upiid@bank/note
    if (description.startsWith('UPI/')) {
      final parts = description.split('/');
      if (parts.length >= 4) {
        final merchantName = parts[3].trim();
        final refNumber = parts.length >= 3 ? parts[2].trim() : null;
        return _ParsedDescription(
          merchantName: merchantName,
          note: null,
          refNumber: refNumber,
        );
      }
    }

    // NEFT/IMPS/other: use first meaningful word
    return _ParsedDescription(
      merchantName: description.split(RegExp(r'\s+|/'))[0].trim(),
      note: null,
      refNumber: null,
    );
  }

  // ── Category Assignment ────────────────────────────────────────────────────

  ParsedTransaction _assignCategory(_RawRow row) {
    final parsed = _parseDescription(row.description);
    final isDebit = (row.debit ?? 0) > 0;
    final amount = isDebit ? (row.debit ?? 0) : (row.credit ?? 0);

    // Try to match merchant
    final matchedMerchant = _findMerchant(parsed.merchantName);

    String categoryId;
    String? subcategoryId;
    String type;
    bool needsReview = false;

    if (matchedMerchant != null) {
      categoryId = matchedMerchant.categoryId;
      subcategoryId = matchedMerchant.subcategoryId;
      type = isDebit ? 'expense' : 'income';
      if (categoryId == 'cat_misc_expense') {
        needsReview = true;
      }
    } else {
      // Default fallback
      categoryId = isDebit ? 'cat_misc_expense' : 'cat_other_income';
      subcategoryId = null;
      type = isDebit ? 'expense' : 'income';
      needsReview = true;
    }

    return ParsedTransaction(
      description: row.description,
      merchantName: parsed.merchantName,
      note: parsed.note,
      amount: amount,
      isDebit: isDebit,
      date: row.date,
      bankRefNumber: parsed.refNumber,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      type: type,
      isSelected: true,
      needsReview: needsReview,
    );
  }

  MerchantModel? _findMerchant(String merchantName) {
    if (merchantName.isEmpty) return null;
    final lower = merchantName.toLowerCase();

    // Exact match first
    for (final m in merchants) {
      for (final variant in m.nameVariants) {
        if (variant.toLowerCase() == lower) return m;
      }
    }

    // Prefix match
    for (final m in merchants) {
      for (final variant in m.nameVariants) {
        final varLower = variant.toLowerCase();
        if (lower.startsWith(varLower) || varLower.startsWith(lower)) {
          return m;
        }
      }
    }

    // Contains match (last resort)
    for (final m in merchants) {
      for (final variant in m.nameVariants) {
        final varLower = variant.toLowerCase();
        if (lower.contains(varLower) || varLower.contains(lower)) {
          return m;
        }
      }
    }

    return null;
  }
}

class _RawRow {
  final DateTime date;
  final String description;
  final double? debit;
  final double? credit;

  _RawRow({
    required this.date,
    required this.description,
    this.debit,
    this.credit,
  });
}

class _ParsedDescription {
  final String merchantName;
  final String? note;
  final String? refNumber;

  _ParsedDescription({
    required this.merchantName,
    this.note,
    this.refNumber,
  });
}
