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
  String? _currentUserId;

  MailState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;

  List<MailModel> get displayedMails {
    List<MailModel> baseList;
    switch (_activeFolder) {
      case 'Sent':
        baseList = _sentMails;
        break;
      case 'Trash':
        baseList = _trashMails;
        break;
      case 'Starred':
        baseList = _starredMails;
        break;
      default:
        baseList = _inboxMails;
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
    if (_activeFolder == folder) return;
    _activeFolder = folder;
    _searchQuery = '';
    // Optional: Clear specific list to show loading state clearly
    notifyListeners();
  }

  void searchMails(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _ensureUserId() async {
    final id = await _secureStorage.getEmployeeId();
    if (_currentUserId != id) {
      _currentUserId = id;
      _clearAllData(); // Clear everything if user changed
    }
  }

  void _clearAllData() {
    _inboxMails = [];
    _sentMails = [];
    _trashMails = [];
    _starredMails = [];
    notifyListeners();
  }

  Future<void> fetchInbox({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();
    try {
      await _ensureUserId();
      if (_currentUserId == null) return;

      final response = await _mailService.getInbox(employeeId: _currentUserId!);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'] ?? [];
        _inboxMails = mailsJson
            .map((json) => MailModel.fromJson(json))
            .toList();

        // Double check: Only keep mails where I am a receiver
        _inboxMails = _inboxMails
            .where((m) => m.receiver.contains(_currentUserId))
            .toList();

        await _local.saveMails(LocalStorageService.keyInboxMails, _inboxMails);
        _state = MailState.loaded;
      }
    } catch (e) {
      _logger.error('MAIL_PROVIDER', 'Error fetching inbox', error: e);
      _state = MailState.error;
    }
    notifyListeners();
  }

  Future<void> fetchSent({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();
    try {
      await _ensureUserId();
      if (_currentUserId == null) return;

      final response = await _mailService.getSentMails(
        employeeId: _currentUserId!,
      );
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'] ?? [];
        _sentMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();

        // Double check: Only keep mails sent by me
        _sentMails = _sentMails
            .where((m) => m.sender == _currentUserId)
            .toList();

        await _local.saveMails(LocalStorageService.keySentMails, _sentMails);
        _state = MailState.loaded;
      }
    } catch (e) {
      _logger.error('MAIL_PROVIDER', 'Error fetching sent', error: e);
      _state = MailState.error;
    }
    notifyListeners();
  }

  Future<void> fetchTrash({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();
    try {
      await _ensureUserId();
      if (_currentUserId == null) return;

      final response = await _mailService.getTrashMails(
        employeeId: _currentUserId!,
      );
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'] ?? [];
        _trashMails = mailsJson
            .map((json) => MailModel.fromJson(json))
            .toList();
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
      await _ensureUserId();
      if (_currentUserId == null) return;

      final response = await _mailService.getStarredMails(
        employeeId: _currentUserId!,
      );
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'] ?? [];
        _starredMails = mailsJson
            .map((json) => MailModel.fromJson(json))
            .toList();
        _state = MailState.loaded;
      }
    } catch (e) {
      _state = MailState.error;
    }
    notifyListeners();
  }

  Future<void> toggleStarMail(MailModel mail) async {
    final original = mail.isStarred;
    mail.isStarred = !original;
    if (mail.isStarred) {
      if (!_starredMails.any((m) => m.id == mail.id))
        _starredMails.insert(0, mail);
    } else {
      _starredMails.removeWhere((m) => m.id == mail.id);
    }
    notifyListeners();

    try {
      await _ensureUserId();
      await _mailService.toggleStarMail(
        mailId: mail.id,
        employeeId: _currentUserId!,
        isStarred: mail.isStarred,
      );
      // 🔥 Always refresh starred from backend
      await fetchStarredMails();

      if (_activeFolder == 'Sent') {
        await fetchSent(forceRefresh: true);
      } else if (_activeFolder == 'Inbox') {
        await fetchInbox(forceRefresh: true);
      }
    } catch (e) {
      mail.isStarred = original;

      if (original) {
        _starredMails.insert(0, mail);
      } else {
        _starredMails.removeWhere((m) => m.id == mail.id);
      }

      notifyListeners();
    }
  }

  Future<void> moveMailToTrash(MailModel mail) async => moveManyToTrash([mail]);

  Future<void> moveManyToTrash(List<MailModel> mails) async {
    if (mails.isEmpty) return;
    final List<MailModel> mailsToMove = List.from(mails);
    try {
      for (var m in mailsToMove) {
        _inboxMails.removeWhere((x) => x.id == m.id);
        _sentMails.removeWhere((x) => x.id == m.id);
        _starredMails.removeWhere((x) => x.id == m.id);
        if (!_trashMails.any((x) => x.id == m.id)) _trashMails.insert(0, m);
      }
      notifyListeners();
      await _ensureUserId();
      await _mailService.moveManyToTrash(
        mailIds: mailsToMove.map((e) => e.id).toList(),
        employeeId: _currentUserId!,
      );
      await _saveAllLocally();
    } catch (e) {
      fetchInbox();
      fetchSent();
      fetchTrash();
    }
  }

  Future<void> restoreMail(MailModel mail) async => restoreMany([mail]);

  Future<void> restoreMany(List<MailModel> mails) async {
    if (mails.isEmpty) return;
    final List<MailModel> listToRestore = List.from(mails);
    try {
      for (var m in listToRestore) {
        _trashMails.removeWhere((x) => x.id == m.id);
      }
      notifyListeners();
      await _ensureUserId();
      await _mailService.restoreManyFromTrash(
        mailIds: listToRestore.map((e) => e.id).toList(),
        employeeId: _currentUserId!,
      );

      // Refresh to put them back in correct places (Inbox or Sent)
      await Future.wait([fetchInbox(), fetchSent(), fetchTrash()]);
      await _saveAllLocally();
    } catch (e) {
      fetchInbox();
      fetchSent();
      fetchTrash();
    }
  }

  Future<void> deleteMail(MailModel mail) async {
    try {
      _trashMails.removeWhere((m) => m.id == mail.id);
      notifyListeners();
      await _mailService.deleteMail(mailId: mail.id);
      await _saveTrashLocally();
    } catch (e) {
      fetchTrash();
    }
  }

  Future<void> deleteAllTrash() async {
    try {
      _trashMails.clear();
      notifyListeners();
      await _ensureUserId();
      await _mailService.emptyTrash(_currentUserId!);
      await _saveTrashLocally();
    } catch (e) {
      fetchTrash();
    }
  }

  Future<void> _saveAllLocally() async {
    await _local.saveMails(LocalStorageService.keyInboxMails, _inboxMails);
    await _local.saveMails(LocalStorageService.keySentMails, _sentMails);
    await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);
  }

  Future<void> _saveTrashLocally() async =>
      await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);

  Future<bool> sendMail({
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
    try {
      final response = await _mailService.sendMail(
        sender: sender,
        senderName: senderName,
        receiver: receiver,
        receiverName: receiverName,
        cc: cc,
        bcc: bcc,
        subject: subject,
        body: body,
        attachmentUrls: attachmentUrls,
      );
      if (response.success) {
        fetchSent();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
