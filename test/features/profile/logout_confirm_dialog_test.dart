import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/dialogs/confirm_action_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({required void Function(BuildContext) onOpen}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => onOpen(context),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders logout confirm dialog matching Figma design',
      (WidgetTester tester) async {
    bool? result;

    await tester.pumpWidget(
      buildTestableWidget(
        onOpen: (context) async {
          result = await ConfirmActionDialog.showLogout(context);
        },
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Subtitle
    expect(find.text('are you sure to log out?'), findsOneWidget);
    expect(
      find.text(
        'Taking a little break? Your tasks will be right here when you come back.',
      ),
      findsOneWidget,
    );

    // Verify mascot image asset
    final imageFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AppAssets.hearbreak,
    );
    expect(imageFinder, findsOneWidget);

    // Verify cancel and logout buttons
    expect(find.text('cancel'), findsOneWidget);
    expect(find.text('logout'), findsOneWidget);

    // Tap cancel
    await tester.tap(find.text('cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(result, isFalse);
  });

  testWidgets('confirming logout returns true', (WidgetTester tester) async {
    bool? result;

    await tester.pumpWidget(
      buildTestableWidget(
        onOpen: (context) async {
          result = await ConfirmActionDialog.showLogout(context);
        },
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap logout
    await tester.tap(find.text('logout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(result, isTrue);
  });
}
