/// Parsed transaction from bank statement — temporary model used during import review.
class ParsedTransaction {
  final String description;
  final String merchantName;
  final String? note;
  final double amount;
  final bool isDebit; // true = expense, false = income/credit
  final DateTime date;
  final String? bankRefNumber;

  // Assigned category/subcategory (can be edited by user)
  String categoryId;
  String? subcategoryId;
  String type; // 'expense' | 'income'

  // UI state
  bool isSelected; // will be imported
  bool needsReview; // couldn't auto-match

  ParsedTransaction({
    required this.description,
    required this.merchantName,
    this.note,
    required this.amount,
    required this.isDebit,
    required this.date,
    this.bankRefNumber,
    required this.categoryId,
    this.subcategoryId,
    required this.type,
    this.isSelected = true,
    this.needsReview = false,
  });

  ParsedTransaction copyWith({
    String? categoryId,
    String? subcategoryId,
    String? type,
    String? note,
    bool? isSelected,
    bool? needsReview,
  }) {
    return ParsedTransaction(
      description: description,
      merchantName: merchantName,
      note: note ?? this.note,
      amount: amount,
      isDebit: isDebit,
      date: date,
      bankRefNumber: bankRefNumber,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      needsReview: needsReview ?? this.needsReview,
    );
  }
}
