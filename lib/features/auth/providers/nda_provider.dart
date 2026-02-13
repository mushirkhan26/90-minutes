import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';

class NdaProvider extends ChangeNotifier {
  final LocalStorageService _local = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();
  
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController joiningDateController = TextEditingController();
  final TextEditingController signatureDateController = TextEditingController();

  String? _signatureFileName;
  String? get signatureFileName => _signatureFileName;

  bool _isAccepted = false;
  bool get isAccepted => _isAccepted;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const String _draftKey = 'nda_form_draft';

  NdaProvider() {
    _init();
  }

  Future<void> _init() async {
    await _initializeFields();
    await _loadDraft();
  }

  Future<void> _initializeFields() async {
    final userData = await _secureStorage.getUserData();
    fullNameController.text = userData?['username'] ?? '';
    employeeIdController.text = userData?['employeeId'] ?? '';
    emailController.text = userData?['email'] ?? '';

    final now = DateTime.now();
    signatureDateController.text = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    notifyListeners();
  }

  void setAccepted(bool value) {
    _isAccepted = value;
    _saveDraft();
    notifyListeners();
  }

  Future<void> pickSignature() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      _signatureFileName = result.files.single.name;
      _saveDraft();
      notifyListeners();
    }
  }

  Future<void> _loadDraft() async {
    try {
      final draft = await _local.getString(_draftKey);
      if (draft != null) {
        final data = jsonDecode(draft);
        positionController.text = data['position'] ?? '';
        departmentController.text = data['department'] ?? '';
        joiningDateController.text = data['joiningDate'] ?? '';
        _signatureFileName = data['signatureFileName'];
        _isAccepted = data['isAccepted'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      // Handle or ignore
    }
  }

  Future<void> _saveDraft() async {
    final data = {
      'position': positionController.text,
      'department': departmentController.text,
      'joiningDate': joiningDateController.text,
      'signatureFileName': _signatureFileName,
      'isAccepted': _isAccepted,
    };
    await _local.saveString(_draftKey, jsonEncode(data));
  }

  void onFieldChanged() {
    _saveDraft();
  }

  Future<bool> submitNda(AuthProvider authProvider) async {
    if (_signatureFileName == null || !_isAccepted) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call to submit NDA data if needed
      // Currently just following existing logic of updating status in AuthProvider
      await authProvider.updateNdaStatus(true);
      await _local.removeString(_draftKey);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateJoiningDate(DateTime pickedDate) {
    joiningDateController.text = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
    _saveDraft();
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    employeeIdController.dispose();
    emailController.dispose();
    positionController.dispose();
    departmentController.dispose();
    joiningDateController.dispose();
    signatureDateController.dispose();
    super.dispose();
  }
}
