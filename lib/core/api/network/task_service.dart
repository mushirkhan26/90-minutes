import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class TaskService {
  static const String taskBaseUrl = "https://3qhglx2bhd.execute-api.us-east-1.amazonaws.com/";
  
  final ApiHelper _apiHelper = ApiHelper(baseUrl: taskBaseUrl);
  final LoggingService _logger = LoggingService.instance;

  /// 📋 Get All Assigned Items (Tasks & Subtasks) for a User (Doc 8.1)
  Future<ApiResponse<Map<String, dynamic>>> getAssignedItems(String employeeId) async {
    _logger.logNetwork('Fetching assigned items for employeeId: $employeeId');
    return await _apiHelper.get<Map<String, dynamic>>('task/getReviewItems?employeeId=$employeeId');
  }

  /// 📋 Get All Standalone Tasks (Doc 3.7)
  Future<ApiResponse<Map<String, dynamic>>> getStandaloneTasks() async {
    return await _apiHelper.get<Map<String, dynamic>>('task/standalone/getAll');
  }

  /// 📋 Get All Tasks by Sprint (Doc 3.1) - Used for Activity Log as per requirement
  Future<ApiResponse<Map<String, dynamic>>> getAllTasksBySprint(String sprintId) async {
    return await _apiHelper.get<Map<String, dynamic>>('task/getAll?sprintId=$sprintId');
  }

  /// ➕ Create Task (Standalone or Sprint) (Doc 3.3, 3.8)
  Future<ApiResponse<Map<String, dynamic>>> addTask(Task task) async {
    final bool isStandalone = task.sprintId == null || task.sprintId!.isEmpty;
    final String endpoint = isStandalone ? 'task/standalone/create' : 'task/create';
    return await _apiHelper.post<Map<String, dynamic>>(endpoint, task.toMap());
  }

  /// ✏️ Update Task Fields (Doc 3.4, 8.3)
  Future<ApiResponse<Map<String, dynamic>>> updateTask(String taskId, Map<String, dynamic> updateData) async {
    return await _apiHelper.put<Map<String, dynamic>>('task/update/$taskId', updateData);
  }

  /// ✏️ Update Task Status (Doc 3.4, 8.3)
  Future<ApiResponse<Map<String, dynamic>>> updateTaskStatus(String taskId, String employeeId, String status) async {
    final body = {
      "employeeId": employeeId,
      "status": status
    };
    return await _apiHelper.put<Map<String, dynamic>>('task/update/$taskId', body);
  }

  /// 🗑️ Delete Task (Doc 3.6)
  Future<ApiResponse<Map<String, dynamic>>> deleteTask(String taskId) async {
    return await _apiHelper.delete<Map<String, dynamic>>('task/delete/$taskId');
  }

  // --- Subtask APIs ---

  /// 📋 Get All Subtasks by Task (Doc 4.1)
  Future<ApiResponse<Map<String, dynamic>>> getSubtasks(String taskId) async {
    return await _apiHelper.get<Map<String, dynamic>>('subtask/getAll?taskId=$taskId');
  }

  /// ➕ Create Subtask (Doc 4.3)
  Future<ApiResponse<Map<String, dynamic>>> createSubtask(Map<String, dynamic> subtaskData) async {
    return await _apiHelper.post<Map<String, dynamic>>('subtask/create', subtaskData);
  }

  /// ✏️ Update Subtask Status (Doc 4.4, 8.4)
  Future<ApiResponse<Map<String, dynamic>>> updateSubtaskStatus(String subtaskId, String employeeId, String status) async {
    final body = {
      "employeeId": employeeId,
      "status": status
    };
    return await _apiHelper.put<Map<String, dynamic>>('subtask/update/$subtaskId', body);
  }

  /// 🗑️ Delete Subtask (Doc 4.6)
  Future<ApiResponse<Map<String, dynamic>>> deleteSubtask(String subtaskId) async {
    return await _apiHelper.delete<Map<String, dynamic>>('subtask/delete/$subtaskId');
  }

  // --- Comment APIs ---

  /// 📋 Get All Comments with Replies (Doc 5.1)
  Future<ApiResponse<Map<String, dynamic>>> getComments(String parentId, String parentType) async {
    return await _apiHelper.get<Map<String, dynamic>>('comment/getAllWithReplies?parentId=$parentId&parentType=$parentType');
  }

  /// ➕ Create Comment (Doc 5.2)
  Future<ApiResponse<Map<String, dynamic>>> createComment(Map<String, dynamic> commentData) async {
    return await _apiHelper.post<Map<String, dynamic>>('comment/create', commentData);
  }

  /// ❤️ Toggle Like on Comment (Doc 5.3)
  Future<ApiResponse<Map<String, dynamic>>> toggleLike(String commentId, String employeeId) async {
    return await _apiHelper.post<Map<String, dynamic>>('comment/toggleLike/$commentId', {"employeeId": employeeId});
  }
}
