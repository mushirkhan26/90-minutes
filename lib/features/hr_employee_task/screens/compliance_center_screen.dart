import 'package:flutter/material.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/compliance_provider.dart';
import '../widgets/compliance_card.dart';
import '../widgets/compliance_tab_bar.dart';
import '../widgets/compliance_summary_section.dart';
import 'package:hrtz_hrms/features/hr_employee_task/widgets/create_task_dailog.dart';

class ComplianceCenterScreen extends StatefulWidget {
  const ComplianceCenterScreen({super.key});

  @override
  State<ComplianceCenterScreen> createState() =>
      _ComplianceCenterScreenState();
}

class _ComplianceCenterScreenState
    extends State<ComplianceCenterScreen> {
  bool _isAdmin = false;
  String _selectedTab = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRoleAndData();
    });
  }

  void _initializeRoleAndData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.userData?['role']?.toString().toLowerCase();
    
    setState(() {
      _isAdmin = role == 'hr' || role == 'manager';
    });

    _fetchData();
  }

  Future<void> _fetchData() async {
    final provider = context.read<ComplianceProvider>();
    if (_isAdmin) {
      await provider.fetchAllCompliances();
    } else {
      await provider.fetchCompliances();
    }
  }

  List _filterCompliances(List compliances) {
    if (!_isAdmin || _selectedTab == "All") {
      return compliances;
    }

    return compliances.where((c) {
      final status = c.status.toLowerCase();
      if (_selectedTab == "Assigned") {
        return status == "assigned";
      }
      if (_selectedTab == "Submitted") {
        return status == "submitted";
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        toolbarHeight: _isAdmin ? 80 : kToolbarHeight,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isAdmin ? "HR Task Management System" : "HR Employee Task",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            if (_isAdmin)
              const Text(
                "Streamline your onboarding process",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
          ],
        ),
        actions: _isAdmin
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomButton(
                    text: "Add",
                    icon: Icons.add,
                    width: 100,
                    height: 40,
                    borderRadius: 25,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    borderColor: Colors.transparent,
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const CreateTaskDialog(),
                      );
                    },
                  ),
                )
              ]
            : null,
      ),
      body: Consumer<ComplianceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.compliances.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.compliances.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          final filteredCompliances = _filterCompliances(provider.compliances);

          return RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isAdmin) ...[
                    ComplianceTabBar(
                      selectedTab: _selectedTab,
                      onTabChanged: (tab) => setState(() => _selectedTab = tab),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    ComplianceSummarySection(provider: provider),
                    const SizedBox(height: 32),
                  ],

                  if (filteredCompliances.isEmpty)
                    const Center(child: Text("No compliances found"))
                  else
                    ...filteredCompliances.map(
                      (compliance) => ComplianceCard(
                        compliance: compliance,
                        isAdmin: _isAdmin,
                        onSubmit: (docs) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await provider.submitCompliance(
                              compliance.id, docs);

                          if (!mounted) return;
                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Compliance submitted successfully"),
                              ),
                            );
                            await _fetchData();
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
