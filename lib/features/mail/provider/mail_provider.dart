import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/employee.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

import '../../../core/models/mail_model.dart';
import '../repository/mail_repository.dart';

class MailProvider extends ChangeNotifier {
  final MailRepository repository;
  final LocalStorageService _localStorage = LocalStorageService();
  final secureStorageService = SecureStorageService();
  List<Mail> _inbox = [];
  List<Mail> _sent = [];
  List<Mail> _trash = [];
  List<Employee> _employee = [];

  bool _isLoading = false;
  String? _error;

  MailProvider({required this.repository});

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Mail> get inbox => _inbox;
  List<Mail> get sent => _sent;
  List<Mail> get trash => _trash;
  List<Employee> get employee => _employee;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Fetch inbox mails
  Future<void> fetchInbox() async {
    _setLoading(true);
    _setError(null);
    try {
      // final employeeId = (await secureStorageService
      //     .getUserData())!['employeeId'];
      _inbox = await repository.getInbox('25060018');
      if ((await _localStorage.getEmployee()) == null) {
        _employee = await repository.getEmployee();
        _localStorage.saveEmployee(_employee);
      } else {
        _employee = await _localStorage.getEmployee() ?? [];
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Fetch sent mails
  Future<void> fetchSent(String employeeId) async {
    _setLoading(true);
    _setError(null);
    try {
      _sent = await repository.getSent(employeeId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Fetch trash mails
  Future<void> fetchTrash(String employeeId) async {
    _setLoading(true);
    _setError(null);
    try {
      _trash = await repository.getTrash(employeeId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Send a mail
  Future<void> sendMail(Map<String, dynamic> body) async {
    _setLoading(true);
    _setError(null);
    try {
      final sentMail = await repository.sendMail(body);
      if (sentMail != null) {
        _sent.insert(0, sentMail);
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Delete a mail
  Future<void> deleteMail(String mailId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await repository.deleteMail(mailId);
      if (success) {
        // _inbox.removeWhere((m) => m.data?.id == mailId);
        _sent.removeWhere((m) => m.id == mailId);
        _trash.removeWhere((m) => m.id == mailId);
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Move one mail to trash
  Future<void> moveToTrash(String mailId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await repository.moveToTrash(mailId);
      if (success) {
        final mail = _inbox.firstWhere(
          (m) => m.id == mailId,
          orElse: () => _sent.firstWhere((m) => m.id == mailId),
        );
        _inbox.remove(mail);
        _sent.remove(mail);
        _trash.insert(0, mail);
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Restore one mail from trash
  Future<void> restoreFromTrash(String mailId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await repository.restoreFromTrash(mailId);
      if (success) {
        final mail = _trash.firstWhere((m) => m.id == mailId);
        _trash.remove(mail);
        _inbox.insert(0, mail); // or _sent depending on original folder
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Empty trash
  Future<void> emptyTrash(String employeeId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await repository.emptyTrash(employeeId);
      if (success) {
        _trash.clear();
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Move many mails to trash
  Future<void> moveManyToTrash(String employeeId, List<String> mailIds) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await repository.moveManyToTrash(employeeId, mailIds);
      if (success) {
        _inbox.removeWhere((m) => mailIds.contains(m.id));
        _sent.removeWhere((m) => mailIds.contains(m.id));
        _trash.addAll(
          mailIds.map(
            (id) => _inbox.firstWhere(
              (m) => m.id == id,
              orElse: () => _sent.firstWhere((m) => m.id == id),
            ),
          ),
        );
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Restore many mails from trash
  Future<void> restoreManyFromTrash(
    String employeeId,
    List<String> mailIds,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await repository.restoreManyFromTrash(
        employeeId,
        mailIds,
      );
      if (success) {
        final mailsToRestore = _trash
            .where((m) => mailIds.contains(m.id))
            .toList();
        _trash.removeWhere((m) => mailIds.contains(m.id));
        _inbox.addAll(mailsToRestore);
      }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }
}
