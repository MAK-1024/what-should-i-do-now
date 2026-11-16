import 'package:fpdart/fpdart.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';

/// Contract for CRUD operations on task categories.
///
/// Implementations live in `features/categories/data/repositories/`.
/// No Supabase or UI imports are permitted in this file.
abstract interface class CategoryRepository {
  /// Returns all categories belonging to the authenticated user.
  Future<Either<Failure, List<Category>>> getCategories();

  /// Creates a new category and returns the persisted [Category].
  Future<Either<Failure, Category>> createCategory({
    required String name,
    String? color,
    String? icon,
  });

  /// Permanently deletes the category identified by [categoryId].
  Future<Either<Failure, void>> deleteCategory(String categoryId);
}
