import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart';

/// Creates a new account with [email], [password], and [displayName].
@injectable
class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserProfile>> call({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
}
