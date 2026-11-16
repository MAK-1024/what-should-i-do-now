import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/domain/repositories/category_repository.dart';

/// Creates a new category with the given [name], and optional [color] / [icon].
@injectable
class CreateCategoryUseCase {
  const CreateCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, Category>> call({
    required String name,
    String? color,
    String? icon,
  }) =>
      _repository.createCategory(name: name, color: color, icon: icon);
}
