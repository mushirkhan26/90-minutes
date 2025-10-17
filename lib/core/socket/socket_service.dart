import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService instance = SocketService._internal();
  SocketService._internal();

  late io.Socket socket;
  bool _isConnected = false;

  /// Initialize socket connection
  void init() {
    socket = io.io(
      AppConstants.socketbaseurl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _registerGlobalEvents();
    socket.connect();

    LoggingService.instance.logNetwork('SocketService initialized and connecting...');
  }

  void _registerGlobalEvents() {
    socket.onConnect((_) {
      _isConnected = true;
      LoggingService.instance.logNetwork('Socket connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      LoggingService.instance.warning("[Socket service]", 'Socket disconnected');
    });

    socket.onReconnect((attempt) {
      LoggingService.instance.info("[Socket service]", 'Socket reconnect attempt: $attempt');
    });

    socket.onReconnectAttempt((attempt) {
      LoggingService.instance.info("[Socket service]", 'Reconnect attempt #: $attempt');
    });

    socket.onError((error) {
      LoggingService.instance.error('Socket', 'Socket error', error: error);
    });

    socket.onConnectError((error) {
      LoggingService.instance.error('Socket', 'Connect error', error: error);
    });
  }

  bool get isConnected => _isConnected;

  void dispose() {
    socket.dispose();
    _isConnected = false;
    LoggingService.instance.logNetwork('SocketService disposed');
  }
}
