import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';
import 'sub_department_screen.dart';
import 'course_status_screen.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/learning_studio/widgets/add_course_bottom_sheet.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hrtz_hrms/features/learning_studio/screens/progress_history_screen.dart';
import 'package:hrtz_hrms/features/learning_studio/widgets/progress_history_card.dart';

class LearningStudioScreen extends StatefulWidget {
  const LearningStudioScreen({super.key});

  @override
  State<LearningStudioScreen> createState() => _LearningStudioScreenState();
}

class _LearningStudioScreenState extends State<LearningStudioScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredDepartments = [];
  bool isManager = false;

  @override
  void initState() {
    super.initState();
    // Logic moved to Provider constructor / bootstrap.
    // UI just sets up initial local state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final role = auth.userData?['role']?.toString().toLowerCase() ?? '';
      setState(() {
        isManager = role == 'manager';
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData getDepartmentIcon(String department) {
    final name = department.toLowerCase();
    if (name.contains('dev')) return Icons.code;
    if (name.contains('hr')) return Icons.person;
    if (name.contains('market')) return Icons.campaign;
    return Icons.folder;
  }

  void _applySearch(List<String> source) {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredDepartments =
          q.isEmpty ? source : source.where((e) => e.toLowerCase().contains(q)).toList();
    });
  }

  void _openAddCourseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCourseBottomSheet(),
    );
  }

  Widget _myProgressItem(
    BuildContext context,
    Map<String, dynamic> course,
    String employeeId,
  ) {
    final String status = course['courseStatus'] ?? 'NotStarted';
    final double progressValue = status == 'Completed' ? 1.0 : status == 'Ongoing' ? 0.5 : 0.0;
    final String progressText = status == 'Completed' ? '100%' : status == 'Ongoing' ? '50%' : '0%';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseStatusScreen(course: course, employeeId: employeeId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            course['courseName'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Start Date: ${(course['startDate'] ?? '').toString().split('T').first}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Current Progress'),
              // Text(progressText), // Handled by variable
            ],
          ),
          // Re-adding the text properly
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Text(progressText),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.grey.shade300,
            color: status == 'NotStarted' ? Colors.grey : Colors.green,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: status == 'Completed'
                    ? Colors.green
                    : status == 'Ongoing'
                        ? Colors.orange
                        : Colors.grey,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                '$count Courses',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamProgressChart(int completed, int ongoing, int notStarted) {
    final total = completed + ongoing + notStarted;
    if (total == 0) {
      return Center(
        child: Column(
          children: const [
            SizedBox(height: 40),
            Text('0', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text('Courses', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 60,
              sectionsSpace: 2,
              sections: [
                PieChartSectionData(
                  value: completed.toDouble(),
                  color: const Color(0xFF5BC4B8),
                  title: '$completed',
                  radius: 45,
                  titleStyle: const TextStyle(color: Colors.white),
                ),
                PieChartSectionData(
                  value: ongoing.toDouble(),
                  color: const Color(0xFFF4A261),
                  title: '$ongoing',
                  radius: 45,
                  titleStyle: const TextStyle(color: Colors.white),
                ),
                PieChartSectionData(
                  value: notStarted.toDouble(),
                  color: const Color(0xFFE45745),
                  title: '$notStarted',
                  radius: 45,
                  titleStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$total',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Courses', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();
    final auth = context.read<AuthProvider>();
    final employeeId = auth.userData?['employeeId']?.toString();

    final progressHistory = provider.progressHistory ?? [];
    final previewHistory = progressHistory.take(4).toList();
    
    // Manage filtered departments list based on provider data
    final displayDepartments = _searchController.text.isEmpty ? provider.departments : _filteredDepartments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Studio', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF26A69A),
        actions: isManager
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FBFC0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Create', style: TextStyle(color: Colors.white)),
                    onPressed: () => _openAddCourseBottomSheet(context),
                  ),
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF26A69A),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applySearch(provider.departments),
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.state == LearningStudioState.loading && provider.departments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.loadDepartments(force: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                              ),
                              itemCount: displayDepartments.length,
                              itemBuilder: (_, i) {
                                final d = displayDepartments[i];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SubDepartmentScreen(department: d, subDepartment: ''),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(getDepartmentIcon(d), size: 36, color: const Color(0xFF26A69A)),
                                        const SizedBox(height: 10),
                                        Text(d, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isManager) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text('Team Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Progress Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 12),
                                    _summaryCard('Completed', provider.courseCount?['completed'] ?? 0, const Color(0xFF5BC4B8)),
                                    _summaryCard('Ongoing', provider.courseCount?['ongoing'] ?? 0, const Color(0xFFF4A261)),
                                    _summaryCard('Not Started', provider.courseCount?['notStarted'] ?? 0, const Color(0xFFE45745)),
                                    const SizedBox(height: 16),
                                    _teamProgressChart(
                                      provider.courseCount?['completed'] ?? 0,
                                      provider.courseCount?['ongoing'] ?? 0,
                                      provider.courseCount?['notStarted'] ?? 0,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (previewHistory.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Progress History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    InkWell(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressHistoryScreen())),
                                      child: const Text('See All', style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ),
                              ProgressHistoryCard(
                                items: previewHistory,
                                onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressHistoryScreen())),
                                onItemTap: (item) => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressHistoryScreen())),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                          if (!isManager && provider.employeeCourses != null && provider.employeeCourses!.isNotEmpty && employeeId != null) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text('My Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.employeeCourses!.length,
                              itemBuilder: (context, index) => _myProgressItem(context, provider.employeeCourses![index], employeeId),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
