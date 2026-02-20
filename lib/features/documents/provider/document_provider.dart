import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import '../../../core/api/network/document_service.dart';
import '../../../core/models/document_model.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  final LocalStorageService _storage = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  List<Document> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DocumentProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final employeeId = await _storage.getEmployeeId();
    if (employeeId != null) {
      await loadDocuments(employeeId);
    }
  }

  Future<void> loadDocuments(String employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Load from local storage first
    final cachedDocs = await _storage.getDocuments(employeeId);
    if (cachedDocs != null && cachedDocs.isNotEmpty) {
      _documents = cachedDocs;
      _isLoading = false;
      notifyListeners();
      _logger.logNetwork('✅ Loaded documents from cache');
    }

    // 2. Fetch fresh data from API
    await fetchDocuments(employeeId);
  }

  Future<void> fetchDocuments(String employeeId) async {
    if (_documents.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await _documentService.getEmployeeDocuments(employeeId);
      if (response.success && response.data != null) {
        _documents = response.data!;
        // 3. Save to local storage
        await _storage.saveDocuments(employeeId, _documents);
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDocuments(String employeeId) async {
    await fetchDocuments(employeeId);
  }
}
