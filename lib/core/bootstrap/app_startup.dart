import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/core/services/notification_service.dart';

/// Cold-start timing for the brand splash shown before [MaterialApp.router].
abstract final class AppStartup {
  static DateTime? splashVisibleSince;

  /// Must match [AppSettingsCubit] storage key.
  static const String themePreferenceKey = 'app_theme_mode_name';

  /// Loaded in [main] before [runApp] so the boot splash matches saved theme.
  static ThemeMode initialThemeMode = ThemeMode.system;

  static ThemeMode readThemeMode(SharedPreferences prefs) {
    final String? themeName = prefs.getString(themePreferenceKey);
    return ThemeMode.values.firstWhere(
      (ThemeMode mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }

  static bool resolvesToDark({
    required ThemeMode mode,
    required Brightness platformBrightness,
  }) {
    return switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
  }

  static Future<void> run() async {
    LicenseRegistry.addLicense(() async* {
      final String license =
          await rootBundle.loadString('assets/fonts/Tajawal-OFL.txt');
      yield LicenseEntryWithLineBreaks(<String>['Tajawal'], license);
    });

    tz.initializeTimeZones();
    try {
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      debugPrint('Could not set local timezone with name: $e');
      final Duration offset = DateTime.now().timeZoneOffset;
      for (final location in tz.timeZoneDatabase.locations.values) {
        if (location.currentTimeZone.offset == offset) {
          tz.setLocalLocation(location);
          break;
        }
      }
    }

    await dotenv.load();

    final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
      'SUPABASE_URL and SUPABASE_ANON_KEY must be set in your .env file.',
    );

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );

    await configureDependencies();

    final NotificationService notificationService =
        getIt<NotificationService>();
    await notificationService.init();
  }
}