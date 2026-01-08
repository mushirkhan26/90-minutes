import 'package:flutter/material.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hrtz_hrms/features/leave/provider/leave_provider.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import '../../../../core/utils/alert_utils.dart';

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
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now()), // ✅ end date initial logic fix

    firstDate: isStartDate
        ? DateTime.now()
        : (_startDate ?? DateTime.now()), // ✅ END DATE cannot be before START DATE

    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    setState(() {
      if (isStartDate) {
        _startDate = pickedDate;

        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;      // ✅ invalid end date reset
          _duration = 0;        // ✅ duration reset
        }
      } else {
        _endDate = pickedDate;  // ✅ now safe (cannot pick before start)
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
      AlertHelper.snackBarInfo(context, 'Please select both start and end dates');
      return;
    }
    if (_leaveType == null) {
      AlertHelper.snackBarInfo(context, 'Please select a leave type');
      return;
    }
    setState(() => _isSubmitting = true);
    
    final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
    
    // Changing date format to yyyy-MM-dd as it's standard for most APIs
    final (success, message) = await leaveProvider.addLeaveRequest(
      name: widget.name,
      employeeId: widget.employeeId,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      reason: _reasonController.text.trim(),
      duration: _duration,
      type: _leaveType!,
    );
    
    if (!mounted) return;
    if (success) {
      AlertHelper.snackBarSuccess(context, message);
      Navigator.pop(context);
    } else {
      AlertHelper.snackBarError(context, message);
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
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
                    CustomTextField(
                      controller: TextEditingController(text: widget.name),
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: TextEditingController(text: widget.employeeId),
                      labelText: 'Employee ID',
                      prefixIcon: const Icon(Icons.badge),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _leaveType,
                      items: _leaveTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => _leaveType = val),
                      validator: (val) => val == null ? 'Please select a leave type' : null,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(isStartDate: true),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          labelText: 'Start Date',
                          prefixIcon: const Icon(Icons.date_range),
                          controller: TextEditingController(
                            text: _startDate != null ? DateFormat('dd-MM-yyyy').format(_startDate!) : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(isStartDate: false),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          labelText: 'End Date',
                          prefixIcon: const Icon(Icons.event),
                          controller: TextEditingController(
                            text: _endDate != null ? DateFormat('dd-MM-yyyy').format(_endDate!) : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_duration > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Duration: $_duration day${_duration > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    CustomTextField(
                      controller: _reasonController,
                      labelText: 'Reason',
                      prefixIcon: const Icon(Icons.edit_note),
                      maxLines: 4,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please provide a reason' : null,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Request',
                      onPressed: _submitLeave,
                      icon: (Icons.send),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
