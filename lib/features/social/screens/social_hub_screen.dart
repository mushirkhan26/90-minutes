import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/social/provider/social_provider.dart';
import 'package:hrtz_hrms/features/social/widgets/social_post_card.dart';
import 'package:hrtz_hrms/features/social/screens/create_social_post_screen.dart';
import 'package:provider/provider.dart';

class SocialHubScreen extends StatefulWidget {
  const SocialHubScreen({super.key});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> {

  final List<Map<String, dynamic>> _tabs = [
    {'type': 'all', 'label': 'All', 'icon': Icons.groups_outlined},
    {'type': 'birthday', 'label': 'Birthday', 'icon': Icons.card_giftcard_outlined},
    {'type': 'post', 'label': 'Post', 'icon': Icons.chat_bubble_outline},
    {'type': 'wellbeing', 'label': 'Well Being', 'icon': Icons.health_and_safety_outlined},
    {'type': 'event', 'label': 'Event', 'icon': Icons.calendar_month_outlined},
    {'type': 'poll', 'label': 'Poll', 'icon': Icons.poll_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Social Hub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CreateSocialPostScreen(),
                );
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
              label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _tabs.map((tab) {
                  bool isSelected = socialProvider.selectedType == tab['type'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () => socialProvider.setSelectedType(tab['type']),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF26A69A) : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              boxShadow: isSelected 
                                ? [BoxShadow(color: const Color(0xFF26A69A).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                : [],
                            ),
                            child: Icon(
                              tab['icon'],
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tab['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF26A69A) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(socialProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SocialProvider provider) {
    if (provider.state == SocialState.loading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
    }

    final filteredPosts = provider.filteredPosts;

    if (filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No ${provider.selectedType == 'all' ? '' : provider.selectedType} posts yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchPosts(showLoader: false),
      color: const Color(0xFF26A69A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: filteredPosts.length,
        itemBuilder: (context, index) {
          return SocialPostCard(post: filteredPosts[index]);
        },
      ),
    );
  }
}
