import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AddEditTaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const AddEditTaskDialog({super.key, this.task, required this.onSave});

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _deadline;
  late String _status;
  late String _priority;
  late String _assignedBy;
  
  // New fields
  late String _type;
  late List<String> _selectedAssignees;
  late List<String> _selectedReviewers;
  late String _category;
  late int _storyPoints;
  List<String> _references = [];

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.userData?['employeeId'] ?? "";
    
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _deadline = widget.task?.deadline ?? DateTime.now();
    _status = widget.task?.status ?? 'ToDo';
    _priority = widget.task?.priority ?? 'Medium';
    _assignedBy = widget.task?.assignedBy ?? currentUserId;
    
    _type = widget.task?.type ?? 'Task';
    _selectedAssignees = List.from(widget.task?.assignees ?? []);
    _selectedReviewers = List.from(widget.task?.reviewers ?? []);
    _category = widget.task?.category?.toLowerCase() ?? 'development';
    _storyPoints = widget.task?.storyPoints ?? 2;
    _references = List.from(widget.task?.references ?? []);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.fetchAndCacheEmployeeList();
    });
  }

  InputDecoration _inputDecoration(String label, {IconData? icon, bool isRequired = false}) {
    return InputDecoration(
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label),
            if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      labelStyle: const TextStyle(color: AppColors.black151515, fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.primary) : null,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  void _showEmployeeSelectionDialog({required bool isAssignee}) {
    final authProvider = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final employees = authProvider.searchEmployees(searchQuery);
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 500,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAssignee ? 'Select Assignees' : 'Select Reviewer',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search employees by name, dept, role or id',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (val) => setDialogState(() => searchQuery = val),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final emp = employees[index];
                          final isSelected = isAssignee 
                              ? _selectedAssignees.contains(emp.employeeID)
                              : _selectedReviewers.contains(emp.employeeID);
                          
                          return CheckboxListTile(
                            activeColor: AppColors.primary,
                            title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('ID: ${emp.employeeID}'),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (isAssignee) {
                                  if (value == true) {
                                    _selectedAssignees.add(emp.employeeID);
                                  } else {
                                    _selectedAssignees.remove(emp.employeeID);
                                  }
                                } else {
                                  // For Reviewer: Only allow single selection
                                  if (value == true) {
                                    _selectedReviewers.clear();
                                    _selectedReviewers.add(emp.employeeID);
                                  } else {
                                    _selectedReviewers.remove(emp.employeeID);
                                  }
                                }
                              });
                              setDialogState(() {}); // Update dialog UI
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        // In a real app, you would upload these files to S3 and store the URLs.
        // For now, we'll just add the names as placeholders to show it's working.
        _references.addAll(result.files.map((file) => file.name));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task == null ? 'Create New Task' : 'Edit Task',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Name
                      TextFormField(
                        initialValue: _title,
                        decoration: _inputDecoration('Task Name', isRequired: true).copyWith(hintText: 'Enter task name'),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                        onSaved: (value) => _title = value!,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      TextFormField(
                        initialValue: _description,
                        maxLines: 4,
                        decoration: _inputDecoration('Description', isRequired: true).copyWith(
                          hintText: 'Describe the task',
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                        onSaved: (value) => _description = value!,
                      ),
                      const SizedBox(height: 20),

                      // Type & Priority Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _type,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: ['Story', 'Task', 'Bug', 'Epic']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _type = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _priority,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: ['Lowest', 'Low', 'Medium', 'High', 'Highest']
                                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _priority = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Assignees
                      _buildSelectionField(
                        label: 'Assignees',
                        isRequired: true,
                        value: _selectedAssignees.isEmpty ? 'No assignees selected' : '${_selectedAssignees.length} selected',
                        onTap: () => _showEmployeeSelectionDialog(isAssignee: true),
                      ),
                      const SizedBox(height: 20),

                      // Reviewer
                      _buildSelectionField(
                        label: 'Reviewer',
                        isRequired: true,
                        value: _selectedReviewers.isEmpty ? 'No reviewer selected' : '${_selectedReviewers.length} selected',
                        onTap: () => _showEmployeeSelectionDialog(isAssignee: false),
                      ),
                      const SizedBox(height: 20),

                      // Category
                      const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['development', 'research', 'ui', 'testing', 'documentation', 'hr', 'finance', 'operations', 'other']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1))))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 20),

                      // Due Date & Story Points
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text.rich(TextSpan(children: [TextSpan(text: 'Due Date'), TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _deadline,
                                      // firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                      // lastDate: DateTime.now().add(const Duration(days: 365)),
                                      firstDate: DateTime.now().subtract(const Duration(minutes: 1)),
                                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                    );
                                    if (date != null) setState(() => _deadline = date);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('dd-MM-yyyy').format(_deadline)),
                                        const Icon(Icons.calendar_today, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Story Points', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: _storyPoints.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onSaved: (val) => _storyPoints = int.tryParse(val ?? '0') ?? 0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // References
                      const Text('References (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._references.map((file) => Chip(
                                label: Text(file, style: const TextStyle(fontSize: 10)),
                                onDeleted: () => setState(() => _references.remove(file)),
                              )),
                          InkWell(
                            onTap: _pickFiles,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final task = Task(
                        id: widget.task?.id ?? '',
                        taskKey: widget.task?.taskKey ?? '',
                        title: _title,
                        description: _description,
                        deadline: _deadline,
                        status: _status,
                        priority: _priority,
                        assignedBy: _assignedBy,
                        itemType: widget.task?.itemType ?? 'task',
                        subtaskCount: widget.task?.subtaskCount ?? 0,
                        type: _type,
                        assignees: _selectedAssignees,
                        reviewers: _selectedReviewers,
                        category: _category,
                        storyPoints: _storyPoints,
                        references: _references,
                        department: widget.task?.department ?? "Development",
                      );
                      widget.onSave(task);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.task == null ? 'Create Task' : 'Update Task', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionField({required String label, required bool isRequired, required String value, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_add_alt_1, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(value, style: TextStyle(color: value.contains('No') ? Colors.grey : Colors.black))),
                const Icon(Icons.add_circle_outline, size: 24, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
