import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/service_request_service.dart';
import 'package:hrtz_hrms/features/service_request/widgets/service_request_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum ServiceRequestState { idle, loading, success, error }

class ServiceRequestProvider extends ChangeNotifier {
  final ServiceRequestService _service = ServiceRequestService();
  final LocalStorageService _localStorage = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  // ================= STATE =================
  ServiceRequestState _state = ServiceRequestState.idle;
  ServiceRequestState get state => _state;

  String? _error;
  String? get error => _error;

  // ================= DATA =================
  List<ServiceRequest> _allRequests = [];
  Map<String, int> _requestCounts = {};

  List<ServiceRequest> get allRequests => _allRequests;
  Map<String, int> get requestCounts => _requestCounts;

  bool _isDepartmentLoading = false;
  bool get isDepartmentLoading => _isDepartmentLoading;

  bool _isUserRequestsLoading = false;
  bool get isUserRequestLoading => _isUserRequestsLoading;

  List<String> _departments = [];
  
  List<String> get departments => _departments;

  static const Duration _cacheValidity = Duration(minutes: 10);

  // ================= CONSTRUCTOR =================
  ServiceRequestProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromCache();
    await _loadDepartmentsFromCache();
    await fetchDepartments();
    await fetchServiceRequests();
    await fetchRequestCounts();
  }

  // ================= LOAD FROM CACHE =================
  Future<void> _loadFromCache() async {
    final cachedRequests = await _localStorage.getServiceRequests();
    final cachedCounts = await _localStorage.getServiceRequestCounts();

    if (cachedRequests != null && cachedRequests.isNotEmpty) {
      _allRequests = cachedRequests
          .map((e) => ServiceRequest.fromJson(e))
          .toList();

      _state = ServiceRequestState.success;
      notifyListeners();
    }

    if (cachedCounts != null) {
      _requestCounts =
          cachedCounts.map((k, v) => MapEntry(k, v as int));
      notifyListeners();
    }
  }

  // ================= LOAD DEPARTMENTS FROM CACHE =================
Future<void> _loadDepartmentsFromCache() async {
  final cached = await _localStorage.getDepartments();
  if (cached != null && cached.isNotEmpty) {
    _departments = cached;
    notifyListeners();
  }
}

  // ================= GET ALL REQUESTS =================
  Future<void> fetchServiceRequests({bool forceRefresh = false}) async {
  try {
    final lastFetched =
        await _localStorage.getServiceRequestTimestamp();
    final now = DateTime.now();

    final shouldRefresh = forceRefresh ||
        lastFetched == null ||
        now.difference(lastFetched) > _cacheValidity;

    if (!shouldRefresh && _allRequests.isNotEmpty) {
      _logger.logStorage(
        "🟢 ServiceRequest cache valid, skipping API",
      );
      _state = ServiceRequestState.success;
      notifyListeners();
      return;
    }

    _state = ServiceRequestState.loading;
    notifyListeners();

    final response = await _service.getAllRequests();

    if (response.success && response.data != null) {
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] is List) {
        final List list = data['data'];

        _allRequests =
            list.map((e) => ServiceRequest.fromJson(e)).toList();

        await _localStorage.saveServiceRequests(
          _allRequests.map((e) => e.toJson()).toList(),
        );

        _state = ServiceRequestState.success;
        _logger.logNetwork(
          "✅ Service requests fetched (${_allRequests.length})",
        );
        notifyListeners();
        return;
      }
    }

    // ❌ only if structure is wrong
    throw Exception("Invalid API response structure");

  } catch (e, s) {
    _error = e.toString();
    _logger.error(
      "SERVICE_REQUEST_PROVIDER",
      "fetchServiceRequests failed",
      error: e,
      stackTrace: s,
    );
    if (_allRequests.isEmpty) {
      _state = ServiceRequestState.error;
    }
    notifyListeners();
  }
}

  // ================= GET REQUEST COUNTS =================
  Future<void> fetchRequestCounts({bool forceRefresh = false}) async {
    try {
      final cachedCounts =
          await _localStorage.getServiceRequestCounts();

      if (cachedCounts != null && !forceRefresh) {
        _requestCounts =
            cachedCounts.map((k, v) => MapEntry(k, v as int));
        notifyListeners();
      }

      final response = await _service.getRequestCounts();

      if (response.success &&
          response.data is Map<String, dynamic>) {
        final Map<String, dynamic> message = response.data['message'] as Map<String, dynamic>;
        final Map<String, dynamic> categoryCounts = message['categoryCounts'] as Map<String, dynamic>;
        _requestCounts = categoryCounts.map(
          (k, v) => MapEntry(k, v as int),
        );

        await _localStorage.saveServiceRequestCounts(_requestCounts);
        _logger.logNetwork("✅ Request counts updated");
        notifyListeners();
      }
    } catch (e) {
      _logger.error(
        "SERVICE_REQUEST_PROVIDER",
        "fetchRequestCounts error",
        error: e,
      );
    }
  }

  // ================= UPDATE STATUS =================
  Future<bool> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    _state = ServiceRequestState.loading;
    notifyListeners();

    try {
      final response = await _service.updateRequestStatus(
        requestId: requestId,
        status: status,
      );

      if (response.success) {
        final index =
            _allRequests.indexWhere((r) => r.requestId == requestId);

        if (index != -1) {
          _allRequests[index] =
              _allRequests[index].copyWith(requestStatus: status);

          // ✅ SAVE AS MAP LIST
          await _localStorage.saveServiceRequests(
            _allRequests.map((e) => e.toJson()).toList(),
          );
        }

        await fetchRequestCounts(forceRefresh: true);

        _state = ServiceRequestState.success;
        notifyListeners();
        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _error = e.toString();
      _state = ServiceRequestState.error;
      notifyListeners();
      return false;
    }
  }

  // ================= GET REQUESTS BY EMPLOYEE =================
