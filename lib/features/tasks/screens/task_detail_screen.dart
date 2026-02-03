import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/add_subtask_dialog.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class TaskDetailDialog extends StatefulWidget {
  final Task task;
  const TaskDetailDialog({super.key, required this.task});

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _taskStatuses = ['ToDo', 'In Progress', 'In-Review', 'Review-completed', 'Done'];
  final List<String> _subtaskStatuses = ['To Do', 'In Progress', 'In Review', 'Review Completed', 'Done'];
  final List<String> _priorities = ['Lowest', 'Low', 'Medium', 'High', 'Highest'];

  bool _isEditingPriority = false;
  bool _isEditingDueDate = false;
  DateTime? _tempDeadline;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TasksProvider>();
      provider.fetchSubtasks(widget.task.id);
      provider.fetchComments(widget.task.id);
      
      if (widget.task.sprintId != null && widget.task.sprintId!.isNotEmpty) {
        provider.fetchActivityLogs(widget.task.sprintId!);
      } else {
        provider.setActivityLogs(widget.task.activityLog);
      }
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
    final isImage = ['.jpg', '.jpeg', '.png', '.webp'].any((ext) => url.toLowerCase().contains(ext));
    if (isImage) {
      _showImagePreview(url);
      return;
    }
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot open file: $rawUrl")));
    }
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white), elevation: 0),
        body: PhotoView(imageProvider: CachedNetworkImageProvider(url), minScale: PhotoViewComputedScale.contained, maxScale: PhotoViewComputedScale.covered * 2),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
                            SizedBox(height: 500, child: _buildSidePanel(employeeId)),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(flex: 2, child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: _buildMainContent(employeeId, employeeName))),
                          VerticalDivider(width: 1, color: Colors.grey[200]),
                          Expanded(flex: 1, child: _buildSidePanel(employeeId)),
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
            onPressed: () => Navigator.pop(context)
          ),
          const Text("Task Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent), 
            onPressed: () => _showDeleteConfirmation(employeeId)
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(String employeeId, String employeeName) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        final currentTask = provider.allTasksList.followedBy(provider.standaloneTasks).firstWhere((t) => t.id == widget.task.id, orElse: () => widget.task);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeaderInfo(currentTask, employeeId, provider),
              const SizedBox(height: 16),
              Text(currentTask.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
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
        _buildSectionHeader(Icons.attachment_outlined, "Attachments (${files.length})"),
        const SizedBox(height: 12),
        if (files.isEmpty) _buildEmptySection("No attachments")
        else Wrap(spacing: 12, runSpacing: 12, children: files.map((url) {
          final fileName = url.split('/').last;
          final isImg = ['.jpg', '.jpeg', '.png', '.webp'].any((ext) => url.toLowerCase().contains(ext));
          return InkWell(
            onTap: () => _openAttachment(url), 
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 250, 
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)), 
              child: Row(
                children: [
                  Icon(isImg ? Icons.image_outlined : Icons.insert_drive_file_outlined, color: Colors.blue), 
                  const SizedBox(width: 10), 
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue), maxLines: 1, overflow: TextOverflow.ellipsis), const Text("Click to view", style: TextStyle(fontSize: 10, color: Colors.grey))]))
                ]
              )
            )
          );
        }).toList()),
      ],
    );
  }

  Widget _buildTaskHeaderInfo(Task task, String employeeId, TasksProvider provider) {
    return Wrap(
      spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.bug_report, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(task.taskKey, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        _buildPriorityChip(task.priority),
        _buildDynamicStatusDropdown(task, employeeId, provider),
      ],
    );
  }

  Widget _buildDynamicStatusDropdown(Task task, String employeeId, TasksProvider provider) {
    return PopupMenuButton<String>(
      onSelected: (String status) => provider.updateTaskStatus(task.id, employeeId, status),
      itemBuilder: (BuildContext context) => _taskStatuses.map((s) => PopupMenuItem<String>(value: s, child: Text(s, style: TextStyle(color: task.status == s ? const Color(0xFF673AB7) : Colors.black87, fontWeight: task.status == s ? FontWeight.bold : FontWeight.normal)))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
        decoration: BoxDecoration(color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]), 
        child: Row(mainAxisSize: MainAxisSize.min, children: [Text(task.status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 4), const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18)])
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
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), 
          child: Text(task.description.isEmpty ? "No description." : task.description, style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF455A64)))
        )
      ]
    );
  }

  Widget _buildSubtasksSection(TasksProvider provider, String employeeId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            _buildSectionHeader(Icons.checklist_rtl_outlined, "Subtasks ${provider.currentSubtasks.length}"), 
            TextButton.icon(
              onPressed: () => _openAddSubtaskDialog(provider, employeeId), 
              icon: const Icon(Icons.add, size: 18), 
              label: const Text("Add subtask"), 
              style: TextButton.styleFrom(foregroundColor: Colors.blue[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
            )
          ]
        ), 
        const SizedBox(height: 8), 
        _buildProgressBar(provider), 
        const SizedBox(height: 16), 
        _buildSubtasksTable(provider, employeeId)
      ]
    );
  }

  Widget _buildCommentsSection(TasksProvider provider, String employeeId, String employeeName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        _buildSectionHeader(Icons.chat_bubble_outline, "Comments (${provider.currentComments.length})"), 
        const SizedBox(height: 16), 
        _buildCommentList(provider, employeeId), 
        const SizedBox(height: 24), 
        _buildCommentInput(provider, employeeId, employeeName)
      ]
    );
  }

  Widget _buildCommentList(TasksProvider provider, String currentEmployeeId) {
    // Only show loader if we have NO comments. If we have some, refresh in background.
    if (provider.isCommentLoading && provider.currentComments.isEmpty) {
      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    
    if (provider.currentComments.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No comments yet.", style: TextStyle(color: Colors.grey))));

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.currentComments.length,
        itemBuilder: (context, index) {
          final comment = provider.currentComments[index];
          final List<dynamic> likes = comment['likes'] as List? ?? [];
          final bool isLiked = likes.any((like) {
            if (like is Map) return like['employeeId']?.toString() == currentEmployeeId.toString();
            return like.toString() == currentEmployeeId.toString();
          });

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18, 
                  backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                  child: Text(comment['employeeName']?[0].toUpperCase() ?? "U", style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold))
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(comment['employeeName'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF263238))),
                          const SizedBox(width: 8),
                          Text(
                              comment['createdAt'] != null
                                  ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(comment['createdAt']))
                                  : "Just now",
                              style: const TextStyle(fontSize: 10, color: Colors.grey)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(comment['text'] ?? "", style: const TextStyle(fontSize: 13, color: Color(0xFF37474F), height: 1.4)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => provider.toggleCommentLike(comment['commentId'] ?? comment['_id'], currentEmployeeId, widget.task.id),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 16,
                                    color: isLiked ? Colors.red : Colors.grey[600],
                                  ),
                                  if (likes.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Text("${likes.length}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              _commentController.text = "@${comment['employeeName']} ";
                              _commentController.selection = TextSelection.fromPosition(TextPosition(offset: _commentController.text.length));
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text("Reply", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
        }
    );
  }

  Widget _buildCommentInput(TasksProvider provider, String employeeId, String employeeName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _commentController, 
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Add a comment...", 
          hintStyle: TextStyle(color: Colors.grey[400]),
          isDense: true, 
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.send, size: 20, color: Color(0xFF26A69A)), 
            onPressed: () { 
              if (_commentController.text.isNotEmpty) { 
                final commentData = {
                  'parentId': widget.task.id, 
                  'parentType': 'task', 
                  'employeeId': employeeId, 
                  'employeeName': employeeName, 
                  'text': _commentController.text, 
                  'mentions': [], 
                  'attachments': [], 
                  'parentCommentId': null
                }; 
                provider.addComment(commentData, widget.task.id); 
                _commentController.clear(); 
              } 
            }
          )
        )
      ),
    );
  }

  void _openAddSubtaskDialog(TasksProvider provider, String employeeId) {
    showDialog(context: context, builder: (context) => AddSubtaskDialog(onSave: (data) { final subtaskData = {'taskId': widget.task.id, 'title': data['title'], 'description': data['description'], 'priority': data['priority'], 'storyPoints': data['storyPoints'], 'deadline': data['deadline'], 'assignee': data['assignee'], 'createdBy': employeeId}; provider.createSubtask(subtaskData, widget.task.id); }));
  }

  void _showDeleteConfirmation(String employeeId) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Task"), 
        content: const Text("Are you sure you want to delete this task? This action cannot be undone."), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.grey[600]))), 
          ElevatedButton(
            onPressed: () { context.read<TasksProvider>().deleteTask(widget.task.id, employeeId); Navigator.pop(context); Navigator.pop(context); }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            child: const Text("Delete", style: TextStyle(color: Colors.white))
          )
        ],
      )
    );
  }

  Widget _buildProgressBar(TasksProvider provider) {
    double progress = 0;
    if (provider.currentSubtasks.isNotEmpty) {
      final doneCount = provider.currentSubtasks.where((s) => s['status'] == 'Done').length;
      progress = doneCount / provider.currentSubtasks.length;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${(progress * 100).toInt()}% Complete", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)), Text("${provider.currentSubtasks.where((s) => s['status'] == 'Done').length}/${provider.currentSubtasks.length}", style: const TextStyle(fontSize: 11, color: Colors.grey))]), const SizedBox(height: 6), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)), minHeight: 6))]);
  }

  Widget _buildSubtasksTable(TasksProvider provider, String employeeId) {
    // Background refresh: only show loader if list is empty
    if (provider.isSubtaskLoading && provider.currentSubtasks.isEmpty) {
      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    
    if (provider.currentSubtasks.isEmpty) return _buildEmptySection("No subtasks yet");
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)), 
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, 
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 650), 
          child: Table(
            columnWidths: const {0: FixedColumnWidth(40), 1: FlexColumnWidth(2), 2: FixedColumnWidth(90), 3: FixedColumnWidth(70), 4: FlexColumnWidth(1.5), 5: FixedColumnWidth(130), 6: FixedColumnWidth(40)}, 
            defaultVerticalAlignment: TableCellVerticalAlignment.middle, 
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[50]), 
                children: const [SizedBox(height: 40), _TableCell(text: "WORK", isHeader: true), _TableCell(text: "PRIORITY", isHeader: true), _TableCell(text: "POINTS", isHeader: true), _TableCell(text: "ASSIGNEE", isHeader: true), _TableCell(text: "STATUS", isHeader: true), _TableCell(text: "", isHeader: true)]
              ), 
              ...provider.currentSubtasks.map((sub) => TableRow(
                children: [
                  Center(child: Checkbox(activeColor: const Color(0xFF26A69A), value: sub['status'] == 'Done', onChanged: (v) { provider.updateSubtaskStatus(sub['subtaskId'], employeeId, v! ? 'Done' : 'ToDo', widget.task.id); })), 
                  Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sub['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF37474F))), if(sub['description'] != null && sub['description'].isNotEmpty) Text(sub['description'], style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)])), 
                  _buildTablePriorityBadge(sub['priority'] ?? 'Medium'), 
                  _TableCell(text: "${sub['storyPoints'] ?? 0}"), 
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [CircleAvatar(radius: 10, backgroundColor: Colors.blue[50], child: Text((sub['assignee'] ?? "U")[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold))), const SizedBox(width: 6), Flexible(child: Text(sub['assignee'] ?? "Unassigned", style: const TextStyle(fontSize: 11, color: Colors.black87), overflow: TextOverflow.ellipsis))])), 
                  _buildSubtaskStatusDropdown(sub, employeeId, provider), 
                  IconButton(splashRadius: 20, icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () => provider.deleteSubtask(sub['subtaskId'], widget.task.id))
                ]
              ))
            ]
          )
        )
      )
    );
  }

  Widget _buildSubtaskStatusDropdown(dynamic sub, String employeeId, TasksProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8), 
      child: Container(
        height: 32, 
        padding: const EdgeInsets.symmetric(horizontal: 8), 
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)), 
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _subtaskStatuses.contains(sub['status']) ? sub['status'] : 'To Do', 
            isExpanded: true, 
            icon: const Icon(Icons.arrow_drop_down, size: 16),
            style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500), 
            items: _subtaskStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), 
            onChanged: (val) => provider.updateSubtaskStatus(sub['subtaskId'], employeeId, val!, widget.task.id)
          )
        )
      )
    );
  }

  Widget _buildSidePanel(String employeeId) {
    return Column(children: [TabBar(controller: _tabController, labelColor: const Color(0xFF26A69A), unselectedLabelColor: Colors.grey, indicatorColor: const Color(0xFF26A69A), indicatorWeight: 3, labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), tabs: const [Tab(text: "Details"), Tab(text: "Activity Log")]), Expanded(child: TabBarView(controller: _tabController, children: [_buildSidePanelContent(employeeId), _buildActivityLogTab()]))]);
  }

  Widget _buildSidePanelContent(String employeeId) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        final currentTask = provider.allTasksList.followedBy(provider.standaloneTasks).firstWhere((t) => t.id == widget.task.id, orElse: () => widget.task);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditablePriority(currentTask, employeeId, provider),
              _buildEditableAssignees(currentTask, employeeId, provider),
              _buildEditableDueDate(currentTask, employeeId, provider),
              _buildDetailItem("DEPARTMENT", currentTask.department ?? "Development", null, null),
              _buildDetailItem("CATEGORY", currentTask.category ?? "UI", null, null),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditablePriority(Task task, String employeeId, TasksProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("PRIORITY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 0.5)), InkWell(onTap: () => setState(() => _isEditingPriority = !_isEditingPriority), borderRadius: BorderRadius.circular(4), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), child: Text("Edit", style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold))))]),
          const SizedBox(height: 8),
          if (_isEditingPriority) Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [..._priorities.map((p) => ListTile(dense: true, visualDensity: VisualDensity.compact, title: Text(p, style: TextStyle(fontSize: 13, color: task.priority == p ? Colors.orange[800] : Colors.black87, fontWeight: task.priority == p ? FontWeight.bold : FontWeight.normal)), tileColor: task.priority == p ? Colors.orange[50] : null, onTap: () { provider.updateTask(task.id, {'priority': p, 'employeeId': employeeId}, employeeId); setState(() => _isEditingPriority = false); })), const Divider(height: 1), ListTile(dense: true, visualDensity: VisualDensity.compact, title: const Center(child: Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 12))), onTap: () => setState(() => _isEditingPriority = false))]))
          else Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: Colors.orange[50], border: Border.all(color: Colors.orange.shade100), borderRadius: BorderRadius.circular(6)), child: Text(task.priority, style: TextStyle(fontSize: 14, color: Colors.orange[800], fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildEditableAssignees(Task task, String employeeId, TasksProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("ASSIGNEES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 0.5)), InkWell(onTap: () => _showEmployeeSelectionDialog(task, employeeId, provider), borderRadius: BorderRadius.circular(4), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), child: Text("Edit", style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold))))]),
          const SizedBox(height: 8),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)), child: Wrap(spacing: 8, runSpacing: 8, children: task.assignees.isEmpty ? [const Text("Unassigned", style: TextStyle(fontSize: 13, color: Colors.grey))] : task.assignees.map((a) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.purple.shade100)), child: Row(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 8, backgroundColor: Colors.purple[100], child: Text(a[0].toUpperCase(), style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.purple))), const SizedBox(width: 6), Text(a, style: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w500))]))).toList())),
        ],
      ),
    );
  }

  void _showEmployeeSelectionDialog(Task task, String employeeId, TasksProvider provider) {
    final authProvider = context.read<AuthProvider>();
    List<String> tempSelected = List.from(task.assignees);
    showDialog(context: context, builder: (context) { String searchQuery = ''; return StatefulBuilder(builder: (context, setDialogState) { final employees = authProvider.searchEmployees(searchQuery); return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Container(padding: const EdgeInsets.all(16), height: 500, child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Select Assignees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]), TextField(decoration: InputDecoration(hintText: 'Search employees...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true), onChanged: (val) => setDialogState(() => searchQuery = val)), const SizedBox(height: 16), Expanded(child: ListView.builder(itemCount: employees.length, itemBuilder: (context, index) { final emp = employees[index]; final isSelected = tempSelected.contains(emp.employeeID) || tempSelected.contains(emp.name); return CheckboxListTile(activeColor: const Color(0xFF26A69A), title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), subtitle: Text('ID: ${emp.employeeID}', style: const TextStyle(fontSize: 12)), value: isSelected, onChanged: (bool? value) { setDialogState(() { if (value == true) tempSelected.add(emp.employeeID); else tempSelected.remove(emp.employeeID); }); }); })), const Divider(), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), onPressed: () { provider.updateTask(task.id, {'assignedTo': tempSelected, 'employeeId': employeeId}, employeeId); Navigator.pop(context); }, child: const Text('Done')))]))); }); });
  }

  Widget _buildEditableDueDate(Task task, String employeeId, TasksProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("DUE DATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 0.5)), InkWell(onTap: () => setState(() { _isEditingDueDate = !_isEditingDueDate; _tempDeadline = task.deadline; }), borderRadius: BorderRadius.circular(4), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), child: Text("Edit", style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold))))]),
          const SizedBox(height: 8),
          if (_isEditingDueDate) Row(children: [Expanded(child: InkWell(onTap: () async { final date = await showDatePicker(context: context, initialDate: _tempDeadline ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365))); if (date != null) setState(() => _tempDeadline = date); }, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(DateFormat('dd-MM-yyyy').format(_tempDeadline ?? task.deadline), style: const TextStyle(fontSize: 13)), const Icon(Icons.calendar_today, size: 16, color: Colors.grey)])))), const SizedBox(width: 8), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), onPressed: () { provider.updateTask(task.id, {'deadline': DateFormat('yyyy-MM-dd').format(_tempDeadline!), 'employeeId': employeeId}, employeeId); setState(() => _isEditingDueDate = false); }, child: const Text("Save", style: TextStyle(fontSize: 12))), const SizedBox(width: 4), TextButton(onPressed: () => setState(() => _isEditingDueDate = false), child: const Text("Cancel", style: TextStyle(fontSize: 12, color: Colors.grey)))])
          else Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)), child: Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(DateFormat('MMM dd, yyyy').format(task.deadline), style: const TextStyle(fontSize: 13, color: Color(0xFF455A64)))]))
        ],
      ),
    );
  }

  Widget _buildActivityLogTab() {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        if (provider.isLogLoading && provider.currentActivityLogs.isEmpty) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        if (provider.currentActivityLogs.isEmpty) return const Center(child: Text("No activity logs found.", style: TextStyle(color: Colors.grey)));
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: provider.currentActivityLogs.length,
          itemBuilder: (context, index) {
            final log = provider.currentActivityLogs[index];
            final creator = log['employeeName'] ?? "System";
            final action = log['action'] ?? "updated";
            final details = log['details'] ?? "";
            final timeStr = log['timestamp'] ?? log['createdAt'];
            final time = timeStr != null 
                ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(timeStr))
                : "Recently";
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Color(0xFF455A64)),
                            children: [
                              TextSpan(text: creator, style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: " $action"),
                            ]
                          )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      details,
                      style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, Color? bgColor, Color? textColor) {
    return Padding(padding: const EdgeInsets.only(bottom: 20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 0.5)), const SizedBox(height: 8), Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor ?? Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)), child: Text(value, style: TextStyle(fontSize: 12, color: textColor ?? Colors.black87, fontWeight: FontWeight.w500)))]));
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(children: [Icon(icon, size: 18, color: const Color(0xFF26A69A)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF263238)))]);
  }

  Widget _buildEmptySection(String text) {
    return Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)), child: Center(child: Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 13, fontStyle: FontStyle.italic))));
  }

  Widget _buildPriorityChip(String priority) {
    Color color = priority.toLowerCase() == 'high' || priority.toLowerCase() == 'highest' ? Colors.red[700]! : priority.toLowerCase() == 'medium' ? Colors.orange[800]! : Colors.blue[700]! ;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.2))), child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
  }

  Widget _buildTablePriorityBadge(String priority) {
    Color color = priority.toLowerCase() == 'high' || priority.toLowerCase() == 'highest' ? Colors.red : priority.toLowerCase() == 'medium' ? Colors.orange : Colors.blue ;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(priority, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)));
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _TableCell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(12.0), child: Text(text, style: TextStyle(fontSize: isHeader ? 10 : 12, fontWeight: isHeader ? FontWeight.w900 : FontWeight.normal, color: isHeader ? Colors.grey[600] : const Color(0xFF37474F), letterSpacing: isHeader ? 0.5 : 0)));
  }
}
