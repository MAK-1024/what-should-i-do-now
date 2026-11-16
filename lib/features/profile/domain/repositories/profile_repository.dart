import 'package:fpdart/fpdart.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';

/// Domain contract for profile-related operations.
abstract interface class ProfileRepository {
  /// Updates the [displayName] of the currently authenticated user.
  ///
  /// Returns the updated [UserProfile] on success, or a [Failure] on error.
  Future<Either<Failure, UserProfile>> updateProfile({
    required String displayName,
  });

  /// Permanently deletes the authenticated user's account and signs them out.
  Future<Either<Failure, void>> deleteAccount();
}
