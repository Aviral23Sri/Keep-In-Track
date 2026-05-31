import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

@HiveType(typeId: AppConstants.subcategoryTypeId)
class SubcategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String categoryId;

  @HiveField(3)
  late bool isDefault;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.isDefault,
  });

  SubcategoryModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    bool? isDefault,
  }) {
    return SubcategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categoryId': categoryId,
        'isDefault': isDefault,
      };

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) =>
      SubcategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryId: json['categoryId'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}
