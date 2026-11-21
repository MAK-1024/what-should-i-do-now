import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wsidappp/app/app.dart';
import 'package:wsidappp/config/theme/app_colors.dart';
import 'package:wsidappp/config/theme/app_theme.dart';
import 'package:wsidappp/core/bootstrap/app_startup.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/onboarding/presentation/widgets/splash_page_widgets/sections/splash_brand_section.dart';

/// Shows the Figma splash while async startup work runs, then mounts the real app.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late final Future<void> _ready = AppStartup.run();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _ImmediateBrandSplash();
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Startup failed: ${snapshot.error}'),
              ),
            ),
          );
        }
        return const WhatShouldIDoApp();
      },
    );
  }
}

class _ImmediateBrandSplash extends StatelessWidget {
  const _ImmediateBrandSplash();

  @override
  Widget build(BuildContext context) {
    final Brightness platform =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final bool useDark = AppStartup.resolvesToDark(
      mode: AppStartup.initialThemeMode,
      platformBrightness: platform,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: useDark ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        backgroundColor:
            useDark ? AppColors.darkBackground : AppColors.surface,
        body: const _ImmediateBrandSplashBody(),
      ),
    );
  }
}

class _ImmediateBrandSplashBody extends StatelessWidget {
  const _ImmediateBrandSplashBody();

  @override
  Widget build(BuildContext context) {
    final String brandLabel = AppLocalizations.of(context).whatShouldIDo;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SplashBrandSection(wordmarkSemanticsLabel: brandLabel),
          ],
        );
      },
    );
  }
}