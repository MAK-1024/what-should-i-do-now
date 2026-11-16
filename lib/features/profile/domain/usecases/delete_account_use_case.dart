import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/profile/domain/repositories/profile_repository.dart';

/// Permanently deletes the authenticated user's account.
@injectable
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, void>> call() => _repository.deleteAccount();
}
