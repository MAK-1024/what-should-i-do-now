import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wsidappp/core/network/network_info.dart';

class NetworkState extends Equatable {
  const NetworkState({
    required this.isConnected,
    this.isChecking = false,
  });

  final bool isConnected;
  final bool isChecking;

  NetworkState copyWith({
    bool? isConnected,
    bool? isChecking,
  }) {
    return NetworkState(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  @override
  List<Object?> get props => <Object?>[isConnected, isChecking];
}

@lazySingleton
class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit(this._networkInfo) : super(const NetworkState(isConnected: true));

  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;

  void init() {
    _subscription?.cancel();
    _subscription =
        _networkInfo.onConnectivityChanged.listen((bool isConnected) {
      emit(state.copyWith(isConnected: isConnected, isChecking: false));
    });
    checkConnection();
  }

  Future<void> checkConnection() async {
    emit(state.copyWith(isChecking: true));
    try {
      final bool connected = await _networkInfo.isConnected;
      emit(state.copyWith(isConnected: connected, isChecking: false));
    } catch (_) {
      emit(state.copyWith(isConnected: false, isChecking: false));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
