import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/hr_services/provider/performance_provider.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
                  CustomButton(
                    text: "Update Message",
                    onPressed: () async {
                      final success = await provider.updateEmployeeResponse(
                        reviewId: rating.reviewId,
                        comment: _controller.text,
                      );
                      if (!context.mounted) return;
                      if (success) {
                        Navigator.pop(context);
                        AlertHelper.snackBarSuccess(context, "Response updated successfully");
                      } else {
                        AlertHelper.snackBarError(context, "Failed to update response");
                      }
                    },
                    backgroundColor: const Color(0xFF14B8A6),
                    borderColor: const Color(0xFF14B8A6),
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
            CustomButton(
              text: "Add Review Instead",
              icon: Icons.edit_note,
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AddReviewDialog(employeeName: employeeName, employeeId: employeeId),
                );
              },
              backgroundColor: const Color(0xFF00897B),
              borderColor: const Color(0xFF00897B),
              width: 200,
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
            CustomButton(
              text: "Submit Review",
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await Provider.of<PerformanceProvider>(context, listen: false).addReview(
                  employeeId: widget.employeeId,
                  employeeName: widget.employeeName,
                  reviewerId: authProvider.userData?['employeeId'] ?? '',
                  reviewerName: authProvider.userData?['username'] ?? '',
                  rating: _selectedRating.toDouble(),
                  comment: _commentController.text,
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  AlertHelper.snackBarSuccess(context, "Review added successfully");
                }
              },
              backgroundColor: const Color(0xFF00897B),
              borderColor: const Color(0xFF00897B),
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
                  CustomButton(
                    text: "Send Message",
                    width: 150,
                    onPressed: () async {
                      final success = await Provider.of<PerformanceProvider>(context, listen: false).replyToReview(
                        reviewId: widget.rating.reviewId,
                        reply: _controller.text,
                      );
                      if (success && context.mounted) {
                        Navigator.pop(context);
                        AlertHelper.snackBarSuccess(context, "Reply sent successfully");
                      }
                    },
                    backgroundColor: const Color(0xFF2962FF),
                    borderColor: const Color(0xFF2962FF),
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
