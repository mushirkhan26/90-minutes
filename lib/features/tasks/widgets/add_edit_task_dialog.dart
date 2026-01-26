import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _deadline = widget.task?.deadline ?? DateTime.now();
    _status = widget.task?.status ?? 'ToDo';
    _priority = widget.task?.priority ?? 'Medium';
    _assignedBy = widget.task?.assignedBy ?? '';
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.gray475467, fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      filled: true,
      fillColor: Colors.grey[50],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.task == null ? 'New Task' : 'Edit Task',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black151515,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Task Name
                TextFormField(
                  initialValue: _title,
                  style: const TextStyle(fontSize: 15),
                  decoration: _inputDecoration('Task Title', Icons.title),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  initialValue: _description,
                  style: const TextStyle(fontSize: 15),
                  maxLines: 3,
                  decoration: _inputDecoration('Description', Icons.notes),
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: 16),

                // Deadline
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _deadline = date);
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: _inputDecoration(
                        'Deadline',
                        Icons.calendar_month,
                      ).copyWith(
                        hintText: DateFormat('MMM dd, yyyy').format(_deadline),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status & Priority Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true, // Fixes overflow
                        value: _status,
                        decoration: _inputDecoration('Status', Icons.pending_actions),
                        items: ['ToDo', 'In Progress', 'In-Review', 'Review-completed', 'Done']
                            .map((s) => DropdownMenuItem(
                                  value: s, 
                                  child: Text(s, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true, // Fixes overflow
                        value: _priority,
                        decoration: _inputDecoration('Priority', Icons.flag),
                        items: ['Lowest', 'Low', 'Medium', 'High', 'Highest']
                            .map((p) => DropdownMenuItem(
                                  value: p, 
                                  child: Text(p, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
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
                              assignedBy: _assignedBy.isEmpty ? 'Me' : _assignedBy,
                              itemType: widget.task?.itemType ?? 'task',
                              subtaskCount: widget.task?.subtaskCount ?? 0,
                            );
                            widget.onSave(task);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save Task', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
