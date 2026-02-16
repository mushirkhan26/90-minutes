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

 final TextEditingController _requestTypeCtrl = TextEditingController();
  String? _selectedDepartment;
  bool _submitting = false;

  File? _selectedFile;
  String? _uploadedFileUrl;

  final FileUploadService _uploadService = FileUploadService();

  @override
  void initState() {
    super.initState();
    _requestTypeCtrl.text = widget.requestType;
  

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<ServiceRequestProvider>();

      // Autofill
    
      _empIdCtrl.text = auth.userData?['employeeId'] ?? '';
  
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
    _requestTypeCtrl.dispose();
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
      // Upload file to S3 
      if (_selectedFile != null) {
        _uploadedFileUrl =
            await _uploadService.uploadFile(_selectedFile!);
            if(!mounted) return;
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
  backgroundColor: AppColors.primary,
  iconTheme: const IconThemeData(color: Colors.white),
  title: Text(
    'Request For ${widget.requestType} Service',
    style: const TextStyle(
      color: Colors.white,        
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
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

            TextFormField(
  controller: _empIdCtrl,
  readOnly: true,
  decoration: InputDecoration(
    label: RichText(
      text: const TextSpan(
        text: "Employee ID",
        style: TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(
            text: " *",
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    ),
    filled: true,
    fillColor: const Color(0xFFF1F1F1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
  ),
  validator: (v) =>
      v == null || v.isEmpty ? "Employee ID is required" : null,
),
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
  initialValue: _selectedDepartment,
  decoration: InputDecoration(
    label: RichText(
      text: const TextSpan(
        text: "Department",
        style: TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(
            text: " *",
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
  ),
  validator: (v) =>
      v == null ? "Department is required" : null,
  items: provider.departments
      .map((d) => DropdownMenuItem(
            value: d,
            child: Text(d),
          ))
      .toList(),
  onChanged: (v) => setState(() => _selectedDepartment = v),
);
  },
),
              const SizedBox(height: 12),

              TextFormField(
  controller: _requestTypeCtrl,
  readOnly: true,
  decoration: InputDecoration(
    label: RichText(
      text: const TextSpan(
        text: "Request Type",
        style: TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(
            text: " *",
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    ),
    filled: true,
    fillColor: const Color(0xFFF1F1F1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
  ),
  validator: (v) =>
      v == null || v.isEmpty ? "Request Type is required" : null,
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
              _addImageBox(),
              const SizedBox(height: 24),
              

              // ================= SUBMIT =================
              Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    //  CANCEL BUTTON
    TextButton(
      onPressed: _submitting
          ? null
          : () {
              Navigator.pop(context);
            },
      style: TextButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    const SizedBox(width: 12),

    // SUBMIT BUTTON
    ElevatedButton(
      onPressed: _submitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _submitting
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Submit',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  ],
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
  bool required = true,
}) {
  return TextFormField(
    controller: ctrl,
    decoration: InputDecoration(
      label: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          children: required
              ? const [
                  TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  )
                ]
              : [],
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),
    validator: required
        ? (v) => v == null || v.isEmpty ? "$label is required" : null
        : null,
  );
}
  Widget _addImageBox() {
  return GestureDetector(
    onTap: _pickFile,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 34,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add Image',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Click to browse image',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          // 🔹 show selected file name
          if (_selectedFile != null) ...[
            const SizedBox(height: 10),
            Text(
              _selectedFile!.path.split('/').last,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}