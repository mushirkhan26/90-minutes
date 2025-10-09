import 'dart:convert';
import 'dart:io';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hrtz_hrms/core/errors/app_exception.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  // final String _baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String _baseUrl = "";
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return _request('GET', endpoint, headers: headers);
  }

  Future<dynamic> post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    return _request('POST', endpoint, body: body, headers: headers);
  }

  Future<dynamic> put(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    return _request('PUT', endpoint, body: body, headers: headers);
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    return _request('DELETE', endpoint, headers: headers);
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    try {
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            body: jsonEncode(body),
            headers: _defaultHeaders(headers),
          );
          break;
        case 'PUT':
          response = await http.put(url, body: jsonEncode(body), headers: _defaultHeaders(headers));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw BadRequestException('Invalid HTTP method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on FormatException {
      throw FormatException('Bad response format');
    }
  }

  Map<String, String> _defaultHeaders(Map<String, String>? customHeaders) {
    return {'Content-Type': 'application/json', ...?customHeaders};
  }

  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(responseBody['message'] ?? 'Bad Request');
      case 401:
        throw UnauthorizedException(responseBody['message'] ?? 'Unauthorized');
      case 403:
        throw ForbiddenException(responseBody['message'] ?? 'Forbidden');
      case 404:
        throw NotFoundException(responseBody['message'] ?? 'Not Found');
      case 500:
        throw ServerException(responseBody['message'] ?? 'Server Error');
      default:
        throw FetchDataException('Error occurred with StatusCode: ${response.statusCode}');
    }
  }
}
