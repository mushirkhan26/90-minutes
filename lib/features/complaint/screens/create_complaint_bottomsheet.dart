import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hrtz_hrms/features/complaint/provider/complaint_provider.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'dart:io';

class CreateComplaintBottomSheet extends StatefulWidget {
  const CreateComplaintBottomSheet({super.key});

  @override
  State<CreateComplaintBottomSheet> createState() =>
      _CreateComplaintBottomSheetState();
}

class _CreateComplaintBottomSheetState
    extends State<CreateComplaintBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final FileUploadService _uploader = FileUploadService();

  Future<void> _pickFile(ComplaintProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result == null) return;

    for (final file in result.files) {
      if (file.path == null) continue;

      final s3Url = await _uploader.uploadFile(File(file.path!));
      if (s3Url != null) {
        provider.addAttachment(s3Url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New Complaint',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 NAME
                  _readOnlyField('Your Name *', provider.nameController),
                  const SizedBox(height: 12),

                  /// 🔹 EMPLOYEE ID
                  _readOnlyField('Employee ID *', provider.employeeIdController),
                  const SizedBox(height: 12),

                  /// 🔹 CATEGORY + PERSON
                  Row(
                    children: [
                      Expanded(
                        child: _dropdown(
                          label: 'Category *',
                          hintText: 'Select Category',
                          initialValue: provider.selectedCategory,
                          items: provider.categories,
                          onChanged: (v) => provider.setCategory(v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dropdown(
                          label: 'Mention Complaining People',
                          hintText: 'Select Person',
                          initialValue: provider.selectedPerson,
                          items: provider.mentionPeople,
                          onChanged: (v) => provider.setPerson(v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 ADDITIONAL INFO
                  _textField('Additional Info', provider.additionalInfoController, maxLines: 4, onChanged: (_) => provider.onFieldChanged()),

                  const SizedBox(height: 12),

                  /// 🔹 ATTACHMENT
                  GestureDetector(
                    onTap: () => _pickFile(provider),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_upload_outlined, size: 32),
                          SizedBox(height: 8),
                          Text('Drop files here'),
                          Text(
                            'OR Browse Files',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (provider.attachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${provider.attachments.length} file(s) selected',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),

                  const SizedBox(height: 12),

                  /// 🔹 TITLE
                  _textField(
                    'Title of Complaint *',
                    provider.titleController,
                    onChanged: (_) => provider.onFieldChanged(),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 DESCRIPTION
                  _textField(
                    'Description *',
                    provider.descriptionController,
                    maxLines: 4,
                    onChanged: (_) => provider.onFieldChanged(),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : () async {
                            if (!_formKey.currentState!.validate()) return;

                            final success = await provider.addComplaint();

                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 READ-ONLY FIELD
  Widget _readOnlyField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextFormField(
          // initialValue: value,
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFF2F2F2),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  /// 🔹 TEXT FIELD
  Widget _textField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  /// 🔹 DROPDOWN
  Widget _dropdown({
    required String label,
    required String? initialValue,
    required List<String> items,
    required void Function(String?) onChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: initialValue,
          hint: Text(hintText),
          style: const TextStyle(color: Colors.black, fontSize: 14),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: label.contains('*')
              ? (v) => v == null ? 'Required' : null
              : null,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
