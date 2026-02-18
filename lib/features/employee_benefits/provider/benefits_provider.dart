import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/benefits_claim_model.dart';
import 'package:hrtz_hrms/core/api/network/benefits_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

enum BenefitsState { idle, loading, success, error }

class BenefitsProvider extends ChangeNotifier {
  final BenefitsService _service = BenefitsService();
  final LocalStorageService _local = LocalStorageService();
  final SecureStorageService _secure = SecureStorageService();
  final LoggingService _logger = LoggingService.instance;

  // ---------------- STATE ----------------
  BenefitsState _state = BenefitsState.idle;
  BenefitsState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------- DATA ----------------
  List<BenefitsClaimModel> _myClaims = [];
  List<BenefitsClaimModel> _allClaims = [];

  String _searchQuery = "";
  String _statusFilter = "All";

  String? _currentEmployeeId;

  static const Duration _cacheDuration = Duration(minutes: 10);

  //  CONSTRUCTOR
  BenefitsProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _currentEmployeeId = await _secure.getEmployeeId();
    if (_currentEmployeeId == null) return;

    // 1️⃣ Load cache instantly
    final cached = await _local.getClaims(_currentEmployeeId!);
    if (cached != null) {
      _myClaims = cached;
      _state = BenefitsState.success;
      notifyListeners();
      _logger.logStorage("✅ My claims loaded from cache (bootstrap)");
    }

    // 2 Silent refresh
    fetchMyClaims(_currentEmployeeId!, forceRefresh: false);
  }

  //  FETCH MY CLAIMS (CACHE FIRST)
  Future<void> fetchMyClaims(
    String employeeId, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = await _local.getClaims(employeeId);
        final timestamp = await _local.getClaimsTimestamp(employeeId);

        if (cached != null &&
            timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheDuration) {
          _myClaims = cached;
          _state = BenefitsState.success;
          notifyListeners();
          _logger.logStorage("✅ Loaded my claims from cache");
          return;
        }
      }

      if (_myClaims.isEmpty) {
        _state = BenefitsState.loading;
        notifyListeners();
      }

      _logger.logNetwork("🌐 Fetching my claims from API");

      final response = await _service.getClaimsByEmployee(employeeId);

      if (response.success && response.data != null) {
        _myClaims = response.data!;
        await _local.saveClaims(employeeId, _myClaims);

        _errorMessage = null;
        _state = BenefitsState.success;
      } else {
        _errorMessage = response.message;
        _state = _myClaims.isNotEmpty
            ? BenefitsState.success
            : BenefitsState.error;
      }
    } catch (e) {
      _logger.error("BENEFITS_PROVIDER", "Fetch my claims failed", error: e);
      _errorMessage = e.toString();
      _state = _myClaims.isNotEmpty
          ? BenefitsState.success
          : BenefitsState.error;
    }

    notifyListeners();
  }

  //  FETCH ALL CLAIMS (ADMIN)
  Future<void> fetchAllClaims({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = await _local.getAllClaims();
        final timestamp = await _local.getAllClaimsTimestamp();

        if (cached != null &&
            timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheDuration) {
          _allClaims = cached;
          _state = BenefitsState.success;
          notifyListeners();
          return;
        }
      }

      if (_allClaims.isEmpty) {
        _state = BenefitsState.loading;
        notifyListeners();
      }

      _logger.logNetwork("🌐 Fetching all claims from API");

      final response = await _service.getAllClaims();

      if (response.success && response.data != null) {
        _allClaims = response.data!;
        await _local.saveAllClaims(_allClaims);

        _errorMessage = null;
        _state = BenefitsState.success;
      } else {
        _errorMessage = response.message;
        _state = _allClaims.isNotEmpty
            ? BenefitsState.success
            : BenefitsState.error;
      }
    } catch (e) {
      _logger.error("BENEFITS_PROVIDER", "Fetch all claims failed", error: e);
      _errorMessage = e.toString();
      _state = _allClaims.isNotEmpty
          ? BenefitsState.success
          : BenefitsState.error;
    }

    notifyListeners();
  }

  // FILTERED VIEWS
  List<BenefitsClaimModel> get myClaims => _applyFilters(_myClaims);
  List<BenefitsClaimModel> get allClaims => _applyFilters(_allClaims);

  List<BenefitsClaimModel> _applyFilters(
      List<BenefitsClaimModel> list) {
    var filtered = List<BenefitsClaimModel>.from(list);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) =>
          c.beneficiaryName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          c.benefitName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())).toList();
    }

    if (_statusFilter != "All") {
      filtered =
          filtered.where((c) => c.claimStatus == _statusFilter).toList();
    }

    return filtered;
  }

  //  SEARCH & FILTER
  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  
  //  UPDATE CLAIM STATUS (ADMIN)
  Future<bool> updateClaimStatus(String claimId, String status) async {
    try {
      final response =
          await _service.updateClaimStatus(claimId, status);

      if (response.success) {
        // Update in My Claims
        final myIndex =
            _myClaims.indexWhere((element) => element.id == claimId);
        if (myIndex != -1) {
          _myClaims[myIndex] =
              _myClaims[myIndex].copyWith(claimStatus: status);

          if (_currentEmployeeId != null) {
            await _local.saveClaims(_currentEmployeeId!, _myClaims);
          }
        }

        // Update in All Claims
        final allIndex =
            _allClaims.indexWhere((element) => element.id == claimId);
        if (allIndex != -1) {
          _allClaims[allIndex] =
              _allClaims[allIndex].copyWith(claimStatus: status);

          await _local.saveAllClaims(_allClaims);
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _logger.error(
        "BENEFITS_PROVIDER",
        "Update claim status failed",
        error: e,
      );
      return false;
    }
  }

  //  ADD CLAIM
Future<bool> addClaim(BenefitsClaimModel model) async {
  try {
    _state = BenefitsState.loading;
    notifyListeners();

    _logger.logNetwork("📤 Adding new claim...");

    final response = await _service.addClaim(model.toAddClaimJson());

    if (response.success) {
      _logger.logNetwork("✅ Claim added successfully");

      // If backend returns created object
      if (response.data != null) {
        final newClaim =
            BenefitsClaimModel.fromJson(response.data!);

        _myClaims.insert(0, newClaim);

        if (_currentEmployeeId != null) {
          await _local.saveClaims(
              _currentEmployeeId!, _myClaims);
        }
      }

      _errorMessage = null;
      _state = BenefitsState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _state = BenefitsState.error;
      notifyListeners();
      return false;
    }
  } catch (e) {
    _logger.error(
      "BENEFITS_PROVIDER",
      "Add claim failed",
      error: e,
    );

    _errorMessage = e.toString();
    _state = BenefitsState.error;
    notifyListeners();
    return false;
  }
}

  //  FORCE REFRESH
  Future<void> refresh() async {
    if (_currentEmployeeId != null) {
      await fetchMyClaims(_currentEmployeeId!, forceRefresh: true);
    }
  }
}