import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/core/constants/supabase_tables.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/errors/supabase_error_handler.dart';
import 'package:wsidappp/features/categories/domain/entities/category.dart';
import 'package:wsidappp/features/categories/domain/repositories/category_repository.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final data = await _supabase
          .from(SupabaseTables.categories)
          .select()
          .order('created_at');
      final categories =
          (data as List<dynamic>).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
      return right(categories);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory({
    required String name,
    String? color,
    String? icon,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return left(const AuthFailure(message: 'User not authenticated'));
      }
      final data = await _supabase
          .from(SupabaseTables.categories)
          .insert({
            'name': name,
            'color': color,
            'icon': icon,
            'user_id': currentUser.id,
          })
          .select()
          .single();
      return right(Category.fromJson(data));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await _supabase
          .from(SupabaseTables.categories)
          .delete()
          .eq('id', categoryId);
      return right(null);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }
}
