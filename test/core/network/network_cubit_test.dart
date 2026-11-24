import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wsidappp/core/network/network_cubit.dart';
import 'package:wsidappp/core/network/network_info.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({this.initialConnected = true});

  bool initialConnected;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isConnected async => initialConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void emitConnectivity(bool isConnected) {
    initialConnected = isConnected;
    _controller.add(isConnected);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('NetworkCubit', () {
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

    test('initial state defaults to isConnected = true, isChecking = false', () {
      expect(cubit.state.isConnected, isTrue);
      expect(cubit.state.isChecking, isFalse);
    });

    test('init updates state from connectivity stream and initial check', () async {
      fakeNetworkInfo.initialConnected = false;
      cubit.init();

      // Wait for initial check to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isConnected, isFalse);
      expect(cubit.state.isChecking, isFalse);

      // Fire online event from stream
      fakeNetworkInfo.emitConnectivity(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isConnected, isTrue);
      expect(cubit.state.isChecking, isFalse);
    });

    test('checkConnection verifies connectivity and updates state', () async {
      fakeNetworkInfo.initialConnected = false;
      final Future<void> checkFuture = cubit.checkConnection();

      expect(cubit.state.isChecking, isTrue);
      await checkFuture;

      expect(cubit.state.isConnected, isFalse);
      expect(cubit.state.isChecking, isFalse);

      fakeNetworkInfo.initialConnected = true;
      await cubit.checkConnection();

      expect(cubit.state.isConnected, isTrue);
      expect(cubit.state.isChecking, isFalse);
    });
  });
}
