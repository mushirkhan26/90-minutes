import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class ProjectService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  // Using the new Base URL which worked for Leaderboard
  static const String projectBaseUrl = "https://3qhglx2bhd.execute-api.us-east-1.amazonaws.com/";

  /// 📁 Get All Projects
  Future<ApiResponse<List<ProjectModel>>> getAllProjects() async {
    _logger.info('PROJECT_SERVICE', 'Fetching all projects using new Base URL');
    
    // Set the base URL for this service
    _apiHelper.setBaseUrl(projectBaseUrl);
    
    final response = await _apiHelper.get<dynamic>('project/getAll');

    if (response.success && response.data != null) {
      try {
        final List<dynamic> projectJson = response.data['message'] ?? [];
        final projects = projectJson.map((json) => ProjectModel.fromJson(json)).toList();
        return ApiResponse.success(projects);
      } catch (e) {
        _logger.error('PROJECT_SERVICE', 'Error parsing projects', error: e);
        return ApiResponse.error('Failed to parse projects');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch projects');
  }

  /// ➕ Add New Project
  Future<ApiResponse<Map<String, dynamic>>> addProject(Map<String, dynamic> projectData) async {
    _logger.info('PROJECT_SERVICE', 'Adding new project');
    
    // Set the base URL for this service
    _apiHelper.setBaseUrl(projectBaseUrl);
    
    return await _apiHelper.post<Map<String, dynamic>>('project/addProject', projectData);
  }

  /// 🗑️ Delete Project
  Future<ApiResponse<Map<String, dynamic>>> deleteProject(String projectId) async {
    _logger.info('PROJECT_SERVICE', 'Deleting project: $projectId');
    
    // Set the base URL for this service
    _apiHelper.setBaseUrl(projectBaseUrl);
    
    // Updated to use the correct endpoint: project/delete/:id
    return await _apiHelper.delete<Map<String, dynamic>>('project/delete/$projectId');
  }
}
