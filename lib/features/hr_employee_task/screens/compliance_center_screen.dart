import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/alert_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/compliance_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/compliance_card.dart';

class ComplianceCenterScreen extends StatefulWidget {
  const ComplianceCenterScreen({super.key});

  @override
  State<ComplianceCenterScreen> createState() => _ComplianceCenterScreenState();
}

class _ComplianceCenterScreenState extends State<ComplianceCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final id = authProvider.userData?['_id']?.toString() ?? 
               authProvider.userData?['id']?.toString() ??
               authProvider.profileData?.id ??
               authProvider.userData?['employeeId']?.toString();
               
    if (id != null) {
      await context.read<ComplianceProvider>().fetchCompliances(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'HR Employee Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<ComplianceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.compliances.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.compliances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final compliances = provider.compliances;

          return RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compliance Center',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and track your compliance requirements',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SummaryCard(
                        title: 'Total',
                        count: provider.totalCount,
                        backgroundColor: Colors.white,
                        borderColor: const Color(0xFFE2E8F0),
                        titleColor: const Color(0xFF475569),
                        countColor: const Color(0xFF0F172A),
                      ),
                      const SizedBox(width: 8),
                      SummaryCard(
                        title: 'Action\nRequired',
                        count: provider.actionRequiredCount,
                        backgroundColor: const Color(0xFFFFFBEB),
                        borderColor: const Color(0xFFFEF3C7),
                        titleColor: const Color(0xFFB45309),
                        countColor: const Color(0xFF78350F),
                      ),
                      const SizedBox(width: 8),
                      SummaryCard(
                        title: 'Completed',
                        count: provider.completedCount,
                        backgroundColor: const Color(0xFFF0FDF4),
                        borderColor: const Color(0xFFDCFCE7),
                        titleColor: const Color(0xFF15803D),
                        countColor: const Color(0xFF064E3B),
                      ),
                      const SizedBox(width: 8),
                      SummaryCard(
                        title: 'Overdue',
                        count: provider.overdueCount,
                        backgroundColor: const Color(0xFFFEF2F2),
                        borderColor: const Color(0xFFFEE2E2),
                        titleColor: const Color(0xFFB91C1C),
                        countColor: const Color(0xFF7F1D1D),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (compliances.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 72, color: Colors.grey[200]),
                          const SizedBox(height: 20),
                          Text(
                            'No compliances found',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...compliances.map((compliance) => ComplianceCard(
                          compliance: compliance,
                          onSubmit: (docs) async {
                            // After submitting compliance
                            final response = await provider.submitCompliance(compliance.id, docs);
                            if (!context.mounted) return;
                            if (response.success) {
                              AlertHelper.snackBarSuccess(context, 'Compliance submitted successfully');
                            } else {
                              AlertHelper.snackBarError(context, response.message ?? 'Submission failed');
                            }
                          },
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
