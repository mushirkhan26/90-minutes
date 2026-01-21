import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/mail_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import '../../../core/models/mail_model.dart';

enum MailState { idle, loading, loaded, error }

class MailProvider extends ChangeNotifier {
  final MailService _mailService = MailService();
  final LoggingService _logger = LoggingService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();
  final LocalStorageService _local = LocalStorageService();

  MailState _state = MailState.idle;
  String? _errorMessage;
  List<MailModel> _inboxMails = [];
  List<MailModel> _sentMails = [];
  List<MailModel> _trashMails = [];
  List<MailModel> _starredMails = [];
  
  String _activeFolder = 'Inbox';
  String _searchQuery = '';

  MailState get state => _state;
  String? get errorMessage => _errorMessage;

  List<MailModel> get displayedMails {
    List<MailModel> baseList;
    switch (_activeFolder) {
      case 'Sent': baseList = _sentMails; break;
      case 'Trash': baseList = _trashMails; break;
      case 'Starred': baseList = _starredMails; break;
      default: baseList = _inboxMails;
    }

    if (_searchQuery.isEmpty) return baseList;

    final query = _searchQuery.toLowerCase();
    return baseList.where((mail) {
      return mail.subject.toLowerCase().contains(query) ||
             mail.senderName.toLowerCase().contains(query) ||
             mail.receiverName.any((name) => name.toLowerCase().contains(query)) ||
             mail.body.toLowerCase().contains(query);
    }).toList();
  }

  void setActiveFolder(String folder) {
    _activeFolder = folder;
    _searchQuery = ''; 
    notifyListeners();
  }

  void searchMails(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // MAILS FETCHING
  // ---------------------------------------------------------------------------

  Future<void> fetchInbox({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();
    try {
      final employeeId = await _secureStorage.getEmployeeId();
      final response = await _mailService.getInbox(employeeId: employeeId!);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'];
        _inboxMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();
        await _local.saveMails(LocalStorageService.keyInboxMails, _inboxMails);
        _state = MailState.loaded;
      }
    } catch (e) {
      _state = MailState.error;
    }
    notifyListeners();
  }

  Future<void> fetchSent({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();
    try {
      final employeeId = await _secureStorage.getEmployeeId();
      final response = await _mailService.getSentMails(employeeId: employeeId!);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'];
        _sentMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();
        await _local.saveMails(LocalStorageService.keySentMails, _sentMails);
        _state = MailState.loaded;
      }
    } catch (e) {
      _state = MailState.error;
    }
    notifyListeners();
  }

  Future<void> fetchTrash({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();
    try {
      final employeeId = await _secureStorage.getEmployeeId();
      final response = await _mailService.getTrashMails(employeeId: employeeId!);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'];
        _trashMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();
        await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);
        _state = MailState.loaded;
      }
    } catch (e) {
      _state = MailState.error;
    }
    notifyListeners();
  }

  Future<void> fetchStarredMails({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();
    try {
      final employeeId = await _secureStorage.getEmployeeId();
      final response = await _mailService.getStarredMails(employeeId: employeeId!);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'];
        _starredMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();
        _state = MailState.loaded;
      }
    } catch (e) {
      _state = MailState.error;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // ACTIONS (Optimistic & Error Safe)
  // ---------------------------------------------------------------------------

  Future<void> toggleStarMail(MailModel mail) async {
    final original = mail.isStarred;
    mail.isStarred = !original;
    if (mail.isStarred) _starredMails.insert(0, mail);
    else _starredMails.removeWhere((m) => m.id == mail.id);
    notifyListeners();

    try {
      final employeeId = await _secureStorage.getEmployeeId();
      await _mailService.toggleStarMail(mailId: mail.id, employeeId: employeeId!, isStarred: mail.isStarred);
    } catch (e) {
      mail.isStarred = original;
      notifyListeners();
    }
  }

  Future<void> moveMailToTrash(MailModel mail) async => moveManyToTrash([mail]);

  Future<void> moveManyToTrash(List<MailModel> mails) async {
    if (mails.isEmpty) return;
    try {
      for (var m in mails) {
        _inboxMails.removeWhere((x) => x.id == m.id);
        _sentMails.removeWhere((x) => x.id == m.id);
        _starredMails.removeWhere((x) => x.id == m.id);
        _trashMails.insert(0, m);
      }
      notifyListeners();
      final employeeId = await _secureStorage.getEmployeeId();
      await _mailService.moveManyToTrash(mailIds: mails.map((e) => e.id).toList(), employeeId: employeeId!);
      await _saveAllLocally();
    } catch (e) {
      fetchInbox(); fetchSent(); fetchTrash();
    }
  }

  Future<void> restoreMail(MailModel mail) async => restoreMany([mail]);

  Future<void> restoreMany(List<MailModel> mails) async {
    if (mails.isEmpty) return;
    try {
      for (var m in mails) {
        _trashMails.removeWhere((x) => x.id == m.id);
        _inboxMails.insert(0, m);
      }
      notifyListeners();
      final employeeId = await _secureStorage.getEmployeeId();
      await _mailService.restoreManyFromTrash(mailIds: mails.map((e) => e.id).toList(), employeeId: employeeId!);
      await _saveAllLocally();
    } catch (e) {
      fetchInbox(); fetchTrash();
    }
  }

  Future<void> deleteMail(MailModel mail) async {
    try {
      _trashMails.removeWhere((m) => m.id == mail.id);
      notifyListeners();
      await _mailService.deleteMail(mailId: mail.id);
      await _saveTrashLocally();
    } catch (e) { fetchTrash(); }
  }

  Future<void> deleteAllTrash() async {
    try {
      _trashMails.clear();
      notifyListeners();
      final employeeId = await _secureStorage.getEmployeeId();
      await _mailService.emptyTrash(employeeId!);
      await _saveTrashLocally();
    } catch (e) { fetchTrash(); }
  }

  Future<void> _saveAllLocally() async {
    await _local.saveMails(LocalStorageService.keyInboxMails, _inboxMails);
    await _local.saveMails(LocalStorageService.keySentMails, _sentMails);
    await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);
  }

  Future<void> _saveTrashLocally() async => await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);

  Future<bool> sendMail({
    required String sender, required String senderName, required List<String> receiver,
    required List<String> receiverName, required List<String> cc, required List<String> bcc,
    required String subject, required String body, required List<String> attachmentUrls,
  }) async {
    try {
      final response = await _mailService.sendMail(
        sender: sender, senderName: senderName, receiver: receiver, receiverName: receiverName,
        cc: cc, bcc: bcc, subject: subject, body: body, attachmentUrls: attachmentUrls,
      );
      if (response.success) { fetchSent(); return true; }
      return false;
    } catch (e) { return false; }
  }
}
