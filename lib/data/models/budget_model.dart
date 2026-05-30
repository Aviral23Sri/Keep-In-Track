import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

@HiveType(typeId: AppConstants.budgetTypeId)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String? categoryId; // null = overall monthly budget

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late int month; // 1–12

  @HiveField(4)
  late int year;

  BudgetModel({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  bool get isOverall => categoryId == null;

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? month,
    int? year,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'amount': amount,
        'month': month,
        'year': year,
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String?,
        amount: (json['amount'] as num).toDouble(),
        month: json['month'] as int,
        year: json['year'] as int,
      );
}
