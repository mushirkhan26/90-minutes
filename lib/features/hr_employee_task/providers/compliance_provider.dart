import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/compliance_service.dart';
import 'package:hrtz_hrms/core/models/compliance_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum ComplianceState { idle, loading, success, error }

class ComplianceProvider with ChangeNotifier {
  final ComplianceService _service = ComplianceService();
  final LocalStorageService _local = LocalStorageService();
  final SecureStorageService _secure = SecureStorageService();
  final LoggingService _logger = LoggingService.instance;

  // ---------------- STATE ----------------
  ComplianceState _state = ComplianceState.idle;
  ComplianceState get state => _state;
  bool get isLoading => _state == ComplianceState.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------- DATA ----------------
  List<Compliance> _compliances = [];
  List<Compliance> get compliances => _compliances;

  String? _employeeId;

  static const Duration _cacheDuration = Duration(minutes: 10);

  // ---------------- CONSTRUCTOR ----------------
  ComplianceProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _employeeId = await _secure.getEmployeeId();
    if (_employeeId == null) return;

    // Load from cache instantly
    final cached = await _local.getComplianceList(_employeeId!);
    if (cached != null) {
      _compliances = cached;
      _state = ComplianceState.success;
      notifyListeners();
      _logger.logStorage("✅ Compliance loaded from cache (bootstrap)");
    }

    // Silent refresh
    fetchCompliances(forceRefresh: false);
  }

  // ---------------- FETCH (CACHE FIRST) ----------------
  Future<void> fetchCompliances({bool forceRefresh = false}) async {
    if (_employeeId == null) return;

    try {
      if (!forceRefresh) {
        final cached = await _local.getComplianceList(_employeeId!);
        final timestamp =
            await _local.getComplianceTimestamp(_employeeId!);

        if (cached != null &&
            timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheDuration) {
          _compliances = cached;
          _state = ComplianceState.success;
          notifyListeners();
          _logger.logStorage("✅ Compliance loaded from cache");
          return;
        }
      }

      if (_compliances.isEmpty) {
        _state = ComplianceState.loading;
        notifyListeners();
      }

      _logger.logNetwork("🌐 Fetching compliance from API");

      final response =
          await _service.getEmployeeCompliance(_employeeId!);

      if (response.success && response.data != null) {
        _compliances = response.data!;

        await _local.saveComplianceList(
            _employeeId!, _compliances);

        _errorMessage = null;
        _state = ComplianceState.success;
      } else {
        _errorMessage = response.message;
        _state = _compliances.isNotEmpty
            ? ComplianceState.success
            : ComplianceState.error;
      }
    } catch (e) {
      _logger.error(
          "COMPLIANCE_PROVIDER", "Fetch failed",
          error: e);

      _errorMessage = e.toString();
      _state = _compliances.isNotEmpty
          ? ComplianceState.success
          : ComplianceState.error;
    }

    notifyListeners();
  }

  // ---------------- COUNTS ----------------

  int get totalCount => _compliances.length;

  int get actionRequiredCount => _compliances.where((c) {
        final s = c.status.trim().toLowerCase();
        return s == 'assigned' ||
            s == 'pending' ||
            s == 'action required';
      }).length;

  int get completedCount => _compliances.where((c) {
        final s = c.status.trim().toLowerCase();
        return s == 'submitted' || s == 'completed';
      }).length;

  int get overdueCount => _compliances.where((c) {
        final s = c.status.trim().toLowerCase();
        final isDone =
            s == 'submitted' || s == 'completed';

        final now = DateTime.now();
        final today =
            DateTime(now.year, now.month, now.day);

        final due = DateTime(
            c.dueDate.year,
            c.dueDate.month,
            c.dueDate.day);

        return !isDone && due.isBefore(today);
      }).length;

  // ---------------- SUBMIT ----------------

  Future<bool> submitCompliance(
      String complianceId,
      List<String> submittedDocuments) async {
    try {
      _state = ComplianceState.loading;
      notifyListeners();

      final response = await _service.submitCompliance(
          complianceId, submittedDocuments);

      if (response.success) {
        // Refresh after submit
        await fetchCompliances(forceRefresh: true);
        return true;
      }

      _errorMessage = response.message;
      _state = ComplianceState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _logger.error(
          "COMPLIANCE_PROVIDER", "Submit failed",
          error: e);

      _errorMessage = e.toString();
      _state = ComplianceState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAllCompliances() async {
  try {
    _state = ComplianceState.loading;
    notifyListeners();

    final response = await _service.getAllCompliances();

    if (response.success && response.data != null) {
      _compliances = response.data!;
      _state = ComplianceState.success;
    } else {
      _errorMessage = response.message;
      _state = ComplianceState.error;
    }
  } catch (e) {
    _errorMessage = e.toString();
    _state = ComplianceState.error;
  }

  notifyListeners();
}

Future<bool> createCompliance({
  required String employeeId,
  required String complianceType,
  required String title,
  required String description,
  required String note,
  required String dueDate,
  required List<String> requiredDocuments,
  required List<Map<String, String>> actionLinks,
}) async {
  try {
    _state = ComplianceState.loading;
    notifyListeners();

    final response = await _service.createCompliance(
      employeeId: employeeId,
      complianceType: complianceType,
      title: title,
      description: description,
      note: note,
      dueDate: dueDate,
      requiredDocuments: requiredDocuments,
      actionLinks: actionLinks,
    );

    if (response.success) {
      await fetchAllCompliances(); // refresh list
      _state = ComplianceState.success;
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    _state = ComplianceState.error;
    notifyListeners();
    return false;
  } catch (e) {
    _errorMessage = e.toString();
    _state = ComplianceState.error;
    notifyListeners();
    return false;
  }
}

Future<bool> updateCompliance({
  required String complianceId,
  required String employeeId,
  required String complianceType,
  required String title,
  required String description,
  required String note,
  required String dueDate,
  required List<String> requiredDocuments,
  required List<Map<String, String>> actionLinks,
}) async {
  try {
    _state = ComplianceState.loading;
    notifyListeners();

    final response = await _service.updateCompliance(
      complianceId: complianceId,
      employeeId: employeeId,
      complianceType: complianceType,
      title: title,
      description: description,
      note: note,
      dueDate: dueDate,
      requiredDocuments: requiredDocuments,
      actionLinks: actionLinks,
    );

    if (response.success) {
      await fetchAllCompliances(); // refresh list
      _state = ComplianceState.success;
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    _state = ComplianceState.error;
    notifyListeners();
    return false;
  } catch (e) {
    _errorMessage = e.toString();
    _state = ComplianceState.error;
    notifyListeners();
    return false;
  }
}

Future<bool> deleteCompliance(String complianceId) async {
  try {
    _state = ComplianceState.loading;
    notifyListeners();

    final response =
        await _service.deleteCompliance(complianceId);

    if (response.success) {
      _compliances.removeWhere(
          (c) => c.id == complianceId);

      _state = ComplianceState.success;
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    _state = ComplianceState.error;
    notifyListeners();
    return false;
  } catch (e) {
    _errorMessage = e.toString();
    _state = ComplianceState.error;
    notifyListeners();
    return false;
  }
}

  

  // ---------------- FORCE REFRESH ----------------

  Future<void> refresh() async {
    await fetchCompliances(forceRefresh: true);
  }
}