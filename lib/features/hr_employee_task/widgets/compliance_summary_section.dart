import 'package:flutter/material.dart';
import '../providers/compliance_provider.dart';
import 'summary_card.dart';

class ComplianceSummarySection extends StatelessWidget {
  final ComplianceProvider provider;

  const ComplianceSummarySection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                borderColor: const Color(0xFFE2E8F0),
                titleColor: const Color(0xFF475569),
                countColor: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryCard(
                title: 'Action\nRequired',
                count: provider.actionRequiredCount,
                backgroundColor: const Color(0xFFFFFBEB),
                borderColor: const Color(0xFFFEF3C7),
                titleColor: const Color(0xFFB45309),
                countColor: const Color(0xFF78350F),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryCard(
                title: 'Completed',
                count: provider.completedCount,
                backgroundColor: const Color(0xFFF0FDF4),
                borderColor: const Color(0xFFDCFCE7),
                titleColor: const Color(0xFF15803D),
                countColor: const Color(0xFF064E3B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryCard(
                title: 'Overdue',
                count: provider.overdueCount,
                backgroundColor: const Color(0xFFFEF2F2),
                borderColor: const Color(0xFFFEE2E2),
                titleColor: const Color(0xFFB91C1C),
                countColor: const Color(0xFF7F1D1D),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
