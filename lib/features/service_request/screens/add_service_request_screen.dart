import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/service_request/providers/service_request_provider.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:file_picker/file_picker.dart';

class AddServiceRequestScreen extends StatefulWidget {
  final String requestType; // Hardware | Software | Backup | Document etc

  const AddServiceRequestScreen({
    super.key,
    required this.requestType,
  });

  @override
  State<AddServiceRequestScreen> createState() =>
      _AddServiceRequestScreenState();
}

class _AddServiceRequestScreenState extends State<AddServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _empIdCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  String? _selectedDepartment;
  bool _submitting = false;

  File? _selectedFile;
  String? _uploadedFileUrl;

  final FileUploadService _uploadService = FileUploadService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<ServiceRequestProvider>();

      // 🔹 Autofill
      _nameCtrl.text = auth.userData?['username'] ?? '';
      _empIdCtrl.text = auth.userData?['employeeId'] ?? '';
      _emailCtrl.text = auth.userData?['email'] ?? '';
      _mobileCtrl.text = auth.userData?['mobile'] ?? '';

      // 🔹 Fetch departments for dropdown
      provider.fetchDepartments();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _empIdCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ================= FILE PICK =================
  Future<void> _pickFile() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
  );

  if (result != null && result.files.single.path != null) {
    setState(() {
      _selectedFile = File(result.files.single.path!);
    });
  }
}

  // ================= SUBMIT =================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // 🔹 Upload file to S3 (if exists)
      if (_selectedFile != null) {
        _uploadedFileUrl =
            await _uploadService.uploadFile(_selectedFile!);
      }

      final provider = context.read<ServiceRequestProvider>();

      final success = await provider.addServiceRequest(
        name: _nameCtrl.text.trim(),
        employeeId: _empIdCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        type: widget.requestType,
        department: _selectedDepartment!,
        description: _descCtrl.text.trim(),
        attachmentUrl:
            _uploadedFileUrl != null ? [_uploadedFileUrl!] : [],
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request For ${widget.requestType} Service',
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Requester Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _input(_nameCtrl, 'Name'),
              const SizedBox(height: 12),

              _input(_empIdCtrl, 'Employee ID', enabled: false),
              const SizedBox(height: 12),

              _input(_emailCtrl, 'Email'),
              const SizedBox(height: 12),

              _input(_mobileCtrl, 'Mobile'),
              const SizedBox(height: 12),

              // ================= DEPARTMENT DROPDOWN =================
              Consumer<ServiceRequestProvider>(
  builder: (_, provider, __) {
    if (provider.isDepartmentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      hint: const Text('Select Department'),
      items: provider.departments
          .map(
            (d) => DropdownMenuItem(
              value: d,
              child: Text(d),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedDepartment = v),
      validator: (v) => v == null ? 'Department required' : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  },
),
              const SizedBox(height: 12),

              _input(
                TextEditingController(text: widget.requestType),
                'Request Type',
                enabled: false,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              // ================= FILE =================
              OutlinedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('Upload Attachment'),
                onPressed: _pickFile,
              ),

              const SizedBox(height: 24),

              // ================= SUBMIT =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INPUT =================
  Widget _input(
    TextEditingController ctrl,
    String label, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? '$label required' : null,
    );
  }
}