import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wsidappp/features/auth/domain/entities/user_profile.dart';

part 'profile_state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;

  /// [actionError] is a one-shot signal for mutation failures; the profile
  /// stays visible while it is shown.
  const factory ProfileState.loaded({
    required UserProfile profile,
    @Default(false) bool isSaving,
    String? actionError,
  }) = _Loaded;

  const factory ProfileState.error({required String message}) = _Error;
}
