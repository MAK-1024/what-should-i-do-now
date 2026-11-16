import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/services/notification_service.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    required this.themeMode,
    required this.locale,
    required this.notificationsEnabled,
    this.reminderHour = 9,
    this.reminderMinute = 0,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsEnabled;
  final int reminderHour;
  final int reminderMinute;

  static const AppSettingsState defaults = AppSettingsState(
    themeMode: ThemeMode.system,
    locale: Locale(AppLocalizations.fallbackLanguageCode),
    notificationsEnabled: false,
    reminderHour: 9,
    reminderMinute: 0,
  );

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) =>
      AppSettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
      );

  @override
  List<Object?> get props => <Object?>[
        themeMode,
        locale,
        notificationsEnabled,
        reminderHour,
        reminderMinute,
      ];
}

@lazySingleton
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._prefs, this._notificationService)
      : super(AppSettingsState.defaults);

  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  static const String _keyTheme = 'app_theme_mode_name';
  static const String _keyLanguage = 'app_language_code';
  static const String _keyNotifications = 'app_notifications_enabled';
  static const String _keyReminderHour = 'app_reminder_hour';
  static const String _keyReminderMinute = 'app_reminder_minute';

  Future<void> loadSettings() async {
    final String? themeName = _prefs.getString(_keyTheme);
    final String? languageCode = _prefs.getString(_keyLanguage);

    final bool osGranted = await _notificationService.isPermissionGranted();
    final bool userPref = _prefs.getBool(_keyNotifications) ?? false;
    final bool effectiveNotifications = userPref && osGranted;

    final int reminderHour = _prefs.getInt(_keyReminderHour) ??
        AppSettingsState.defaults.reminderHour;
    final int reminderMinute = _prefs.getInt(_keyReminderMinute) ??
        AppSettingsState.defaults.reminderMinute;

    if (userPref != effectiveNotifications) {
      await _prefs.setBool(_keyNotifications, effectiveNotifications);
    }

    emit(
      AppSettingsState(
        themeMode: ThemeMode.values.firstWhere(
          (ThemeMode mode) => mode.name == themeName,
          orElse: () => AppSettingsState.defaults.themeMode,
        ),
        locale: languageCode != null &&
                AppLocalizations.isSupported(languageCode)
            ? Locale(languageCode)
            : AppSettingsState.defaults.locale,
        notificationsEnabled: effectiveNotifications,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      ),
    );

    if (effectiveNotifications) {
      await _notificationService.scheduleDailyReminder(
        hour: reminderHour,
        minute: reminderMinute,
      );
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  /// Synchronizes app notification toggle state with current operating system permission.
  ///
  /// Useful when returning from OS settings.
  Future<void> syncWithSystemPermissions() async {
    final bool osGranted = await _notificationService.isPermissionGranted();
    final bool userPref = _prefs.getBool(_keyNotifications) ?? false;
    final bool effectiveNotifications = userPref && osGranted;

    if (state.notificationsEnabled != effectiveNotifications) {
      emit(state.copyWith(notificationsEnabled: effectiveNotifications));
      await _prefs.setBool(_keyNotifications, effectiveNotifications);

      if (effectiveNotifications) {
        await _notificationService.scheduleDailyReminder(
          hour: state.reminderHour,
          minute: state.reminderMinute,
        );
      } else {
        await _notificationService.cancelAllNotifications();
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _prefs.setString(_keyTheme, mode.name);
  }

  Future<void> setLanguage(String languageCode) async {
    if (!AppLocalizations.isSupported(languageCode)) return;
    emit(state.copyWith(locale: Locale(languageCode)));
    await _prefs.setString(_keyLanguage, languageCode);
  }

  /// Updates the daily push notification reminder time and reschedules if active.
  Future<void> updateReminderTime(int hour, int minute) async {
    emit(state.copyWith(reminderHour: hour, reminderMinute: minute));
    await _prefs.setInt(_keyReminderHour, hour);
    await _prefs.setInt(_keyReminderMinute, minute);

    if (state.notificationsEnabled) {
      await _notificationService.cancelDailyReminder();
      await _notificationService.scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    if (isEnabled) {
      final bool granted =
          await _notificationService.requestPermissionOrOpenSettings();
      if (!granted) {
        emit(state.copyWith(notificationsEnabled: false));
        await _prefs.setBool(_keyNotifications, false);
        await _notificationService.cancelAllNotifications();
        return;
      }
      emit(state.copyWith(notificationsEnabled: true));
      await _prefs.setBool(_keyNotifications, true);
      await _notificationService.scheduleDailyReminder(
        hour: state.reminderHour,
        minute: state.reminderMinute,
      );
    } else {
      emit(state.copyWith(notificationsEnabled: false));
      await _prefs.setBool(_keyNotifications, false);
      await _notificationService.cancelAllNotifications();
    }
  }

  /// Alias for [toggleNotifications].
  Future<void> setNotificationsEnabled(bool enabled) =>
      toggleNotifications(enabled);
}
