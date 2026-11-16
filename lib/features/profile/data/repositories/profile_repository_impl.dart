import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/core/constants/supabase_tables.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/errors/supabase_error_handler.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/profile/domain/repositories/profile_repository.dart';

/// Supabase-backed implementation of [ProfileRepository].
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String displayName,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return left(const AuthFailure(message: 'No authenticated user found.'));
      }

      await _supabase.auth.updateUser(
        UserAttributes(data: <String, dynamic>{'display_name': displayName}),
      );

      final Map<String, dynamic> row = <String, dynamic>{
        'id': userId,
        'display_name': displayName,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      Map<String, dynamic> data;
      try {
        data = await _upsertProfile(row);
      } on PostgrestException catch (e) {
        if (e.code != _missingColumnCode) rethrow;
        data = await _upsertProfile(
          Map<String, dynamic>.of(row)..remove('updated_at'),
        );
      }

      return right(UserProfile.fromJson(data));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  /// PostgREST error raised when a column in the payload does not exist.
  static const String _missingColumnCode = 'PGRST204';

  Future<Map<String, dynamic>> _upsertProfile(Map<String, dynamic> row) =>
      _supabase
          .from(SupabaseTables.profiles)
          .upsert(row, onConflict: 'id')
          .select()
          .single();

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return left(const AuthFailure(message: 'No authenticated user found.'));
      }

      await _supabase.rpc<bool>(SupabaseTables.deleteUserAccount);

      try {
        await _supabase.auth.signOut();
      } catch (_) {
        // Session may already be invalidated on the server following account deletion.
      }

      return right(null);
    } on PostgrestException catch (e) {
      return left(handleSupabaseError(e));
    } on AuthException catch (e) {
      return left(handleSupabaseError(e));
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }
}
