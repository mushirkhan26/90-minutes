import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/hr_services/provider/performance_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool isMyPerformance = true;


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userData?['role']?.toString().toLowerCase();
    final isManagerOrAdmin = role == 'manager' || role == 'admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Performance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (isManagerOrAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isMyPerformance = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isMyPerformance
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            "My Performance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isMyPerformance ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isMyPerformance = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isMyPerformance
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            "Team Performance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !isMyPerformance ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: isMyPerformance
                ? const MyPerformanceView()
                : const TeamPerformanceView(),
          ),
        ],
      ),
    );
  }
}

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
                  child: ElevatedButton(
                    onPressed: rating.status == 'approved' ? null : () {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      Provider.of<PerformanceProvider>(context, listen: false)
                          .approveReview(rating.reviewId, authProvider.userData?['employeeId'] ?? '');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => UpdateMessageDialog(reviewId: rating.reviewId),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("View/Edit", style: TextStyle(fontWeight: FontWeight.bold)),
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

class UpdateMessageDialog extends StatefulWidget {
  final String reviewId;
  const UpdateMessageDialog({super.key, required this.reviewId});

  @override
  State<UpdateMessageDialog> createState() => _UpdateMessageDialogState();
}

class _UpdateMessageDialogState extends State<UpdateMessageDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final provider = Provider.of<PerformanceProvider>(context, listen: false);
       final rating = provider.myRatings.firstWhere((r) => r.reviewId == widget.reviewId);
       _controller.text = rating.employeeComment ?? "";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerformanceProvider>();
    final rating = provider.myRatings.firstWhere((r) => r.reviewId == widget.reviewId, orElse: () => provider.myRatings.first);

    String formattedDate = "";
    if (rating.employeeResponseAt != null) {
      try {
        DateTime date = DateTime.parse(rating.employeeResponseAt!);
        formattedDate = DateFormat('d/M/yyyy, h:mm:ss a').format(date);
      } catch (e) {
        formattedDate = rating.employeeResponseAt!;
      }
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Message for ${rating.reviewPersonName}",
                      style: const TextStyle(
                        color: Color(0xFF00897B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Rating: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            Icons.star,
                            color: i < rating.rating ? const Color(0xFF00897B) : Colors.grey[300],
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Status: ${rating.status}",
                      style: const TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F9),
                  border: Border.all(color: const Color(0xFFB2DFDB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reviewer's Comment:",
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rating.reviewText,
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  border: Border.all(color: const Color(0xFFD1E3FF)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Previous Message:",
                      style: TextStyle(
                        color: Color(0xFF2962FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(rating.employeeComment ?? ""),
                    if (formattedDate.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Sent on: $formattedDate",
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Update Your Message:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF00897B)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.toggleLike(rating.reviewId, rating.employeeLiked);
                        },
                        icon: Icon(
                          rating.employeeLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: rating.employeeLiked ? Colors.red : Colors.grey,
                        ),
                        label: Text(
                          rating.employeeLiked ? "Liked" : "Like",
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Close", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await provider.updateEmployeeResponse(
                          reviewId: rating.reviewId,
                          comment: _controller.text,
                        );
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Response updated successfully")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Update Message", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamPerformanceView extends StatelessWidget {
  const TeamPerformanceView({super.key});

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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (value) => performanceProvider.setSearchQuery(value),
                          decoration: const InputDecoration(
                            hintText: "Search by name...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => NoReviewDialog(employeeName: rating.employeeName, employeeId: rating.employeeId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("View/Reply", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PerformanceProvider>().fetchReviewsForEmployee(rating.employeeId);
                        context.goToPreviousReviews(rating.employeeName, rating.employeeId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200], 
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Previous Review", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddReviewDialog(employeeName: rating.employeeName, employeeId: rating.employeeId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Add Review", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => TeamReplyDialog(rating: rating),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("View/Reply", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ],
            ),
            if (rating.rating != 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PerformanceProvider>().fetchReviewsForEmployee(rating.employeeId);
                      context.goToPreviousReviews(rating.employeeName, rating.employeeId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Previous Review", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NoReviewDialog extends StatelessWidget {
  final String employeeName;
  final String employeeId;
  const NoReviewDialog({super.key, required this.employeeName, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              "No review found for $employeeName",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AddReviewDialog(employeeName: employeeName, employeeId: employeeId),
                );
              },
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text("Add Review Instead"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const Divider(height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddReviewDialog extends StatefulWidget {
  final String employeeName;
  final String employeeId;
  const AddReviewDialog({super.key, required this.employeeName, required this.employeeId});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                const Text(
                  "Add Performance Review",
                  style: TextStyle(
                    color: Color(0xFF00897B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _selectedRating = index + 1),
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color: index < _selectedRating ? Colors.amber : Colors.grey[400],
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your constructive feedback here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  Provider.of<PerformanceProvider>(context, listen: false).addReview(
                    employeeId: widget.employeeId,
                    employeeName: widget.employeeName,
                    reviewerId: authProvider.userData?['employeeId'] ?? '',
                    reviewerName: authProvider.userData?['username'] ?? '',
                    rating: _selectedRating.toDouble(),
                    comment: _commentController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Submit Review", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamReplyDialog extends StatefulWidget {
  final PerformanceModel rating;
  const TeamReplyDialog({super.key, required this.rating});

  @override
  State<TeamReplyDialog> createState() => _TeamReplyDialogState();
}

class _TeamReplyDialogState extends State<TeamReplyDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.rating.reviewText);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Message for ${widget.rating.employeeName}",
                      style: const TextStyle(
                        color: Color(0xFF2962FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Rating: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            Icons.star,
                            color: i < widget.rating.rating ? Colors.green[700] : Colors.grey[300],
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Status: ${widget.rating.status}",
                      style: TextStyle(color: Colors.orange[800], fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F9),
                  border: Border.all(color: const Color(0xFFB2DFDB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Previous Review:",
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.rating.reviewText,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  border: Border.all(color: const Color(0xFFD1E3FF)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Employee Comment:",
                      style: TextStyle(
                        color: Color(0xFF2962FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.rating.employeeComment ?? "No comment provided by employee.",
                      style: TextStyle(color: widget.rating.employeeComment == null ? Colors.grey : Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "New Message/Reply:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Close"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<PerformanceProvider>(context, listen: false).replyToReview(
                        reviewId: widget.rating.reviewId,
                        reply: _controller.text,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Send Message"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
