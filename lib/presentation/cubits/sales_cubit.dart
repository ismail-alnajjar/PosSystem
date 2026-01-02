import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/sales_model.dart';
import '../../data/repositories/pos_repository.dart';

// State
abstract class SalesState extends Equatable {
  const SalesState();
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final SalesSummary? summary;
  final List<TopProduct> topProducts;
  final List<DailySales> dailySales;

  const SalesLoaded({
    this.summary,
    this.topProducts = const [],
    this.dailySales = const [],
  });

  SalesLoaded copyWith({
    SalesSummary? summary,
    List<TopProduct>? topProducts,
    List<DailySales>? dailySales,
  }) {
    return SalesLoaded(
      summary: summary ?? this.summary,
      topProducts: topProducts ?? this.topProducts,
      dailySales: dailySales ?? this.dailySales,
    );
  }

  @override
  List<Object?> get props => [summary, topProducts, dailySales];
}

class SalesError extends SalesState {
  final String message;

  const SalesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SalesCubit extends Cubit<SalesState> {
  final PosRepository _repository;

  SalesCubit(this._repository) : super(SalesInitial());

  /// Load all sales analytics data
  Future<void> loadSalesData({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    int topProductsLimit = 10,
    int dailySalesDays = 7,
  }) async {
    emit(SalesLoading());
    
    try {
      // Default to last 30 days if not specified
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      // Load all data in parallel
      final results = await Future.wait([
        _repository.getSalesSummary(
          startDate: start,
          endDate: end,
          categoryId: categoryId,
        ),
        _repository.getTopProducts(
          limit: topProductsLimit,
          categoryId: categoryId,
        ),
        _repository.getDailySales(days: dailySalesDays),
      ]);

      emit(SalesLoaded(
        summary: results[0] as SalesSummary,
        topProducts: results[1] as List<TopProduct>,
        dailySales: results[2] as List<DailySales>,
      ));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Load only summary
  Future<void> loadSummary({
    required DateTime startDate,
    required DateTime endDate,
    int? categoryId,
  }) async {
    emit(SalesLoading());
    
    try {
      final summary = await _repository.getSalesSummary(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
      );

      final currentState = state;
      if (currentState is SalesLoaded) {
        emit(currentState.copyWith(summary: summary));
      } else {
        emit(SalesLoaded(summary: summary));
      }
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Load only top products
  Future<void> loadTopProducts({
    int limit = 10,
    int? categoryId,
  }) async {
    try {
      final topProducts = await _repository.getTopProducts(
        limit: limit,
        categoryId: categoryId,
      );

      final currentState = state;
      if (currentState is SalesLoaded) {
        emit(currentState.copyWith(topProducts: topProducts));
      } else {
        emit(SalesLoaded(topProducts: topProducts));
      }
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Load only daily sales
  Future<void> loadDailySales({int days = 7}) async {
    try {
      final dailySales = await _repository.getDailySales(days: days);

      final currentState = state;
      if (currentState is SalesLoaded) {
        emit(currentState.copyWith(dailySales: dailySales));
      } else {
        emit(SalesLoaded(dailySales: dailySales));
      }
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadSalesData();
  }
}
