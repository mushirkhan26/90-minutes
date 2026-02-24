import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';

class TaskAttachmentsSection extends StatelessWidget {
  final Task task;
  final Function(String) onOpenAttachment;

  const TaskAttachmentsSection({
    super.key,
    required this.task,
    required this.onOpenAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final files = task.references ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.attachment_outlined,
          "Attachments (${files.length})",
        ),
        const SizedBox(height: 12),
        if (files.isEmpty)
          _buildEmptySection("No attachments")
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: files.map((url) {
              final fileName = url.split('/').last;
              final isImg = [
                '.jpg',
                '.jpeg',
                '.png',
                '.webp',
              ].any((ext) => url.toLowerCase().contains(ext));
              return InkWell(
                onTap: () => onOpenAttachment(url),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isImg
                            ? Icons.image_outlined
                            : Icons.insert_drive_file_outlined,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              "Click to view",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF263238)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF263238),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
        fontSize: 13,
      ),
    );
  }
}
