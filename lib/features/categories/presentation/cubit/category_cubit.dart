import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/domain/usecases/create_category_use_case.dart';
import 'package:wsidappp/features/categories/domain/usecases/delete_category_use_case.dart';
import 'package:wsidappp/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:wsidappp/features/categories/presentation/cubit/category_state.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(
    this._getCategoriesUseCase,
    this._createCategoryUseCase,
    this._deleteCategoryUseCase,
  ) : super(const CategoryState.initial());

  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  Future<void> loadCategories() async {
    emit(const CategoryState.loading());
    final result = await _getCategoriesUseCase();
    result.fold(
      (failure) => emit(CategoryState.error(message: failure.message)),
      (categories) => emit(
        CategoryState.loaded(
          categories: categories,
          selectedCategory: null,
        ),
      ),
    );
  }

  void selectCategory(Category? category) {
    state.mapOrNull(
      loaded: (loadedState) {
        emit(loadedState.copyWith(selectedCategory: category));
      },
    );
  }

  Future<void> createCategory({
    required String name,
    String? color,
    String? icon,
  }) async {
    emit(const CategoryState.loading());
    final result = await _createCategoryUseCase(
      name: name,
      color: color,
      icon: icon,
    );
    await result.fold(
      (failure) async => emit(CategoryState.error(message: failure.message)),
      (_) async => loadCategories(),
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    emit(const CategoryState.loading());
    final result = await _deleteCategoryUseCase(categoryId);
    await result.fold(
      (failure) async => emit(CategoryState.error(message: failure.message)),
      (_) async => loadCategories(),
    );
  }
}
