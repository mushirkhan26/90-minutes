import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/url_launcher_helper.dart';
import 'package:hrtz_hrms/features/tasks/providers/project_provider.dart';
import 'package:hrtz_hrms/features/tasks/screens/add_project_screen.dart';
import 'package:hrtz_hrms/features/tasks/widgets/project_card.dart';
import 'package:hrtz_hrms/features/tasks/widgets/project_details_dialog.dart';
import 'package:provider/provider.dart';

class ManageTasksScreen extends StatefulWidget {
  const ManageTasksScreen({super.key});

  @override
  State<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  void _launchUrl(String? url) {
    if (_isValidUrl(url)) {
      UrlLauncherHelper.launchUrlString(url!);
    } else {
      AlertHelper.snackBarError(context, "Invalid or missing URL");
    }
  }

  void _confirmDelete(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Project"),
        content: Text("Are you sure you want to delete '${project.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<ProjectProvider>().deleteProject(project.id);

              if (!context.mounted) return;

              if (success) {
                AlertHelper.snackBarSuccess(context, "Project deleted successfully");
              } else {
                AlertHelper.snackBarError(
                    context,
                    context.read<ProjectProvider>().errorMessage ??
                        "Failed to delete project");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProjectDetails(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailsDialog(
        project: project,
        onLaunchUrl: _launchUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final projects = provider.projects;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Projects",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => provider.fetchProjects(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchProjects(),
        child: provider.state == ProjectState.loading && projects.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, projects.length),
                    const SizedBox(height: 24),
                    if (projects.isEmpty &&
                        provider.state == ProjectState.success)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text("No projects found"),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projects.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.48,
                        ),
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return ProjectCard(
                            project: project,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddProjectScreen(project: project)),
                              );
                            },
                            onDelete: () => _confirmDelete(context, project),
                            onDetails: () =>
                                _showProjectDetails(context, project),
                            onVisit: () {
                              final userUrl =
                                  project.links?['webDeployment']?['user'];
                              _launchUrl(userUrl);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Projects",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "$count total projects",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProjectScreen()),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            "Add Project",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
