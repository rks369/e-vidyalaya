import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectionStates { checking, notConnected, error, connected }

class ConnectionCubit extends Cubit<ConnectionStates> {

  ConnectionCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(ConnectionStates.checking) {

    _start();

  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  static ConnectionStates _stateOf({required List<ConnectivityResult> results}) {

    final offline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);

    return offline ? ConnectionStates.notConnected : ConnectionStates.connected;

  }

  Future<void> _start() async {

    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        (results) => emit(_stateOf(results: results)),
      );
      emit(_stateOf(results: await _connectivity.checkConnectivity()));
    } on Exception catch (e) {
      emit(ConnectionStates.error);
      developer.log(
        "Couldn't check connectivity status",
        error: e,
      );
    }

  }

  Future<void> retry() async {

    emit(ConnectionStates.checking);
    try {
      emit(_stateOf(results: await _connectivity.checkConnectivity()));
    } on Exception catch (e) {
      emit(ConnectionStates.error);
      developer.log(
        "Couldn't check connectivity status",
        error: e,
      );
    }

  }

  @override
  Future<void> close() async {

    await _subscription?.cancel();
    return super.close();

  }

}
