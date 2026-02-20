import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/features/tasks/providers/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddProjectScreen extends StatefulWidget {
  final ProjectModel? project;
  const AddProjectScreen({super.key, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  
  late TextEditingController _userPortalController;
  late TextEditingController _adminPortalController;
  late TextEditingController _testEnvController;
  late TextEditingController _playStoreController;
  late TextEditingController _appStoreController;
  
  String _selectedPriority = "Low";
  String _selectedStatus = "Not-Started";
  
  DateTime? _startDate;
  DateTime? _endDate;

  final FileUploadService _fileUploadService = FileUploadService();
  String? _uploadedImageUrl;
  bool _isUploading = false;

  List<Map<String, String>> _credentials = [];

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    
    _nameController = TextEditingController(text: p?.name);
    _descController = TextEditingController(text: p?.description);
    _startDateController = TextEditingController(text: p != null ? _formatDateForDisplay(p.startDate) : "");
    _endDateController = TextEditingController(text: p != null ? _formatDateForDisplay(p.endDate) : "");
    
    _userPortalController = TextEditingController(text: p?.links?['webDeployment']?['user']);
    _adminPortalController = TextEditingController(text: p?.links?['webDeployment']?['admin']);
    _testEnvController = TextEditingController(text: p?.links?['webDeployment']?['test']);
    _playStoreController = TextEditingController(text: p?.links?['mobileDeployment']?['playStore']);
    _appStoreController = TextEditingController(text: p?.links?['mobileDeployment']?['appStore']);
    
    _selectedPriority = p?.priority ?? "Low";
    _selectedStatus = p?.status ?? "Not-Started";
    _uploadedImageUrl = p?.imageUrl;
    
    if (p?.credentials != null) {
      _credentials = p!.credentials!.map((c) => {
        "role": c.role,
        "username": c.username,
        "password": c.password,
        "notes": c.notes ?? ""
      }).toList();
    } else {
      _credentials = [{"role": "Admin", "username": "", "password": "", "notes": ""}];
    }
  }

  String _formatDateForDisplay(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) { return ""; }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _userPortalController.dispose();
    _adminPortalController.dispose();
    _testEnvController.dispose();
    _playStoreController.dispose();
    _appStoreController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      try {
        final url = await _fileUploadService.uploadFile(
          File(result.files.single.path!),
        );
        setState(() {
          _uploadedImageUrl = url;
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final projectData = {
      if (widget.project != null) "projectId": widget.project!.id,
      "projectName": _nameController.text,
      "description": _descController.text,
      "priority": _selectedPriority,
      "imageLink": _uploadedImageUrl ?? "https://task-m.s3.us-east-1.amazonaws.com/logo.png-1770791861055",
      "projectStatus": _selectedStatus,
      "startDate": _startDate?.toUtc().toIso8601String() ?? 
                   (widget.project != null ? widget.project!.startDate : DateTime.now().toUtc().toIso8601String()),
      "endDate": _endDate?.toUtc().toIso8601String() ?? 
                 (widget.project != null ? widget.project!.endDate : DateTime.now().toUtc().toIso8601String()),
      "links": {
        "webDeployment": {
          "user": _userPortalController.text,
          "admin": _adminPortalController.text,
          "test": _testEnvController.text
        },
        "mobileDeployment": {
          "playStore": _playStoreController.text,
          "appStore": _appStoreController.text
        },
        "otherLinks": []
      },
      "testCredentials": _credentials
    };

    // If widget.project exists, call update API (to be implemented), else call add
    final success = await context.read<ProjectProvider>().addProject(projectData);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.project != null ? "Project updated successfully" : "Project added successfully")));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<ProjectProvider>().errorMessage ?? "Failed to save project")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.project != null ? "Edit Project" : "Add New Project", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: provider.state == ProjectState.loading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Basic Information"),
              const SizedBox(height: 20),
              
              _buildLabel("Project Image *"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : _uploadedImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _uploadedImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text("Click to upload", 
                                style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildLabel("Project Name *"),
              _buildTextField("Enter project name", controller: _nameController, validator: (v) => v!.isEmpty ? "Required" : null),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Priority *"),
                        _buildDropdown(["Low", "Normal", "High"], _selectedPriority, (v) => setState(() => _selectedPriority = v!)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Status *"),
                        _buildDropdown(["Not-Started", "In-Progress", "In-Test", "Completed"], _selectedStatus, (v) => setState(() => _selectedStatus = v!)),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Start Date"),
                        _buildDateField("dd-mm-yyyy", _startDateController, () => _selectDate(context, true)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("End Date"),
                        _buildDateField("dd-mm-yyyy", _endDateController, () => _selectDate(context, false)),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              _buildLabel("Description *"),
              _buildTextField("Enter project description", controller: _descController, maxLines: 4, validator: (v) => v!.isEmpty ? "Required" : null),
              
              const SizedBox(height: 32),
              _buildSectionHeader("Deployment Links"),
              const SizedBox(height: 20),
              
              const Text("Web Deployment", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 16),
              _buildDeployField("User Portal", "https://app.example.com", _userPortalController),
              const SizedBox(height: 12),
              _buildDeployField("Admin Portal", "https://admin.example.com", _adminPortalController),
              const SizedBox(height: 12),
              _buildDeployField("Test Environment", "https://test.example.com", _testEnvController),
              
              const SizedBox(height: 24),
              const Text("Mobile Deployment", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 16),
              _buildDeployField("Play Store", "https://play.google.com/...", _playStoreController),
              const SizedBox(height: 12),
              _buildDeployField("App Store", "https://apps.apple.com/...", _appStoreController),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("Test Credentials"),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _credentials.add({"role": "", "username": "", "password": "", "notes": ""});
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text("Add Credential", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._credentials.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCredentialCard(entry.key),
              )),
              
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(widget.project != null ? "Update Project" : "Add Project", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : items[0],
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateField(String hint, TextEditingController controller, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(controller.text.isEmpty ? hint : controller.text, style: TextStyle(color: controller.text.isEmpty ? Colors.grey[400] : Colors.black87, fontSize: 14)),
            Icon(Icons.calendar_month_outlined, size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDeployField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        _buildTextField(hint, controller: controller),
      ],
    );
  }

  Widget _buildCredentialCard(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Role", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: _credentials[index]['role'],
                      onChanged: (v) => _credentials[index]['role'] = v,
                      decoration: _credsInputDecoration("Admin, Tester..."),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Username", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: _credentials[index]['username'],
                      onChanged: (v) => _credentials[index]['username'] = v,
                      decoration: _credsInputDecoration("username"),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () => setState(() => _credentials.removeAt(index)), icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Password", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: _credentials[index]['password'],
                      onChanged: (v) => _credentials[index]['password'] = v,
                      decoration: _credsInputDecoration("password"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notes", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: _credentials[index]['notes'],
                      onChanged: (v) => _credentials[index]['notes'] = v,
                      decoration: _credsInputDecoration("notes"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _credsInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    );
  }
}
