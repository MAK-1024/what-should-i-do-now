import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/categories/domain/repositories/category_repository.dart';

/// Permanently deletes the category identified by [categoryId].
@injectable
class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, void>> call(String categoryId) =>
      _repository.deleteCategory(categoryId);
}
