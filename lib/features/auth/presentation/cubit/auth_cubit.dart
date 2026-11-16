import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart';
import 'package:wsidappp/features/auth/domain/usecases/get_current_profile_use_case.dart';
import 'package:wsidappp/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:wsidappp/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:wsidappp/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
    this._getCurrentProfileUseCase,
    this._authRepository,
  ) : super(const AuthState.initial()) {
    _authStateSubscription =
        _authRepository.authStateChanges.listen((isAuthenticated) {
      if (!isAuthenticated) {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final AuthRepository _authRepository;
  StreamSubscription<bool>? _authStateSubscription;

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    final result = await _getCurrentProfileUseCase();
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (profile) {
        if (profile != null) {
          emit(AuthState.authenticated(profile: profile));
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    final result = await _signInUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (profile) => emit(AuthState.authenticated(profile: profile)),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const AuthState.loading());
    final result = await _signUpUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (profile) => emit(AuthState.authenticated(profile: profile)),
    );
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    return super.close();
  }
}
