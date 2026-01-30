import 'dart:convert';
import 'dart:io';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/errors/app_exception.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String _defaultBaseUrl = "https://kudr3e0ick.execute-api.us-east-1.amazonaws.com/";
  // static String baseUrl2 = "https://hrms-socket.onrender.com";

  static const String otherBaseUrl =
      "https://hrms-socket.onrender.com/"; // Replace with your mail service base URL
  final LoggingService _logger = LoggingService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();

  String _currentBaseUrl; // Global base URL for the current service

  ApiHelper({String? baseUrl}) : _currentBaseUrl = baseUrl ?? _defaultBaseUrl;

  // Set the base URL for the current service
  void setBaseUrl(String baseUrl) {
    _currentBaseUrl = baseUrl;
  }

  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, String>? headers}) async {
    return _request<T>('GET', endpoint, headers: headers);
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('POST', endpoint, body: body, headers: headers);
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('PUT', endpoint, body: body, headers: headers);
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('PATCH', endpoint, body: body, headers: headers);
  }

  Future<ApiResponse<T>> delete<T>(String endpoint, {Map<String, String>? headers}) async {
    return _request<T>('DELETE', endpoint, headers: headers);
  }

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_currentBaseUrl$endpoint');
    http.Response response;
    final sanitizedBody = body != null ? _sanitizeRequestBody(jsonEncode(body)) : null;

    // Fetch dynamic headers (including Token)
    final defaultHeaders = await _defaultHeaders(headers);
    _logger.logApi(
      '=== REQUEST START ===\nMethod: $method\nURL: $url\nHeaders: ${_sanitizeHeaders(defaultHeaders)}\nBody: $sanitizedBody',
    );

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: defaultHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: defaultHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(url, headers: defaultHeaders, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: defaultHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: defaultHeaders);
          break;
        default:
          throw BadRequestException('Invalid HTTP method');
      }

      final result = _handleResponse<T>(response);
      _logger.logApi(
        '=== RESPONSE ===\nStatus Code: ${response.statusCode}\nBody: ${_sanitizeResponseBody(response.body)}',
      );

      return result;
    } on SocketException catch (e, s) {
      _logger.error('NETWORK', 'No Internet Connection', error: e, stackTrace: s);
      return ApiResponse.error('No Internet Connection');
    } on AppException catch (e, s) {
      _logger.error('API_EXCEPTION', e.message, error: e, stackTrace: s);
      return ApiResponse.error(e.message);
    } catch (e, s) {
      _logger.error('UNEXPECTED', 'Unexpected error: $e', error: e, stackTrace: s);
      return ApiResponse.error('Something went wrong. Please try again later.');
    }
  }

  Future<Map<String, String>> _defaultHeaders(Map<String, String>? customHeaders) async {
    final token = await _secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?customHeaders
    };
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    const sensitiveHeaders = ['authorization', 'x-api-key', 'cookie', 'set-cookie'];
    for (final key in sanitized.keys.toList()) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        sanitized[key] = '***REDACTED***';
      }
    }
    return sanitized;
  }

  String _sanitizeRequestBody(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(data);
        const sensitiveFields = ['password', 'token', 'secret', 'key', 'otp'];
        for (final field in sensitiveFields) {
          if (sanitized.containsKey(field)) sanitized[field] = '***REDACTED***';
        }
        return jsonEncode(sanitized);
      }
    } catch (_) {}
    return body;
  }

  String _sanitizeResponseBody(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(data);
        const sensitiveFields = ['token', 'secret', 'key', 'password'];
        for (final field in sensitiveFields) {
          if (sanitized.containsKey(field)) sanitized[field] = '***REDACTED***';
        }
        return jsonEncode(sanitized);
      }
    } catch (_) {}
    return body.length > 1000 ? '${body.substring(0, 1000)}...[TRUNCATED]' : body;
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
  final statusCode = response.statusCode;
  dynamic body;

  try {
    body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
  } catch (_) {
    body = response.body;
  }

  // ✅ SUCCESS
  if (statusCode >= 200 && statusCode < 300) {
    return ApiResponse.success(body as T, statusCode: statusCode);
  }

  // ✅ SAFE error message extraction
  String message = 'Something went wrong';

  if (body is Map<String, dynamic>) {
    message = body['message']?.toString() ?? message;
  } else if (body is String) {
    message = body;
  }

  switch (statusCode) {
    case 400:
      throw BadRequestException(message);
    case 401:
      throw UnauthorizedException(message);
    case 403:
      throw ForbiddenException(message);
    case 404:
      throw NotFoundException(message);
    case 500:
      throw ServerException(message);
    default:
      throw FetchDataException('Error occurred with StatusCode: $statusCode');
  }
  }
}
