import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';

class TaskDialogHeader extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onClose;

  const TaskDialogHeader({
    super.key,
    required this.isEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      color: const Color(0xFF26A69A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEdit ? "Edit Task" : "Create New Task",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        ],
      ),
    );
  }
}

class EmployeeSelectionField extends StatelessWidget {
  final List<EmployeeModel> employees;
  final EmployeeModel? selectedEmployee;
  final Function(EmployeeModel?) onChanged;

  const EmployeeSelectionField({
    super.key,
    required this.employees,
    required this.selectedEmployee,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Employee ID *", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField2<EmployeeModel>(
          isExpanded: true,
          value: selectedEmployee,
          hint: const Text("Select Employee ID"),
          items: employees.map((emp) => DropdownMenuItem(
            value: emp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emp.employeeID, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(emp.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.zero,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 260,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null ? "Required" : null,
        ),
      ],
    );
  }
}

class TaskTypeSelector extends StatelessWidget {
  final String? selectedType;
  final List<String> types;
  final Function(String?) onChanged;

  const TaskTypeSelector({
    super.key,
    required this.selectedType,
    required this.types,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Task Type *", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: selectedType,
          items: types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator: (value) => value == null ? "Required" : null,
        ),
      ],
    );
  }
}

class CustomTaskTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final bool readOnly;

  const CustomTaskTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            fillColor: readOnly ? Colors.grey[100] : null,
            filled: readOnly,
          ),
          validator: (value) => (label.contains('*') && (value == null || value.isEmpty)) ? "Required" : null,
        ),
      ],
    );
  }
}

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Due Date *", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? "Select Date"
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                ),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DocumentListSection extends StatelessWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const DocumentListSection({
    super.key,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Required Documents", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: const InputDecoration(
                      hintText: "e.g PAN Card",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => onRemove(index),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        CustomButton(
          text: \"Add Document\",
          icon: Icons.add,
          width: 160, // Fixed width to avoid overflow
          height: 35,
          fontSize: 12,
          backgroundColor: Colors.transparent,
          borderColor: const Color(0xFF26A69A),
          textColor: const Color(0xFF26A69A),
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class ActionLinkListSection extends StatelessWidget {
  final List<Map<String, TextEditingController>> links;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const ActionLinkListSection({
    super.key,
    required this.links,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Action Links", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...links.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.value[\"label\"],
                        decoration: const InputDecoration(
                          hintText: \"Label (e.g NDA Form)\",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => onRemove(index),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: entry.value[\"url\"],
                  decoration: const InputDecoration(
                    hintText: \"URL (https://...)\",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        CustomButton(
          text: \"Add Link\",
          icon: Icons.link,
          width: 140, // Fixed width to avoid overflow
          height: 35,
          fontSize: 12,
          backgroundColor: Colors.transparent,
          borderColor: const Color(0xFF26A69A),
          textColor: const Color(0xFF26A69A),
          onPressed: onAdd,
        ),
      ],
    );
  }
}
