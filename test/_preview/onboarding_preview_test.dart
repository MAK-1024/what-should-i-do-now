import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  testWidgets('preview', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.runAsync(() async {
      final loader = FontLoader('Tajawal')
        ..addFont(rootBundle.load('assets/fonts/Tajawal-Medium.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
      await loader.load();
    });
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale('ar'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingPage(),
      ),
    );
    final ctx = tester.element(find.byType(OnboardingPage));
    await tester.runAsync(() async {
      for (final p in [
        AppAssets.onboardingSpin,
        AppAssets.onboardingIdea,
        AppAssets.onboardingFocus,
      ]) {
        await precacheImage(AssetImage(p), ctx);
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    for (var i = 1; i <= 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OnboardingPage),
        matchesGoldenFile('out/slide_$i.png'),
      );
      if (i < 3) {
        await tester.tap(find.text('التالي'));
        await tester.pumpAndSettle();
      }
    }
  });
}
