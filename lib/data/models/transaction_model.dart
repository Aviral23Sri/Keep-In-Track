import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
@HiveType(typeId: AppConstants.transactionTypeId)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String type; // 'expense' | 'income' | 'savings'

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  String? title;

  @HiveField(5)
  String? note;

  @HiveField(6)
  late DateTime date;

  @HiveField(7)
  late String paymentMode; // 'cash' | 'upi' | 'card' | 'bankTransfer' | 'other'

  @HiveField(8)
  late bool isRecurring;

  @HiveField(9)
  String? recurringFrequency; // 'daily' | 'weekly' | 'monthly' | 'yearly'

  @HiveField(10)
  DateTime? recurringEndDate;

  @HiveField(11)
  late DateTime createdAt;

  @HiveField(12)
  String? merchantName;

  // NEW fields (backward-compatible — null for old records)
  @HiveField(13)
  String? subcategoryId;

  @HiveField(14)
  String? bankRefNumber;

  @HiveField(15)
  bool importedFromBank;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.title,
    this.note,
    required this.date,
    required this.paymentMode,
    required this.isRecurring,
    this.recurringFrequency,
    this.recurringEndDate,
    required this.createdAt,
    this.merchantName,
    this.subcategoryId,
    this.bankRefNumber,
    this.importedFromBank = false,
  });

  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? categoryId,
    String? title,
    String? note,
    DateTime? date,
    String? paymentMode,
    bool? isRecurring,
    String? recurringFrequency,
    DateTime? recurringEndDate,
    DateTime? createdAt,
    String? merchantName,
    String? subcategoryId,
    String? bankRefNumber,
    bool? importedFromBank,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      createdAt: createdAt ?? this.createdAt,
      merchantName: merchantName ?? this.merchantName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      bankRefNumber: bankRefNumber ?? this.bankRefNumber,
      importedFromBank: importedFromBank ?? this.importedFromBank,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'categoryId': categoryId,
        'title': title,
        'note': note,
        'date': date.toIso8601String(),
        'paymentMode': paymentMode,
        'isRecurring': isRecurring,
        'recurringFrequency': recurringFrequency,
        'recurringEndDate': recurringEndDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'merchantName': merchantName,
        'subcategoryId': subcategoryId,
        'bankRefNumber': bankRefNumber,
        'importedFromBank': importedFromBank,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        title: json['title'] as String?,
        note: json['note'] as String?,
        date: DateTime.parse(json['date'] as String),
        paymentMode: json['paymentMode'] as String,
        isRecurring: json['isRecurring'] as bool,
        recurringFrequency: json['recurringFrequency'] as String?,
        recurringEndDate: json['recurringEndDate'] != null
            ? DateTime.parse(json['recurringEndDate'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        merchantName: json['merchantName'] as String?,
        subcategoryId: json['subcategoryId'] as String?,
        bankRefNumber: json['bankRefNumber'] as String?,
        importedFromBank: json['importedFromBank'] as bool? ?? false,
      );
}

