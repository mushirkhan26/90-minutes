import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/features/hr_services/provider/performance_provider.dart';
import 'package:hrtz_hrms/features/hr_services/widgets/performance_dialogs.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

class TeamPerformanceView extends StatefulWidget {
  const TeamPerformanceView({super.key});

  @override
  State<TeamPerformanceView> createState() => _TeamPerformanceViewState();
}

class _TeamPerformanceViewState extends State<TeamPerformanceView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final performanceProvider = Provider.of<PerformanceProvider>(context);

    if (performanceProvider.teamState == PerformanceState.loading && performanceProvider.allRatings.isEmpty) {
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Team Performance\nRating",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        enable: true,
                        controller: _searchController,
                        hintText: "Search by name...",
                        onChanged: (value) => performanceProvider.setSearchQuery(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Tooltip(
                        message: "Filter performance ratings",
                        child: Semantics(
                          label: "Filter Ratings Dropdown",
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: performanceProvider.teamFilterType,
                              isDense: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  performanceProvider.setTeamFilter(newValue);
                                }
                              },
                              items: <String>[
                                'All Ratings',
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (performanceProvider.allRatings.isEmpty)
             const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text("No team performance ratings found.")),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: performanceProvider.allRatings.length,
              itemBuilder: (context, index) {
                final rating = performanceProvider.allRatings[index];
                return TeamRatingCard(rating: rating, index: index + 1);
              },
            ),
        ],
      ),
    );
  }
}

class TeamRatingCard extends StatelessWidget {
  final PerformanceModel rating;
  final int index;

  const TeamRatingCard({super.key, required this.rating, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "S. No.: $index",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text("Name: ${rating.employeeName}"),
            Text("Employee ID: ${rating.employeeId}"),
            const Text("Role: Employee"), // Static for now as API doesn't provide
            const Text("Department: IT"), // Static for now as API doesn't provide
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Rating: "),
                if (rating.rating == 0)
                  const Text("N/A (0.0)")
                else ...[
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        Icons.star,
                        color: i < rating.rating.floor() ? Colors.amber : Colors.grey[300],
                        size: 16,
                      );
                    }),
                  ),
                  Text(" (${rating.rating})"),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (rating.rating == 0) ...[
                  Expanded(
                    child: CustomButton(
                      text: "View/Reply",
                      fontSize: 11,
                      height: 35,
                      borderRadius: 8,
                      backgroundColor: Colors.blue,
                      borderColor: Colors.blue,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => NoReviewDialog(employeeName: rating.employeeName, employeeId: rating.employeeId),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: CustomButton(
                      text: "Previous Review",
                      fontSize: 11,
                      height: 35,
                      borderRadius: 8,
                      backgroundColor: Colors.grey[200],
                      borderColor: Colors.grey[200],
                      textColor: Colors.black,
                      onPressed: () {
                        context.read<PerformanceProvider>().fetchReviewsForEmployee(rating.employeeId);
                        context.goToPreviousReviews(rating.employeeName, rating.employeeId);
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: CustomButton(
                      text: "Add Review",
                      fontSize: 11,
                      height: 35,
                      borderRadius: 8,
                      backgroundColor: const Color(0xFF00897B),
                      borderColor: const Color(0xFF00897B),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddReviewDialog(employeeName: rating.employeeName, employeeId: rating.employeeId),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: CustomButton(
                      text: "View/Reply",
                      fontSize: 11,
                      height: 35,
                      borderRadius: 8,
                      backgroundColor: Colors.blue,
                      borderColor: Colors.blue,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => TeamReplyDialog(rating: rating),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            if (rating.rating != 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CustomButton(
                  text: "Previous Review",
                  height: 45,
                  borderRadius: 8,
                  backgroundColor: Colors.grey[200],
                  borderColor: Colors.grey[200],
                  textColor: Colors.black,
                  onPressed: () {
                    context.read<PerformanceProvider>().fetchReviewsForEmployee(rating.employeeId);
                    context.goToPreviousReviews(rating.employeeName, rating.employeeId);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
