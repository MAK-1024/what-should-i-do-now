import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart';

/// Returns the [UserProfile] for the active session, or `null` if signed out.
@injectable
class GetCurrentProfileUseCase {
  const GetCurrentProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserProfile?>> call() =>
      _repository.getCurrentProfile();
}
