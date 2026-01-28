import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class TaskService {
  // Correct Base URL from Documentation
  static const String taskBaseUrl = "https://3qhglx2bhd.execute-api.us-east-1.amazonaws.com/";
  
  // Initialize ApiHelper with the correct base URL for tasks
  final ApiHelper _apiHelper = ApiHelper(baseUrl: taskBaseUrl);
  final LoggingService _logger = LoggingService.instance;

  /// 📋 Get All Assigned Items (Tasks & Subtasks) for a User
  Future<ApiResponse<Map<String, dynamic>>> getAssignedItems(String employeeId) async {
    _logger.logNetwork('Fetching assigned items for employeeId: $employeeId');
    
    // Documentation 8.1
    final response = await _apiHelper.get<Map<String, dynamic>>('task/getAssignedItems?employeeId=$employeeId');
    
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch items');
  }

  /// ➕ Create Task (Standalone or Sprint)
  Future<ApiResponse<Map<String, dynamic>>> addTask(Task task) async {
    // Determine endpoint based on documentation 3.3 and 3.8
    final bool isStandalone = task.sprintId == null || task.sprintId!.isEmpty;
    final String endpoint = isStandalone ? 'task/standalone/create' : 'task/create';
    
    _logger.logNetwork('Creating ${isStandalone ? "standalone" : "sprint"} task at $endpoint');
    return await _apiHelper.post<Map<String, dynamic>>(endpoint, task.toMap());
  }

  /// ✏️ Update Task Status
  Future<ApiResponse<Map<String, dynamic>>> updateTaskStatus(String taskId, String employeeId, String status) async {
    final body = {
      "employeeId": employeeId,
      "status": status
    };
    // Documentation 3.4
    return await _apiHelper.put<Map<String, dynamic>>('task/update/$taskId', body);
  }

  /// 🗑️ Delete Task
  Future<ApiResponse<Map<String, dynamic>>> deleteTask(String taskId) async {
    return await _apiHelper.delete<Map<String, dynamic>>('task/delete/$taskId');
  }
}
