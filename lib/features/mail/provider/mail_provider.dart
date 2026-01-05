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
  List<MailModel> _filteredMails = [];

  MailState get state => _state;
  String? get errorMessage => _errorMessage;
  List<MailModel> get inboxMails => _filteredMails.isNotEmpty ? _filteredMails : _inboxMails;
  List<MailModel> get sentMails => _sentMails;
  List<MailModel> get trashMails => _trashMails;
  List<MailModel> get starredMails => _starredMails;

  /// Duration to consider cache as valid (e.g., 10 minutes)
  static const cacheValidity = Duration(minutes: 10);

  // ---------------------------------------------------------------------------
  // 📨 FETCH INBOX MAILS
  // ---------------------------------------------------------------------------
  Future<void> fetchInbox({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();

    try {
      final cachedInbox = await _local.getMails(LocalStorageService.keyInboxMails);
      final lastCacheTime = await _local.getMailCacheTimestamp(LocalStorageService.keyInboxMails);
      final now = DateTime.now();

      // ✅ Load cached data if available
      if (cachedInbox != null && cachedInbox.isNotEmpty) {
        _inboxMails = cachedInbox.where((mail) => !_trashMails.any((t) => t.id == mail.id)).toList();
        _state = MailState.loaded;
        notifyListeners();
      }

      final shouldRefresh =
          forceRefresh || lastCacheTime == null || now.difference(lastCacheTime) > cacheValidity;

      if (!shouldRefresh && cachedInbox != null && cachedInbox.isNotEmpty) {
        _logger.logStorage('🟢 Inbox cache still valid, skipping API call');
        return;
      }

      // 🔄 Fetch from API
      final employeeId = await _secureStorage.getEmployeeId();
      if (employeeId == null) throw Exception('Employee ID not found');

      final response = await _mailService.getInbox(employeeId: employeeId);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'];
        _inboxMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();
        _inboxMails.removeWhere((mail) => _trashMails.any((t) => t.id == mail.id));
        _filteredMails.clear();

        await _local.saveMails(LocalStorageService.keyInboxMails, _inboxMails);

        _state = MailState.loaded;
        _logger.logNetwork('✅ Inbox refreshed (${_inboxMails.length} mails)');
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _errorMessage = 'Failed to fetch inbox: $e';
      _logger.error('MAIL_PROVIDER', 'fetchInbox failed', error: e, stackTrace: s);
      if (_inboxMails.isEmpty) _state = MailState.error;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 📤 FETCH SENT MAILS
  // ---------------------------------------------------------------------------
  Future<void> fetchSent({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();

    try {
      final cachedSent = await _local.getMails(LocalStorageService.keySentMails);
      final lastCacheTime = await _local.getMailCacheTimestamp(LocalStorageService.keySentMails);
      final now = DateTime.now();

      if (cachedSent != null && cachedSent.isNotEmpty) {
        _sentMails = cachedSent;
        _state = MailState.loaded;
        notifyListeners();
      }

      final shouldRefresh =
          forceRefresh || lastCacheTime == null || now.difference(lastCacheTime) > cacheValidity;

      if (!shouldRefresh && cachedSent != null && cachedSent.isNotEmpty) {
        _logger.logStorage('🟢 Sent cache still valid, skipping API call');
        return;
      }

      final employeeId = await _secureStorage.getEmployeeId();
      if (employeeId == null) throw Exception('Employee ID not found');

      final response = await _mailService.getSentMails(employeeId: employeeId);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'];
        _sentMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();

        await _local.saveMails(LocalStorageService.keySentMails, _sentMails);
        _state = MailState.loaded;
        _logger.logNetwork('✅ Sent refreshed (${_sentMails.length} mails)');
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _errorMessage = 'Failed to fetch sent mails: $e';
      _logger.error('MAIL_PROVIDER', 'fetchSent failed', error: e, stackTrace: s);
      if (_sentMails.isEmpty) _state = MailState.error;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🗑️ FETCH TRASH MAILS
  // ---------------------------------------------------------------------------
  Future<void> fetchTrash({bool forceRefresh = false}) async {
    _state = MailState.loading;
    notifyListeners();

    try {
      final cachedTrash = await _local.getMails(LocalStorageService.keyTrashMails);
      final lastCacheTime = await _local.getMailCacheTimestamp(LocalStorageService.keyTrashMails);
      final now = DateTime.now();

      if (cachedTrash != null && cachedTrash.isNotEmpty) {
        _trashMails = cachedTrash;
        _state = MailState.loaded;
        notifyListeners();
      }

      final shouldRefresh =
          forceRefresh || lastCacheTime == null || now.difference(lastCacheTime) > cacheValidity;

      if (!shouldRefresh && cachedTrash != null && cachedTrash.isNotEmpty) {
        _logger.logStorage('🟢 Trash cache still valid, skipping API call');
        return;
      }

      final employeeId = await _secureStorage.getEmployeeId();
      if (employeeId == null) throw Exception('Employee ID not found');

      final response = await _mailService.getTrashMails(employeeId: employeeId);
      if (response.success && response.data != null) {
        final List<dynamic> mailsJson = response.data!['data'];
        _trashMails = mailsJson.map((json) => MailModel.fromJson(json)).toList();

        await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);
        _state = MailState.loaded;
        _logger.logNetwork('✅ Trash refreshed (${_trashMails.length} mails)');
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _errorMessage = 'Failed to fetch trash mails: $e';
      _logger.error('MAIL_PROVIDER', 'fetchTrash failed', error: e, stackTrace: s);
      if (_trashMails.isEmpty) _state = MailState.error;
    }

    notifyListeners();
  }
// ⭐ FETCH STARRED MAILS
// ---------------------------------------------------------------------------
Future<void> fetchStarredMails({bool forceRefresh = false}) async {
  _state = MailState.loading;
  notifyListeners();

  try {
    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId == null) throw Exception('Employee ID not found');

    final response =
        await _mailService.getStarredMails(employeeId: employeeId);

    if (response.success && response.data != null) {
      final List<dynamic> mailsJson = response.data!['data'];
      _starredMails = mailsJson
     .map((json) => MailModel.fromJson(json))
     .where((mail) => !_trashMails.any((t) => t.id == mail.id))
     .toList();


      _state = MailState.loaded;
      _logger.logNetwork(
          '✅ Starred mails fetched (${_starredMails.length})');
    } else {
      throw Exception(response.message);
    }
  } catch (e, s) {
    _errorMessage = 'Failed to fetch starred mails: $e';
    _logger.error('MAIL_PROVIDER', 'fetchStarredMails failed',
        error: e, stackTrace: s);
    if (_starredMails.isEmpty) _state = MailState.error;
  }

  notifyListeners();
}

  /// Refresh inbox mails
  Future<void> refreshInbox() async {
    await fetchInbox();
  }

  /// ---------------------------------------------------------------------------
  /// 🔍 SEARCH MAILS (only in Inbox)
  /// ---------------------------------------------------------------------------
  void searchMails(String query) {
    if (query.isEmpty) {
      _filteredMails = [];
    } else {
      _filteredMails = _inboxMails.where((mail) {
        return mail.subject.toLowerCase().contains(query.toLowerCase()) ||
            mail.senderName.toLowerCase().contains(query.toLowerCase()) ||
            mail.body.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
  // ⭐ TOGGLE STAR / UNSTAR MAIL
// ---------------------------------------------------------------------------
Future<void> toggleStarMail(MailModel mail) async {
  try {
    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId == null) throw Exception('Employee ID not found');

    final newValue = !mail.isStarred;

    await _mailService.toggleStarMail(
      mailId: mail.id,
      employeeId: employeeId,
      isStarred: newValue,
    );

    // Update local state
    mail.isStarred = newValue;

    if (newValue) {
      _starredMails.add(mail);
    } else {
      _starredMails.removeWhere((m) => m.id == mail.id);
    }

    notifyListeners();
    _logger.logNetwork('⭐ Mail star updated: ${mail.id}');
  } catch (e, s) {
    _logger.error('MAIL_PROVIDER', 'toggleStarMail failed',
        error: e, stackTrace: s);
  }
}
  // ===========================================================================
  // ♻️ MOVE / RESTORE / DELETE (with API + Local Sync)
  // ===========================================================================

  /// Move a single mail to trash (local + API)
 Future<void> moveMailToTrash(MailModel mail) async {
  _logger.logNetwork('🗑️ Moving mail to trash: ${mail.id}');

  // 🔑 LOCAL FIRST
  _inboxMails.removeWhere((m) => m.id == mail.id);
  _starredMails.removeWhere((m) => m.id == mail.id);
  _trashMails.add(mail);

  await _saveAllLocally();
  notifyListeners();

  try {
    await _mailService.moveToTrash(mail.id);
    _logger.logNetwork('✅ Mail moved to trash (${mail.id})');
  } catch (e, s) {
    _logger.error('MAIL_PROVIDER', 'moveMailToTrash failed', error: e, stackTrace: s);
  }
}


  /// Move multiple mails to trash
  Future<void> moveManyToTrash(List<MailModel> mails) async {
  _logger.logNetwork('🗑️ Moving ${mails.length} mails to trash');

  try {
    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId == null) throw Exception('Employee ID not found');

    final mailIds = mails.map((e) => e.id).toList();

    // 1️⃣ API
    await _mailService.moveManyToTrash(
      mailIds: mailIds,
      employeeId: employeeId,
    );

    // 2️⃣ Local update
    for (final mail in mails) {
      _inboxMails.removeWhere((m) => m.id == mail.id);
      _starredMails.removeWhere((m) => m.id == mail.id);
      _trashMails.add(mail);
    }

    await _saveAllLocally();
    notifyListeners();

    _logger.logNetwork('✅ ${mails.length} mails moved to trash');
  } catch (e, s) {
    _logger.error('MAIL_PROVIDER', 'moveManyToTrash failed', error: e, stackTrace: s);
  }
}

  /// Restore a single mail from trash
  Future<void> restoreMail(MailModel mail) async {
    _logger.logNetwork('♻️ Restoring mail: ${mail.id}');
    try {
      _trashMails.remove(mail);
      _inboxMails.add(mail);
      await _local.saveMails(LocalStorageService.keyInboxMails, _inboxMails);
      await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);

      await _mailService.restoreFromTrash(mail.id);
      _logger.logNetwork('✅ Mail restored (${mail.id})');
    } catch (e, s) {
      _logger.error('MAIL_PROVIDER', 'restoreMail failed', error: e, stackTrace: s);
    }
    notifyListeners();
  }

  /// Restore multiple mails from trash
  Future<void> restoreMany(List<MailModel> mails) async {
    _logger.logNetwork('♻️ Restoring ${mails.length} mails');
    try {
      for (final mail in mails) {
        _trashMails.remove(mail);
        _inboxMails.add(mail);
      }
      await _saveAllLocally();

      final mailIds = mails.map((e) => e.id).toList();
      final employeeId = await _secureStorage.getEmployeeId();
      if (employeeId == null) throw Exception('Employee ID not found');

      await _mailService.restoreManyFromTrash(mailIds: mailIds, employeeId: employeeId);

      _logger.logNetwork('✅ ${mails.length} mails restored');
    } catch (e, s) {
      _logger.error('MAIL_PROVIDER', 'restoreMany failed', error: e, stackTrace: s);
    }
    notifyListeners();
  }

  /// Permanently delete a mail
  Future<void> deleteMail(MailModel mail) async {
    _logger.logNetwork('🗑️ Permanently deleting mail: ${mail.id}');
    try {
      await _mailService.deleteMail(mailId: mail.id);
      _trashMails.removeWhere((m) => m.id == mail.id);
      _inboxMails.removeWhere((m) => m.id == mail.id);
      _starredMails.removeWhere((m) => m.id == mail.id);
      await _saveTrashLocally();
      notifyListeners();
      _logger.logNetwork('✅ Mail deleted permanently (${mail.id})');
    } catch (e, s) {
      _logger.error('MAIL_PROVIDER', 'deleteMail failed', error: e, stackTrace: s);
    }
  }

  /// Permanently delete all mails in trash
  Future<void> deleteAllTrash() async {
  _logger.logNetwork('🗑️ Permanently deleting all trash mails');

  try {
    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId == null) throw Exception('Employee ID not found');

    // 🔑 STEP 1: Store trash mail IDs
    final trashIds = _trashMails.map((m) => m.id).toList();

    // 🔑 STEP 2: API
    await _mailService.emptyTrash(employeeId);

    // 🔑 STEP 3: LOCAL REMOVE EVERYWHERE
    _trashMails.clear();
    _inboxMails.removeWhere((m) => trashIds.contains(m.id));
    _starredMails.removeWhere((m) => trashIds.contains(m.id));

    // 🔑 STEP 4: SAVE
    await _saveAllLocally();

    notifyListeners();
    _logger.logNetwork('✅ All trash mails deleted permanently');
  } catch (e, s) {
    _logger.error('MAIL_PROVIDER', 'deleteAllTrash failed', error: e, stackTrace: s);
  }
}

  // ===========================================================================
  // 💾 LOCAL HELPERS
  // ===========================================================================
  Future<void> _saveAllLocally() async {
    await _local.saveMails(LocalStorageService.keyInboxMails, _inboxMails);
    await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);
  }

  Future<void> _saveTrashLocally() async {
    await _local.saveMails(LocalStorageService.keyTrashMails, _trashMails);
  }

  /// Send mail
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
        _logger.logNetwork('✅ Mail sent successfully');
        return true;
      } else {
        _logger.logNetwork('❌ Failed to send mail: ${response.message}', level: LogLevel.error);
        return false;
      }
    } catch (e, s) {
      _logger.error('MAIL_PROVIDER', 'Failed to send mail', error: e, stackTrace: s);
      return false;
    }
  }
}
