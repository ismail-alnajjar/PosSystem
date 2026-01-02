import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imagePath;
  final int categoryId;
  final String? categoryName;
  final int? subCategoryId;
  final String? subCategoryName;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imagePath,
    required this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.isAvailable = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String?,
      subCategoryId: json['subCategoryId'] as int?,
      subCategoryName: json['subCategoryName'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'isAvailable': isAvailable,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        description,
        imagePath,
        categoryId,
        categoryName,
        subCategoryId,
        subCategoryName,
        isAvailable,
      ];
}

