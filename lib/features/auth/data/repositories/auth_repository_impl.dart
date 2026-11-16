import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/core/constants/supabase_tables.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/core/errors/supabase_error_handler.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart';

/// Supabase-backed implementation of [AuthRepository].
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Fetches the profile row for [userId] from [SupabaseTables.profiles].
  Future<UserProfile> _fetchProfile(String userId) async {
    final data = await _supabase
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(data);
  }

  // ── AuthRepository ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserProfile>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      if (response.user == null) {
        return left(const AuthFailure(message: 'Sign-up failed: no user returned.'));
      }
      final profile = await _fetchProfile(response.user!.id);
      return right(profile);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return left(const AuthFailure(message: 'Sign-in failed: no user returned.'));
      }
      final profile = await _fetchProfile(response.user!.id);
      return right(profile);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return right(null);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getCurrentProfile() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return right(null);
      final profile = await _fetchProfile(currentUser.id);
      return right(profile);
    } catch (e) {
      return left(handleSupabaseError(e));
    }
  }

  @override
  Stream<bool> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((data) => data.session != null);
}
