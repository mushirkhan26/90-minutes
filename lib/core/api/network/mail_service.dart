import 'dart:convert';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:http/http.dart' as http;

import '../../models/mail_model.dart';

class MailService {
  final String baseUrl2;
  MailService({required this.baseUrl2});

  // Send a mail
  Future<Mail> sendMail(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/mail/send'),
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
      Uri.parse('$baseUrl2/mail/inbox/$employeeId'),
    );

    if (response.statusCode == 200) {
      final mailResponse = jsonDecode(response.body);
      return MailResponse.fromJson(mailResponse).data ?? [];
    } else {
      throw Exception('Failed to fetch inbox mails');
    }
  }

  // Get Employee
  Future<List<EmployeeModel>> getEmployee() async {
    final response = await http.get(
      Uri.parse(
        'https://7qj30pu8ee.execute-api.us-east-1.amazonaws.com/employee/employeeList',
      ),
    );
    if (response.statusCode == 200 &&
        jsonDecode(response.body)['message'] is List) {
      final data = (jsonDecode(response.body)['message'] as List);
      return data.map((json) => EmployeeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get employee list');
    }
  }

  // Get sent mails
  Future<List<Mail>> getSent(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl2/mail/sent/$employeeId'),
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
      Uri.parse('$baseUrl2/mail/trash/$employeeId'),
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
    final response = await http.delete(Uri.parse('$baseUrl2/mail/$mailId'));
    return response.statusCode == 200;
  }

  // Move a mail to trash
  Future<bool> moveToTrash(String mailId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl2/mail/move-to-trash/$mailId'),
    );
    return response.statusCode == 200;
  }

  // Restore a mail from trash
  Future<bool> restoreFromTrash(String mailId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl2/mail/restore-from-trash/$mailId'),
    );
    return response.statusCode == 200;
  }

  // Empty trash
  Future<bool> emptyTrash(String employeeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl2/mail/empty-trash/$employeeId'),
    );
    return response.statusCode == 200;
  }

  // Move many mails to trash
  Future<bool> moveManyToTrash(String employeeId, List<String> mailIds) async {
    final response = await http.patch(
      Uri.parse('$baseUrl2/mail/move-to-trash-many'),
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
      Uri.parse('$baseUrl2/mail/restore-from-trash-many'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'employeeId': employeeId, 'mailIds': mailIds}),
    );
    return response.statusCode == 200;
  }
}
