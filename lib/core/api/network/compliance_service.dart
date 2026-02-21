import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/compliance_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class ComplianceService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  // =========================================================
  // ================= EMPLOYEE COMPLIANCE ===================
  // =========================================================

  Future<ApiResponse<List<Compliance>>> getEmployeeCompliance(
      String employeeId) async {
    _logger.info('NETWORK',
        'Fetching compliance for employeeId: $employeeId');

    final response = await _apiHelper
        .get<Map<String, dynamic>>(
            'document-compliance/employee/$employeeId');

    if (response.success && response.data != null) {
      final dynamic dataField = response.data!['data'];

      if (dataField is List) {
        final compliances = dataField
            .map((json) => Compliance.fromJson(json))
            .toList();

        _logger.info('NETWORK',
            'Parsed ${compliances.length} compliance items');

        return ApiResponse.success(compliances);
      }

      return ApiResponse.success([]);
    }

    return ApiResponse.error(
        response.message ?? 'Failed to fetch compliance');
  }

  // =========================================================
  // ================= SUBMIT COMPLIANCE =====================
  // =========================================================

  Future<ApiResponse<void>> submitCompliance(
      String complianceId,
      List<String> submittedDocuments) async {
    final body = {
      'submittedDocuments': submittedDocuments
    };

    return _apiHelper.put<void>(
      'document-compliance/submit/$complianceId',
      body,
    );
  }

  // =========================================================
  // ================= ADMIN - GET ALL =======================
  // =========================================================

  Future<ApiResponse<List<Compliance>>> getAllCompliances() async {
    _logger.info('NETWORK', 'Fetching ALL compliances');

    final response = await _apiHelper
        .get<Map<String, dynamic>>(
            'document-compliance/all');

    if (response.success && response.data != null) {
      final List<dynamic> dataList =
          response.data!['data'] ?? [];

      final compliances = dataList
          .map((json) => Compliance.fromJson(json))
          .toList();

      _logger.info('NETWORK',
          'Parsed ${compliances.length} compliances');

      return ApiResponse.success(compliances);
    }

    return ApiResponse.error(
        response.message ?? 'Failed to fetch all compliances');
  }

  // =========================================================
  // ================= ADMIN - CREATE ========================
  // =========================================================

  Future<ApiResponse<bool>> createCompliance({
    required String employeeId,
    required String complianceType,
    required String title,
    required String description,
    required String note,
    required String dueDate,
    required List<String> requiredDocuments,
    required List<Map<String, String>> actionLinks,
  }) async {
    _logger.info('NETWORK', 'Creating compliance');

    final body = {
      "employeeId": employeeId,
      "complianceType": complianceType,
      "title": title,
      "description": description,
      "note": note,
      "dueDate": dueDate,
      "requiredDocuments": requiredDocuments,
      "actionLinks": actionLinks,
    };

    final response = await _apiHelper.post<Map<String, dynamic>>(
      'document-compliance/create',
      body,
    );

    if (response.success) {
      return ApiResponse.success(true);
    }

    return ApiResponse.error(
        response.message ?? 'Failed to create compliance');
  }

 

Future<ApiResponse<bool>> updateCompliance({
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
  _logger.info('NETWORK', 'Updating compliance: $complianceId');

  final body = {
    "employeeId": employeeId,
    "complianceType": complianceType,
    "title": title,
    "description": description,
    "note": note,
    "dueDate": dueDate,
    "requiredDocuments": requiredDocuments,
    "actionLinks": actionLinks,
  };

  final response = await _apiHelper.put<Map<String, dynamic>>(
    'document-compliance/update/$complianceId',
    body,
  );

  if (response.success) {
    return ApiResponse.success(true);
  }

  return ApiResponse.error(
      response.message ?? 'Failed to update compliance');
}


// =========================================================

Future<ApiResponse<bool>> deleteCompliance(
    String complianceId) async {
  _logger.info('NETWORK', 'Deleting compliance: $complianceId');

  final response = await _apiHelper.delete<Map<String, dynamic>>(
    'document-compliance/delete/$complianceId',
  );

  if (response.success) {
    return ApiResponse.success(true);
  }

  return ApiResponse.error(
      response.message ?? 'Failed to delete compliance');
}
}