import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';

import 'package:hrtz_hrms/core/services/logger_service.dart';

class MailService {
  final ApiHelper _apiHelper = ApiHelper(baseUrl: ApiHelper.otherBaseUrl);
  final LoggingService _logger = LoggingService.instance;

  /// Get inbox mails for a specific employee (returns raw response)
  Future<ApiResponse<Map<String, dynamic>>> getInbox({required String employeeId}) async {
    _logger.logNetwork('Fetching inbox for employeeId: $employeeId');
    return await _apiHelper.get<Map<String, dynamic>>('mail/inbox/$employeeId');
  }

  /// 📤 Get sent mails for a specific employee
  Future<ApiResponse<Map<String, dynamic>>> getSentMails({required String employeeId}) async {
    _logger.logNetwork('Fetching sent mails for employeeId: $employeeId');
    return await _apiHelper.get<Map<String, dynamic>>('mail/sent/$employeeId');
  }

  /// 🗑️ Get trash mails for a specific employee
  Future<ApiResponse<Map<String, dynamic>>> getTrashMails({required String employeeId}) async {
    _logger.logNetwork('Fetching trash mails for employeeId: $employeeId');
    return await _apiHelper.get<Map<String, dynamic>>('mail/trash/$employeeId');
  }

  /// ---------------------------------------------------------------------------
  /// ✉️ SEND MAIL
  /// ---------------------------------------------------------------------------
  Future<ApiResponse<Map<String, dynamic>>> sendMail({
    required String sender,
    required String senderName,
    required List<String> receiver,
    required List<String> receiverName,
    required List<String> cc,
    required List<String> bcc,
    required String subject,
    required String body,
    required List<String> attachmentUrls,
  }) async {
    _logger.logNetwork('Sending mail from $sender to $receiver');
    final response = await _apiHelper.post<Map<String, dynamic>>('mail/send', {
      "sender": sender,
      "senderName": senderName,
      "receiver": receiver,
      "receiverName": receiverName,
      "cc": cc,
      "bcc": bcc,
      "subject": subject,
      "body": body,
      "attachmentUrls": attachmentUrls,
    });
    return response;
  }

  /// 🗑️ Move single mail to trash
  Future<ApiResponse<Map<String, dynamic>>> moveToTrash(String mailId) async {
    _logger.logNetwork('Moving mail to trash: $mailId');
    return await _apiHelper.patch<Map<String, dynamic>>('mail/move-to-trash/$mailId', {});
  }

  /// 🔁 Restore single mail from trash
  Future<ApiResponse<Map<String, dynamic>>> restoreFromTrash(String mailId) async {
    _logger.logNetwork('Restoring mail from trash: $mailId');
    return await _apiHelper.patch<Map<String, dynamic>>('mail/restore-from-trash/$mailId', {});
  }

  /// 🧹 Empty entire trash for an employee
  Future<ApiResponse<Map<String, dynamic>>> emptyTrash(String? employeeId) async {
    _logger.logNetwork('Emptying trash for employeeId: $employeeId');
    return await _apiHelper.delete<Map<String, dynamic>>('mail/empty-trash/$employeeId');
  }

  /// 🗑️ Move multiple mails to trash
  Future<ApiResponse<Map<String, dynamic>>> moveManyToTrash({
    required List<String> mailIds,
    required String employeeId,
  }) async {
    _logger.logNetwork('Moving many mails to trash: $mailIds');
    return await _apiHelper.patch<Map<String, dynamic>>('mail/move-to-trash-many', {
      "mailIds": mailIds,
      "employeeId": employeeId,
    });
  }

  /// 🔁 Restore multiple mails from trash
  Future<ApiResponse<Map<String, dynamic>>> restoreManyFromTrash({
    required List<String> mailIds,
    required String employeeId,
  }) async {
    _logger.logNetwork('Restoring many mails from trash: $mailIds');
    return await _apiHelper.put<Map<String, dynamic>>('mail/restore-from-trash-many', {
      "mailIds": mailIds,
      "employeeId": employeeId,
    });
  }

  /// ❌ Delete mail permanently by ID
  Future<ApiResponse<Map<String, dynamic>>> deleteMail({required String mailId}) async {
    _logger.logNetwork('Deleting mail permanently with id: $mailId');
    return await _apiHelper.delete<Map<String, dynamic>>('mail/$mailId');
  }
}
