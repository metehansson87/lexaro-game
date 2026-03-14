import 'dart:async';

/// Service to monitor network connectivity status.
/// Used to determine if multiplayer features are available.
class ConnectivityService {
  bool _isOnline = true;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _connectivityController.stream;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    // Check initial connectivity
    _isOnline = true;
    // In production, use connectivity_plus package:
    // Connectivity().onConnectivityChanged.listen((result) {
    //   _isOnline = result != ConnectivityResult.none;
    //   _connectivityController.add(_isOnline);
    // });
  }

  void setOnline(bool online) {
    _isOnline = online;
    _connectivityController.add(online);
  }

  void dispose() {
    _connectivityController.close();
  }
}
