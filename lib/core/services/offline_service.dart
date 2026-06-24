import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (wasOnline != _isOnline) _connectivityController.add(_isOnline);
    });
  }

  StreamSubscription? _connectivitySubscription;
  void dispose() { _connectivitySubscription?.cancel(); _connectivityController.close(); }
}
