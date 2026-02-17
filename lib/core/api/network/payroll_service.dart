import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class PayrollService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// 💰 Get Payroll History API
  /// endpoint: package/packageHistory/:employeeid/:year/:month
  Future<ApiResponse<Map<String, dynamic>>> getPayrollHistory({
    required String employeeId,
    required String year,
    required String month,
  }) async {
    _logger.logNetwork('Fetching payroll history for $employeeId, $month $year');
    final endpoint = 'package/packageHistory/$employeeId/$year/$month';
    return await _apiHelper.get<Map<String, dynamic>>(endpoint);
  }
}
