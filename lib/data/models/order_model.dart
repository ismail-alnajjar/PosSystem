import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final int? id;
  final int productId;
  final String? productName;
  final int quantity;
  final double? unitPrice;
  final double? totalPrice;

  const OrderItem({
    this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [id, productId, productName, quantity, unitPrice, totalPrice];
}

class CreateOrderRequest extends Equatable {
  final List<OrderItem> items;

  const CreateOrderRequest({
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [items];
}

class Order extends Equatable {
  final int id;
  final DateTime orderDate;
  final double totalAmount;
  final int itemCount;
  final List<OrderItem> items; // New field

  const Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.itemCount,
    this.items = const [], // Default to empty
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItem>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((i) => OrderItem(
                id: i['id'],
                productId: i['productId'] ?? 0,
                productName: i['productName'],
                quantity: i['quantity'] ?? 0,
                unitPrice: (i['unitPrice'] as num?)?.toDouble(),
                totalPrice: (i['totalPrice'] as num?)?.toDouble(),
              ))
          .toList();
    } else if (json['orderItems'] != null) {
       // Fallback for common naming convention
       itemsList = (json['orderItems'] as List)
          .map((i) => OrderItem(
                productId: i['productId'] ?? 0,
                quantity: i['quantity'] ?? 0,
              ))
          .toList(); 
    }

    return Order(
      id: json['id'] as int,
      orderDate: DateTime.parse(json['orderDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      itemCount: json['items'] != null ? (json['items'] as List).length : (json['itemCount'] as int? ?? 0),
      items: itemsList,
    );
  }

  @override
  List<Object?> get props => [id, orderDate, totalAmount, itemCount, items];
}
