import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hrtz_hrms/features/leave/provider/leave_provider.dart';
import 'package:hrtz_hrms/features/holiday/provider/holiday_provider.dart';
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
  File? _medicalCertificateFile;
  bool _isUploadingFile = false;

  Set<DateTime> _holidayDates = {};

  final List<String> _leaveTypes = [
    'casualOrSickLeave',
    'earnedLeave',
    'emergencyLeave',
  ];
  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    final holidayProvider = Provider.of<HolidayProvider>(context, listen: false);
    await holidayProvider.fetchHolidays();
    setState(() {
      _holidayDates = holidayProvider.holidays
          .map((h) => DateTime.parse(h.date))
          .toSet();
    });
  }
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
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStartDate
          ? DateTime.now()
          : (_startDate ?? DateTime.now()),
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
    if (_startDate == null || _endDate == null) {
      setState(() => _duration = 0);
      return;
    }

    int count = 0;
    DateTime current = _startDate!;

    while (!current.isAfter(_endDate!)) {
      final isSunday = current.weekday == DateTime.sunday;
      final isHoliday = _holidayDates.any((h) =>
        h.year == current.year &&
        h.month == current.month &&
        h.day == current.day
      );

      if (!isSunday && !isHoliday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    setState(() {
      _duration = count;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _medicalCertificateFile = File(result.files.single.path!);
      });
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

    // ✅ Validation for duration and leave type
    if (_duration >= 3 && _leaveType != 'emergencyLeave') {
      AlertHelper.snackBarInfo(context, 'Leaves for 3 or more days must be applied as Emergency Leave');
      return;
    }

    if ((_leaveType == 'casualOrSickLeave' || _leaveType == 'earnedLeave') && _duration > 2) {
      AlertHelper.snackBarInfo(context, 'Casual/Sick and Earned leaves can only be for 1 or 2 days');
      return;
    }

    // ✅ Marriage leave restriction
    if (_reasonController.text.toLowerCase().contains('marriage') && _leaveType != 'emergencyLeave') {
      AlertHelper.snackBarInfo(context, 'Marriage leave must be applied as Emergency Leave');
      return;
    }

    // Check if medical certificate is required for emergency leave
    if (_leaveType == 'emergencyLeave' && _medicalCertificateFile == null) {
      AlertHelper.snackBarInfo(context, 'Medical certificate is required for emergency leave');
      return;
    }

    setState(() => _isSubmitting = true);
    
    String? medicalCertificateUrl;
    if (_medicalCertificateFile != null) {
      setState(() => _isUploadingFile = true);
      final uploadService = FileUploadService();
      medicalCertificateUrl = await uploadService.uploadFile(_medicalCertificateFile!);
      setState(() => _isUploadingFile = false);
      
      if (medicalCertificateUrl == null) {
        AlertHelper.snackBarError(context, 'Failed to upload medical certificate');
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
    
    final (success, message) = await leaveProvider.addLeaveRequest(
      name: widget.name,
      employeeId: widget.employeeId,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      reason: _reasonController.text.trim(),
      duration: _duration,
      type: _leaveType!,
      medicalCertificate: medicalCertificateUrl,
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (_isUploadingFile) ...[
                    const SizedBox(height: 16),
                    const Text('Uploading medical certificate...'),
                  ],
                ],
              ),
            )
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
                      value: _leaveType,
                      items: _leaveTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() {
                        _leaveType = val;
                        // Clear certificate if type changes away from emergency
                        if (val != 'emergencyLeave') {
                          _medicalCertificateFile = null;
                        }
                      }),
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
                    if (_leaveType == 'emergencyLeave') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Medical Certificate (Required)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _medicalCertificateFile == null
                                      ? 'Select medical certificate (PDF, JPG, PNG)'
                                      : _medicalCertificateFile!.path.split('/').last,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_medicalCertificateFile != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => setState(() => _medicalCertificateFile = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
