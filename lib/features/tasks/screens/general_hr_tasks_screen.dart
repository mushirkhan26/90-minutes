import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:hrtz_hrms/features/tasks/screens/task_detail_screen.dart';
import 'package:hrtz_hrms/features/tasks/widgets/add_edit_task_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/task_model.dart';

class GeneralHRTasksScreen extends StatefulWidget {
  const GeneralHRTasksScreen({super.key});

  @override
  State<GeneralHRTasksScreen> createState() => _GeneralHRTasksScreenState();
}

class _GeneralHRTasksScreenState extends State<GeneralHRTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _statusTabController;
  final List<String> _statuses = ['ToDo', 'In Progress', 'In-Review', 'Review-completed', 'Done'];
  final List<String> _statusLabels = ['To Do', 'In Progress', 'In Review', 'Review Completed', 'Done'];

  @override
  void initState() {
    super.initState();
    _statusTabController = TabController(length: _statuses.length, vsync: this);
    _statusTabController.addListener(_handleTabSelection);
    // Logic for initial fetching moved to TasksProvider constructor/_bootstrap.
  }

  void _handleTabSelection() {
    if (_statusTabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _statusTabController.removeListener(_handleTabSelection);
    _statusTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "General HR Tasks",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            Text(
              "Tasks not associated with any sprint",
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: Consumer2<TasksProvider, AuthProvider>(
              builder: (context, tasksProvider, authProvider, child) {
                final employeeId = authProvider.userData?['employeeId']?.toString() ?? "";
                return ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddEditTaskDialog(
                        onSave: (task) {
                          tasksProvider.addTask(task, employeeId);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text("Create Task", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<TasksProvider>(
        builder: (context, tasksProvider, child) {
          if (tasksProvider.isLoading && tasksProvider.standaloneTasks.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
          }
          
          return Column(
            children: [
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_statuses.length, (index) {
                      final status = _statuses[index];
                      final count = tasksProvider.standaloneTasks.where((t) => t.status == status).length;
                      final isSelected = _statusTabController.index == index;
                      
                      return GestureDetector(
                        onTap: () {
                          _statusTabController.animateTo(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? const Color(0xFF26A69A) : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _getStatusIcon(status, isSelected ? const Color(0xFF26A69A) : Colors.grey[600]!),
                              const SizedBox(width: 8),
                              Text(
                                _statusLabels[index],
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF26A69A) : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF26A69A).withOpacity(0.1) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$count", 
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: isSelected ? const Color(0xFF26A69A) : Colors.grey[600],
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    _getStatusIcon(_statuses[_statusTabController.index], Colors.black87, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "${_statusLabels[_statusTabController.index]} Tasks",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "(${tasksProvider.standaloneTasks.where((t) => t.status == _statuses[_statusTabController.index]).length})",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF26A69A),
                  onRefresh: () => tasksProvider.fetchStandaloneTasks(),
                  child: TabBarView(
                    controller: _statusTabController,
                    children: _statuses.map((status) => _buildFilteredTaskList(tasksProvider, status)).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilteredTaskList(TasksProvider provider, String status) {
    final filteredTasks = provider.standaloneTasks.where((t) => t.status == status).toList()
    ..sort((a,b)=> b.deadline.compareTo(a.deadline)); // Sort by deadline descending
    

    if (filteredTasks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: _getStatusIcon(status, Colors.grey[400]!, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  "No tasks in ${_statusLabels[_statusTabController.index]}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create a new task or move tasks to this status",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildKanbanCard(task),
        );
      },
    );
  }

  Widget _buildKanbanCard(Task task) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => TaskDetailDialog(task: task),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF26A69A)),
                    const SizedBox(width: 6),
                    Text(
                      task.taskKey,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                _buildPriorityBadge(task.priority),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              task.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple.shade100, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.purple[50],
                    child: Text(
                      task.assignees.isNotEmpty ? task.assignees.first[0].toUpperCase() : "U",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('MMM dd, yyyy').format(task.deadline),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high': color = Colors.orange; break;
      case 'low': color = Colors.blue; break;
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _getStatusIcon(String status, Color color, {double size = 18}) {
    switch (status) {
      case 'ToDo': return Icon(Icons.assignment_outlined, color: color, size: size);
      case 'In Progress': return Icon(Icons.rotate_right_rounded, color: color, size: size);
      case 'In-Review': return Icon(Icons.visibility_outlined, color: color, size: size);
      case 'Review-completed': return Icon(Icons.fact_check_outlined, color: color, size: size);
      case 'Done': return Icon(Icons.check_circle_rounded, color: color, size: size);
      default: return Icon(Icons.help_outline, color: color, size: size);
    }
  }
}
