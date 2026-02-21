import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/url_launcher_helper.dart';
import 'package:intl/intl.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/add_subtask_dialog.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class TaskDetailDialog extends StatefulWidget {
  final Task task;
  const TaskDetailDialog({super.key, required this.task});

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _taskStatuses = [
    'ToDo',
    'In Progress',
    'In-Review',
    'Review-completed',
    'Done',
  ];
  final List<String> _subtaskStatuses = [
    'To Do',
    'In Progress',
    'In Review',
    'Review Completed',
    'Done',
  ];
  final List<String> _priorities = [
    'Lowest',
    'Low',
    'Medium',
    'High',
    'Highest',
  ];

  bool _isEditingPriority = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().loadTaskDetails(widget.task);
      context.read<AuthProvider>().fetchAndCacheEmployeeList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                _buildDialogHeader(employeeId),
                const Divider(height: 1),
                Expanded(
                  child: isMobile
                      ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildMainContent(employeeId, employeeName),
                              const Divider(),
                              SizedBox(
                                height: 500,
                                child: _buildSidePanel(employeeId),
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
                                child: _buildMainContent(
                                  employeeId,
                                  employeeName,
                                ),
                              ),
                            ),
                            VerticalDivider(width: 1, color: Colors.grey[200]),
                            Expanded(
                              flex: 1,
                              child: _buildSidePanel(employeeId),
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

  Widget _buildDialogHeader(String employeeId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Task Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmation(employeeId),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(String employeeId, String employeeName) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        final currentTask = provider.allTasksList
            .followedBy(provider.standaloneTasks)
            .firstWhere(
              (t) => t.id == widget.task.id,
              orElse: () => widget.task,
            );
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeaderInfo(currentTask, employeeId, provider),
              const SizedBox(height: 16),
              Text(
                currentTask.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 32),
              _buildDescriptionSection(currentTask),
              const SizedBox(height: 32),
              _buildSubtasksSection(provider, employeeId),
              const SizedBox(height: 32),
              _buildAttachmentsSection(currentTask),
              const SizedBox(height: 32),
              _buildCommentsSection(provider, employeeId, employeeName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentsSection(Task task) {
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
                onTap: () => _openAttachment(url),
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

  Widget _buildTaskHeaderInfo(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bug_report, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              task.taskKey,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _buildPriorityChip(task.priority),
        _buildDynamicStatusDropdown(task, employeeId, provider),
      ],
    );
  }

  Widget _buildDynamicStatusDropdown(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    return PopupMenuButton<String>(
      onSelected: (String status) =>
          provider.updateTaskStatus(task.id, employeeId, status),
      itemBuilder: (BuildContext context) => _taskStatuses
          .map(
            (s) => PopupMenuItem<String>(
              value: s,
              child: Text(
                s,
                style: TextStyle(
                  color: task.status == s
                      ? const Color(0xFF673AB7)
                      : Colors.black87,
                  fontWeight: task.status == s
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.description_outlined, "Description"),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            task.description.isEmpty ? "No description." : task.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF455A64),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtasksSection(TasksProvider provider, String employeeId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              Icons.checklist_rtl_outlined,
              "Subtasks ${provider.currentSubtasks.length}",
            ),
            TextButton.icon(
              onPressed: () => _openAddSubtaskDialog(provider, employeeId),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add subtask"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildProgressBar(provider),
        const SizedBox(height: 16),
        _buildSubtasksTable(provider, employeeId),
      ],
    );
  }

  Widget _buildCommentsSection(
    TasksProvider provider,
    String employeeId,
    String employeeName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.chat_bubble_outline,
          "Comments (${provider.currentComments.length})",
        ),
        const SizedBox(height: 16),
        _buildCommentList(provider, employeeId),
        const SizedBox(height: 24),
        _buildCommentInput(provider, employeeId, employeeName),
      ],
    );
  }

  Widget _buildCommentList(TasksProvider provider, String currentEmployeeId) {
    if (provider.isCommentLoading && provider.currentComments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (provider.currentComments.isEmpty){
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No comments yet.", style: TextStyle(color: Colors.grey)),
        ),
      );
      }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.currentComments.length,
      itemBuilder: (context, index) {
        final comment = provider.currentComments[index];
        final List<dynamic> likes = comment['likes'] as List? ?? [];
        final bool isLiked = likes.any((like) {
          if (like is Map){
            return like['employeeId']?.toString() ==
                currentEmployeeId.toString();}
          return like.toString() == currentEmployeeId.toString();
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF673AB7).withValues(alpha: 0.1),
                child: Text(
                  comment['employeeName']?[0].toUpperCase() ?? "U",
                  style: const TextStyle(
                    color: Color(0xFF673AB7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment['employeeName'] ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment['createdAt'] != null
                              ? DateFormat(
                                  'MMM dd, hh:mm a',
                                ).format(DateTime.parse(comment['createdAt']))
                              : "Just now",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment['text'] ?? "",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF37474F),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => provider.toggleCommentLike(
                            comment['commentId'] ?? comment['_id'],
                            currentEmployeeId,
                            widget.task.id,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: isLiked
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                                if (likes.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    "${likes.length}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            _commentController.text =
                                "@${comment['employeeName']} ";
                            _commentController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _commentController.text.length,
                                  ),
                                );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.reply,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Reply",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput(
    TasksProvider provider,
    String employeeId,
    String employeeName,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TextField(
            controller: _commentController,
            maxLines: null,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              hintText: "Add a comment...",
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_commentController.text.trim().isEmpty) return;
                    final data = {
                      "employeeId": employeeId,
                      "employeeName": employeeName,
                      "text": _commentController.text.trim(),
                      "itemType": "task",
                      "itemId": widget.task.id,
                      "createdAt": DateTime.now().toIso8601String(),
                    };
                    await provider.addComment(data, widget.task.id);
                    _commentController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Comment",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(String employeeId) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        final currentTask = provider.allTasksList
            .followedBy(provider.standaloneTasks)
            .firstWhere(
              (t) => t.id == widget.task.id,
              orElse: () => widget.task,
            );
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSideSection(
                "STATUS",
                _buildDynamicStatusDropdown(currentTask, employeeId, provider),
              ),
              const SizedBox(height: 24),
              _buildSideSection(
                "PRIORITY",
                _buildPriorityEditor(currentTask, employeeId, provider),
              ),
              const SizedBox(height: 24),
              _buildSideSection(
                "DUE DATE",
                _buildDueDateEditor(currentTask, employeeId, provider),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "ACTIVITY LOG",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildActivityTimeline(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTimeline(TasksProvider provider) {
    final logs = provider.currentActivityLogs;
    if (provider.isLogLoading && logs.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (logs.isEmpty) {
      return const Text(
        "No logs available",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final bool isLast = index == logs.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF26A69A),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: Colors.grey[200]),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log['logMessage'] ?? "Status updated",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log['updatedOn'] != null
                        ? DateFormat(
                            'MMM dd, hh:mm a',
                          ).format(DateTime.parse(log['updatedOn']))
                        : "Unknown",
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Helper Widgets ---

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

  Widget _buildSideSection(String label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        content,
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

  Widget _buildProgressBar(TasksProvider provider) {
    final int total = provider.currentSubtasks.length;
    if (total == 0) return const SizedBox.shrink();
    final int done = provider.currentSubtasks
        .where((s) => s['status'] == 'Done')
        .length;
    final double progress = done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${(progress * 100).toInt()}% Complete",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              "$done/$total",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildSubtasksTable(TasksProvider provider, String employeeId) {
    if (provider.isSubtaskLoading && provider.currentSubtasks.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (provider.currentSubtasks.isEmpty){
      return _buildEmptySection("No subtasks created.");}
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FixedColumnWidth(110),
          2: FixedColumnWidth(50),
        },
        children: provider.currentSubtasks.map<TableRow>((s) {
          return TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  s['title'] ?? "",
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildSubtaskStatusDropdown(s, provider, employeeId),
              ),
              IconButton(
                onPressed: () => provider.deleteSubtask(
                  s['subtaskId'] ?? s['_id'],
                  widget.task.id,
                ),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.redAccent,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubtaskStatusDropdown(
    dynamic subtask,
    TasksProvider provider,
    String employeeId,
  ) {
    return PopupMenuButton<String>(
      onSelected: (val) => provider.updateSubtaskStatus(
        subtask['subtaskId'] ?? subtask['_id'],
        employeeId,
        val,
        widget.task.id,
      ),
      itemBuilder: (ctx) => _subtaskStatuses
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(s, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(subtask['status']).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtask['status'] ?? "ToDo",
              style: TextStyle(
                fontSize: 11,
                color: _getStatusColor(subtask['status']),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'highest':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            priority,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityEditor(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    if (_isEditingPriority) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: task.priority,
            isExpanded: true,
            items: _priorities
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(p, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                provider.updateTask(task.id, {"priority": val}, employeeId);
                setState(() => _isEditingPriority = false);
              }
            },
          ),
        ),
      );
    }
    return InkWell(
      onTap: () => setState(() => _isEditingPriority = true),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            task.priority,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDueDateEditor(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: task.deadline,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (date != null) {
          await provider.updateTask(task.id, {
            "deadline": date.toUtc().toIso8601String(),
          }, employeeId);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMM dd, yyyy').format(task.deadline),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ToDo':
        return Colors.grey;
      case 'In Progress':
        return Colors.blue;
      case 'In Review':
        return Colors.orange;
      case 'Review Completed':
        return Colors.purple;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
