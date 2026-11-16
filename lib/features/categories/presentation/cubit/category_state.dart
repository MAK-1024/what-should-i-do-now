import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';

part 'category_state.freezed.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState.initial() = _Initial;
  const factory CategoryState.loading() = _Loading;
  const factory CategoryState.loaded({
    required List<Category> categories,
    Category? selectedCategory,
  }) = _Loaded;
  const factory CategoryState.error({required String message}) = _Error;
}
