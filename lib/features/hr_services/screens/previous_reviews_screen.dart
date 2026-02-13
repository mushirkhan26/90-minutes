import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_text_styles.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/features/hr_services/provider/performance_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PreviousReviewsScreen extends StatefulWidget {
  final String employeeName;
  final String employeeId;

  const PreviousReviewsScreen({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  State<PreviousReviewsScreen> createState() => _PreviousReviewsScreenState();
}

class _PreviousReviewsScreenState extends State<PreviousReviewsScreen> {
  @override
  void initState() {
    super.initState();
    // API call trigger moved to navigation point or handled by Provider (Millgate pattern)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Previous Ratings: ${widget.employeeName}",
          style: AppTextStyles.black18_600,
        ),
      ),
      body: Consumer<PerformanceProvider>(
        builder: (context, provider, child) {
          if (provider.reviewsState == PerformanceState.loading && provider.selectedEmployeeReviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.selectedEmployeeReviews.isEmpty && provider.reviewsState != PerformanceState.loading) {
            return const Center(
              child: Text("No previous reviews found."),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchReviewsForEmployee(widget.employeeId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: provider.selectedEmployeeReviews.asMap().entries.map((entry) {
                  int idx = entry.key;
                  PerformanceModel review = entry.value;
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ReviewDetailsDialog(review: review),
                      );
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 36) / 2,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "#${idx + 1}",
                                style: AppTextStyles.black16_700,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${review.rating.toInt()}",
                                    style: AppTextStyles.black16_700,
                                  ),
                                  const SizedBox(width: 2),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        Icons.star,
                                        color: i < review.rating
                                            ? const Color(0xFF14B8A6)
                                            : const Color(0xFFD1D5DB),
                                        size: 14,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "From: ${review.reviewPersonName}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Comment:",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            review.reviewText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Status:",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: review.status.toLowerCase() == 'approved'
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              review.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: review.status.toLowerCase() == 'approved'
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF854D0E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReviewDetailsDialog extends StatelessWidget {
  final PerformanceModel review;
  const ReviewDetailsDialog({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    String createdAt = "";
    String updatedAt = "";
    if (review.createdAt != null) {
      try {
        DateTime date = DateTime.parse(review.createdAt!);
        createdAt = DateFormat('M/d/yyyy, h:mm:ss a').format(date);
      } catch (e) {
        createdAt = review.createdAt!;
      }
    }
    if (review.updatedAt != null) {
      try {
        DateTime date = DateTime.parse(review.updatedAt!);
        updatedAt = DateFormat('M/d/yyyy, h:mm:ss a').format(date);
      } catch (e) {
        updatedAt = review.updatedAt!;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Review Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDetailItem("Reviewer", review.reviewPersonName),
                ),
                Expanded(
                  child: _buildDetailItem("Reviewer ID", review.reviewPersonId),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDetailItem("Employee", review.employeeName),
                ),
                Expanded(
                  child: _buildDetailItem("Employee ID", review.employeeId),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Rating",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text("${review.rating.toInt()}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                Icons.star,
                                color: i < review.rating
                                    ? const Color(0xFF14B8A6)
                                    : Colors.grey[300],
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Status",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: review.status.toLowerCase() == 'approved'
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          review.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: review.status.toLowerCase() == 'approved'
                                ? const Color(0xFF166534)
                                : const Color(0xFF854D0E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildDetailItem("Review Comment", review.reviewText),
            const SizedBox(height: 15),
            _buildDetailItem("Employee Response",
                review.employeeComment ?? "No response yet"),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDetailItem("Created At", createdAt),
                ),
                Expanded(
                  child: _buildDetailItem("Last Updated", updatedAt),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Close",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
