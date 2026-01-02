import 'package:equatable/equatable.dart';

class SalesByCategory extends Equatable {
  final int categoryId;
  final String categoryName;
  final double totalRevenue;
  final int totalQuantity;

  const SalesByCategory({
    required this.categoryId,
    required this.categoryName,
    required this.totalRevenue,
    required this.totalQuantity,
  });

  factory SalesByCategory.fromJson(Map<String, dynamic> json) {
    return SalesByCategory(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalQuantity: json['totalQuantity'] as int,
    );
  }

  @override
  List<Object?> get props => [categoryId, categoryName, totalRevenue, totalQuantity];
}

class SalesSummary extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final int totalOrders;
  final int totalItems;
  final List<SalesByCategory> salesByCategory;

  const SalesSummary({
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalOrders,
    required this.totalItems,
    required this.salesByCategory,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      totalItems: json['totalItems'] as int,
      salesByCategory: (json['salesByCategory'] as List<dynamic>)
          .map((item) => SalesByCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalSales,
        totalOrders,
        totalItems,
        salesByCategory,
      ];
}

class TopProduct extends Equatable {
  final int productId;
  final String productName;
  final int totalQuantity;
  final double totalRevenue;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      totalQuantity: json['totalQuantity'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [productId, productName, totalQuantity, totalRevenue];
}

class DailySales extends Equatable {
  final DateTime date;
  final double totalSales;
  final int orderCount;

  const DailySales({
    required this.date,
    required this.totalSales,
    required this.orderCount,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: DateTime.parse(json['date'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      orderCount: json['orderCount'] as int,
    );
  }

  @override
  List<Object?> get props => [date, totalSales, orderCount];
}
