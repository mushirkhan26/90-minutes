import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';
import 'package:hrtz_hrms/features/learning_studio/screens/course_screen.dart';
import '../../../core/shared/shimmer_tile.dart';

class SubDepartmentScreen extends StatefulWidget {
  final String department;
  final String subDepartment;

  const SubDepartmentScreen({super.key, required this.department, required this.subDepartment});

  @override
  State<SubDepartmentScreen> createState() => _SubDepartmentScreenState();
}

class _SubDepartmentScreenState extends State<SubDepartmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LearningStudioProvider>()
          .loadSubDepartments(widget.department);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();

    final allSubDepartments =
        provider.getSubDepartments(widget.department);

    final filteredSubDepartments = _searchQuery.isEmpty
        ? allSubDepartments
        : allSubDepartments
            .where((e) => e.toLowerCase().contains(_searchQuery))
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        title: Text('Learning Studio > ${widget.department}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600
        ),
        ),
        
        actions: [
  Padding(
    padding: const EdgeInsets.only(right: 12),
    child: ElevatedButton.icon(
      onPressed: () {
        _showAddSubDepartmentDialog(context);
      },
      icon: const Icon(
        Icons.add,
        size: 18,
        color: Colors.white,
      ),
      label: const Text(
        'Add',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6FBFC0), // ✅ same as Complaints
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),
  ),
],
      ),
      body: Column(
        children: [
          /// 🔍 Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF26A69A),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search subdepartments...',
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

          /// 📁 Content
          Expanded(
            child: _buildContent(provider, filteredSubDepartments),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    LearningStudioProvider provider,
    List<String> filteredSubDepartments,
  ) {
    if (provider.state == LearningStudioState.loading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerTile(height: 120),
      );
    }

    if (filteredSubDepartments.isEmpty) {
      return const Center(
        child: Text(
          'No subdepartments found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: filteredSubDepartments.length,
      itemBuilder: (context, index) {
        final subDept = filteredSubDepartments[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CoursesScreen(department: widget.department, subDepartment: subDept),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: Color(0xFF26A69A),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subDept,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= ADD SUBDEPARTMENT DIALOG =================
  void _showAddSubDepartmentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Subdepartment',
                      style: TextStyle(
                        fontSize: 18,
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

                const SizedBox(height: 16),

                const Text('Subdepartment Name *',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Frontend Development',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                const Text('Description (Optional)',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Brief description of this subdepartment',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                const Text('Department',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                TextField(
                  enabled: false,
                  controller:
                      TextEditingController(text: widget.department),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

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
                        backgroundColor:
                            const Color(0xFF26A69A),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;

                        final provider =
                            context.read<LearningStudioProvider>();

                        final success =
                            await provider.addSubDepartment(
                          subDepartmentName:
                              nameController.text.trim(),
                          department: widget.department,
                          description:
                              descController.text.trim(),
                        );

                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Create',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}