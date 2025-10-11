import 'dart:convert';
import 'dart:io';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/errors/app_exception.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final String _baseUrl = ""; // dotenv.env['BASE_URL'] ?? "";
  final _logger = LoggerService();

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

  Future<ApiResponse<T>> delete<T>(String endpoint, {Map<String, String>? headers}) async {
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

    _logger.logRequest(method, url.toString(), headers: headers, body: body);

    try {
      switch (method) {
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
          response = await http.put(url, headers: _defaultHeaders(headers), body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: _defaultHeaders(headers));
          break;
        default:
          throw BadRequestException('Invalid HTTP method');
      }

      final result = _handleResponse<T>(response);
      _logger.logResponse(response.statusCode, result.data);
      return result;
    } on SocketException catch (e, s) {
      _logger.logError('No Internet Connection', s);
      return ApiResponse.error('No Internet Connection');
    } on AppException catch (e, s) {
      _logger.logError(e.toString(), s);
      return ApiResponse.error(e.message);
    } catch (e, s) {
      _logger.logError('Unexpected error: $e', s);
      return ApiResponse.error('Something went wrong. Please try again later.');
    }
  }

  Map<String, String> _defaultHeaders(Map<String, String>? customHeaders) {
    return {'Content-Type': 'application/json', ...?customHeaders};
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final statusCode = response.statusCode;
    final dynamic body = jsonDecode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(body as T, statusCode: statusCode);
    }

    // Map status code to custom exception
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
