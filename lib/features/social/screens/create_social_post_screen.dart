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
  
  final FileUploadService _fileUploadService = FileUploadService();
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _isPosting = false;

  final List<String> _postTypes = ['Birthday', 'Post', 'Poll', 'Event', 'Well Being'];

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
      setState(() => _isPosting = true);
      
      final authProvider = context.read<AuthProvider>();
      final socialProvider = context.read<SocialProvider>();
      
      final newPost = SocialPostModel(
        id: '',
        type: _selectedType.toLowerCase().replaceAll(' ', ''),
        title: _titleController.text,
        employeeName: _selectedType == 'Birthday' ? _employeeNameController.text : null,
        message: _messageController.text,
        imageUrl: _uploadedImageUrl,
        createdBy: authProvider.userData?['employeeId'] ?? 'Unknown',
        createdAt: DateTime.now(),
        likes: [],
        comments: [],
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
