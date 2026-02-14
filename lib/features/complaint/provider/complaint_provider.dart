import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/complaint_service.dart';
import 'package:hrtz_hrms/core/models/complaint_model.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

enum ComplaintState { initial, loading, loaded, error }

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  final LocalStorageService _localStorage = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LoggingService _logger = LoggingService.instance;

  // ================== LOGIN USER ==================
  String loggedInName = "";
  String loggedInEmployeeId = "";
  bool isManager = false;

  bool isUserLoaded = false;


  // ================== MASTER DATA ==================
  final List<String> categories = ["IT", "HR", "Facilities"];
  final List<String> mentionPeople = ["Team Lead", "Manager", "CEO"];

  // ================== CACHE KEYS ==================
  static const String _myComplaintsKey = 'cached_my_complaints';
  static const String _teamComplaintsKey = 'cached_team_complaints';
  static const String _draftKey = 'complaint_form_draft';

  // ================== FORM STATE ==================
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController additionalInfoController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();


  String? selectedCategory;
  String? selectedPerson;
  List<String> attachments = [];

  // ================== LIST STATE ==================
  List<ComplaintModel> _complaints = [];
  List<ComplaintModel> _teamComplaints = [];
  
  ComplaintState _state = ComplaintState.initial;
  String? _errorMessage;

  List<ComplaintModel> get complaints => _complaints;
  List<ComplaintModel> get teamComplaints => _teamComplaints;
  ComplaintState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ComplaintState.loading;
  bool isUpdatingStatus = false;

  ComplaintProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadLoginUser();
    await _loadFromLocal();
    await _loadDraft();
    fetchComplaints();
    if (isManager) {
      fetchAllComplaints();
    }
  }

  // ================== LOAD LOGIN USER ==================
  Future<void> loadLoginUser() async {
    final userData = await _secureStorage.getUserData();
    loggedInName = userData?['username'] ?? "";

    loggedInEmployeeId = userData?['employeeId']?.toString() ?? "";

    // Set controller values
    nameController.text = loggedInName;
    employeeIdController.text = loggedInEmployeeId;


    print("\x1B[31m🚨 EmployeeId: $loggedInEmployeeId \x1B[0m");
    print("\x1B[31m👤 Username: $loggedInName \x1B[0m");


    isManager = userData?['role']?.toString().toLowerCase() == 'manager';

    isUserLoaded = true;
    print("SETTING CONTROLLERS NOW");



    notifyListeners();
  }

  // ================== CACHE LOGIC ==================
  Future<void> _loadFromLocal() async {
    try {
      final myCached = await _localStorage.getString(_myComplaintsKey);
      if (myCached != null) {
        final List<dynamic> decoded = jsonDecode(myCached);
        _complaints = decoded.map((json) => ComplaintModel.fromJson(json)).toList();
        _state = ComplaintState.loaded;
      }

      final teamCached = await _localStorage.getString(_teamComplaintsKey);
      if (teamCached != null) {
        final List<dynamic> decoded = jsonDecode(teamCached);
        _teamComplaints = decoded.map((json) => ComplaintModel.fromJson(json)).toList();
      }
      notifyListeners();
    } catch (e) {
      _logger.error('COMPLAINT_PROVIDER', 'Error loading cache', error: e);
    }
  }

  Future<void> _saveToLocal(String key, List<ComplaintModel> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _localStorage.saveString(key, encoded);
  }

  // ================== DRAFT LOGIC ==================
  Future<void> _loadDraft() async {
    try {
      final draft = await _localStorage.getString(_draftKey);
      if (draft != null) {
        final data = jsonDecode(draft);
        titleController.text = data['title'] ?? '';
        descriptionController.text = data['description'] ?? '';
        additionalInfoController.text = data['additionalInfo'] ?? '';
        selectedCategory = data['category'];
        selectedPerson = data['person'];
        attachments = List<String>.from(data['attachments'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      _logger.error('COMPLAINT_PROVIDER', 'Error loading draft', error: e);
    }
  }

  Future<void> _saveDraft() async {
    final data = {
      'title': titleController.text,
      'description': descriptionController.text,
      'additionalInfo': additionalInfoController.text,
      'category': selectedCategory,
      'person': selectedPerson,
      'attachments': attachments,
    };
    await _localStorage.saveString(_draftKey, jsonEncode(data));
  }

  void onFieldChanged() => _saveDraft();

  void setCategory(String? value) {
    selectedCategory = value;
    _saveDraft();
    notifyListeners();
  }

  void setPerson(String? value) {
    selectedPerson = value;
    _saveDraft();
    notifyListeners();
  }

  void addAttachment(String url) {
    attachments.add(url);
    _saveDraft();
    notifyListeners();
  }

  // ================== FETCH MY COMPLAINTS ==================
  Future<void> fetchComplaints() async {
    if (_complaints.isEmpty) {
      _state = ComplaintState.loading;
      notifyListeners();
    }

    try {
      if (loggedInEmployeeId.isEmpty) await loadLoginUser();
      if (loggedInEmployeeId.isEmpty) return;

      final ApiResponse response = await _complaintService.getComplaints(loggedInEmployeeId);

      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final List list = body['message'] ?? [];

        _complaints = list.map((e) => ComplaintModel.fromJson(e)).toList();
        _complaints.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
        
        await _saveToLocal(_myComplaintsKey, _complaints);
        _state = ComplaintState.loaded;
      } else {
        _state = ComplaintState.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _state = ComplaintState.error;
      _logger.error('COMPLAINT_PROVIDER', 'fetchComplaints error', error: e);
    }
    notifyListeners();
  }

  // ================== ADD COMPLAINT ==================
  Future<bool> addComplaint() async {
    _state = ComplaintState.loading;
    notifyListeners();

    try {
      if (loggedInEmployeeId.isEmpty) await loadLoginUser();

      final ApiResponse response = await _complaintService.addComplaint(
        name: loggedInName,
        employeeId: loggedInEmployeeId,
        category: selectedCategory ?? '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        additionalInfo: additionalInfoController.text.trim(),
        attachment: attachments,
      );

      if (response.success) {
        _clearForm();
        await fetchComplaints();
        return true;
      }
    } catch (e) {
      _logger.error('COMPLAINT_PROVIDER', 'addComplaint error', error: e);
    } finally {
      _state = ComplaintState.loaded;
      notifyListeners();
    }
    return false;
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    additionalInfoController.clear();
    selectedCategory = null;
    selectedPerson = null;
    attachments = [];
    _localStorage.removeString(_draftKey);
  }

  // ================== FETCH TEAM COMPLAINTS ==================
  Future<void> fetchAllComplaints() async {
    if (_teamComplaints.isEmpty) {
      _state = ComplaintState.loading;
      notifyListeners();
    }

    try {
      final ApiResponse response = await _complaintService.getAllComplaints();

      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final List list = body['message'] ?? [];

        _teamComplaints = list
            .map((e) => ComplaintModel.fromJson(e))
            .where((c) => c.employeeId != loggedInEmployeeId)
            .toList();
        _teamComplaints.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));

        await _saveToLocal(_teamComplaintsKey, _teamComplaints);
        _state = ComplaintState.loaded;
      }
    } catch (e) {
      _logger.error('COMPLAINT_PROVIDER', 'fetchAllComplaints error', error: e);
    }
    notifyListeners();
  }

  // ================== UPDATE COMPLAINT STATUS ==================
  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String status,
  }) async {
    isUpdatingStatus = true;
    notifyListeners();

    try {
      final ApiResponse response = await _complaintService.updateComplaintStatus(
        complaintId: complaintId,
        status: status,
      );

      if (response.success) {
        _updateLocalStatus(complaintId, status);
        await _saveToLocal(_myComplaintsKey, _complaints);
        await _saveToLocal(_teamComplaintsKey, _teamComplaints);
        return true;
      }
    } catch (e) {
      _logger.error('COMPLAINT_PROVIDER', 'updateComplaintStatus error', error: e);
    } finally {
      isUpdatingStatus = false;
      notifyListeners();
    }
    return false;
  }

  void _updateLocalStatus(String id, String status) {
    final myIdx = _complaints.indexWhere((c) => c.id == id);
    if (myIdx != -1) _complaints[myIdx] = _complaints[myIdx].copyWith(status: status);
    
    final teamIdx = _teamComplaints.indexWhere((c) => c.id == id);
    if (teamIdx != -1) _teamComplaints[teamIdx] = _teamComplaints[teamIdx].copyWith(status: status);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    additionalInfoController.dispose();
    nameController.dispose();
    employeeIdController.dispose();

    super.dispose();
  }

  void clearComplaints() {
    _complaints = [];
    _teamComplaints = [];
    loggedInName = "";
    loggedInEmployeeId = "";
    isManager = false;
    _state = ComplaintState.initial;
    notifyListeners();
  }
}
