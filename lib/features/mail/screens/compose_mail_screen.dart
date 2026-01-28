import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/mail/provider/mail_provider.dart';
import 'package:hrtz_hrms/features/mail/widgets/attachments_chips.dart';
import 'package:hrtz_hrms/features/mail/widgets/cc_bcc_filds.dart';
import 'package:hrtz_hrms/features/mail/widgets/reciepient_selector.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ComposeMailScreen extends StatefulWidget {
  const ComposeMailScreen({super.key});

  @override
  State<ComposeMailScreen> createState() => _ComposeMailScreenState();
}

class _ComposeMailScreenState extends State<ComposeMailScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();

  final FileUploadService _fileUploadService = FileUploadService();
  final SecureStorageService _secureStorage = SecureStorageService();

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  final List<EmployeeModel> _selectedReceivers = [];

  List<String> _ccList = [];
  List<String> _bccList = [];
  final List<String> _attachmentUrls = [];

  bool _showDropdown = false;
  bool _showCcBcc = false;
  bool _isSending = false;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final employees = await LocalStorageService().getEmployeeList();
    if (employees != null) {
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
      });
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees
          .where(
            (e) =>
                e.name.toLowerCase().contains(query.toLowerCase()) ||
                e.employeeID.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0;
      });

      int totalFiles = result.files.length;
      int completed = 0;

      for (var file in result.files) {
        if (file.path != null) {
          final uploadedUrl = await _fileUploadService.uploadFile(File(file.path!));
          if (uploadedUrl != null) {
            _attachmentUrls.add(uploadedUrl);
          }

          completed++;
          setState(() {
            _uploadProgress = completed / totalFiles;
          });
        }
      }

      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendMail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReceivers.isEmpty) {
      AlertHelper.snackBarError(context, 'Please select at least one recipient.');
      return;
    }

    setState(() => _isSending = true);

    try {
      final senderId = await _secureStorage.getEmployeeId() ?? '';
      final senderName = await _secureStorage.getUserName() ?? '';
      
      final mailProvider = context.read<MailProvider>();

      final success = await mailProvider.sendMail(
        sender: senderId,
        senderName: senderName,
        receiver: _selectedReceivers.map((e) => e.employeeID).toList(),
        receiverName: _selectedReceivers.map((e) => e.name).toList(),
        cc: _ccList,
        bcc: _bccList,
        subject: _subjectController.text.trim(),
        body: _bodyController.text.trim(),
        attachmentUrls: _attachmentUrls,
      );

      if (success) {
        if (mounted) {
          AlertHelper.snackBarSuccess(context, 'Mail sent successfully!');
          // Refresh Sent Mails
          mailProvider.fetchSent(forceRefresh: true);
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          AlertHelper.snackBarError(context, 'Failed to send mail.');
        }
      }
    } catch (e) {
      if (mounted) {
        AlertHelper.snackBarError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Mail'),
        actions: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFiles),
          IconButton(
            icon: _isSending
                ? LoadingAnimationWidget.staggeredDotsWave(color: AppColors.primary, size: 22)
                : const Icon(Icons.send),
            onPressed: _isSending ? null : _sendMail,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecipientSelector(
                showDropdown: _showDropdown,
                employees: _filteredEmployees,
                selectedReceivers: _selectedReceivers,
                onToggleDropdown: () => setState(() => _showDropdown = !_showDropdown),
                onFilter: _filterEmployees,
                onAdd: (emp){
                  setState(() {
                    if(!_selectedReceivers.contains(emp)){
                      _selectedReceivers.add(emp);
                    }
                  });
                },
                onRemove: (emp){
                  setState(() {
                    _selectedReceivers.remove(emp);
                  });
                }
              ),

              const SizedBox(height: 10),

              CcBccFields(
                showCcBcc: _showCcBcc,
                ccController: _ccController,
                bccController: _bccController,
                onToggle: () => setState(() => _showCcBcc = !_showCcBcc),
                onCcChanged: (v) => _ccList = v.split(',').map((e) => e.trim()).toList(),
                onBccChanged: (v) => _bccList = v.split(',').map((e) => e.trim()).toList(),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _subjectController,
                hintText: 'Subject',
                validator: (v) => v == null || v.trim().isEmpty ? 'Subject cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _bodyController,
                hintText: 'Compose your mail...',
                minLines: 10,
                maxLines: 20,
                validator: (v) => v == null || v.trim().isEmpty ? 'Body cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              if (_isUploading) ...[
                const Text('Uploading attachments...'),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 12),
              ],

              AttachmentChips(
                attachments: _attachmentUrls,
                onRemove: (url) => setState(() => _attachmentUrls.remove(url)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
