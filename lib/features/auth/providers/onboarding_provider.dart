import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';

class OnboardingProvider extends ChangeNotifier {
  final LocalStorageService _local = LocalStorageService();

  // Academic Details
  final TextEditingController tenthPercentController = TextEditingController();
  final TextEditingController twelfthPercentController = TextEditingController();
  final TextEditingController ugPercentController = TextEditingController();
  final TextEditingController pgPercentController = TextEditingController();

  // Work Details
  String _modeOfWork = 'Onsite';
  String get modeOfWork => _modeOfWork;

  // Document Uploads (File names)
  String? _ugMarksheetName;
  String? get ugMarksheetName => _ugMarksheetName;
  
  String? _photoName;
  String? get photoName => _photoName;
  
  String? _resumeName;
  String? get resumeName => _resumeName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const String _draftKey = 'onboarding_form_draft';

  OnboardingProvider() {
    _loadDraft();
  }

  void setModeOfWork(String value) {
    _modeOfWork = value;
    _saveDraft();
    notifyListeners();
  }

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      if (type == 'ug') _ugMarksheetName = result.files.single.name;
      if (type == 'photo') _photoName = result.files.single.name;
      if (type == 'resume') _resumeName = result.files.single.name;
      _saveDraft();
      notifyListeners();
    }
  }

  Future<void> _loadDraft() async {
    try {
      final draft = await _local.getString(_draftKey);
      if (draft != null) {
        final data = jsonDecode(draft);
        tenthPercentController.text = data['tenth'] ?? '';
        twelfthPercentController.text = data['twelfth'] ?? '';
        ugPercentController.text = data['ug_percent'] ?? '';
        pgPercentController.text = data['pg_percent'] ?? '';
        _modeOfWork = data['modeOfWork'] ?? 'Onsite';
        _ugMarksheetName = data['ugMarksheetName'];
        _photoName = data['photoName'];
        _resumeName = data['resumeName'];
        notifyListeners();
      }
    } catch (e) {
      // Handle or ignore
    }
  }

  Future<void> _saveDraft() async {
    final data = {
      'tenth': tenthPercentController.text,
      'twelfth': twelfthPercentController.text,
      'ug_percent': ugPercentController.text,
      'pg_percent': pgPercentController.text,
      'modeOfWork': _modeOfWork,
      'ugMarksheetName': _ugMarksheetName,
      'photoName': _photoName,
      'resumeName': _resumeName,
    };
    await _local.saveString(_draftKey, jsonEncode(data));
  }

  void onFieldChanged() {
    _saveDraft();
  }

  Future<bool> submitOnboarding(AuthProvider authProvider) async {
    if (_photoName == null || _resumeName == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Logic for actual submission would go here (API call)
      await authProvider.updateOnboardingStatus(true);
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

  @override
  void dispose() {
    tenthPercentController.dispose();
    twelfthPercentController.dispose();
    ugPercentController.dispose();
    pgPercentController.dispose();
    super.dispose();
  }
}
