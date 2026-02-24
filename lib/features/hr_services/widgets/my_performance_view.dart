import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/hr_services/provider/performance_provider.dart';
import 'package:hrtz_hrms/features/hr_services/widgets/performance_dialogs.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class MyPerformanceView extends StatelessWidget {
  const MyPerformanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final performanceProvider = Provider.of<PerformanceProvider>(context);

    if (performanceProvider.myState == PerformanceState.loading && performanceProvider.myRatings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF004D40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Performance Ratings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: performanceProvider.myFilterType,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            performanceProvider.setMyFilter(newValue);
                          }
                        },
                        items: <String>[
                          'Default (Recent)',
                          'Highest to Lowest',
                          'Lowest to Highest',
                          '5 Stars',
                          '4 Stars',
                          '3 Stars',
                          '2 Stars',
                          '1 Star'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Colors.black, fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (performanceProvider.myRatings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text("No performance ratings found.")),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: performanceProvider.myRatings.length,
              itemBuilder: (context, index) {
                final rating = performanceProvider.myRatings[index];
                return MyRatingCard(rating: rating, index: index + 1);
              },
            ),
        ],
      ),
    );
  }
}

class MyRatingCard extends StatelessWidget {
  final PerformanceModel rating;
  final int index;

  const MyRatingCard({super.key, required this.rating, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#$index",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star,
                      color: i < rating.rating ? Colors.amber : Colors.grey[300],
                      size: 24,
                    );
                  }),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(text: "Reviewer: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: rating.reviewPersonName),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(text: "Reviewer ID: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: rating.reviewPersonId),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Comment:",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              rating.reviewText,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: rating.status == 'approved'
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rating.status,
                    style: TextStyle(
                      color: rating.status == 'approved' ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    context.read<PerformanceProvider>().toggleLike(rating.reviewId, rating.employeeLiked);
                  },
                  icon: Icon(
                    rating.employeeLiked ? Icons.favorite : Icons.favorite_border,
                    color: rating.employeeLiked ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Approve",
                    onPressed: rating.status == 'approved' ? null : () {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      Provider.of<PerformanceProvider>(context, listen: false)
                          .approveReview(rating.reviewId, authProvider.userData?['employeeId'] ?? '');
                    },
                    backgroundColor: Colors.grey[200],
                    borderColor: Colors.grey[200],
                    textColor: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: "View/Edit",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => UpdateMessageDialog(reviewId: rating.reviewId),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    borderColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
