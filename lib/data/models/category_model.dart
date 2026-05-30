import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

@HiveType(typeId: AppConstants.categoryTypeId)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon; // Material icon codepoint hex string

  @HiveField(3)
  late String color; // hex color e.g. 'FFFF6B6B'

  @HiveField(4)
  late String type; // 'expense' | 'income' | 'savings'

  @HiveField(5)
  late bool isDefault;

  @HiveField(6)
  late bool isHidden;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    this.isHidden = false,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? type,
    bool? isDefault,
    bool? isHidden,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'type': type,
        'isDefault': isDefault,
        'isHidden': isHidden,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        color: json['color'] as String,
        type: json['type'] as String,
        isDefault: json['isDefault'] as bool,
        isHidden: (json['isHidden'] as bool?) ?? false,
      );
}
