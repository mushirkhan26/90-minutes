import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:intl/intl.dart';

class CommentsSection extends StatelessWidget {
  final TasksProvider provider;
  final String employeeId;
  final String employeeName;
  final String taskId;
  final TextEditingController commentController;

  const CommentsSection({
    super.key,
    required this.provider,
    required this.employeeId,
    required this.employeeName,
    required this.taskId,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.chat_bubble_outline,
          "Comments (${provider.currentComments.length})",
        ),
        const SizedBox(height: 16),
        _buildCommentList(provider, employeeId),
        const SizedBox(height: 24),
        _buildCommentInput(provider, employeeId, employeeName),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF263238)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF263238),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentList(TasksProvider provider, String currentEmployeeId) {
    if (provider.isCommentLoading && provider.currentComments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (provider.currentComments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No comments yet.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.currentComments.length,
      itemBuilder: (context, index) {
        final comment = provider.currentComments[index];
        final List<dynamic> likes = comment['likes'] as List? ?? [];
        final bool isLiked = likes.any((like) {
          if (like is Map) {
            return like['employeeId']?.toString() == currentEmployeeId.toString();
          }
          return like.toString() == currentEmployeeId.toString();
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                child: Text(
                  comment['employeeName']?[0].toUpperCase() ?? "U",
                  style: const TextStyle(
                    color: Color(0xFF673AB7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment['employeeName'] ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment['createdAt'] != null
                              ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(comment['createdAt']))
                              : "Just now",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment['text'] ?? "",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF37474F),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => provider.toggleCommentLike(
                            comment['commentId'] ?? comment['_id'],
                            currentEmployeeId,
                            taskId,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 16,
                                  color: isLiked ? Colors.red : Colors.grey[600],
                                ),
                                if (likes.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    "${likes.length}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            commentController.text = "@${comment['employeeName']} ";
                            commentController.selection = TextSelection.fromPosition(
                              TextPosition(offset: commentController.text.length),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  "Reply",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput(TasksProvider provider, String employeeId, String employeeName) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TextField(
            controller: commentController,
            maxLines: null,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              hintText: "Add a comment...",
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;
                    final data = {
                      "employeeId": employeeId,
                      "employeeName": employeeName,
                      "text": commentController.text.trim(),
                      "itemType": "task",
                      "itemId": taskId,
                      "createdAt": DateTime.now().toIso8601String(),
                    };
                    await provider.addComment(data, taskId);
                    commentController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Comment",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
