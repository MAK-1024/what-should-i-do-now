import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/network/network_cubit.dart';
import 'package:wsidappp/core/network/network_info.dart';
import 'package:wsidappp/shared/widgets/network_connection_barrier.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({this.initialConnected = true});

  bool initialConnected;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isConnected async => initialConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void emit(bool value) {
    initialConnected = value;
    _controller.add(value);
  }

  void dispose() {
    _controller.close();
  }
}

Widget _buildTestApp({
  required NetworkCubit cubit,
  required Widget child,
}) {
  return MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: NetworkConnectionBarrier(
      cubit: cubit,
      child: child,
    ),
  );
}

void main() {
  group('NetworkConnectionBarrier', () {
    late _FakeNetworkInfo fakeNetworkInfo;
    late NetworkCubit cubit;

    setUp(() {
      fakeNetworkInfo = _FakeNetworkInfo(initialConnected: true);
      cubit = NetworkCubit(fakeNetworkInfo);
    });

    tearDown(() async {
      await cubit.close();
      fakeNetworkInfo.dispose();
    });

    testWidgets('shows child and does not show offline view when connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          child: const Scaffold(
            body: Center(child: Text('Main App Content')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Main App Content'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('network_offline_view')), findsNothing);
    });

    testWidgets('blocks screen with offline illustration and retry button when offline',
        (WidgetTester tester) async {
      fakeNetworkInfo.initialConnected = false;
      cubit.init();

      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          child: const Scaffold(
            body: Center(child: Text('Main App Content')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Offline blocker is visible
      expect(find.byKey(const ValueKey<String>('network_offline_view')), findsOneWidget);
      expect(find.text("Looks like you're offline!"), findsOneWidget);
      expect(
        find.text(
          'Looks like your internet connection took a little break. Check your connection and try again!',
        ),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping retry triggers checkConnection and unblocks when connection restored',
        (WidgetTester tester) async {
      fakeNetworkInfo.initialConnected = false;
      cubit.init();

      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          child: const Scaffold(
            body: Center(child: Text('Main App Content')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const ValueKey<String>('network_offline_view')), findsOneWidget);

      // Now restore connection
      fakeNetworkInfo.initialConnected = true;

      // Tap retry button
      await tester.tap(find.widgetWithText(WsidButton, 'Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Blocker dismissed
      expect(find.byKey(const ValueKey<String>('network_offline_view')), findsNothing);
      expect(find.text('Main App Content'), findsOneWidget);
    });
  });
}
