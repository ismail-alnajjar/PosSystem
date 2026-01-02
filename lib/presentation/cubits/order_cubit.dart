import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/pos_repository.dart';

// State
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderInProgress extends OrderState {
  final List<CartItem> items;
  final int? editingOrderId; // If not null, we are editing this order

  const OrderInProgress({this.items = const [], this.editingOrderId});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => items.length;

  OrderInProgress copyWith({List<CartItem>? items, int? editingOrderId}) {
    return OrderInProgress(
      items: items ?? this.items,
      editingOrderId: editingOrderId ?? this.editingOrderId,
    );
  }

  @override
  List<Object?> get props => [items, editingOrderId];
}

class OrderSubmitting extends OrderState {
  final List<CartItem> items;

  const OrderSubmitting(this.items);

  @override
  List<Object?> get props => [items];
}

class OrderSubmitted extends OrderState {
  final Order order;
  final List<CartItem> items;

  const OrderSubmitted(this.order, this.items);

  @override
  List<Object?> get props => [order, items];
}

class OrderError extends OrderState {
  final String message;
  final List<CartItem> items; // Keep items so user can retry

  const OrderError(this.message, this.items);

  @override
  List<Object?> get props => [message, items];
}

// Cubit
class OrderCubit extends Cubit<OrderState> {
  final PosRepository _repository;

  OrderCubit(this._repository) : super(const OrderInitial());

  void addProduct(Product product) {
    final currentState = state;
    List<CartItem> currentItems = [];
    int? editingOrderId;

    if (currentState is OrderInProgress) {
      currentItems = currentState.items;
      editingOrderId = currentState.editingOrderId;
    } else if (currentState is OrderError) {
      currentItems = currentState.items;
      // Note: OrderError currently doesn't track editingOrderId, so it might be lost here if retrying from error.
      // Ideally OrderError should also track it, but for now we focus on the main flow.
    }

    final existingIndex = currentItems.indexWhere(
      (i) => i.product.id == product.id,
    );

    List<CartItem> newItems;
    if (existingIndex >= 0) {
      // Update quantity
      newItems = List<CartItem>.from(currentItems);
      final existingItem = newItems[existingIndex];
      newItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Add new
      final newItem = CartItem(product: product);
      newItems = [...currentItems, newItem];
    }
    
    emit(OrderInProgress(items: newItems, editingOrderId: editingOrderId));
  }

  void removeProduct(Product product) {
    final currentState = state;
    if (currentState is! OrderInProgress) return;

    final newItems = currentState.items
        .where((i) => i.product.id != product.id)
        .toList();
    
    emit(currentState.copyWith(items: newItems));
  }

  void incrementQuantity(CartItem item) {
    final currentState = state;
    if (currentState is! OrderInProgress) return;

    final index = currentState.items.indexOf(item);
    if (index == -1) return;

    final newItems = List<CartItem>.from(currentState.items);
    newItems[index] = item.copyWith(quantity: item.quantity + 1);
    
    emit(currentState.copyWith(items: newItems));
  }

  void decrementQuantity(CartItem item) {
    final currentState = state;
    if (currentState is! OrderInProgress) return;

    final index = currentState.items.indexOf(item);
    if (index == -1) return;

    if (item.quantity > 1) {
      final newItems = List<CartItem>.from(currentState.items);
      newItems[index] = item.copyWith(quantity: item.quantity - 1);
      
      emit(currentState.copyWith(items: newItems));
    }
  }

  void clearOrder() {
    emit(const OrderInitial());
  }

  /// Load an existing order for editing
  Future<void> loadOrderForEditing(Order summaryOrder) async {
    emit(const OrderInitial()); // Reset variables
    
    try {
      List<OrderItem> orderItems = summaryOrder.items;

      // If summary didn't have items (e.g. from a list that didn't include them), fetch full order
      if (orderItems.isEmpty) {
        try {
          final fullOrder = await _repository.getOrderById(summaryOrder.id);
          orderItems = fullOrder.items;
        } catch (e) {
           // If getOrderById fails (e.g. endpoint not supported), check if we can proceed
           if (orderItems.isEmpty) rethrow; 
        }
      }
      
      // Reconstruct Cart Items (fetch Product details for each item)
      List<CartItem> loadedItems = [];
      
      for (var item in orderItems) {
          try {
             final product = await _repository.getProductById(item.productId);
             loadedItems.add(CartItem(
               product: product,
               quantity: item.quantity,
               id: const Uuid().v4(),
             ));
          } catch (e) {
             print('Error loading product ${item.productId} for order edit: $e');
          }
      }
      
      emit(OrderInProgress(items: loadedItems, editingOrderId: summaryOrder.id));
      
    } catch (e) {
      emit(OrderError('فشل في تحميل تفاصيل الطلب: $e', []));
    }
  }

  /// Submit order (Create or Update)
  Future<void> submitOrder() async {
    final currentState = state;
    if (currentState is! OrderInProgress) return;

    if (currentState.items.isEmpty) {
      emit(const OrderError('لا يمكن إرسال طلب فارغ', []));
      return;
    }

    emit(OrderSubmitting(currentState.items));

    try {
      // Convert CartItems to OrderItems
      final orderItems = currentState.items.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          quantity: cartItem.quantity,
        );
      }).toList();

      final request = CreateOrderRequest(items: orderItems);
      
      Order order;
      if (currentState.editingOrderId != null) {
        // Update existing order
        await _repository.updateOrder(currentState.editingOrderId!, request);
        // We might not get the updated order back from PUT, so we might need to fetch it or just construct it.
        // For simplicity, let's assume successful update and just refetch or use what we have + ID.
        // Actually, let's fetch it to be safe and get updated totals.
        order = await _repository.getOrderById(currentState.editingOrderId!);
      } else {
        // Create new order
        order = await _repository.createOrder(request);
      }

      // Pass the original cart items along with the created order
      emit(OrderSubmitted(order, currentState.items));
    } catch (e) {
      emit(
        OrderError('فشل في إرسال الطلب: ${e.toString()}', currentState.items),
      );
    }
  }

  /// Start a new order after successful submission
  void startNewOrder() {
    emit(const OrderInitial());
  }
}
