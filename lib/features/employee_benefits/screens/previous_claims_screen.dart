import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/employee_benefits/provider/benefits_provider.dart';
import 'package:hrtz_hrms/features/employee_benefits/screens/new_claim_screen.dart';

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
                      builder: (_) =>
                          const NewClaimScreen(benefitName: "REIMBURSEMENT"),
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
                final status = claim.claimStatus.toLowerCase();
                final borderColor = status == "approved"
                    ? Colors.green
                    : status == "rejected"
                    ? Colors.red
                    : Colors.orange;

                final statusColor = status == "approved"
                    ? Colors.green
                    : status == "rejected"
                    ? Colors.red
                    : Colors.orange;

                // final isApproved =
                //     claim.claimStatus.toLowerCase() == "approved";

                // final borderColor =
                //     isApproved ? Colors.green : Colors.orange;

                // final statusColor =
                //     isApproved ? Colors.green : Colors.orange;

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
                      const Text(
                        "Insurance ID:",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(claim.insuranceId ?? "-"),

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
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              // Track screen
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
}
