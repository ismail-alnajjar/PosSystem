import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'product_model.dart';

class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;

  CartItem({
    String? id,
    required this.product,
    this.quantity = 1,
  }) : id = id ?? const Uuid().v4();

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => product.price * quantity;

  @override
  List<Object?> get props => [id, product, quantity];
}
