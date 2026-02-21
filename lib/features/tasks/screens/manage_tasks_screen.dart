import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/url_launcher_helper.dart';
import 'package:hrtz_hrms/features/tasks/providers/project_provider.dart';
import 'package:hrtz_hrms/features/tasks/screens/add_project_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ManageTasksScreen extends StatefulWidget {
  const ManageTasksScreen({super.key});

  @override
  State<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '--';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

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

              // Safe check before using context after an async operation
              if (!context.mounted) return;

              if (success) {
                AlertHelper.snackBarSuccess(context, "Project deleted successfully");
              } else {
                AlertHelper.snackBarError(context, context.read<ProjectProvider>().errorMessage ?? "Failed to delete project");
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (_isValidUrl(project.imageUrl))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(project.imageUrl!,
                                  width: 40, height: 40, fit: BoxFit.cover),
                            )
                          else
                            const Icon(Icons.business,
                                size: 40, color: Colors.teal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(project.name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("Description",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(project.description, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Status",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          _buildBadge(project.status, const Color(0xFFF1F5F9),
                              Colors.black87),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Priority",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          _buildBadge(project.priority, const Color(0xFFECFDF5),
                              Colors.green),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Start Date",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(_formatDate(project.startDate),
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("End Date",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(_formatDate(project.endDate),
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("Web Deployment Links",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (project.links != null &&
                    project.links!['webDeployment'] != null) ...[
                  _buildLinkItem("User", project.links!['webDeployment']['user']),
                  const SizedBox(height: 12),
                  _buildLinkItem(
                      "Admin", project.links!['webDeployment']['admin']),
                ] else
                  const Text("No links available",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 24),
                const Text("Test Credentials",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (project.credentials != null &&
                    project.credentials!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: project.credentials!
                          .map((cred) => Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Username",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Text(cred.username,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Password",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            Text(cred.password,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Role",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        Text(cred.role,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  if (project.credentials!.indexOf(cred) !=
                                      project.credentials!.length - 1)
                                    const Divider(height: 24),
                                ],
                              ))
                          .toList(),
                    ),
                  )
                else
                  const Text("No credentials available",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkItem(String label, String? url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                const Text("Open",
                    style: TextStyle(
                        color: Color(0xFF14B8A6), fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new, size: 16, color: Color(0xFF14B8A6)),
              ],
            ),
          ],
        ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Projects",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${projects.length} total projects",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
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
                          return _buildProjectCard(projects[index]);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final testAccountsCount = project.credentials?.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  image: _isValidUrl(project.imageUrl)
                      ? DecorationImage(
                          image: NetworkImage(project.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !_isValidUrl(project.imageUrl)
                    ? Center(
                        child: Icon(Icons.insert_photo_outlined,
                            size: 32, color: Colors.grey[400]),
                      )
                    : null,
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    _buildIconButton(
                        Icons.edit_outlined, const Color(0xFF2196F3), onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddProjectScreen(project: project)),
                          );
                        }),
                    const SizedBox(width: 6),
                    _buildIconButton(Icons.delete_outline, Colors.redAccent, onTap: () => _confirmDelete(context, project)),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined,
                          size: 16, color: Color(0xFF009688)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildBadge(project.status, const Color(0xFFE3F2FD),
                          const Color(0xFF1976D2)),
                      Text(
                        project.priority,
                        style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 9,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  _buildDateItem("Start Date", _formatDate(project.startDate)),
                  _buildDateItem("End Date", _formatDate(project.endDate)),
                  if (testAccountsCount > 0)
                    _buildDateItem("Test Accounts", "$testAccountsCount"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                            "Details", Icons.info_outline, const Color(0xFF2196F3),
                            onTap: () => _showProjectDetails(context, project)),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildActionButton("Visit", Icons.launch_outlined,
                            const Color(0xFF00BFA5),
                            onTap: () {
                              final userUrl = project.links?['webDeployment']?['user'];
                              _launchUrl(userUrl);
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: txt, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDateItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Color(0xFF455A64)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 12),
            const SizedBox(width: 2),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
