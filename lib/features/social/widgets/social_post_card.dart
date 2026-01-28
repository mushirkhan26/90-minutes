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
                      Text(
                        widget.post.type == 'birthday' 
                            ? '${widget.post.title} ${widget.post.employeeName ?? ''}' 
                            : widget.post.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(widget.post.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                if (isCreator)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text('Are you sure you want to delete this post?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                      const PopupMenuItem(value: 'delete', child: Text('Delete Post', style: TextStyle(color: Colors.red))),
                    ],
                  ),
              ],
            ),
          ),
          if (widget.post.type != 'birthday' || widget.post.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: Text(widget.post.message, style: const TextStyle(fontSize: 14)),
            ),
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ClipRRect(
                child: Image.network(
                  widget.post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.favorite, size: 14, color: isLiked ? Colors.red : Colors.grey),
                const SizedBox(width: 4),
                Text('${widget.post.likes.length}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${widget.post.comments.length}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => socialProvider.toggleLike(widget.post.id, currentUserId),
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
                        Text('Like', style: TextStyle(color: isLiked ? Colors.red : Colors.grey, fontWeight: FontWeight.w500)),
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
                        const Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        const Text('Comment', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.teal.shade100,
                        child: Text(comment.userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 10)),
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
                              Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(comment.comment, style: const TextStyle(fontSize: 13)),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        return Image.network('https://cdn-icons-png.flaticon.com/512/3132/3132693.png', height: 32, width: 32);
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
