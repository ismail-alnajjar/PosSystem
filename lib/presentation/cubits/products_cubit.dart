import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/pos_repository.dart';

// State
abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  
  const ProductsLoaded(this.products);
  
  @override
  List<Object> get props => [products];
}

class ProductsError extends ProductsState {
  final String message;
  
  const ProductsError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Cubit
class ProductsCubit extends Cubit<ProductsState> {
  final PosRepository _repository;
  List<Product> _allProducts = [];

  ProductsCubit(this._repository) : super(ProductsInitial()) {
    loadAllProducts();
  }

  Future<void> loadAllProducts() async {
    emit(ProductsLoading());
    try {
      _allProducts = await _repository.getProducts();
      emit(ProductsLoaded(_allProducts));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> filterByCategory(int categoryId) async {
    emit(ProductsLoading());
    try {
      final filtered = await _repository.getProductsByCategory(categoryId);
      emit(ProductsLoaded(filtered));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> filterBySubCategory(int subCategoryId) async {
    emit(ProductsLoading());
    try {
      final filtered = await _repository.getProductsBySubCategory(subCategoryId);
      emit(ProductsLoaded(filtered));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void showAllProducts() {
    emit(ProductsLoaded(_allProducts));
  }
}

