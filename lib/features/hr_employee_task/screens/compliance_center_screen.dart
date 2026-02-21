import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/compliance_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/compliance_card.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth =
          Provider.of<AuthProvider>(context, listen: false);

      final role =
          auth.userData?['role']?.toString().toLowerCase();

      setState(() {
        _isAdmin = role == 'hr' || role == 'manager';
      });

      _fetchData();
    });
  }

  // ================= FETCH DATA =================
  Future<void> _fetchData() async {
    if (!mounted) return;

    final provider =
        context.read<ComplianceProvider>();

    if (_isAdmin) {
      await provider.fetchAllCompliances(); // HR / Manager
    } else {
      await provider.fetchCompliances();    // Employee (UNCHANGED)
    }
  }

  // ================= TAB FILTER =================
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

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF26A69A)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),

    // ================= APPBAR =================
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
            _isAdmin
                ? "HR Task Management System"
                : "HR Employee Task",
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
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const CreateTaskDialog(),
              );
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              "Add",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        )
      ]
    : null,
    ),

    body: Consumer<ComplianceProvider>(
      builder: (context, provider, child) {

        if (provider.isLoading &&
            provider.compliances.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.errorMessage != null &&
            provider.compliances.isEmpty) {
          return Center(
            child: Text(provider.errorMessage!),
          );
        }

        final filteredCompliances =
            _filterCompliances(provider.compliances);

        return RefreshIndicator(
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ================= HR TABS =================
                if (_isAdmin) ...[
                  Row(
                    children: [
                      _buildTab("All"),
                      const SizedBox(width: 8),
                      _buildTab("Assigned"),
                      const SizedBox(width: 8),
                      _buildTab("Submitted"),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // ================= EMPLOYEE UI =================
                if (!_isAdmin) ...[

                  const Text(
                    'Compliance Center',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Manage and track your compliance requirements',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total',
                          count: provider.totalCount,
                          backgroundColor: Colors.white,
                          borderColor:
                              const Color(0xFFE2E8F0),
                          titleColor:
                              const Color(0xFF475569),
                          countColor:
                              const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: 'Action\nRequired',
                          count:
                              provider.actionRequiredCount,
                          backgroundColor:
                              const Color(0xFFFFFBEB),
                          borderColor:
                              const Color(0xFFFEF3C7),
                          titleColor:
                              const Color(0xFFB45309),
                          countColor:
                              const Color(0xFF78350F),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: 'Completed',
                          count:
                              provider.completedCount,
                          backgroundColor:
                              const Color(0xFFF0FDF4),
                          borderColor:
                              const Color(0xFFDCFCE7),
                          titleColor:
                              const Color(0xFF15803D),
                          countColor:
                              const Color(0xFF064E3B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: 'Overdue',
                          count:
                              provider.overdueCount,
                          backgroundColor:
                              const Color(0xFFFEF2F2),
                          borderColor:
                              const Color(0xFFFEE2E2),
                          titleColor:
                              const Color(0xFFB91C1C),
                          countColor:
                              const Color(0xFF7F1D1D),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],

                // ================= CARDS =================
                if (filteredCompliances.isEmpty)
                  const Center(
                    child: Text("No compliances found"),
                  )
                else
                  ...filteredCompliances.map(
                    (compliance) =>
                        ComplianceCard(
                      compliance: compliance,
                      isAdmin: _isAdmin,
                      onSubmit: (docs) async {
                        final success =
                            await provider
                                .submitCompliance(
                                    compliance.id,
                                    docs);

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Compliance submitted successfully"),
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