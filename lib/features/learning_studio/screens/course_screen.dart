import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';
import '../widgets/add_course_bottom_sheet.dart';
import 'course_details_screen.dart';
import 'package:hrtz_hrms/features/learning_studio/widgets/course_video_player.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/learning_studio/widgets/assign_video_dialog.dart';

class CoursesScreen extends StatefulWidget {
  final String department;
  final String subDepartment;

  const CoursesScreen({
    super.key,
    required this.department,
    required this.subDepartment,
  });

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final Set<String> selectedTags = {};
  final GlobalKey _filterKey = GlobalKey();
  bool isManager = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LearningStudioProvider>();
      provider.loadCourses(widget.subDepartment);
      
      final auth = context.read<AuthProvider>();
      final role = auth.userData?['role']?.toString().toLowerCase();
      setState(() => isManager = role == 'manager');
    });
  }

  void _confirmDelete(
    BuildContext context, {
    required String courseId,
    required String courseName,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Course', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "$courseName"?\nThis action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<LearningStudioProvider>().deleteCourse(
                    courseId: courseId,
                    subDepartment: widget.subDepartment,
                  );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openAssignVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AssignVideoDialog(subDepartment: widget.subDepartment),
    );
  }

  void _openTagFilterDropdown(List<String> allTags) async {
    final RenderBox box = _filterKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy + box.size.height + 6, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Tags', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ...allTags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return InkWell(
                  onTap: () {
                    setState(() {
                      isSelected ? selectedTags.remove(tag) : selectedTags.add(tag);
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2F1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(tag, style: TextStyle(color: isSelected ? const Color(0xFF26A69A) : Colors.black, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
                        if (isSelected) const Icon(Icons.check, size: 18, color: Color(0xFF26A69A)),
                      ],
                    ),
                  ),
                );
              }),
              const Divider(),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() => selectedTags.clear());
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All', style: TextStyle(color: Color(0xFF26A69A))),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();
    final courses = provider.getCourses(widget.subDepartment);

    final List<String> allTags = courses.expand((c) => (c['tags'] ?? []) as List).map((e) => e.toString()).toSet().toList();

    final filteredCourses = selectedTags.isEmpty
        ? courses
        : courses.where((course) {
            final tags = course['tags'] ?? [];
            return selectedTags.every((t) => tags.contains(t));
          }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        title: Text('Learning Studio > ${widget.subDepartment}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadCourses(widget.subDepartment, force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DBBB3)),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddCourseBottomSheet(department: widget.department, subDepartment: widget.subDepartment),
                      );
                    },
                    child: const Text('Add Video', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (isManager) ...[
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                      onPressed: () => _openAssignVideoDialog(context),
                      child: const Text('Assign Video', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 24),
            Text('${widget.subDepartment} Courses', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Browse all courses in this subdepartment', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            GestureDetector(
              key: _filterKey,
              onTap: () => _openTagFilterDropdown(allTags),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF5DBBB3), borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.label_outline, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Filter by Tags (${selectedTags.length})', style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ]),
              ),
            ),
            if (selectedTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  children: [
                    const Text('Active filters:', style: TextStyle(color: Colors.grey)),
                    ...selectedTags.map((t) => Chip(label: Text(t), onDeleted: () => setState(() => selectedTags.remove(t)))),
                    TextButton(onPressed: () => setState(() => selectedTags.clear()), child: const Text('Clear all')),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (provider.state == LearningStudioState.loading && courses.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (filteredCourses.isEmpty)
              const Center(
                child: Column(children: [
                  SizedBox(height: 40),
                  Icon(Icons.search_off, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No courses found', style: TextStyle(color: Colors.grey)),
                ]),
              )
            else
              ...filteredCourses.map((course) {
                final String videoUrl = course['videoUrl'] ?? '';
                final List tags = course['tags'] ?? [];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => _confirmDelete(context, courseId: course['courseId'].toString(), courseName: course['courseName'] ?? ''),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 8),
                    videoUrl.isNotEmpty ? CourseVideoPlayer(videoUrl: videoUrl) : Container(height: 180, alignment: Alignment.center, child: const Text('No video available')),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, children: tags.map<Widget>((t) => _chip(t.toString(), const Color(0xFFE0F2F1))).toList()),
                    const SizedBox(height: 12),
                    Text(course['courseName'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Duration: ${course['duration']}', style: const TextStyle(color: Colors.teal)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1FA8A8)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course)));
                        },
                        child: const Text('View Details', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ]),
                );
              }),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
