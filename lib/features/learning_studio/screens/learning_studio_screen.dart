import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';
import 'sub_department_screen.dart';

class LearningStudioScreen extends StatefulWidget {
  const LearningStudioScreen({super.key});

  @override
  State<LearningStudioScreen> createState() => _LearningStudioScreenState();
}

class _LearningStudioScreenState extends State<LearningStudioScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredDepartments = [];

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();

    /// 🔑 KEY FIX: always sync UI list with provider data
    _applySearch(provider.departments);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Studio'),
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
                : _filteredDepartments.isEmpty
                    ? const Center(
                        child: Text(
                          'No departments found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
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
                                  builder: (_) =>
                                      SubDepartmentScreen(department: d, subDepartment: ''),
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
        ],
      ),
    );
  }
}