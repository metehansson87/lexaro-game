import 'dart:async';
import '../config/app_config.dart';
import '../constants/api_constants.dart';

/// Socket.io client service for real-time multiplayer communication.
/// Wraps socket_io_client with game-specific event handling.
class SocketService {
  // In production, this would use socket_io_client package:
  // import 'package:socket_io_client/socket_io_client.dart' as IO;
  // IO.Socket? _socket;

  bool _connected = false;
  String? _playerId;
  final _eventControllers = <String, StreamController<Map<String, dynamic>>>{};

  bool get isConnected => _connected;

  /// Connect to the game server.
  Future<void> connect({required String playerId, String? authToken}) async {
    if (!AppConfig.enableMultiplayer) return;
    _playerId = playerId;

    // In production:
    // _socket = IO.io(AppConfig.wsUrl, IO.OptionBuilder()
    //   .setTransports(['websocket'])
    //   .setAuth({'token': authToken, 'playerId': playerId})
    //   .setTimeout(ApiConstants.connectionTimeout.inMilliseconds)
    //   .enableAutoConnect()
    //   .build());
    //
    // _socket!.onConnect((_) { _connected = true; });
    // _socket!.onDisconnect((_) { _connected = false; });
    // _socket!.onError((data) { _getController('error').add(data); });

    _connected = true;
  }

  /// Disconnect from the server.
  void disconnect() {
    // _socket?.disconnect();
    _connected = false;
    _playerId = null;
  }

  /// Emit an event to the server.
  void emit(String event, [Map<String, dynamic>? data]) {
    if (!_connected) return;
    // _socket?.emit(event, data);
  }

  /// Listen to a specific server event.
  Stream<Map<String, dynamic>> on(String event) {
    return _getController(event).stream;
  }

  /// Join the matchmaking queue.
  void joinQueue({required String difficulty, required String language}) {
    emit(ApiConstants.socketMatchQueue, {
      'playerId': _playerId,
      'difficulty': difficulty,
      'language': language,
    });
  }

  /// Leave the matchmaking queue.
  void leaveQueue() {
    emit('match:leave_queue', {'playerId': _playerId});
  }

  /// Submit answer for current round.
  void submitAnswer({required String matchId, required String answer}) {
    emit(ApiConstants.socketRoundAnswer, {
      'matchId': matchId,
      'playerId': _playerId,
      'answer': answer,
    });
  }

  /// Notify server that player used a hint.
  void notifyHintUsed({required String matchId}) {
    emit(ApiConstants.socketHintUsed, {
      'matchId': matchId,
      'playerId': _playerId,
    });
  }

  /// Handle reconnection to an active match.
  void reconnect({required String matchId}) {
    emit(ApiConstants.socketPlayerReconnect, {
      'matchId': matchId,
      'playerId': _playerId,
    });
  }

  StreamController<Map<String, dynamic>> _getController(String event) {
    _eventControllers[event] ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _eventControllers[event]!;
  }

  void dispose() {
    disconnect();
    for (final controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();
  }
}
