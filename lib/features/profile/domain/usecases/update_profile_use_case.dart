import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/profile/domain/repositories/profile_repository.dart';

/// Updates the display name of the currently authenticated user.
@injectable
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, UserProfile>> call({required String displayName}) =>
      _repository.updateProfile(displayName: displayName);
}
