
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:intl/intl.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetails;
  final VoidCallback onVisit;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
    required this.onDetails,
    required this.onVisit,
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
    final testAccountsCount = project.credentials?.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                        Icons.edit_outlined, const Color(0xFF2196F3), onTap: onEdit),
                    const SizedBox(width: 6),
                    _buildIconButton(Icons.delete_outline, Colors.redAccent, onTap: onDelete),
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
                            onTap: onDetails),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildActionButton("Visit", Icons.launch_outlined,
                            const Color(0xFF00BFA5),
                            onTap: onVisit),
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
              color: Colors.black.withOpacity(0.1),
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
