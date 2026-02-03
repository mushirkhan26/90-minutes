import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hrtz_hrms/features/complaint/provider/complaint_provider.dart';

class CreateComplaintBottomSheet extends StatefulWidget {
  const CreateComplaintBottomSheet({super.key});

  @override
  State<CreateComplaintBottomSheet> createState() =>
      _CreateComplaintBottomSheetState();
}

class _CreateComplaintBottomSheetState
    extends State<CreateComplaintBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // 🔹 Controllers
  final _nameCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addInfoCtrl = TextEditingController();

  String? _category;
  String? _complainPerson;

  List<String> attachments = [];

  final categories = ['IT', 'HR', 'Facilities'];
  final people = ['Team Lead', 'Manager', 'CEO'];

  @override
  void initState() {
    super.initState();
    _loadUser(); // ✅ Autofill
  }

  /// 🔹 Load login user details
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _nameCtrl.text = prefs.getString('employee_name') ?? '';
    _employeeIdCtrl.text = prefs.getString('employee_id') ?? '';
  }

  /// 🔹 File picker
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        attachments = result.paths.whereType<String>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
                  /// 🔹 HEADER (First pic style)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF66B7AE),
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

                  /// 🔹 NAME (Auto-filled)
                  _readOnlyField('Your Name *', _nameCtrl),
                  const SizedBox(height: 12),

                  /// 🔹 EMPLOYEE ID (Auto-filled)
                  _readOnlyField('Employee ID *', _employeeIdCtrl),
                  const SizedBox(height: 12),

                  /// 🔹 CATEGORY + PERSON
                  Row(
                    children: [
                      Expanded(
                        child: _dropdown(
                          label: 'Category *',
                          hintText: 'Select Category',
                          value: _category,
                          items: categories,
                          onChanged: (v) => setState(() => _category = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dropdown(
                          label: 'Mention Complaining People',
                          hintText: 'Select Person',
                          value: _complainPerson,
                          items: people,
                          onChanged: (v) => setState(() => _complainPerson = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 ADDITIONAL INFO
                  _textField('Additional Info', _addInfoCtrl, maxLines: 4),

                  const SizedBox(height: 12),

                  /// 🔹 ATTACHMENT
                  GestureDetector(
                    onTap: _pickFile,
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
                            style: TextStyle(color: Color(0xFF66B7AE)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (attachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${attachments.length} file(s) selected',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),

                  const SizedBox(height: 12),

                  /// 🔹 TITLE
                  _textField(
                    'Title of Complaint *',
                    _titleCtrl,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 DESCRIPTION
                  _textField(
                    'Description *',
                    _descCtrl,
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 BUTTONS (First pic style)
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
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final provider = context.read<ComplaintProvider>();

                            final success = await provider.addComplaint(
                              category: _category!,
                              title: _titleCtrl.text,
                              description: _descCtrl.text,
                              additionalInfo: _addInfoCtrl.text,
                              attachment: attachments,
                            );

                            if (success && mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66B7AE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
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
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  /// 🔹 DROPDOWN
  Widget _dropdown({
    required String label,
    required String? value,
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
          initialValue: value,
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
