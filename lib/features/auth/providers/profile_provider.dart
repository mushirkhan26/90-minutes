import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  final LocalStorageService _local = LocalStorageService();
  final FileUploadService _fileUploadService = FileUploadService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController alterMobileController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();

  String? _profileImageUrl;
  String? get profileImageUrl => _profileImageUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  static const String _draftKey = 'profile_edit_draft';

  ProfileProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadProfileData();
    await _loadDraft();
  }

  void setEditing(bool value) {
    _isEditing = value;
    if (!value) {
      _local.removeString(_draftKey);
    }
    notifyListeners();
  }

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    final userData = await _secureStorage.getUserData();
    final profileData = await _secureStorage.getProfileData();
    final employeeId = await _secureStorage.getEmployeeId();

    nameController.text = userData?['username'] ?? '';
    emailController.text = userData?['email'] ?? '';
    employeeIdController.text = employeeId ?? '';

    if (profileData != null) {
      mobileController.text = profileData['mobile'] ?? '';
      alterMobileController.text = profileData['alterMobile'] ?? '';
      genderController.text = profileData['gender'] ?? '';
      addressController.text = profileData['address'] ?? '';
      _profileImageUrl = profileData['profileImage'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDraft() async {
    if (!_isEditing) return;
    try {
      final draft = await _local.getString(_draftKey);
      if (draft != null) {
        final data = jsonDecode(draft);
        nameController.text = data['name'] ?? nameController.text;
        emailController.text = data['email'] ?? emailController.text;
        mobileController.text = data['mobile'] ?? mobileController.text;
        alterMobileController.text = data['alterMobile'] ?? alterMobileController.text;
        genderController.text = data['gender'] ?? genderController.text;
        addressController.text = data['address'] ?? addressController.text;
        _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
        notifyListeners();
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveDraft() async {
    if (!_isEditing) return;
    final data = {
      'name': nameController.text,
      'email': emailController.text,
      'mobile': mobileController.text,
      'alterMobile': alterMobileController.text,
      'gender': genderController.text,
      'address': addressController.text,
      'profileImageUrl': _profileImageUrl,
    };
    await _local.saveString(_draftKey, jsonEncode(data));
  }

  void onFieldChanged() {
    if (_isEditing) _saveDraft();
  }

  Future<void> uploadImage(File file) async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = await _fileUploadService.uploadFile(file);
      if (url != null) {
        _profileImageUrl = url;
        onFieldChanged();
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(AuthProvider authProvider) async {
    _isLoading = true;
    notifyListeners();
    try {
      final employeeId = await _secureStorage.getEmployeeId() ?? '';
      final success = await authProvider.updateProfileData(
        employeeId: employeeId,
        name: nameController.text,
        email: emailController.text,
        mobile: mobileController.text,
        alterMobile: alterMobileController.text,
        gender: genderController.text,
        address: addressController.text,
        profileImage: _profileImageUrl,
      );

      if (success) {
        _isEditing = false;
        await _local.removeString(_draftKey);
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    alterMobileController.dispose();
    genderController.dispose();
    addressController.dispose();
    employeeIdController.dispose();
    super.dispose();
  }
}
