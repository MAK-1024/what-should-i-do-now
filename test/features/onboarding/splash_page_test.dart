import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsidappp/features/onboarding/presentation/widgets/splash_page_widgets/sections/splash_brand_section.dart';
import 'package:wsidappp/features/onboarding/presentation/widgets/splash_screen.dart';

void main() {
  group('SplashScreen & SplashBrandSection', () {
    testWidgets('SplashBrandSection renders SVGs without asset loading errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplashBrandSection(wordmarkSemanticsLabel: 'What Should I Do'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SplashBrandSection), findsOneWidget);
    });

    testWidgets('SplashScreen plays animated sequence and invokes onFinished',
        (WidgetTester tester) async {
      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () => finished = true,
            holdAfter: const Duration(milliseconds: 100),
          ),
        ),
      );

      // Initially not finished
      expect(finished, isFalse);

      // Advance animation through the timeline
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 200));

      expect(finished, isTrue);
    });
  });
}
