import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _lastStatus = true;

  Stream<bool> get onStatusChange => _controller.stream;
  bool get lastStatus => _lastStatus;

  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (online != _lastStatus) {
        _lastStatus = online;
        _controller.add(online);
      }
    });
    isOnline().then((online) {
      _lastStatus = online;
      _controller.add(online);
    });
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    _lastStatus = result != ConnectivityResult.none;
    return _lastStatus;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
