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
import 'package:hrtz_hrms/core/models/holiday_model.dart';

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

  // New Summary Variables
  int _totalDays = 0;
  int _weekendsCount = 0;
  int _holidaysCount = 0;
  List<HolidayModel> _foundHolidays = [];

  List<HolidayModel> _allHolidays = [];

  final List<String> _leaveTypes = [
    'casualOrSickLeave',
    'earnedLeave',
    'emergencyLeave',
  ];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Fetch holidays safely
      final holidayProvider = context.read<HolidayProvider>();

      await holidayProvider.fetchHolidays();

      if (!mounted) return;

      setState(() {
        _allHolidays = holidayProvider.holidays;
      });

      // Fetch leave balance safely
      await context.read<LeaveProvider>().fetchLeaveInfo(
        employeeId: widget.employeeId,
      );
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
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
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
      setState(() {
        _duration = 0;
        _totalDays = 0;
        _weekendsCount = 0;
        _holidaysCount = 0;
        _foundHolidays = [];
      });
      return;
    }

    int workingDays = 0;
    int total = 0;
    int weekends = 0;
    int holidays = 0;
    List<HolidayModel> holidaysInRange = [];

    DateTime current = _startDate!;

    while (!current.isAfter(_endDate!)) {
      total++;
      final isSunday = current.weekday == DateTime.sunday;

      final holiday = _allHolidays.firstWhere((h) {
        try {
          final hDate = DateTime.parse(h.date);
          return hDate.year == current.year &&
              hDate.month == current.month &&
              hDate.day == current.day;
        } catch (_) {
          return false;
        }
      }, orElse: () => HolidayModel(date: '', day: '', holiday: ''));

      bool isHoliday = holiday.date.isNotEmpty;

      if (isSunday) {
        weekends++;
      } else if (isHoliday) {
        holidays++;
        holidaysInRange.add(holiday);
      } else {
        workingDays++;
      }

      current = current.add(const Duration(days: 1));
    }

    setState(() {
      _duration = workingDays;
      _totalDays = total;
      _weekendsCount = weekends;
      _holidaysCount = holidays;
      _foundHolidays = holidaysInRange;
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
      AlertHelper.snackBarInfo(
        context,
        'Please select both start and end dates',
      );
      return;
    }
    if (_leaveType == null) {
      AlertHelper.snackBarInfo(context, 'Please select a leave type');
      return;
    }

    setState(() => _isSubmitting = true);

    String? medicalCertificateUrl;
    if (_medicalCertificateFile != null) {
      setState(() => _isUploadingFile = true);
      final uploadService = FileUploadService();
      medicalCertificateUrl = await uploadService.uploadFile(
        _medicalCertificateFile!,
      );
      if (!mounted) return;
      setState(() => _isUploadingFile = false);

      if (medicalCertificateUrl == null) {
        AlertHelper.snackBarError(
          context,
          'Failed to upload medical certificate',
        );
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
    final leaveProvider = context.watch<LeaveProvider>();
    final available = leaveProvider.availableLeave?['available'] ?? {};

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
                      controller: TextEditingController(
                        text: widget.employeeId,
                      ),
                      labelText: 'Employee ID',
                      prefixIcon: const Icon(Icons.badge),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _leaveType,
                      items: _leaveTypes.map((type) {
                        final left = available[type] ?? 0;
                        return DropdownMenuItem(
                          value: type,
                          child: Text('$type ($left left)'),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() {
                        _leaveType = val;
                        if (val != 'emergencyLeave') {
                          _medicalCertificateFile = null;
                        }
                      }),
                      validator: (val) =>
                          val == null ? 'Please select a leave type' : null,
                    ),
                    const SizedBox(height: 16),
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
                            text: _endDate != null
                                ? DateFormat('dd-MM-yyyy').format(_endDate!)
                                : '',
                          ),
                        ),
                      ),
                    ),

                    // ✅ Leave Summary Box
                    if (_startDate != null && _endDate != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Leave Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryItem('Total days', '$_totalDays'),
                            _buildSummaryItem('Working days', '$_duration'),
                            _buildSummaryItem('Weekends', '$_weekendsCount'),
                            _buildSummaryItem('Holidays', '$_holidaysCount'),
                            if (_foundHolidays.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              const Text(
                                'Holidays in range:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              ..._foundHolidays.map(
                                (h) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 2,
                                  ),
                                  child: Text(
                                    '• ${h.holiday} (${DateFormat('MMM d, yyyy').format(DateTime.parse(h.date))})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _reasonController,
                      labelText: 'Reason',
                      prefixIcon: const Icon(Icons.edit_note),
                      maxLines: 4,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please provide a reason'
                          : null,
                    ),
                    if (_leaveType == 'emergencyLeave') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Medical Certificate (Optional)',
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
                                      : _medicalCertificateFile!.path
                                            .split('/')
                                            .last,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_medicalCertificateFile != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => setState(
                                    () => _medicalCertificateFile = null,
                                  ),
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

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('• $label: ', style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
