
import '../../errors/app_exception.dart';
import '../../models/notification_model.dart';
import '../base_api/api_helper.dart';
import '../base_api/api_response.dart';

class NotificationService {
  final ApiHelper _apiHelper = ApiHelper();

  Future<ApiResponse<List<NotificationModel>>> getNotifications(String employeeId) async {
    try {
      // API: notification/getUserNotification/:employeeId
      final response = await _apiHelper.get<Map<String, dynamic>>("notification/getUserNotification/$employeeId");
      
      if (response.success && response.data != null) {
        final dynamic data = response.data!['message'] ?? response.data!['notifications'] ?? [];
        
        if (data is List) {
          final notifications = data.map((e) => NotificationModel.fromJson(e)).toList();
          return ApiResponse.success(notifications);
        }
      }
      return ApiResponse.error(response.message ?? "Failed to fetch notifications");
    } on NotFoundException {
      // ✅ Handle 404 specifically: Return empty list instead of error
      return ApiResponse.success([]);
    } catch (e) {
      // ✅ Fallback for other errors that might contain the message
      if (e.toString().contains("No requests found")) {
        return ApiResponse.success([]);
      }
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<bool>> markAsRead(String notificationId) async {
    return ApiResponse.success(true);
  }

  Future<ApiResponse<bool>> markAllAsRead(String employeeId) async {
    try {
      // API: notification/clearUserNotification (Method: DELETE)
      final response = await _apiHelper.delete<Map<String, dynamic>>(
        "notification/clearUserNotification",
        body: {"employeeId": employeeId},
      );
      
      return ApiResponse.success(response.success);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
