import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';

class LeaveRequestFormScreen extends StatefulWidget {
  final String name;
  final String employeeId;

  const LeaveRequestFormScreen({
    super.key,
    required this.name,
    required this.employeeId,
  });

  @override
  State<LeaveRequestFormScreen> createState() => _LeaveRequestFormScreenState();
}

class _LeaveRequestFormScreenState extends State<LeaveRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _leaveType;
  int _duration = 0;
  bool _isSubmitting = false;

  final List<String> _leaveTypes = [
    'casualOrSickLeave',
    'earnedLeave',
    'emergencyLeave',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initialDate = isStartDate
        ? _startDate ?? DateTime.now()
        : _endDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _duration = 0;
          }
        } else {
          _endDate = pickedDate;
        }
        _calculateDuration();
      });
    }
  }

  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      _duration = _endDate!.difference(_startDate!).inDays + 1;
    }
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }
    if (_leaveType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a leave type')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final (success, message) = await authProvider.addLeaveRequest(
      name: widget.name,
      employeeId: widget.employeeId,
      startDate: DateFormat('dd-MM-yyyy').format(_startDate!),
      endDate: DateFormat('dd-MM-yyyy').format(_endDate!),
      reason: _reasonController.text.trim(),
      duration: _duration,
      type: _leaveType!,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      _formKey.currentState!.reset();
      setState(() {
        _startDate = null;
        _endDate = null;
        _leaveType = null;
        _duration = 0;
      });
      Navigator.pop(context); // Close the screen after submission
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Employee Name
                    CustomTextField(
                      controller: TextEditingController(text: widget.name),
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    // Employee ID
                    CustomTextField(
                      controller: TextEditingController(
                        text: widget.employeeId,
                      ),
                      labelText: 'Employee ID',
                      prefixIcon: const Icon(Icons.badge),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    // Leave Type Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _leaveType,
                      items: _leaveTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => _leaveType = val),
                      validator: (val) =>
                          val == null ? 'Please select a leave type' : null,
                    ),
                    const SizedBox(height: 16),
                    // Start Date
                    GestureDetector(
                      onTap: () => _selectDate(isStartDate: true),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          labelText: 'Start Date',
                          prefixIcon: const Icon(Icons.date_range),
                          controller: TextEditingController(
                            text: _startDate != null
                                ? DateFormat('dd-MM-yyyy').format(_startDate!)
                                : '',
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Select start date'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // End Date
                    GestureDetector(
                      onTap: () => _selectDate(isStartDate: false),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          labelText: 'End Date',
                          prefixIcon: const Icon(Icons.event),
                          controller: TextEditingController(
                            text: _endDate != null
                                ? DateFormat('dd-MM-yyyy').format(_endDate!)
                                : '',
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Select end date'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Duration Display
                    if (_duration > 0)
                      Text(
                        'Duration: $_duration day${_duration > 1 ? 's' : ''}',
                        style: textStyle,
                      ),
                    if (_duration > 0) const SizedBox(height: 16),
                    // Reason Field
                    CustomTextField(
                      controller: _reasonController,
                      labelText: 'Reason',
                      prefixIcon: const Icon(Icons.edit_note),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a reason for leave';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submitLeave,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Request'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
