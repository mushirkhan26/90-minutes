import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/url_launcher_helper.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:hrtz_hrms/features/tasks/widgets/task_detail_header.dart';
import 'package:hrtz_hrms/features/tasks/widgets/task_detail_main_content.dart';
import 'package:hrtz_hrms/features/tasks/widgets/task_detail_side_panel.dart';
import 'package:provider/provider.dart';
import '../widgets/add_subtask_dialog.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class TaskDetailDialog extends StatefulWidget {
  final Task task;
  final bool isReadOnly;
  const TaskDetailDialog({super.key, required this.task, this.isReadOnly = false});

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().loadTaskDetails(widget.task);
      context.read<AuthProvider>().fetchAndCacheEmployeeList();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatUrl(String url) {
    if (url.startsWith('http')) return url;
    return "https://task-m.s3.amazonaws.com/tasks/$url";
  }

  void _openAttachment(String rawUrl) async {
    final url = _formatUrl(rawUrl);
    final isImage = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
    ].any((ext) => url.toLowerCase().contains(ext));
    if (isImage) {
      _showImagePreview(url);
      return;
    }
    try {
      await UrlLauncherHelper.launchUrlString(url);
    } catch (e) {
      if (mounted) {
        AlertHelper.snackBarError(context, "Cannot open file");
      }
    }
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: PhotoView(
          imageProvider: CachedNetworkImageProvider(url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Selector<AuthProvider, Map<String, String>>(
      selector: (_, auth) => {
        'id': auth.userData?['employeeId']?.toString() ?? "",
        'name': auth.userData?['username'] ?? "User",
      },
      builder: (context, userData, _) {
        final String employeeId = userData['id']!;
        final String employeeName = userData['name']!;

        return Dialog(
          insetPadding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TaskDetailHeader(
                  employeeId: employeeId,
                  isReadOnly: widget.isReadOnly,
                  onDelete: () => _showDeleteConfirmation(employeeId),
                ),
                const Divider(height: 1),
                Expanded(
                  child: isMobile
                      ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              TaskDetailMainContent(
                                task: widget.task,
                                employeeId: employeeId,
                                employeeName: employeeName,
                                isReadOnly: widget.isReadOnly,
                                onOpenAttachment: _openAttachment,
                                onAddSubtask: () => _openAddSubtaskDialog(context.read<TasksProvider>(), employeeId),
                                commentController: _commentController,
                              ),
                              const Divider(),
                              SizedBox(
                                height: 500,
                                child: TaskDetailSidePanel(
                                  employeeId: employeeId,
                                  task: widget.task,
                                  isReadOnly: widget.isReadOnly,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: TaskDetailMainContent(
                                  task: widget.task,
                                  employeeId: employeeId,
                                  employeeName: employeeName,
                                  isReadOnly: widget.isReadOnly,
                                  onOpenAttachment: _openAttachment,
                                  onAddSubtask: () => _openAddSubtaskDialog(context.read<TasksProvider>(), employeeId),
                                  commentController: _commentController,
                                ),
                              ),
                            ),
                            VerticalDivider(width: 1, color: Colors.grey[200]),
                            Expanded(
                              flex: 1,
                              child: TaskDetailSidePanel(
                                employeeId: employeeId,
                                task: widget.task,
                                isReadOnly: widget.isReadOnly,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAddSubtaskDialog(TasksProvider provider, String employeeId) {
    showDialog(
      context: context,
      builder: (context) => AddSubtaskDialog(
        onSave: (title) {
          provider.createSubtask({
            "title": title,
            "status": "ToDo",
            "taskId": widget.task.id,
            "employeeId": employeeId,
          }, widget.task.id);
        },
      ),
    );
  }

  void _showDeleteConfirmation(String employeeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text(
          "Are you sure you want to delete this task? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<TasksProvider>().deleteTask(
                widget.task.id,
                employeeId,
              );
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
