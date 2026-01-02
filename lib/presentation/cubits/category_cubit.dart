import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';
import '../../data/models/subcategory_model.dart';
import '../../data/repositories/pos_repository.dart';

// State
abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final Category? selectedCategory;
  final List<SubCategory> subCategories;
  final SubCategory? selectedSubCategory;

  const CategoryLoaded({
    required this.categories,
    this.selectedCategory,
    this.subCategories = const [],
    this.selectedSubCategory,
  });

  CategoryLoaded copyWith({
    List<Category>? categories,
    Category? selectedCategory,
    List<SubCategory>? subCategories,
    SubCategory? selectedSubCategory,
    bool clearSelectedCategory = false,
    bool clearSelectedSubCategory = false,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      subCategories: subCategories ?? this.subCategories,
      selectedSubCategory: clearSelectedSubCategory ? null : (selectedSubCategory ?? this.selectedSubCategory),
    );
  }

  @override
  List<Object?> get props => [categories, selectedCategory, subCategories, selectedSubCategory];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class CategoryCubit extends Cubit<CategoryState> {
  final PosRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoryLoaded(categories: categories));
      
      // Select first category by default if available
      if (categories.isNotEmpty) {
        selectCategory(categories.first);
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> selectCategory(Category category) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    try {
      // Load subcategories for this category
      final subCategories = await _repository.getSubCategoriesByCategory(category.id);
      
      // Add 'All' option if there are subcategories
      if (subCategories.isNotEmpty) {
        subCategories.insert(0, SubCategory(
          id: -1, 
          name: 'الكل', 
          categoryId: category.id,
          categoryName: category.name
        ));
      }

      emit(currentState.copyWith(
        selectedCategory: category,
        subCategories: subCategories,
        selectedSubCategory: subCategories.isNotEmpty ? subCategories.first : null,
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void selectSubCategory(SubCategory? subCategory) {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    emit(currentState.copyWith(
      selectedSubCategory: subCategory,
      clearSelectedSubCategory: subCategory == null,
    ));
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    emit(currentState.copyWith(
      clearSelectedCategory: true,
      clearSelectedSubCategory: true,
      subCategories: [],
    ));
  }
}

