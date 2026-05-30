import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

@HiveType(typeId: AppConstants.merchantTypeId)
class MerchantModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late List<String> nameVariants;

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  double? typicalAmount;

  @HiveField(5)
  String? paymentMode;

  @HiveField(6)
  late bool isDefault;

  @HiveField(7)
  late int usageCount;

  @HiveField(8)
  DateTime? lastUsed;

  MerchantModel({
    required this.id,
    required this.name,
    required this.nameVariants,
    required this.categoryId,
    this.typicalAmount,
    this.paymentMode,
    required this.isDefault,
    this.usageCount = 0,
    this.lastUsed,
  });

  MerchantModel copyWith({
    String? id,
    String? name,
    List<String>? nameVariants,
    String? categoryId,
    double? typicalAmount,
    String? paymentMode,
    bool? isDefault,
    int? usageCount,
    DateTime? lastUsed,
  }) {
    return MerchantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameVariants: nameVariants ?? this.nameVariants,
      categoryId: categoryId ?? this.categoryId,
      typicalAmount: typicalAmount ?? this.typicalAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      isDefault: isDefault ?? this.isDefault,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameVariants': nameVariants,
        'categoryId': categoryId,
        'typicalAmount': typicalAmount,
        'paymentMode': paymentMode,
        'isDefault': isDefault,
        'usageCount': usageCount,
        'lastUsed': lastUsed?.toIso8601String(),
      };

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
        id: json['id'] as String,
        name: json['name'] as String,
        nameVariants: List<String>.from(json['nameVariants'] as List),
        categoryId: json['categoryId'] as String,
        typicalAmount: (json['typicalAmount'] as num?)?.toDouble(),
        paymentMode: json['paymentMode'] as String?,
        isDefault: json['isDefault'] as bool,
        usageCount: (json['usageCount'] as int?) ?? 0,
        lastUsed: json['lastUsed'] != null
            ? DateTime.parse(json['lastUsed'] as String)
            : null,
      );
}
