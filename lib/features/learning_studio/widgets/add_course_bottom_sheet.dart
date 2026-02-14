import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:hrtz_hrms/core/shared/shimmer_tile.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/features/learning_studio/widgets/course_content_bottom_sheet.dart';
import 'package:hrtz_hrms/features/learning_studio/provider/learning_studio_provider.dart';

class AddCourseBottomSheet extends StatefulWidget {
  final String? department;
  final String? subDepartment;

  const AddCourseBottomSheet({super.key, this.department, this.subDepartment});

  @override
  State<AddCourseBottomSheet> createState() => _AddCourseBottomSheetState();
}

class _AddCourseBottomSheetState extends State<AddCourseBottomSheet> {
  final _courseName = TextEditingController();
  final _duration = TextEditingController();
  final _details = TextEditingController();
  final _videoUrl = TextEditingController();
  final _tags = TextEditingController();

  final _departmentController = TextEditingController();
  final _subDepartmentController = TextEditingController();

  String? _selectedSubDepartment;

  final FileUploadService _uploadService = FileUploadService();
  bool _uploading = false;

  bool _courseNameError = false;
  bool _durationError = false;
  bool _detailsError = false;

  @override
  void dispose() {
    _courseName.dispose();
    _duration.dispose();
    _details.dispose();
    _videoUrl.dispose();
    _tags.dispose();
    _departmentController.dispose();
    _subDepartmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();

    // ✅ ONLY CHANGE HERE
    final deptText = widget.department ?? _departmentController.text.trim();

    final isExistingDepartment =
        deptText.isNotEmpty && provider.departments.contains(deptText);

    final subDepartments = isExistingDepartment
        ? provider.getSubDepartments(deptText)
        : <String>[];

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Course',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF26A69A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ================= FORM =================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _input(
                    label: 'Course Name *',
                    hint: 'Enter course name',
                    controller: _courseName,
                    blockNumbers : true,
                  ),

                  // ===== Department =====
                  widget.department != null
                      ? _readonly(
                          label: 'Department',
                          value: widget.department!,
                        )
                      : _input(
                          label: 'Department *',
                          hint: 'Enter department',
                          controller: _departmentController,
                          onChanged: (val) async {
                            _selectedSubDepartment = null;
                            _subDepartmentController.clear();

                            if (provider.departments.contains(val.trim())) {
                              await provider.loadSubDepartments(val.trim());
                            }
                            setState(() {});
                          },
                        ),

                  // ===== SubDepartment =====
                  widget.subDepartment != null
                      ? _readonly(
                          label: 'SubDepartment',
                          value: widget.subDepartment!,
                        )
                      : isExistingDepartment
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSubDepartment,
                            items: subDepartments
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedSubDepartment = val;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'SubDepartment *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : _input(
                          label: 'SubDepartment *',
                          hint: 'Enter sub department',
                          controller: _subDepartmentController,
                        ),

                  _input(
                    label: 'Tags (comma separated)',
                    hint: 'e.g. backend, nodejs',
                    controller: _tags,
                  ),

                  _input(
                    label: 'Duration *',
                    hint: '00:03:28',
                    controller: _duration,
                  ),

                  _input(
                    label: 'Details *',
                    hint: 'Enter course details',
                    controller: _details,
                    maxLines: 3,
                  ),

                  // ================= VIDEO UPLOAD (UNCHANGED) =================
                  const SizedBox(height: 12),
                  const Text(
                    'Video URL',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      children: [
                        _uploading
                            ? const ShimmerTile(height: 36)
                            : const Icon(
                                Icons.cloud_upload_outlined,
                                size: 36,
                                color: Colors.grey,
                              ),
                        const SizedBox(height: 8),
                        const Text('Drag & Drop file Here'),
                        const SizedBox(height: 4),
                        const Text('Or'),
                        const SizedBox(height: 10),
                        // ElevatedButton(
                        //   onPressed: _uploading ? null : _pickAndUploadVideo,
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: const Color(0xFF5DBBB3),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //   ),
                        //   child: const Text(
                        //     'Browse Files',
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // ),

                        ElevatedButton(
                          onPressed: _uploading ? null : _pickAndUploadVideo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            _uploading ? Colors.blue : const Color(0xFF5DBBB3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _uploading
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Browse Files',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Text('Or enter video URL directly:'),
                        const SizedBox(height: 8),
                        // TextField(
                        //   controller: _videoUrl,
                        //   decoration: InputDecoration(
                        //     hintText:
                        //         'https://example-bucket.s3.amazonaws.com/video.mp4',
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //   ),
                        // ),

                        TextField(
                          controller: _videoUrl,
                          enabled: !_uploading,
                          readOnly: _videoUrl.text.isNotEmpty,
                          decoration: InputDecoration(
                            hintText: 'https://example-bucket.s3.amazonaws.com/video.mp4',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= ACTION =================
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _uploading
                    ? null
                    : () {
                  setState(() {
                    _courseNameError = _courseName.text.trim().isEmpty;
                    _durationError = _duration.text.trim().isEmpty;
                    _detailsError = _details.text.trim().isEmpty;
                  });

                  if (_courseNameError || _durationError || _detailsError) {
                    return;
                  }

                  Navigator.pop(context);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CourseContentBottomSheet(
                      courseName: _courseName.text.trim(),
                      duration: _duration.text.trim(),
                      details: _details.text.trim(),
                      videoUrl: _videoUrl.text.trim(),
                      tags: _tags.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      department:
                          widget.department ??
                          _departmentController.text.trim(),
                      subDepartment:
                          widget.subDepartment ??
                          (isExistingDepartment
                              ? _selectedSubDepartment!
                              : _subDepartmentController.text.trim()),
                    ),
                  );
                },
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _input({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    bool onlyLetters   = false,
    bool blockNumbers = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,

            // ✅ ONLY CHANGE HERE
            inputFormatters: blockNumbers
                ? [
              FilteringTextInputFormatter.deny(
                RegExp(r'[0-9]'), // ✅ Numbers block instantly
              ),
            ]
                : [],

            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readonly({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: value,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _pickAndUploadVideo() async {
  //   final result =
  //       await FilePicker.platform.pickFiles(type: FileType.video);
  //   if (result == null) return;
  //
  //   final file = File(result.files.single.path!);
  //   setState(() => _uploading = true);
  //
  //   final url = await _uploadService.uploadFile(file);
  //   if(!mounted) return;
  //
  //   setState(() => _uploading = false);
  //
  //   if (url != null) {
  //     _videoUrl.text = url;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Video uploaded successfully')),
  //     );
  //   }
  // }

  Future<void> _pickAndUploadVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4',
        'mov',
        'avi',
        'mkv',
        'wmv',
        'webm',
      ],
    );

    if (result == null) return;

    final extension = result.files.single.extension?.toLowerCase();

    // Extra safety validation
    if (![
      'mp4',
      'mov',
      'avi',
      'mkv',
      'wmv',
      'webm',
    ].contains(extension?.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only video files are allowed'),
        ),
      );
      return;
    }


    final file = File(result.files.single.path!);

    setState(() => _uploading = true);

    final url = await _uploadService.uploadFile(file);

    if (!mounted) return;

    setState(() => _uploading = false);

    if (url != null) {
      // _videoUrl.text = url;
      setState(() {
        _videoUrl.text = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully')),
      );
    }
  }
}
