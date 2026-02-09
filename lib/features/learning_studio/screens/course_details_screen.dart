import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/learning_studio/widgets/course_video_player.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final String videoUrl = course['videoUrl'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK BUTTON
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: Colors.black,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// COURSE NAME
              Text(
                course['courseName'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26A69A),
                ),
              ),

              const SizedBox(height: 6),

              /// TAG + DURATION
              Text(
                '${(course['tags'] as List?)?.first ?? ''} • ${course['duration']}',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 6),

              /// DETAILS
              Text(
                course['details'] ?? '',
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 30),

              /// VIDEO / NO VIDEO  ✅ (ONLY CHANGE)
              Center(
                child: videoUrl.isEmpty
                    ? Column(
                        children: const [
                          Icon(
                            Icons.cloud_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No video available for this course.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: CourseVideoPlayer(videoUrl: videoUrl),
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              /// COURSE CONTENT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Content',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26A69A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course['content'] ?? 'No course content available',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}