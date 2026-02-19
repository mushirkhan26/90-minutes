import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/payroll_documents/provider/payroll_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PayrollDocumentsScreen extends StatelessWidget {
  const PayrollDocumentsScreen({super.key});

  final List<String> years = const ['2024', '2025', '2026'];
  final List<String> months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payroll Documents'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<PayrollProvider>(
        builder: (context, payrollProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee Payslip',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'View and download your payslip',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        payrollProvider.selectedYear,
                        years,
                        (value) => payrollProvider.updateSelection(value!, payrollProvider.selectedMonth),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildDropdown(
                        payrollProvider.selectedMonth,
                        months,
                        (value) => payrollProvider.updateSelection(payrollProvider.selectedYear, value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // For force refresh, we might need a way to trigger it. 
                        // But usually, selection update is enough. 
                        // If we want a dedicated refresh:
                        payrollProvider.fetchPayroll(
                          employeeId: payrollProvider.payrollData?.employeeId ?? '', 
                          year: payrollProvider.selectedYear, 
                          month: payrollProvider.selectedMonth,
                          forceRefresh: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: const Text('VIEW', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                if (payrollProvider.state == PayrollState.loading && payrollProvider.payrollData == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (payrollProvider.state == PayrollState.error && payrollProvider.payrollData == null)
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(payrollProvider.errorMessage ?? 'Error loading payroll'),
                        TextButton(
                          onPressed: () => payrollProvider.fetchPayroll(
                            employeeId: '', // Ideally retrieved internally or passed
                            year: payrollProvider.selectedYear,
                            month: payrollProvider.selectedMonth,
                            forceRefresh: true,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (payrollProvider.payrollData == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No payslip available for the selected period.'),
                        ],
                      ),
                    ),
                  )
                else
                  _buildPayslipCard(context, payrollProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayslipCard(BuildContext context, PayrollProvider provider) {
    final data = provider.payrollData!;
    
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              Image.asset(
                AppConstants.logo,
                height: 40,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 40),
              ),
              const SizedBox(height: 10),
              const Text(
                'Hertzworkz Private Limited',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'PAYSLIP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${provider.selectedMonth} ${provider.selectedYear}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Employee ID',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.employeeId ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Package',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.packageName ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSalaryRow('Basic Salary', '₹${data.basicSalary?.toStringAsFixed(2) ?? '0.00'}'),
              _buildSalaryRow('Allowances', '₹${data.allowances?.toStringAsFixed(2) ?? '0.00'}'),
              _buildSalaryRow('Bonus', '₹${data.bonus?.toStringAsFixed(2) ?? '0.00'}'),
              _buildSalaryRow('Gross Salary', '₹${data.grossSalary?.toStringAsFixed(2) ?? '0.00'}'),
              _buildSalaryRow('Provident Fund', '-₹${data.providentFund?.toStringAsFixed(2) ?? '0.00'}', isNegative: true),
              _buildSalaryRow('Tax', '-₹${data.tax?.toStringAsFixed(2) ?? '0.00'}', isNegative: true),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NET SALARY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '₹${data.netSalary?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (data.lastUpdated != null)
                Text(
                  'Last Updated: ${data.lastUpdated}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _generateAndDownloadPdf(context, provider),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('DOWNLOAD PAYSLIP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSalaryRow(String label, String amount, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
        ],
      ),
    );
  }

  Future<void> _generateAndDownloadPdf(BuildContext context, PayrollProvider provider) async {
    final data = provider.payrollData;
    if (data == null) return;

    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context pwContext) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text('Hertzworkz Private Limited',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Text('PAYSLIP',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Center(
                    child: pw.Text('${provider.selectedMonth} ${provider.selectedYear}',
                        style: const pw.TextStyle(fontSize: 14)),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Employee ID: ${data.employeeId ?? 'N/A'}'),
                      pw.Text('Package: ${data.packageName ?? 'N/A'}'),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Earnings', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  _buildPdfRow('Basic Salary', 'INR ${data.basicSalary?.toStringAsFixed(2)}'),
                  _buildPdfRow('Allowances', 'INR ${data.allowances?.toStringAsFixed(2)}'),
                  _buildPdfRow('Bonus', 'INR ${data.bonus?.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 10),
                  _buildPdfRow('Gross Salary', 'INR ${data.grossSalary?.toStringAsFixed(2)}', isBold: true),
                  pw.SizedBox(height: 20),
                  pw.Text('Deductions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  _buildPdfRow('Provident Fund', 'INR ${data.providentFund?.toStringAsFixed(2)}'),
                  _buildPdfRow('Tax', 'INR ${data.tax?.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  _buildPdfRow('NET SALARY', 'INR ${data.netSalary?.toStringAsFixed(2)}', isBold: true),
                  pw.SizedBox(height: 40),
                  pw.Text('Note: This is a computer generated payslip and does not require a signature.',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Payslip_${provider.selectedMonth}_${provider.selectedYear}.pdf");
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
          pw.Text(value, style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
        ],
      ),
    );
  }
}
