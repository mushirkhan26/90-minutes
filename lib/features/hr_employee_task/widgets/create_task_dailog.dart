import 'package:flutter/material.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import '../providers/compliance_provider.dart';
import 'package:hrtz_hrms/core/models/compliance_model.dart';
import 'task_form_widgets.dart';

class CreateTaskDialog extends StatefulWidget {
  final bool isEdit;
  final Compliance? existingCompliance;

  const CreateTaskDialog({
    super.key,
    this.isEdit = false,
    this.existingCompliance,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();

  final _employeeIdController = TextEditingController();
  final _employeeNameController = TextEditingController();
  final _taskTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  EmployeeModel? _selectedEmployee;

  String? _selectedTaskType;
  DateTime? _selectedDate;

  final List<TextEditingController> _documentControllers = [];
  final List<Map<String, TextEditingController>> _actionLinks = [];

  bool _isLoading = false;

  final List<String> _taskTypes = [
    "Add Documents",
    "Complete NDA",
    "Complete Onboarding",
    "HR Verification",
    "System Access Setup",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingCompliance != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final c = widget.existingCompliance!;
    _employeeIdController.text = c.employeeId ?? "";
    _taskTitleController.text = c.title;
    _descriptionController.text = c.description;
    _notesController.text = c.note ?? "";
    _selectedTaskType = c.complianceType;
    _selectedDate = c.dueDate;

    for (var doc in c.requiredDocuments) {
      _documentControllers.add(TextEditingController(text: doc.name));
    }
    for (var link in c.actionLinks) {
      _actionLinks.add({
        "label": TextEditingController(text: link.title),
        "url": TextEditingController(text: link.url),
      });
    }
  }

  bool _employeeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_employeeInitialized && widget.isEdit && widget.existingCompliance != null) {
      final employees = context.read<AuthProvider>().employeeList ?? [];
      try {
        _selectedEmployee = employees.firstWhere(
          (emp) => emp.employeeID == widget.existingCompliance!.employeeId,
        );
        _employeeNameController.text = _selectedEmployee!.name;
      } catch (_) {}
      _employeeInitialized = true;
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    _taskTitleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    for (var c in _documentControllers) {
      c.dispose();
    }
    for (var link in _actionLinks) {
      link["label"]?.dispose();
      link["url"]?.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select due date")));
      }
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<ComplianceProvider>();
    final requiredDocs = _documentControllers.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
    final actionLinks = _actionLinks.map((link) => {
      "label": link["label"]!.text.trim(),
      "url": link["url"]!.text.trim(),
    }).toList();

    final dueDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    bool success;
    if (widget.isEdit && widget.existingCompliance != null) {
      success = await provider.updateCompliance(
        complianceId: widget.existingCompliance!.id,
        employeeId: _employeeIdController.text.trim(),
        complianceType: _selectedTaskType!,
        title: _taskTitleController.text.trim(),
        description: _descriptionController.text.trim(),
        note: _notesController.text.trim(),
        dueDate: dueDateStr,
        requiredDocuments: requiredDocs,
        actionLinks: actionLinks,
      );
    } else {
      success = await provider.createCompliance(
        employeeId: _employeeIdController.text.trim(),
        complianceType: _selectedTaskType!,
        title: _taskTitleController.text.trim(),
        description: _descriptionController.text.trim(),
        note: _notesController.text.trim(),
        dueDate: dueDateStr,
        requiredDocuments: requiredDocs,
        actionLinks: actionLinks,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task ${widget.isEdit ? 'updated' : 'created'} successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<AuthProvider>().employeeList ?? [];

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              TaskDialogHeader(
                isEdit: widget.isEdit,
                onClose: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EmployeeSelectionField(
                          employees: employees,
                          selectedEmployee: _selectedEmployee,
                          onChanged: (emp) {
                            setState(() {
                              _selectedEmployee = emp;
                              _employeeIdController.text = emp!.employeeID;
                              _employeeNameController.text = emp.name;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTaskTextField(
                          controller: _employeeNameController,
                          label: "Employee Name",
                          hint: "",
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        TaskTypeSelector(
                          selectedType: _selectedTaskType,
                          types: _taskTypes,
                          onChanged: (v) => setState(() => _selectedTaskType = v),
                        ),
                        const SizedBox(height: 16),
                        CustomTaskTextField(
                          controller: _taskTitleController,
                          label: "Task Title *",
                          hint: "Brief task title",
                        ),
                        const SizedBox(height: 16),
                        CustomTaskTextField(
                          controller: _descriptionController,
                          label: "Description",
                          hint: "Detailed task description",
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        CustomTaskTextField(
                          controller: _notesController,
                          label: "Notes",
                          hint: "Additional notes (optional)",
                        ),
                        const SizedBox(height: 16),
                        DatePickerField(
                          selectedDate: _selectedDate,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                        ),
                        const SizedBox(height: 20),
                        DocumentListSection(
                          controllers: _documentControllers,
                          onAdd: () => setState(() => _documentControllers.add(TextEditingController())),
                          onRemove: (index) => setState(() => _documentControllers.removeAt(index)),
                        ),
                        const SizedBox(height: 20),
                        ActionLinkListSection(
                          links: _actionLinks,
                          onAdd: () => setState(() => _actionLinks.add({"label": TextEditingController(), "url": TextEditingController()})),
                          onRemove: (index) => setState(() => _actionLinks.removeAt(index)),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: _isLoading ? "Processing..." : (widget.isEdit ? "Update Task" : "Create Task"),
                          onPressed: _isLoading ? null : _handleSubmit,
                          backgroundColor: const Color(0xFF26A69A),
                          borderColor: const Color(0xFF26A69A),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
