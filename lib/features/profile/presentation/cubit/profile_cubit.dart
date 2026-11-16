import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/auth/domain/usecases/get_current_profile_use_case.dart';
import 'package:wsidappp/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:wsidappp/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getCurrentProfileUseCase,
    this._updateProfileUseCase,
    this._deleteAccountUseCase,
  ) : super(const ProfileState.initial());

  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  Future<void> loadProfile() async {
    emit(const ProfileState.loading());
    final Either<Failure, UserProfile?> result =
        await _getCurrentProfileUseCase();
    result.fold(
      (Failure failure) => emit(ProfileState.error(message: failure.message)),
      (UserProfile? profile) => emit(
        profile != null
            ? ProfileState.loaded(profile: profile)
            : const ProfileState.error(message: 'No profile found.'),
      ),
    );
  }

  Future<bool> updateDisplayName(String displayName) async {
    final UserProfile? current = _currentProfile;
    if (current == null) return false;

    emit(ProfileState.loaded(profile: current, isSaving: true));
    final Either<Failure, UserProfile> result =
        await _updateProfileUseCase(displayName: displayName);
    return result.fold(
      (Failure failure) {
        _emitActionError(current, failure.message);
        return false;
      },
      (UserProfile updated) {
        emit(ProfileState.loaded(profile: updated));
        return true;
      },
    );
  }

  Future<void> deleteAccount() async {
    final UserProfile? current = _currentProfile;
    if (current == null) return;

    emit(ProfileState.loaded(profile: current, isSaving: true));
    final Either<Failure, void> result = await _deleteAccountUseCase();
    result.fold(
      (Failure failure) => _emitActionError(current, failure.message),
      (_) {},
    );
  }

  UserProfile? get _currentProfile => state.maybeWhen(
        loaded: (UserProfile profile, _, _) => profile,
        orElse: () => null,
      );

  void _emitActionError(UserProfile profile, String message) {
    emit(ProfileState.loaded(profile: profile, actionError: message));
    emit(ProfileState.loaded(profile: profile));
  }
}
