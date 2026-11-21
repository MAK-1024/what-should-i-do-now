import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget buildTestableWidget() {
    final router = GoRouter(
      initialLocation: RouteList.onboarding,
      routes: [
        GoRoute(
          path: RouteList.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: RouteList.auth,
          builder: (context, state) => const Scaffold(body: Text('Auth View')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  Future<void> pumpOnboarding(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();
  }

  testWidgets('renders wordmark, first slide and actions', (tester) async {
    await pumpOnboarding(tester);

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('stuck on what to do?'), findsOneWidget);
    expect(find.text('skip'), findsOneWidget);
    expect(find.text('next'), findsOneWidget);
  });

  testWidgets('next advances slides and the last slide shows get started',
      (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    expect(find.text('clear your head'), findsOneWidget);

    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    expect(find.text('one task at a time'), findsOneWidget);
    expect(find.text('get started'), findsOneWidget);

    await tester.tap(find.text('get started'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_completed_onboarding'), isTrue);
    expect(find.text('Auth View'), findsOneWidget);
  });

  testWidgets('skip marks onboarding as completed and opens auth',
      (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('skip'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_completed_onboarding'), isTrue);
    expect(find.text('Auth View'), findsOneWidget);
  });
}
