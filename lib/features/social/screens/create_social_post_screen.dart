import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/social_post_model.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/social/provider/social_provider.dart';
import 'package:provider/provider.dart';

class CreateSocialPostScreen extends StatefulWidget {
  const CreateSocialPostScreen({super.key});

  @override
  State<CreateSocialPostScreen> createState() => _CreateSocialPostScreenState();
}

class _CreateSocialPostScreenState extends State<CreateSocialPostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Post';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  
  // Poll Controllers
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(text: 'Option 1'),
    TextEditingController(text: 'Option 2'),
  ];
  DateTime? _pollExpiry;

  // Event Date
  DateTime? _eventDate;

  final FileUploadService _fileUploadService = FileUploadService();
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _isPosting = false;

  final List<String> _postTypes = ['Birthday', 'Post', 'Poll', 'Event', 'Well Being'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _employeeNameController.dispose();
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      try {
        final url = await _fileUploadService.uploadFile(File(result.files.single.path!));
        setState(() {
          _uploadedImageUrl = url;
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Social Post',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const Text('Post Type', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: _postTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Title', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter the post title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Title is required' : null,
                ),

                if (_selectedType == 'Poll') ...[
                  const SizedBox(height: 16),
                  const Text('Question', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Enter poll question',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) => _selectedType == 'Poll' && value!.isEmpty ? 'Question is required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Options', style: TextStyle(fontWeight: FontWeight.w500)),
                  ..._optionControllers.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                hintText: 'Option ${idx + 1}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              validator: (value) => _selectedType == 'Poll' && value!.isEmpty ? 'Option required' : null,
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => setState(() => _optionControllers.removeAt(idx)),
                            ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => setState(() => _optionControllers.add(TextEditingController())),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Option'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) setState(() => _pollExpiry = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_pollExpiry == null ? 'Select Expiry Date' : _pollExpiry.toString().split(' ')[0]),
                    ),
                  ),
                ],

                if (_selectedType == 'Event') ...[
                  const SizedBox(height: 16),
                  const Text('Event Date', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        if (mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if(!mounted) return;
                          if (time != null) {
                            setState(() {
                              _eventDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_eventDate == null ? 'Select Event Date & Time' : _eventDate.toString().substring(0, 16)),
                    ),
                  ),
                ],

                if (_selectedType == 'Birthday') ...[
                  const SizedBox(height: 16),
                  const Text('Employee Name', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _employeeNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter employee name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Employee name is required' : null,
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Message', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your news or announcement...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Message is required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Image (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isUploading 
                      ? const Center(child: CircularProgressIndicator())
                      : _uploadedImageUrl != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(_uploadedImageUrl!, height: 100, width: double.infinity, fit: BoxFit.cover),
                          )
                        : Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF26A69A),
                                child: Icon(Icons.upload, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              const Text('Tap to select image', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('• Allowed: JPG, JPEG, PNG, GIF (Max: 3 MB)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isPosting || _isUploading ? null : _handlePost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A69A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isPosting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Post', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePost() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == 'Poll' && _pollExpiry == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select poll expiry date')));
        return;
      }
      
      if (_selectedType == 'Event' && _eventDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select event date')));
        return;
      }

      setState(() => _isPosting = true);
      
      final authProvider = context.read<AuthProvider>();
      final socialProvider = context.read<SocialProvider>();
      
      final newPost = SocialPostModel(
        id: '',
        type: _selectedType.toLowerCase().replaceAll(' ', ''),
        title: _titleController.text,
        userName: authProvider.userData?['username'],
        userId: authProvider.userData?['employeeId'],
        employeeName: _selectedType == 'Birthday' ? _employeeNameController.text : null,
        message: _messageController.text,
        imageUrl: _uploadedImageUrl,
        createdBy: authProvider.userData?['employeeId'] ?? 'Unknown',
        createdAt: DateTime.now(),
        likes: [],
        comments: [],
        question: _selectedType == 'Poll' ? _questionController.text : null,
        expiry: _selectedType == 'Poll' ? _pollExpiry : null,
        options: _selectedType == 'Poll' 
            ? _optionControllers.map((c) => PollOption(label: c.text)).toList() 
            : null,
        eventDate: _selectedType == 'Event' ? _eventDate : null,
      );
      
      final success = await socialProvider.createPost(newPost);
      
      setState(() => _isPosting = false);
      
      if (success) {
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create post')),
          );
        }
      }
    }
  }
}
