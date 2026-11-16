import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart';

/// Signs an existing user in with [email] and [password].
@injectable
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserProfile>> call({
    required String email,
    required String password,
  }) =>
      _repository.signIn(email: email, password: password);
}
