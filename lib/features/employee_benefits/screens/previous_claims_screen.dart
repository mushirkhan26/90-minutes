import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/employee_benefits/provider/benefits_provider.dart';
import 'package:hrtz_hrms/features/employee_benefits/screens/new_claim_screen.dart';
import 'package:hrtz_hrms/core/models/benefits_claim_model.dart';

class PreviousClaimsScreen extends StatelessWidget {
  const PreviousClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BenefitsProvider>();
    final claims = provider.myClaims;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Previous Claims",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [

          // Proceed to Claim button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewClaimScreen(
                        benefitName: "REIMBURSEMENT",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Proceed to Claim",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: claims.length,
              itemBuilder: (context, index) {
                final claim = claims[index];

                final isApproved =
                    claim.claimStatus.toLowerCase() == "approved";

                final borderColor =
                    isApproved ? Colors.green : Colors.orange;

                final statusColor =
                    isApproved ? Colors.green : Colors.orange;

                return Container(
  margin: const EdgeInsets.only(bottom: 18),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: borderColor,
      width: 1.2, // thinner like web
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // Benefit Name 
      Text(
        claim.benefitName,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(height: 10),

      // 🔹 Insurance ID
      Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Insurance ID: ",
      style: TextStyle(fontWeight: FontWeight.w500),
    ),
    Expanded(
      child: Text(
        claim.insuranceId?.isNotEmpty == true
            ? claim.insuranceId!
            : "-",
      ),
    ),
  ],
),

      const SizedBox(height: 6),

      Text("Claim ID: ${claim.id}"),
      const SizedBox(height: 6),

      Text("Beneficiary: ${claim.beneficiaryName}"),
      const SizedBox(height: 6),

      Text("Claim Amount: ${claim.claimAmount}"),

      const SizedBox(height: 6),

      // 🔹 Status
      Text(
        "Status: ${claim.claimStatus}",
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(height: 14),

      // 🔹 Track Button
      Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          height: 34,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              _showClaimDetailsDialog(context, claim);
            },
            child: const Text(
              "Track Claim",

              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
              },
            ),
          ),
        ],
      ),
    );
  }
  void _showClaimDetailsDialog(BuildContext context, BenefitsClaimModel claim) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Claim Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.red),
                    )
                  ],
                ),

                const SizedBox(height: 16),

                /// LEFT COLUMN DETAILS
                _buildRow("Insurance ID", claim.insuranceId),
                _buildRow("Beneficiary", claim.beneficiaryName),
                _buildRow("Claim Amount", "₹${claim.claimAmount}"),
                _buildRow("Hospital Name", claim.hospitalName),
                _buildRow("Discharge Date", claim.dischargeDate),

                const SizedBox(height: 10),

                ///  REQUIRED NEW ORDER
                _buildRow("Claim ID", claim.id),
                _buildRow("Relation", claim.relationWithEmployee),
                _buildRow("Bill Amount", "₹${claim.billAmount}"),
                _buildRow("Admission Date", claim.admissionDate),
                _buildRow("Email", claim.email),

                const SizedBox(height: 6),

                Text(
                  "Status: ${claim.claimStatus}",
                  style: TextStyle(
                    color: claim.claimStatus.toLowerCase() == "approved"
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ///  VISIT HOSPITAL BILL CLICK
                if (claim.receipt != null && claim.receipt!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: InteractiveViewer(
                            child: Image.network(
                              claim.receipt!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Visit Hospital Bill",
                      style: TextStyle(
                        color: Colors.teal,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                /// BANK DETAILS SECTION
                const Text(
                  "Bank Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(
                          "Bank Name", claim.bankDetails.first.bankName),
                      _buildRow("Account Holder",
                          claim.bankDetails.first.accountHolderName),
                      _buildRow("Account Number",
                          claim.bankDetails.first.accountNumber),
                      _buildRow(
                          "IFSC Code", claim.bankDetails.first.ifscCode),
                      _buildRow(
                          "Account Type", claim.bankDetails.first.accountType),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
Widget _buildRow(String title, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value == null || value.isEmpty ? "-" : value),
        ),
      ],
    ),
  );
}
}