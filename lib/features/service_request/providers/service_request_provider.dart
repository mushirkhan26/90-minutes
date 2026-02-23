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
  List<String> _departments = [];
  String? _currentUserEmployeeId;
  String _searchQuery = '';

  List<ServiceRequest> get allRequests => _allRequests;
  Map<String, int> get requestCounts => _requestCounts;
  List<String> get departments => _departments;

  bool _isDepartmentLoading = false;
  bool get isDepartmentLoading => _isDepartmentLoading;

  bool _isUserRequestsLoading = false;
  bool get isUserRequestLoading => _isUserRequestsLoading;

  static const Duration _cacheValidity = Duration(minutes: 15);

  // ================= FILTERED DATA GETTERS =================

  List<ServiceRequest> get myFilteredRequests {
    final myReqs =
        _allRequests.where((r) => r.employeeId == _currentUserEmployeeId);
    if (_searchQuery.isEmpty) return myReqs.toList();
    return myReqs
        .where((r) =>
            r.name.toLowerCase().contains(_searchQuery) ||
            r.description.toLowerCase().contains(_searchQuery) ||
            r.department.toLowerCase().contains(_searchQuery) ||
            r.requestId.toLowerCase().contains(_searchQuery))
        .toList();
  }

  List<ServiceRequest> get allFilteredRequests {
    if (_searchQuery.isEmpty) return _allRequests;
    return _allRequests.where((r) {
      return r.name.toLowerCase().contains(_searchQuery) ||
          r.description.toLowerCase().contains(_searchQuery) ||
          r.type.toLowerCase().contains(_searchQuery) ||
          r.managerName.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // ================= ACTIONS =================

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // ================= CONSTRUCTOR =================
  ServiceRequestProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromCache();
    await refreshData();
  }

  // ================= CACHE LOGIC =================
  Future<void> _loadFromCache() async {
    try {
      _currentUserEmployeeId = await _localStorage.getEmployeeId();
      final cachedRequests = await _localStorage.getServiceRequests();
      final cachedCounts = await _localStorage.getServiceRequestCounts();
      final cachedDepts = await _localStorage.getDepartments();

      if (cachedRequests != null && cachedRequests.isNotEmpty) {
        _allRequests =
            cachedRequests.map((e) => ServiceRequest.fromJson(e)).toList();
        _state = ServiceRequestState.success;
      }

      if (cachedCounts != null) {
        _requestCounts = cachedCounts.map(
          (k, v) => MapEntry(k, int.tryParse(v.toString()) ?? 0),
        );
      }

      if (cachedDepts != null) {
        _departments = cachedDepts;
      }

      notifyListeners();
      _logger.logStorage("✅ ServiceRequest data loaded from cache");
    } catch (e) {
      _logger.error("SERVICE_REQUEST_PROVIDER", "Cache load failed", error: e);
    }
  }

  // ================= REFRESH DATA (MANAGER OR EMPLOYEE) =================
  Future<void> refreshData({bool forceRefresh = false}) async {
    try {
      final role = await _localStorage.getUserRole();
      _currentUserEmployeeId = await _localStorage.getEmployeeId();

      if (role == null || _currentUserEmployeeId == null) return;

      final String r = role.toLowerCase();

      await fetchRequestCounts(forceRefresh: forceRefresh);
      await fetchDepartments(forceRefresh: forceRefresh);

      if (r == 'employee' || r == 'intern') {
        await fetchRequestsByEmployee(_currentUserEmployeeId!,
            forceRefresh: forceRefresh);
      } else if (r == 'manager' || r == 'hr') {
        await fetchServiceRequests(forceRefresh: forceRefresh);
      }
    } catch (e) {
      _logger.error("SERVICE_REQUEST_PROVIDER", "Auto-refresh failed",
          error: e);
    }
  }

  // ================= GET ALL REQUESTS (MANAGER/HR) =================
  Future<void> fetchServiceRequests({bool forceRefresh = false}) async {
    try {
      final lastFetched = await _localStorage.getServiceRequestTimestamp();
      final now = DateTime.now();

      final shouldRefresh = forceRefresh ||
          lastFetched == null ||
          now.difference(lastFetched) > _cacheValidity;

      if (!shouldRefresh && _allRequests.isNotEmpty) {
        return;
      }

      _state = ServiceRequestState.loading;
      notifyListeners();

      final response = await _service.getAllRequests();

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is List) {
          final List list = data['data'];
          _allRequests = list.map((e) => ServiceRequest.fromJson(e)).toList();

          await _localStorage.saveServiceRequests(
            _allRequests.map((e) => e.toJson()).toList(),
          );
          await _localStorage.saveServiceRequestTimestamp(DateTime.now());

          _state = ServiceRequestState.success;
          _logger.logNetwork("✅ All service requests fetched and cached");
          notifyListeners();
          return;
        }
      }
      throw Exception("Invalid API response structure");
    } catch (e, s) {
      _error = e.toString();
      _state = _allRequests.isEmpty
          ? ServiceRequestState.error
          : ServiceRequestState.success;
      _logger.error("SERVICE_REQUEST_PROVIDER", "fetchServiceRequests failed",
          error: e, stackTrace: s);
      notifyListeners();
    }
  }

  // ================= GET REQUESTS BY EMPLOYEE =================
  Future<void> fetchRequestsByEmployee(String employeeId,
    {bool forceRefresh = false}) async {
  try {
    _currentUserEmployeeId = employeeId;

    _isUserRequestsLoading = true;
    notifyListeners();

    _logger.logGeneral("Fetching service requests for employee → $employeeId");

    final response = await _service.getRequestsByEmployee(employeeId);

    if (response.success && response.data is Map<String, dynamic>) {
      final List list = response.data['message'] ?? [];

      _allRequests =
          list.map((e) => ServiceRequest.fromJson(e)).toList();

      await _localStorage.saveServiceRequests(
        _allRequests.map((e) => e.toJson()).toList(),
      );

      _state = ServiceRequestState.success;

      _logger.logNetwork(
          "✅ Employee service requests fetched and cached (${_allRequests.length})");
    } else {
      _error = response.message;
      _state = ServiceRequestState.error;
    }
  } catch (e, s) {
    _logger.error(
        "SERVICE_REQUEST_PROVIDER", "fetchRequestsByEmployee failed",
        error: e, stackTrace: s);

    _state = ServiceRequestState.error;
  } finally {
    _isUserRequestsLoading = false;
    notifyListeners();
  }
}
    // ================= GET REQUEST COUNTS =================
  Future<void> fetchRequestCounts({bool forceRefresh = false}) async {
    try {
      final lastFetched = await _localStorage.getServiceRequestTimestamp();
      final now = DateTime.now();

      if (!forceRefresh && 
          lastFetched != null && 
          now.difference(lastFetched) < _cacheValidity && 
          _requestCounts.isNotEmpty) {
        return;
      }

      final response = await _service.getRequestCounts();

      if (response.success && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> message = response.data['message'] ?? {};
        final Map<String, dynamic> categoryCounts = message['categoryCounts'] ?? {};
        
        _requestCounts = categoryCounts.map(
          (k, v) => MapEntry(k, int.tryParse(v.toString()) ?? 0),
        );

        await _localStorage.saveServiceRequestCounts(_requestCounts);
        _logger.logNetwork("✅ Request counts updated and cached");
        notifyListeners();
      }
    } catch (e) {
      _logger.error("SERVICE_REQUEST_PROVIDER", "fetchRequestCounts error", error: e);
    }
  }

  // ================= GET DEPARTMENTS =================
  Future<void> fetchDepartments({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _departments.isNotEmpty) return;

      _isDepartmentLoading = true;
      notifyListeners();

      final response = await _service.getDepartments();

      if (response.success && response.data is Map<String, dynamic>) {
        final List list = response.data['data']?['departments'] ?? [];
        _departments = list.map((e) => e['name'].toString()).toList();

        await _localStorage.saveDepartments(_departments);
        _logger.logNetwork("✅ Departments fetched and cached");
      }
    } catch (e) {
      _logger.error("SERVICE_REQUEST_PROVIDER", "fetchDepartments error", error: e);
    } finally {
      _isDepartmentLoading = false;
      notifyListeners();
    }
  }


  // ================= UPDATE STATUS =================
  Future<bool> updateRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  }) async {
    _state = ServiceRequestState.loading;
    notifyListeners();

    try {
      final response = await _service.updateRequestStatus(
        requestId: requestId,
        status: status,
        adminComment: rejectionReason ?? "",
      );

      if (response.success) {
        final index = _allRequests.indexWhere((r) => r.requestId == requestId);
        if (index != -1) {
          _allRequests[index] = _allRequests[index].copyWith(
            requestStatus: status,
            adminComment: rejectionReason ?? "",
          );
          await _localStorage.saveServiceRequests(
            _allRequests.map((e) => e.toJson()).toList(),
          );
        }
        await fetchRequestCounts(forceRefresh: true);
        _state = ServiceRequestState.success;
        notifyListeners();
        return true;
      }
      throw Exception(response.message);
    } catch (e) {
      _error = e.toString();
      _state = ServiceRequestState.error;
      notifyListeners();
      return false;
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
        await fetchRequestsByEmployee(employeeId, forceRefresh: true);
        notifyListeners();
        return true;
      }
      throw Exception(response.message);
    } catch (e) {
      _error = e.toString();
      _state = ServiceRequestState.error;
      _logger.error("SERVICE_REQUEST_PROVIDER", "addServiceRequest failed",
          error: e);
      notifyListeners();
      return false;
    }
  }

  // ================= SEND MAIL =================
  Future<bool> sendMail({
    required String email,
    required String subject,
    required String content,
    required String requestId,
    required String employeeName,
    required String employeeId,
    required String requestType,
  }) async {
    try {
      _state = ServiceRequestState.loading;
      notifyListeners();

      final response = await _service.sendMail(
        email: email,
        subject: subject,
        content: content,
        requestId: requestId,
        employeeName: employeeName,
        employeeId: employeeId,
        requestType: requestType,
      );

      if (response.success) {
        _state = ServiceRequestState.success;
        notifyListeners();
        return true;
      }
      throw Exception(response.message);
    } catch (e) {
      _error = e.toString();
      _state = ServiceRequestState.error;
      notifyListeners();
      return false;
    }
  }

  // ================= ADD VIDEO =================
  Future<bool> addVideoToRequest({
    required String requestId,
    required String videoUrl,
  }) async {
    try {
      _state = ServiceRequestState.loading;
      notifyListeners();

      final response = await _service.addVideoToRequest(
        requestId: requestId,
        videoUrl: videoUrl,
      );

      if (response.success) {
        final index = _allRequests.indexWhere((r) => r.requestId == requestId);
        if (index != -1) {
          _allRequests[index] =
              _allRequests[index].copyWith(videoUrl: videoUrl);
          await _localStorage.saveServiceRequests(
            _allRequests.map((e) => e.toJson()).toList(),
          );
        }
        _state = ServiceRequestState.success;
        notifyListeners();
        return true;
      }
      throw Exception(response.message);
    } catch (e) {
      _error = e.toString();
      _state = ServiceRequestState.error;
      notifyListeners();
      return false;
    }
  }

  // ================= CLEAR =================
  void clear() {
    _allRequests = [];
    _requestCounts = {};
    _departments = [];
    _state = ServiceRequestState.idle;
    notifyListeners();
  }
}
