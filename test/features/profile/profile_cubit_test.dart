import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:wsidappp/core/errors/failure.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart';
import 'package:wsidappp/features/auth/domain/usecases/get_current_profile_use_case.dart';
import 'package:wsidappp/features/profile/domain/repositories/profile_repository.dart';
import 'package:wsidappp/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:wsidappp/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:wsidappp/features/profile/presentation/cubit/profile_state.dart';

final UserProfile _profile = UserProfile(
  id: 'user-1',
  displayName: 'Old Name',
  createdAt: DateTime.utc(2026),
);

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, UserProfile?>> getCurrentProfile() async =>
      right(_profile);

  @override
  Stream<bool> get authStateChanges => const Stream<bool>.empty();

  @override
  Future<Either<Failure, UserProfile>> signIn({
    required String email,
    required String password,
  }) async =>
      right(_profile);

  @override
  Future<Either<Failure, void>> signOut() async => right(null);

  @override
  Future<Either<Failure, UserProfile>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async =>
      right(_profile);
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.failUpdate = false});

  final bool failUpdate;

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String displayName,
  }) async =>
      failUpdate
          ? left(const ServerFailure(message: 'update failed'))
          : right(_profile.copyWith(displayName: displayName));

  @override
  Future<Either<Failure, void>> deleteAccount() async => right(null);
}

ProfileCubit _buildCubit({bool failUpdate = false}) {
  final _FakeProfileRepository profileRepository =
      _FakeProfileRepository(failUpdate: failUpdate);
  return ProfileCubit(
    GetCurrentProfileUseCase(_FakeAuthRepository()),
    UpdateProfileUseCase(profileRepository),
    DeleteAccountUseCase(profileRepository),
  );
}

void main() {
  group('ProfileCubit.updateDisplayName', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits saving then the updated profile on success',
      build: _buildCubit,
      seed: () => ProfileState.loaded(profile: _profile),
      act: (ProfileCubit cubit) => cubit.updateDisplayName('New Name'),
      expect: () => <ProfileState>[
        ProfileState.loaded(profile: _profile, isSaving: true),
        ProfileState.loaded(
          profile: _profile.copyWith(displayName: 'New Name'),
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'keeps the loaded profile and signals a one-shot error on failure',
      build: () => _buildCubit(failUpdate: true),
      seed: () => ProfileState.loaded(profile: _profile),
      act: (ProfileCubit cubit) => cubit.updateDisplayName('New Name'),
      expect: () => <ProfileState>[
        ProfileState.loaded(profile: _profile, isSaving: true),
        ProfileState.loaded(profile: _profile, actionError: 'update failed'),
        ProfileState.loaded(profile: _profile),
      ],
    );
  });
}
