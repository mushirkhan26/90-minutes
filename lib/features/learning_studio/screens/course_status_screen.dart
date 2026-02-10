import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/core/shared/shimmer_tile.dart';
import 'package:hrtz_hrms/features/learning_studio/widgets/course_video_player.dart';
import '../provider/learning_studio_provider.dart';

class CourseStatusScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  final String employeeId;

  const CourseStatusScreen({
    super.key,
    required this.course,
    required this.employeeId,
  });

  @override
  State<CourseStatusScreen> createState() => _CourseStatusScreenState();
}

class _CourseStatusScreenState extends State<CourseStatusScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();

    _currentStatus =
        widget.course['courseStatus'] ?? 'NotStarted';

    
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();

    if (provider.state == LearningStudioState.loading) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerTile(height: 180),
        ),
      );
    }

    final courseData = widget.course;
    

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(courseData['courseName'] ?? ''),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _topCard(
              courseData['courseName'],
              courseData['details'],
              courseData['duration'],
              _currentStatus,
            ),

            /// 🎥 VIDEO
            if ((courseData['videoUrl'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CourseVideoPlayer(
                  videoUrl: courseData['videoUrl'],
                ),
              ),

            /// 📊 STATUS CARD
            _statusCard(
              context,
              provider,
              _currentStatus,
              widget.course['courseStatusId'],
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOP CARD =================

  Widget _topCard(
    String? name,
    String? details,
    String? duration,
    String? status,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name ?? '', style: _title()),
          const SizedBox(height: 6),
          Text(details ?? '', style: _grey()),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 6),
              Text(duration ?? 'N/A'),
              const SizedBox(width: 12),
              _statusChipWithPercent(status ?? 'NotStarted'),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS CARD =================

  Widget _statusCard(
    BuildContext context,
    LearningStudioProvider provider,
    String status,
    String courseStatusId,
  ) {
    final bool isCompleted = status == 'Completed';
    final bool isOngoing = status == 'Ongoing';

    final double progress =
        isCompleted ? 1.0 : isOngoing ? 0.5 : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Course Status',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _statusChipWithPercent(status),
            ],
          ),

          const SizedBox(height: 14),

          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            borderRadius: BorderRadius.circular(6),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  text: 'Mark as Ongoing',
                  color: Colors.orange,
                  enabled: !isOngoing && !isCompleted,
                  onTap: () => _updateStatus(
                    context,
                    provider,
                    courseStatusId,
                    'Ongoing',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionBtn(
                  text: 'Mark as Completed',
                  color: Colors.green,
                  enabled: !isCompleted,
                  onTap: () => _updateStatus(
                    context,
                    provider,
                    courseStatusId,
                    'Completed',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ACTION =================

  void _updateStatus(
    BuildContext context,
    LearningStudioProvider provider,
    String courseStatusId,
    String status,
  ) async {
    final ok = await provider.updateCourseStatus(
      courseDetailId: courseStatusId,
      status: status,
      employeeId: widget.employeeId,
    );

    if (ok && context.mounted) {
      setState(() {
        _currentStatus = status; // 🔥 KEY FIX
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course marked as $status'),
          backgroundColor:
              status == 'Completed' ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  // ================= UI HELPERS =================

  Widget _statusChipWithPercent(String status) {
    late Color bg;
    late Color text;
    late String label;

    if (status == 'Completed') {
      bg = Colors.green.withValues(alpha: 0.15);
      text = Colors.green;
      label = 'Completed (100%)';
    } else if (status == 'Ongoing') {
      bg = Colors.orange.withValues(alpha: 0.15);
      text = Colors.orange;
      label = 'Ongoing (50%)';
    } else {
      bg = Colors.grey.withValues(alpha: 0.2);
      text = Colors.grey;
      label = 'Not Started';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: text),
      ),
    );
  }

  Widget _actionBtn({
    required String text,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      );

  TextStyle _title() =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  TextStyle _grey() => const TextStyle(color: Colors.grey);
}