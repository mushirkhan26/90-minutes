import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/project_service.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum ProjectState { idle, loading, success, error }

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final LocalStorageService _local = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  ProjectState _state = ProjectState.idle;
  List<ProjectModel> _projects = [];
  String? _errorMessage;

  ProjectProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Load from local storage for instant UI
    await _loadFromLocal();
    
    // 2. Fetch fresh data from API in background
    await fetchProjects();
  }

  ProjectState get state => _state;
  List<ProjectModel> get projects => _projects;
  String? get errorMessage => _errorMessage;

  Future<void> _loadFromLocal() async {
    try {
      final cached = await _local.getProjectList();
      if (cached != null && cached.isNotEmpty) {
        _projects = cached;
        _state = ProjectState.success;
        _logger.info('PROJECT_PROVIDER', 'Loaded ${cached.length} projects from local storage');
        notifyListeners();
      }
    } catch (e) {
      _logger.error('PROJECT_PROVIDER', 'Error loading from local storage', error: e);
    }
  }

  Future<void> fetchProjects() async {
    // Only show loader if we have no cached data
    if (_projects.isEmpty) {
      _state = ProjectState.loading;
      notifyListeners();
    }

    try {
      final response = await _projectService.getAllProjects();

      if (response.success && response.data != null) {
        _projects = response.data!;
        _state = ProjectState.success;
        // 3. Save to local storage
        await _local.saveProjectList(_projects);
      } else {
        _state = _projects.isNotEmpty ? ProjectState.success : ProjectState.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _state = _projects.isNotEmpty ? ProjectState.success : ProjectState.error;
      _errorMessage = e.toString();
      _logger.error('PROJECT_PROVIDER', 'Error fetching projects', error: e);
    }
    notifyListeners();
  }

  Future<bool> addProject(Map<String, dynamic> projectData) async {
    _state = ProjectState.loading;
    notifyListeners();

    try {
      final response = await _projectService.addProject(projectData);
      if (response.success) {
        await fetchProjects();
        return true;
      } else {
        _errorMessage = response.message;
        _state = ProjectState.success;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProjectState.success;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    _state = ProjectState.loading;
    notifyListeners();

    try {
      final response = await _projectService.deleteProject(projectId);
      if (response.success) {
        _projects.removeWhere((p) => p.id == projectId);
        // Update local cache after deletion
        await _local.saveProjectList(_projects);
        _state = ProjectState.success;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _state = ProjectState.success;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProjectState.success;
      notifyListeners();
      return false;
    }
  }
}
