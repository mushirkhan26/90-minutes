import 'dart:convert';
import 'package:hrtz_hrms/core/models/employee.dart';
import 'package:http/http.dart' as http;

import '../models/mail_model.dart';

class MailService {
  // final String baseUrl;
  // MailService({required this.baseUrl});

  static const String baseUrl = "https://hrms-socket.onrender.com";

  // Send a mail
  Future<Mail> sendMail(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mail/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Mail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send mail');
    }
  }

  // Get inbox mails
  Future<List<Mail>> getInbox(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mail/inbox/$employeeId'),
    );

    if (response.statusCode == 200) {
      final mailResponse = jsonDecode(response.body);
      return (mailResponse['data'] as List)
          .map((e) => Mail.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch inbox mails');
    }
  }

  // Get Employee
  Future<List<Employee>> getEmployee() async {
    final response = await http.get(
      Uri.parse(
        'https://7qj30pu8ee.execute-api.us-east-1.amazonaws.com/employee/employeeList',
      ),
    );
    if (response.statusCode == 200 &&
        jsonDecode(response.body)['message'] is List) {
      final data = (jsonDecode(response.body)['message'] as List);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get employee list');
    }
  }

  // Get sent mails
  Future<List<Mail>> getSent(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mail/sent/$employeeId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((json) => Mail.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch sent mails');
    }
  }

  // Get trash mails
  Future<List<Mail>> getTrash(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mail/trash/$employeeId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((json) => Mail.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch trash mails');
    }
  }

  // Delete a mail
  Future<bool> deleteMail(String mailId) async {
    final response = await http.delete(Uri.parse('$baseUrl/mail/$mailId'));
    return response.statusCode == 200;
  }

  // Move a mail to trash
  Future<bool> moveToTrash(String mailId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/mail/move-to-trash/$mailId'),
    );
    return response.statusCode == 200;
  }

  // Restore a mail from trash
  Future<bool> restoreFromTrash(String mailId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/mail/restore-from-trash/$mailId'),
    );
    return response.statusCode == 200;
  }

  // Empty trash
  Future<bool> emptyTrash(String employeeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/mail/empty-trash/$employeeId'),
    );
    return response.statusCode == 200;
  }

  // Move many mails to trash
  Future<bool> moveManyToTrash(String employeeId, List<String> mailIds) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/mail/move-to-trash-many'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'employeeId': employeeId, 'mailIds': mailIds}),
    );
    return response.statusCode == 200;
  }

  // Restore many mails from trash
  Future<bool> restoreManyFromTrash(
    String employeeId,
    List<String> mailIds,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/mail/restore-from-trash-many'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'employeeId': employeeId, 'mailIds': mailIds}),
    );
    return response.statusCode == 200;
  }
}
