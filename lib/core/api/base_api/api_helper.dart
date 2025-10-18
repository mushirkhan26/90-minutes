import 'dart:convert';
import 'dart:io';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/errors/app_exception.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final String _baseUrl =
      "https://7qj30pu8ee.execute-api.us-east-1.amazonaws.com/";
  static String baseUrl2 = "https://hrms-socket.onrender.com";
  final LoggingService _logger = LoggingService.instance;

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
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

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('DELETE', endpoint, headers: headers);
  }

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    http.Response response;
    final sanitizedBody = body != null
        ? _sanitizeRequestBody(jsonEncode(body))
        : null;

    _logger.logApi(
      '=== REQUEST START ===\nMethod: $method\nURL:\nHeaders: ${_sanitizeHeaders(headers ?? {})}\nBody: $sanitizedBody',
    );

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: _defaultHeaders(headers));
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: _defaultHeaders(headers),
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: _defaultHeaders(headers),
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: _defaultHeaders(headers));
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
      _logger.error(
        'NETWORK',
        'No Internet Connection',
        error: e,
        stackTrace: s,
      );
      return ApiResponse.error('No Internet Connection');
    } on AppException catch (e, s) {
      _logger.error('API_EXCEPTION', e.message, error: e, stackTrace: s);
      return ApiResponse.error(e.message);
    } catch (e, s) {
      _logger.error(
        'UNEXPECTED',
        'Unexpected error: $e',
        error: e,
        stackTrace: s,
      );
      return ApiResponse.error('Something went wrong. Please try again later.');
    }
  }

  Map<String, String> _defaultHeaders(Map<String, String>? customHeaders) {
    return {'Content-Type': 'application/json', ...?customHeaders};
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    const sensitiveHeaders = [
      'authorization',
      'x-api-key',
      'cookie',
      'set-cookie',
    ];
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
    return body.length > 1000
        ? '${body.substring(0, 1000)}...[TRUNCATED]'
        : body;
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final statusCode = response.statusCode;
    final dynamic body = jsonDecode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(body as T, statusCode: statusCode);
    }

    switch (statusCode) {
      case 400:
        throw BadRequestException(body['message']);
      case 401:
        throw UnauthorizedException(body['message']);
      case 403:
        throw ForbiddenException(body['message']);
      case 404:
        throw NotFoundException(body['message']);
      case 500:
        throw ServerException(body['message']);
      default:
        throw FetchDataException('Error occurred with StatusCode: $statusCode');
    }
  }
}
