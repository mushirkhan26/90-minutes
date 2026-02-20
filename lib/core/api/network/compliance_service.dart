import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/compliance_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class ComplianceService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  Future<ApiResponse<List<Compliance>>> getEmployeeCompliance(String employeeId) async {
    _logger.info('NETWORK', 'Fetching compliance for employeeId: $employeeId');
    final response = await _apiHelper.get<Map<String, dynamic>>('document-compliance/employee/$employeeId');
    
    if (response.success && response.data != null) {
      // The log showed {"data": []}, so we extract from 'data' key
      final dynamic dataField = response.data!['data'];
      
      if (dataField is List) {
        final compliances = dataField.map((json) => Compliance.fromJson(json)).toList();
        _logger.info('NETWORK', 'Parsed ${compliances.length} compliance items');
        return ApiResponse.success(compliances);
      } else if (response.data!['message'] is List) {
        // Fallback: sometimes APIs use 'message' for the data list
        final List<dynamic> list = response.data!['message'];
        final compliances = list.map((json) => Compliance.fromJson(json)).toList();
        return ApiResponse.success(compliances);
      }
      
      return ApiResponse.success([]);
    }
    return ApiResponse.error(response.message ?? 'An unknown error occurred');
  }

  Future<ApiResponse<void>> submitCompliance(String complianceId, List<String> submittedDocuments) async {
    final body = {'submittedDocuments': submittedDocuments};
    return _apiHelper.put<void>('document-compliance/submit/$complianceId', body);
  }
}
