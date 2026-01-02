import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/pos_repository.dart';

// State
abstract class OrdersHistoryState extends Equatable {
  const OrdersHistoryState();
  @override
  List<Object?> get props => [];
}

class OrdersHistoryInitial extends OrdersHistoryState {}

class OrdersHistoryLoading extends OrdersHistoryState {}

class OrdersHistoryLoaded extends OrdersHistoryState {
  final List<Order> orders;
  const OrdersHistoryLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrdersHistoryError extends OrdersHistoryState {
  final String message;
  const OrdersHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class OrdersHistoryCubit extends Cubit<OrdersHistoryState> {
  final PosRepository _repository;

  OrdersHistoryCubit(this._repository) : super(OrdersHistoryInitial());

  Future<void> loadOrders() async {
    emit(OrdersHistoryLoading());
    try {
      final orders = await _repository.getAllOrders();
      // Sort by date descending (newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      emit(OrdersHistoryLoaded(orders));
    } catch (e) {
      emit(OrdersHistoryError(e.toString()));
    }
  }
}
