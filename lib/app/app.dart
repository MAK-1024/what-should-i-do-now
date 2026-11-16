import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wsidappp/config/routes/app_router.dart';
import 'package:wsidappp/config/theme/app_theme.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/settings/app_settings_cubit.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_cubit.dart';

class WhatShouldIDoApp extends StatelessWidget {
  const WhatShouldIDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>(
          create: (_) => getIt<AppSettingsCubit>()..loadSettings(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        buildWhen: (prev, next) =>
            prev.themeMode != next.themeMode || prev.locale != next.locale,
        builder: (context, settings) {
          return MaterialApp.router(
            onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,

            // ── Reactive theme ──────────────────────────────────────────────
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: settings.themeMode,

            // ── Localization ────────────────────────────────────────────────
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
