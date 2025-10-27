// 📁 lib/features/mail/widgets/attachment_chips.dart
import 'package:flutter/material.dart';

class AttachmentChips extends StatelessWidget {
  final List<String> attachments;
  final ValueChanged<String> onRemove;

  const AttachmentChips({super.key, required this.attachments, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attachments:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: attachments.map((url) {
            final fileName = Uri.parse(url).pathSegments.last;
            final extension = fileName.split('.').last.toLowerCase();

            IconData fileIcon;
            if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
              fileIcon = Icons.image;
            } else if (extension == 'pdf') {
              fileIcon = Icons.picture_as_pdf;
            } else if (['doc', 'docx'].contains(extension)) {
              fileIcon = Icons.description;
            } else if (['xls', 'xlsx', 'csv'].contains(extension)) {
              fileIcon = Icons.table_chart;
            } else {
              fileIcon = Icons.insert_drive_file;
            }

            final baseName = fileName.split('.').first;
            final shortName = baseName.length > 8
                ? '${baseName.substring(baseName.length - 8)}...$extension'
                : '$baseName.$extension';

            return Chip(
              avatar: Icon(
                fileIcon,
                size: 18,
                color: extension == 'pdf'
                    ? Colors.red
                    : (['jpg', 'jpeg', 'png'].contains(extension)
                          ? Colors.blue
                          : Colors.grey.shade700),
              ),
              label: Text(
                shortName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onRemove(url),
            );
          }).toList(),
        ),
      ],
    );
  }
}
