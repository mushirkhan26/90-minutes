import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';
import 'sub_department_screen.dart';
import 'course_status_screen.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';

class LearningStudioScreen extends StatefulWidget {
  const LearningStudioScreen({super.key});

  @override
  State<LearningStudioScreen> createState() => _LearningStudioScreenState();
}

class _LearningStudioScreenState extends State<LearningStudioScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredDepartments = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<LearningStudioProvider>();

      final employeeId = auth.userData?['employeeId'];
      if (employeeId != null) {
        provider.loadEmployeeCourses(employeeId.toString());
      }
    });
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
    _filteredDepartments =
        q.isEmpty ? source : source.where((e) => e.toLowerCase().contains(q)).toList();
  }

  /// ---------------- MY PROGRESS CARD ----------------
  Widget _myProgressItem(
    BuildContext context,
    Map<String, dynamic> course,
    String employeeId,
  ) {
    final String status = course['courseStatus'] ?? 'NotStarted';

    final double progressValue =
        status == 'Completed'
            ? 1.0
            : status == 'Ongoing'
                ? 0.5
                : 0.0;

    final String progressText =
        status == 'Completed'
            ? '100%'
            : status == 'Ongoing'
                ? '50%'
                : '0%';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CourseStatusScreen(course: course, employeeId: employeeId),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              children: [
                const Text('Current Progress'),
                Text(progressText),
              ],
            ),
            const SizedBox(height: 6),

            LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey.shade300,
              color: status == 'NotStarted'
                  ? Colors.grey
                  : Colors.green,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();
    final auth = context.read<AuthProvider>();
    final employeeId = auth.userData?['employeeId']?.toString();

    _applySearch(provider.departments);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Studio',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: Column(
        children: [
          // 🔍 Search
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF26A69A),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
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
            child: provider.state == LearningStudioState.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ================= DEPARTMENTS GRID =================
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                            ),
                            itemCount: _filteredDepartments.length,
                            itemBuilder: (_, i) {
                              final d = _filteredDepartments[i];
                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubDepartmentScreen(
                                        department: d,
                                        subDepartment: '',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        getDepartmentIcon(d),
                                        size: 36,
                                        color: const Color(0xFF26A69A),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        d,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        /// ================= MY PROGRESS =================
                        if (provider.employeeCourses != null &&
                            provider.employeeCourses!.isNotEmpty &&
                            employeeId != null) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'My Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.employeeCourses!.length,
                            itemBuilder: (context, index) {
                              return _myProgressItem(
                                context,
                                provider.employeeCourses![index],
                                employeeId,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}