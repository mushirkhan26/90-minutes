
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:intl/intl.dart';

class ProjectDetailsDialog extends StatelessWidget {
  final ProjectModel project;
  final Function(String?) onLaunchUrl;

  const ProjectDetailsDialog({
    super.key,
    required this.project,
    required this.onLaunchUrl,
  });

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
    );
  }

  Widget _buildLinkItem(String label, String? url) {
    return InkWell(
      onTap: () => onLaunchUrl(url),
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
}
