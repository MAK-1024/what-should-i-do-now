import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/domain/repositories/category_repository.dart';

/// Returns all categories belonging to the authenticated user.
@injectable
class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, List<Category>>> call() =>
      _repository.getCategories();
}
