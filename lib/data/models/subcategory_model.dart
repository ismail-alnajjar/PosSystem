import 'package:equatable/equatable.dart';

class SubCategory extends Equatable {
  final int id;
  final String name;
  final int categoryId;
  final String? categoryName;

  const SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }

  @override
  List<Object?> get props => [id, name, categoryId, categoryName];
}
