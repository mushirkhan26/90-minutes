import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/api/network/mail_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import '../../../core/models/mail_model.dart';

class MailProvider extends ChangeNotifier {
  final mailService = MailService(baseUrl2: ApiHelper.baseUrl2);
  final LocalStorageService _localStorage = LocalStorageService();
  final secureStorageService = SecureStorageService();

  List<Mail> _inbox = [];
  List<Mail> _sent = [];
  List<Mail> _trash = [];
  List<EmployeeModel> _employee = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Mail> get inbox => _inbox;
  List<Mail> get sent => _sent;
  List<Mail> get trash => _trash;
  List<EmployeeModel> get employee => _employee;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // Fetch inbox mails
  Future<void> fetchInbox() async {
    _setLoading(true);
    _setError(null);
    try {
      final employeeId = (await secureStorageService.getUserData())!['employeeId'];
      final apiInbox = await mailService.getInbox(employeeId ?? '25060018');
      _inbox = apiInbox.where((apiMail) {
        return !_trash.any((trashMail) => trashMail.id == apiMail.id);
      }).toList();

      if ((await _localStorage.getEmployeeList()) == null) {
        _employee = await mailService.getEmployee();
        _localStorage.saveEmployeeList(_employee);
      } else {
        _employee = await _localStorage.getEmployeeList() ?? [];
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch sent mails
  Future<void> fetchSent(String employeeId) async {
    _setLoading(true);
    _setError(null);
    try {
      _sent = await mailService.getSent(employeeId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch trash mails
  Future<void> fetchTrash(String employeeId) async {
    _setLoading(true);
    _setError(null);
    try {
      _trash = await mailService.getTrash(employeeId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Move one mail to trash
  Future<bool> moveToTrash(String mailId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await mailService.moveToTrash(mailId);
      if (success) {
        final mailInInbox = _inbox.firstWhereOrNull((m) => m.id == mailId);
        final mailInSent = _sent.firstWhereOrNull((m) => m.id == mailId);

        if (mailInInbox != null) {
          _inbox.remove(mailInInbox);
          _trash.insert(0, mailInInbox);
        } else if (mailInSent != null) {
          _sent.remove(mailInSent);
          _trash.insert(0, mailInSent);
        } else {
          _setError('Mail not found');
          return false;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send a mail
  Future<void> sendMail(Map<String, dynamic> body) async {
    _setLoading(true);
    _setError(null);
    try {
      final sentMail = await mailService.sendMail(body);
      if (sentMail != null) {
        _sent.insert(0, sentMail);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Delete a mail
  Future<bool> deleteMail(String mailId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await mailService.deleteMail(mailId);
      if (success) {
        _sent.removeWhere((mail) => mail.id == mailId);
        _trash.removeWhere((mail) => mail.id == mailId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Restore one mail from trash
  Future<void> restoreFromTrash(String mailId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await mailService.restoreFromTrash(mailId);
      if (success) {
        final mail = _trash.firstWhere((m) => m.id == mailId);
        _trash.remove(mail);
        _inbox.insert(0, mail);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Empty trash
  Future<void> emptyTrash(String employeeId) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await mailService.emptyTrash(employeeId);
      if (success) {
        _trash.clear();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Move many mails to trash
  Future<void> moveManyToTrash(String employeeId, List<String> mailIds) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await mailService.moveManyToTrash(employeeId, mailIds);
      if (success) {
        final movedMails = <Mail>[];
        for (var id in mailIds) {
          final mail = _inbox.firstWhere(
            (m) => m.id == id,
            orElse: () => _sent.firstWhere((m) => m.id == id),
          );
          movedMails.add(mail);
        }
        _inbox.removeWhere((m) => mailIds.contains(m.id));
        _sent.removeWhere((m) => mailIds.contains(m.id));
        _trash.insertAll(0, movedMails);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Restore many mails from trash
  Future<void> restoreManyFromTrash(String employeeId, List<String> mailIds) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await mailService.restoreManyFromTrash(employeeId, mailIds);
      if (success) {
        final mailsToRestore = _trash.where((m) => mailIds.contains(m.id)).toList();
        _trash.removeWhere((m) => mailIds.contains(m.id));
        _inbox.addAll(mailsToRestore);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}

extension FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
