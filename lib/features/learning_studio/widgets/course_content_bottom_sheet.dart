import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';

class CourseContentBottomSheet extends StatefulWidget {
  final String courseName;
  final String duration;
  final String details;
  final String videoUrl;
  final List<String> tags;

  // 🔥 ONLY CHANGE: nullable
  final String? department;
  final String? subDepartment;

  const CourseContentBottomSheet({
    super.key,
    required this.courseName,
    required this.duration,
    required this.details,
    required this.videoUrl,
    required this.tags,
    this.department,
    this.subDepartment,
  });

  @override
  State<CourseContentBottomSheet> createState() =>
      _CourseContentBottomSheetState();
}

class _CourseContentBottomSheetState
    extends State<CourseContentBottomSheet> {
  final TextEditingController _contentController =
      TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LearningStudioProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          const SizedBox(height: 6),

          // ================= BACK =================
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back,
                    color: Color(0xFF26A69A)),
                SizedBox(width: 6),
                Text(
                  'Course Content',
                  style: TextStyle(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Write course content (supports Markdown and code)',
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 10),

          // ================= TEXT AREA =================
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: 12,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Write course content here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ================= ACTION BUTTONS =================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),

              ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        if (_contentController.text
                            .trim()
                            .isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Course content is required'),
                            ),
                          );
                          return;
                        }

                        setState(() => _saving = true);

                        final success =
                            await provider.addCourse(
                          courseName: widget.courseName,
                          duration: widget.duration,
                          details: widget.details,
                          content:
                              _contentController.text.trim(),
                          videoUrl: widget.videoUrl,
                          tags: widget.tags,

                          // 🔥 NULL SAFE PASS
                          department:
                              widget.department ?? '',
                          subDepartment:
                              widget.subDepartment ?? '',

                          createdOn:
                              DateTime.now().toIso8601String(),
                        );
                        if(!mounted) return;

                        setState(() => _saving = false);

                        if (success ) {
                          

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Course added successfully'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF5DBBB3),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}