import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import '../providers/compliance_provider.dart';
import 'package:hrtz_hrms/core/models/compliance_model.dart';

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
    final c = widget.existingCompliance!;

    _employeeIdController.text = c.employeeId ?? "";
    _taskTitleController.text = c.title;
    _descriptionController.text = c.description;
    _notesController.text = c.note ?? "";
    _selectedTaskType = c.complianceType;
    _selectedDate = c.dueDate;

    // Required Documents
    for (var doc in c.requiredDocuments) {
      _documentControllers
          .add(TextEditingController(text: doc.name));
    }

    // Action Links
    for (var link in c.actionLinks) {
      _actionLinks.add({
        "label": TextEditingController(text: link.title),
        "url": TextEditingController(text: link.url),
      });
    }
  }
}
bool _employeeInitialized = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (!_employeeInitialized &&
      widget.isEdit &&
      widget.existingCompliance != null) {

    final employees =
        context.read<AuthProvider>().employeeList ?? [];

    try {
      _selectedEmployee = employees.firstWhere(
        (emp) =>
            emp.employeeID ==
            widget.existingCompliance!.employeeId,
      );

      _employeeNameController.text =
          _selectedEmployee!.name;

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

  void _addDocument() {
    setState(() {
      _documentControllers.add(TextEditingController());
    });
  }

  void _addActionLink() {
    setState(() {
      _actionLinks.add({
        "label": TextEditingController(),
        "url": TextEditingController(),
      });
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!value.startsWith("http://") &&
        !value.startsWith("https://")) {
      return "Only http/https allowed";
    }
    return null;
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select due date")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<ComplianceProvider>();

    final requiredDocs = _documentControllers
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final actionLinks = _actionLinks.map((link) {
      return {
        "label": link["label"]!.text.trim(),
        "url": link["url"]!.text.trim(),
      };
    }).toList();

    final dueDate =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    bool success;

if (widget.isEdit &&
    widget.existingCompliance != null) {

  success = await provider.updateCompliance(
    complianceId:
        widget.existingCompliance!.id,
    employeeId:
        _employeeIdController.text.trim(),
    complianceType: _selectedTaskType!,
    title:
        _taskTitleController.text.trim(),
    description:
        _descriptionController.text.trim(),
    note: _notesController.text.trim(),
    dueDate: dueDate,
    requiredDocuments: requiredDocs,
    actionLinks: actionLinks,
  );

} else {

  success = await provider.createCompliance(
    employeeId:
        _employeeIdController.text.trim(),
    complianceType: _selectedTaskType!,
    title:
        _taskTitleController.text.trim(),
    description:
        _descriptionController.text.trim(),
    note: _notesController.text.trim(),
    dueDate: dueDate,
    requiredDocuments: requiredDocs,
    actionLinks: actionLinks,
  );
}

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task created successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? "Failed to create task")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees =
        context.watch<AuthProvider>().employeeList ?? [];

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                color: const Color(0xFF26A69A),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      widget.isEdit
                      ? "+ Edit Task"
                      : "+ Create New Task",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          color: Colors.white),
                    )
                  ],
                ),
              ),

              // BODY
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        // EMPLOYEE ID DROPDOWN
                        const Text("Employee ID *"),
                        const SizedBox(height: 6),

                       DropdownButtonFormField2<EmployeeModel>(
  isExpanded: true,
  value: _selectedEmployee,
  hint: const Text("Select Employee ID"),

  items: employees.map((emp) {
    return DropdownMenuItem<EmployeeModel>(
      value: emp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emp.employeeID,
            style: const TextStyle(
                fontWeight: FontWeight.w500),
          ),
          Text(
            emp.name,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }).toList(),

  // 👇 What shows after selection
  selectedItemBuilder: (context) {
    return employees.map((emp) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          emp.employeeID, // Only ID visible
          style: const TextStyle(fontSize: 14),
        ),
      );
    }).toList();
  },

  onChanged: (emp) {
    setState(() {
      _selectedEmployee = emp;
      _employeeIdController.text = emp!.employeeID;
      _employeeNameController.text = emp.name;
    });
  },

  decoration: const InputDecoration(
    border: OutlineInputBorder(),
  ),

  dropdownStyleData: DropdownStyleData(
    maxHeight: 260,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  validator: (value) =>
      value == null ? "Required" : null,
),
                        const SizedBox(height: 16),

                        // EMPLOYEE NAME (AUTO)
                        TextFormField(
                          controller: _employeeNameController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Employee Name",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // TASK TYPE
                        const Text("Task Type *"),
                        const SizedBox(height: 6),

                        DropdownButtonFormField<String>(
                          initialValue: _selectedTaskType,
                          items: _taskTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedTaskType = v),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null ? "Required" : null,
                        ),

                        const SizedBox(height: 16),

                        // TITLE
                        TextFormField(
                          controller: _taskTitleController,
                          decoration: const InputDecoration(
                            labelText: "Task Title *",
                            hintText: "Brief task title",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Required"
                                  : null,
                        ),

                        const SizedBox(height: 16),

                        // DESCRIPTION
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            hintText:
                                "Detailed task description",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // NOTES
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: "Notes",
                            hintText:
                                "Additional notes (optional)",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // REQUIRED DOCUMENTS
                        const Text("Required Documents",
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),

                        ..._documentControllers
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                                    bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        entry.value,
                                    decoration:
                                        const InputDecoration(
                                      hintText:
                                          "e.g PAN Card",
                                      border:
                                          OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _documentControllers[index]
                                          .dispose();
                                      _documentControllers
                                          .removeAt(index);
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        }),

                        TextButton(
                          onPressed: _addDocument,
                          child:
                              const Text("+ Add Document"),
                        ),

                        const SizedBox(height: 20),

                        // ACTION LINKS
                        const Text("Action Links",
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),

                        ..._actionLinks
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          final label =
                              entry.value["label"]!;
                          final url =
                              entry.value["url"]!;

                          return Column(
                            children: [
                              TextFormField(
                                controller: label,
                                decoration:
                                    const InputDecoration(
                                  hintText:
                                      "Label (e.g NDA Form)",
                                  border:
                                      OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: url,
                                validator:
                                    _validateUrl,
                                decoration:
                                    const InputDecoration(
                                  hintText:
                                      "https://example.com",
                                  border:
                                      OutlineInputBorder(),
                                ),
                              ),
                              Align(
                                alignment:
                                    Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      label.dispose();
                                      url.dispose();
                                      _actionLinks
                                          .removeAt(
                                              index);
                                    });
                                  },
                                  child: const Text(
                                    "Remove Link",
                                    style: TextStyle(
                                        color:
                                            Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }),

                        TextButton(
                          onPressed: _addActionLink,
                          child: const Text(
                              "+ Add Action Link"),
                        ),

                        const SizedBox(height: 20),

                        // DUE DATE
const Text("Due Date *"),
const SizedBox(height: 6),

InkWell(
  onTap: _selectDate,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 16,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedDate == null
              ? "Select Due Date"
              : "${_selectedDate!.day.toString().padLeft(2, '0')}-"
                "${_selectedDate!.month.toString().padLeft(2, '0')}-"
                "${_selectedDate!.year}",
          style: TextStyle(
            color: _selectedDate == null
                ? Colors.grey
                : Colors.black,
          ),
        ),
        const Icon(
          Icons.calendar_today,
          size: 20,
          color: Colors.grey,
        ),
      ],
    ),
  ),
),

                        const SizedBox(height: 24),

                        // BUTTONS
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: ElevatedButton(
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                      const Color(
                                          0xFF26A69A),
                                ),
                                onPressed:
                                    _isLoading
                                        ? null
                                        : _createTask,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors
                                            .white,
                                      )
                                    : Text(
                                      widget.isEdit
                                      ? "Update Task"
                                       : "Create Task",
                                        style: TextStyle(
                                            color: Colors
                                                .white),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                      Colors.grey[300],
                                ),
                                onPressed: () =>
                                    Navigator.pop(
                                        context),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors
                                          .black),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              )
            ]
          )
        )
      )
    );
  }
}