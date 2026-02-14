import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:hrtz_hrms/features/tasks/widgets/add_edit_task_dialog.dart';
import 'package:provider/provider.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    // Logic for fetching tasks moved to Provider constructor/bootstrap.
    // UI simply consumes the current state.
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userData?['username'] ?? "User";
    final employeeId = authProvider.userData?['employeeId'] ?? "";

    final userRole = authProvider.userData?['role']?.toString().toLowerCase() ?? "";
    final bool isManager = userRole == 'manager';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Tasks Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => tasksProvider.fetchTasks(employeeId),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => tasksProvider.fetchTasks(employeeId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Tasks",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Welcome back, $userName!",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Manager Only Section: General HR Tasks Link
              if (isManager)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.assignment_ind_outlined, color: Color(0xFF26A69A)),
                        title: const Text(
                          'General HR Tasks',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: const Text("Tasks not associated with any sprint", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          context.push(AppRoutes.generalHrTasks);
                        },
                      ),
                    ),
                  ),
                ),

              // Stats Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    _buildStatCard(
                      title: "Tasks",
                      count: tasksProvider.totalTasksCount,
                      icon: Icons.description,
                      color: Colors.blue[50]!,
                      iconColor: Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      title: "Subtasks",
                      count: tasksProvider.subtasksCount,
                      icon: Icons.check_box,
                      color: Colors.green[50]!,
                      iconColor: Colors.green,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      title: "Total Items",
                      count: tasksProvider.totalItemsCount,
                      icon: Icons.layers,
                      color: Colors.purple[50]!,
                      iconColor: Colors.purple,
                    ),
                  ],
                ),
              ),

              // Recent Activity Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildFilterDropdown(tasksProvider),
                  ],
                ),
              ),

              if (tasksProvider.isLoading && tasksProvider.allTasksList.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ))
              else if (tasksProvider.tasks.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasksProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasksProvider.tasks[index];
                    return TaskCard(
                      task: task,
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddEditTaskDialog(
                            task: task,
                            onSave: (updatedTask) async {
                              await tasksProvider.updateTask(
                               updatedTask.id,
                               updatedTask.toMap(),
                               employeeId,
                               );
                             },
                          ),
                        );
                      },
                      onDelete: () {
                        _showDeleteDialog(context, tasksProvider, task.id, employeeId);
                      },
                    );
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(TasksProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.selectedFilter,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Items')),
            DropdownMenuItem(value: 'tasks', child: Text('Tasks Only')),
            DropdownMenuItem(value: 'subtasks', child: Text('Subtasks Only')),
          ],
          onChanged: (val) {
            if (val != null) provider.setFilter(val);
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(
              "$count",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.layers_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Tasks Assigned",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any tasks or subtasks assigned to you yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TasksProvider provider, String id, String employeeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteTask(id, employeeId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
