import 'package:flutter/material.dart';
import '../../../core/api/network/document_service.dart';
import '../../../core/models/document_model.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDocuments(String employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _documentService.getEmployeeDocuments(employeeId);
      if (response.success && response.data != null) {
        _documents = response.data!;
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
}
