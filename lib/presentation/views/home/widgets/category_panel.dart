import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/constants/app_colors.dart';
import 'package:pos/presentation/cubits/category_cubit.dart';
import 'package:pos/presentation/cubits/products_cubit.dart';

class CategoryPanel extends StatelessWidget {
  const CategoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CategoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text(state.message),
                ElevatedButton(
                  onPressed: () {
                    context.read<CategoryCubit>().loadCategories();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is! CategoryLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // Main Categories
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isSelected = category == state.selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      context.read<CategoryCubit>().selectCategory(category);
                      // Filter products by category
                      context.read<ProductsCubit>().filterByCategory(
                        category.id,
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Sub Categories
            if (state.subCategories.isNotEmpty)
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.subCategories.length,
                  itemBuilder: (context, index) {
                    final subCat = state.subCategories[index];
                    final isSelected = subCat == state.selectedSubCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(subCat.name),
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        onPressed: () {
                          context.read<CategoryCubit>().selectSubCategory(
                            subCat,
                          );
                          // Filter products based on selection
                          if (subCat.id == -1) {
                            // "All" selected -> Show all products for the category
                            context.read<ProductsCubit>().filterByCategory(
                              subCat.categoryId,
                            );
                          } else {
                            // Specific subcategory selected
                            context.read<ProductsCubit>().filterBySubCategory(
                              subCat.id,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
