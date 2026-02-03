import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddSubtaskDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const AddSubtaskDialog({super.key, required this.onSave});

  @override
  State<AddSubtaskDialog> createState() => _AddSubtaskDialogState();
}

class _AddSubtaskDialogState extends State<AddSubtaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _pointsController = TextEditingController(text: "0");
  String _priority = 'Medium';
  DateTime? _deadline;
  String? _selectedAssigneeId;
  String? _selectedAssigneeName;

  final List<String> _priorities = ['Lowest', 'Low', 'Medium', 'High', 'Highest'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchAndCacheEmployeeList();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _showEmployeeSelectionDialog() {
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
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Assignee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search employees...',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
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
                          final isSelected = _selectedAssigneeId == emp.employeeID;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? const Color(0xFF26A69A) : Colors.grey[200],
                              child: Text(emp.name[0].toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                            ),
                            title: Text(emp.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            subtitle: Text('ID: ${emp.employeeID}'),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF26A69A)) : null,
                            onTap: () {
                              setState(() {
                                _selectedAssigneeId = emp.employeeID;
                                _selectedAssigneeName = emp.name;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("New Subtask", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(height: 32),
                
                _buildLabel("TITLE *"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration("e.g. Design Login Page UI"),
                  validator: (v) => v == null || v.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 20),

                _buildLabel("DESCRIPTION"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController, 
                  maxLines: 2, 
                  decoration: _buildInputDecoration("Provide more context..."),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("PRIORITY"),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _priority,
                            decoration: _buildInputDecoration(""),
                            items: _priorities.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _priority = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("STORY POINTS"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration("0"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("DUE DATE"),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) setState(() => _deadline = date);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 10),
                                  Text(
                                    _deadline == null ? "Select Date" : DateFormat('MMM dd, yyyy').format(_deadline!), 
                                    style: TextStyle(fontSize: 13, color: _deadline == null ? Colors.grey[500] : Colors.black87)
                                  ),
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
                          _buildLabel("ASSIGNEE *"),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _showEmployeeSelectionDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _selectedAssigneeName ?? "Select", 
                                      style: TextStyle(fontSize: 13, color: _selectedAssigneeName == null ? Colors.grey[500] : Colors.black87, overflow: TextOverflow.ellipsis)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: Text("Cancel", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold))
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _selectedAssigneeId != null) {
                            widget.onSave({
                              'title': _titleController.text,
                              'description': _descController.text,
                              'priority': _priority,
                              'storyPoints': int.tryParse(_pointsController.text) ?? 0,
                              'deadline': _deadline != null ? DateFormat('yyyy-MM-dd').format(_deadline!) : null,
                              'assignee': _selectedAssigneeId,
                            });
                            Navigator.pop(context);
                          } else if (_selectedAssigneeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an assignee")));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7), 
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                        ),
                        child: const Text("Create Subtask", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) => Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 0.5));

  InputDecoration _buildInputDecoration(String hint) => InputDecoration(
    hintText: hint, 
    filled: true, 
    fillColor: Colors.grey[50],
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF26A69A), width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
  );
}
