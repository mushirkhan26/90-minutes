import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/social_post_model.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/social/provider/social_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SocialPostCard extends StatefulWidget {
  final SocialPostModel post;

  const SocialPostCard({super.key, required this.post});

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  final TextEditingController _commentController = TextEditingController();
  bool _showComments = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final socialProvider = context.read<SocialProvider>();
    final currentUserId = authProvider.userData?['employeeId'] ?? '';
    final isLiked = widget.post.likes.contains(currentUserId);
    final isCreator = widget.post.createdBy == currentUserId;

    // Check user role for permission
    final userRole =
        authProvider.userData?['role']?.toString().toLowerCase() ?? "";
    final bool isManagement = userRole == 'manager' || userRole == 'team lead';
    final bool canDeletePost = isCreator || isManagement;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _getTypeIcon(widget.post.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.post.type == 'birthday')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF26A69A,
                            ).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                const TextSpan(
                                  text: '🎉 ',
                                  style: TextStyle(fontSize: 18),
                                ),
                                TextSpan(
                                  text: '${widget.post.title}: ',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.post.employeeName ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF26A69A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' 🎂',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(widget.post.createdAt.toLocal()),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),

                      // Text(
                      //   "Raw: ${widget.post.createdAt.toString()} \nLocal: ${DateFormat('hh:mm a').format(widget.post.createdAt.toLocal())}",
                      //   style: TextStyle(fontSize: 10, color: Colors.red),
                      // ),


                    ],
                  ),
                ),
                if (canDeletePost)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text(
                              'Are you sure you want to delete this post?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await socialProvider.deletePost(widget.post.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete Post',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Poll UI
          if (widget.post.type == 'poll' && widget.post.question != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.question!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.post.options != null)
                    Builder(
                      builder: (context) {
                        final bool hasAnyVoted = widget.post.options!.any(
                          (opt) => opt.voters?.contains(currentUserId) ?? false,
                        );
                        final int totalVotes = widget.post.options!.fold(
                          0,
                          (sum, item) => sum + item.votes,
                        );

                        return Column(
                          children: widget.post.options!.map((option) {
                            final bool isMyVote =
                                option.voters?.contains(currentUserId) ?? false;
                            final double percentage = totalVotes > 0
                                ? (option.votes / totalVotes)
                                : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: hasAnyVoted
                                    ? null
                                    : () => socialProvider.vote(
                                        widget.post.id,
                                        option.id!,
                                        currentUserId,
                                      ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isMyVote
                                          ? const Color(0xFF26A69A)
                                          : Colors.grey.shade300,
                                    ),
                                    color: isMyVote
                                        ? const Color(
                                            0xFF26A69A,
                                          ).withValues(alpha: 0.05)
                                        : Colors.white,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (totalVotes > 0)
                                        Positioned.fill(
                                          child: LinearProgressIndicator(
                                            value: percentage,
                                            backgroundColor: Colors.transparent,
                                            color: const Color(
                                              0xFF26A69A,
                                            ).withValues(alpha: 0.1),
                                          ),
                                        ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            option.label,
                                            style: TextStyle(
                                              fontWeight: isMyVote
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isMyVote
                                                  ? const Color(0xFF26A69A)
                                                  : Colors.black87,
                                            ),
                                          ),
                                          if (totalVotes > 0)
                                            Text(
                                              '${(percentage * 100).toInt()}%',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),

          // Event Date Display
          if (widget.post.type == 'event' && widget.post.eventDate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'Scheduled for: ${DateFormat('MMM dd, yyyy • hh:mm a').format(widget.post.eventDate!.toLocal())}',

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (widget.post.type != 'poll' &&
              (widget.post.type != 'birthday' ||
                  widget.post.message.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4,
              ),
              child: Text(
                widget.post.message,
                style: const TextStyle(fontSize: 14),
              ),
            ),

          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.zero),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  width: double.infinity,
                  color: Colors.grey.shade50,
                  child: Image.network(
                    widget.post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 14,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.likes.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.comments.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () =>
                      socialProvider.toggleLike(widget.post.id, currentUserId),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Like',
                          style: TextStyle(
                            color: isLiked ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _showComments = !_showComments),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.comment_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Comment',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showComments) ...[
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.post.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.post.comments[index];
                final bool canDeleteComment =
                    comment.userId == currentUserId ||
                    isCreator ||
                    isManagement;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          comment.userName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (canDeleteComment && comment.id != null)
                                    GestureDetector(
                                      onTap: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Comment'),
                                            content: const Text(
                                              'Are you sure you want to delete this comment?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await socialProvider.deleteComment(
                                            comment.id!,
                                          );
                                        }
                                      },
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                comment.comment,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        socialProvider.addComment(
                          widget.post.id,
                          currentUserId,
                          authProvider.userData?['username'] ?? 'User',
                          _commentController.text.trim(),
                        );
                        _commentController.clear();
                      }
                    },
                    icon: const Icon(Icons.send, color: Color(0xFF26A69A)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    IconData iconData;
    Color color;
    switch (type) {
      case 'birthday':
        return Image.network(
          'https://cdn-icons-png.flaticon.com/512/3132/3132693.png',
          height: 32,
          width: 32,
        );
      case 'post':
        iconData = Icons.chat_bubble_outline;
        color = Colors.blue;
        break;
      case 'wellbeing':
        iconData = Icons.health_and_safety_outlined;
        color = Colors.orange;
        break;
      case 'event':
        iconData = Icons.event_available_outlined;
        color = Colors.green;
        break;
      case 'poll':
        iconData = Icons.poll_outlined;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.groups_outlined;
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
