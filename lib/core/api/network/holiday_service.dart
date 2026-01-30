import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/holiday_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class HolidayService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// 🗓️ Get Holidays
  Future<ApiResponse<List<HolidayModel>>> getHolidays() async {
    _logger.info('HOLIDAY', 'Fetching holidays');
    final response = await _apiHelper.get<dynamic>('holiday');

    if (response.success && response.data != null) {
      try {
        List<dynamic> holidayJson = [];
        if (response.data is List) {
          holidayJson = response.data;
        } else if (response.data is Map<String, dynamic>) {
          holidayJson = response.data['items'] ?? response.data['data'] ?? response.data['message'] ?? [];
        }

        if (holidayJson is! List) {
          holidayJson = [];
        }

        final holidays = holidayJson.map((json) => HolidayModel.fromJson(json)).toList();
        return ApiResponse.success(holidays);
      } catch (e) {
        _logger.error('HOLIDAY', 'Error parsing holidays', error: e);
        return ApiResponse.error('Failed to parse holidays');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch holidays');
  }
}
