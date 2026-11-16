import 'package:fpdart/fpdart.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';

/// Contract for all authentication operations.
///
/// Implementations live in `features/auth/data/repositories/`.
/// No Supabase or UI imports are permitted in this file.
abstract interface class AuthRepository {
  /// Creates a new account and returns the resulting [UserProfile].
  Future<Either<Failure, UserProfile>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs in with email and password, returning the user's [UserProfile].
  Future<Either<Failure, UserProfile>> signIn({
    required String email,
    required String password,
  });

  /// Signs the current user out.
  Future<Either<Failure, void>> signOut();

  /// Returns the [UserProfile] for the currently authenticated user,
  /// or `null` when no session is active.
  Future<Either<Failure, UserProfile?>> getCurrentProfile();

  /// Emits `true` when a valid session exists, `false` on sign-out.
  Stream<bool> get authStateChanges;
}
