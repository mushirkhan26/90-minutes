import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/features/employee_benefits/screens/previous_claims_screen.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/shared/shimmer_tile.dart';
import 'package:hrtz_hrms/features/employee_benefits/screens/new_claim_screen.dart';

class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({Key? key}) : super(key: key);

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final employee = authProvider.profileData;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ✅ AppBar (Title Only)
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "BENEFITS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      body: Column(
        children: [

          // ✅ Search Bar Below AppBar
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search benefits",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ✅ Content Area
          Expanded(
            child: Builder(
              builder: (_) {

                // 🔄 Loading → Shimmer
                if (authProvider.isFetchingProfile) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ShimmerTile(),
                    ),
                  );
                }

                

if (employee == null) {
  return const Center(
    child: Text("Profile not loaded"),
  );
}
                final benefits = employee.benefit;

                final filteredBenefits = benefits.where((b) {
                  return b.benefitName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredBenefits.isEmpty) {
                  return const Center(
                    child: Text(
                      "No benefits available",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBenefits.length,
                  itemBuilder: (context, index) {
                    final benefit = filteredBenefits[index];
                    return _benefitCard(benefit);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitCard(EmployeeBenefit benefit) {
  return GestureDetector(
    onTap: () => _showBenefitDialog(context, benefit),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit.benefitName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showBenefitDialog(BuildContext context, EmployeeBenefit benefit) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 🔹 Dynamic Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      benefit.benefitName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.visibility),
                  label: const Text("View Previous Claims"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PreviousClaimsScreen() ),
                      );
                  },
                ),
              ),

              const SizedBox(height: 12),

              /// ✅ Apply For New Claim Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white, // 👈 TEXT WHITE
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Apply For New Claim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewClaimScreen(benefitName: benefit.benefitName),
                      )
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}