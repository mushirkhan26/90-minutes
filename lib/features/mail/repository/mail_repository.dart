import 'package:hrtz_hrms/core/models/employee.dart';

import '../../../core/models/mail_model.dart';
import '../../../core/services/mail_service.dart';

class MailRepository {
  final MailService service;

  MailRepository({required this.service});

  Future<Mail> sendMail(Map<String, dynamic> body) => service.sendMail(body);

  Future<List<Mail>> getInbox(String employeeId) =>
      service.getInbox(employeeId);
  Future<List<Employee>> getEmployee() async => service.getEmployee();

  Future<List<Mail>> getSent(String employeeId) => service.getSent(employeeId);

  Future<List<Mail>> getTrash(String employeeId) =>
      service.getTrash(employeeId);

  Future<bool> deleteMail(String mailId) => service.deleteMail(mailId);

  Future<bool> moveToTrash(String mailId) => service.moveToTrash(mailId);

  Future<bool> restoreFromTrash(String mailId) =>
      service.restoreFromTrash(mailId);

  Future<bool> emptyTrash(String employeeId) => service.emptyTrash(employeeId);

  Future<bool> moveManyToTrash(String employeeId, List<String> mailIds) =>
      service.moveManyToTrash(employeeId, mailIds);

  Future<bool> restoreManyFromTrash(String employeeId, List<String> mailIds) =>
      service.restoreManyFromTrash(employeeId, mailIds);
}