Future<void> fetchRequestsByEmployee(String employeeId) async {
  try {
    _isUserRequestsLoading = true;
    notifyListeners();

    final response =
        await _service.getRequestsByEmployee(employeeId);

    if (response.success && response.data is Map<String, dynamic>) {
      final List list = response.data['message'] as List;

      _allRequests =
          list.map((e) => ServiceRequest.fromJson(e)).toList();
    }
  } catch (e, s) {
    _logger.error(
      "SERVICE_REQUEST_PROVIDER",
      "fetchRequestsByEmployee failed",
      error: e,
      stackTrace: s,
    );
  } finally {
    _isUserRequestsLoading = false;
    notifyListeners();
  }
}
// ================= ADD SERVICE REQUEST =================
Future<bool> addServiceRequest({
  required String name,
  required String employeeId,
  required String email,
  required String mobile,
  required String type,
  required String department,
  required String description,
  List<String> attachmentUrl = const [],
}) async {
  try {
    _state = ServiceRequestState.loading;
    notifyListeners();

    final body = {
      "name": name,
      "employeeId": employeeId,
      "email": email,
      "mobile": mobile,
      "type": type,
      "department": department,
      "description": description,
      "attachmentUrl": attachmentUrl,
    };

    final response = await _service.addServiceRequest(body);

    if (response.success) {
      _state = ServiceRequestState.success;

      // 🔄 refresh user list after add
      await fetchRequestsByEmployee(employeeId);

      notifyListeners();
      return true;
    }

    throw Exception(response.message);
  } catch (e, s) {
    _error = e.toString();
    _logger.error(
      "SERVICE_REQUEST_PROVIDER",
      "addServiceRequest failed",
      error: e,
      stackTrace: s,
    );
    _state = ServiceRequestState.error;
    notifyListeners();
    return false;
  }
}

// ================= GET DEPARTMENTS =================
Future<void> fetchDepartments({bool forceRefresh = false}) async {
  try {
    if (!forceRefresh && _departments.isNotEmpty) {
      return;
    }

    _isDepartmentLoading = true;
    notifyListeners();

    final response = await _service.getDepartments();

    if (response.success && response.data is Map<String, dynamic>) {
      final List list =
          response.data['data']['departments'] as List;

      _departments =
          list.map((e) => e['name'].toString()).toList();

      // ✅ cache
      await _localStorage.saveDepartments(_departments);
      return;
    }

    throw Exception('Invalid departments response');
  } catch (e, s) {
    _error = e.toString();
    _logger.error(
      "SERVICE_REQUEST_PROVIDER",
      "fetchDepartments failed",
      error: e,
      stackTrace: s,
    );
  } finally {
    _isDepartmentLoading = false;
    notifyListeners();
  }
}
  // ================= FILTER HELPERS =================
  List<ServiceRequest> myRequests(String employeeId) =>
      _allRequests.where((r) => r.employeeId == employeeId).toList();

  List<ServiceRequest> teamRequests(String employeeId) =>
      _allRequests.where((r) => r.employeeId != employeeId).toList();

  // ================= CLEAR =================
  void clear() {
    _allRequests = [];
    _requestCounts = {};
    _state = ServiceRequestState.idle;
    notifyListeners();
  }
}