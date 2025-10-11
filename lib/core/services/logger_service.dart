import 'package:logger/logger.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;

  late final Logger _logger;

  LoggerService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  // 🌐 API Logs
  void logRequest(String method, String url, {Map<String, String>? headers, dynamic body}) {
    _logger.i('📡 [API Request] → [$method] $url\nHeaders: $headers\nBody: $body');
  }

  void logResponse(int statusCode, dynamic data) {
    _logger.d('✅ [API Response] [$statusCode]\n$data');
  }

  void logApi(String message) {
    _logger.i('🌍 [API] $message');
  }

  // 🧾 Storage Logs
  void logStorage(String message) {
    _logger.i('🗄️ [Storage] $message');
  }

  // 🔐 Auth Logs
  void logAuth(String message) {
    _logger.i('🔐 [Auth] $message');
  }

  // 🐞 Debug Logs
  void logDebug(String message) {
    _logger.d('🐞 [Debug] $message');
  }

  // ⚠️ Warning Logs
  void logWarning(String message) {
    _logger.w('⚠️ [Warning] $message');
  }

  // ❌ Error Logs
  void logError(String error, [StackTrace? stack]) {
    _logger.e('❌ [Error] $error', error: error, stackTrace: stack);
  }
}
