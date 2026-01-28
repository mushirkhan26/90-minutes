import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialProvider>().fetchPosts();
    });
  }

  final List<Map<String, dynamic>> _tabs = [
    {'type': 'all', 'icon': Icons.groups_outlined},
    {'type': 'birthday', 'icon': Icons.card_giftcard_outlined},
    {'type': 'post', 'icon': Icons.chat_bubble_outline},
    {'type': 'wellbeing', 'icon': Icons.pie_chart_outline},
    {'type': 'event', 'icon': Icons.calendar_month_outlined},
    {'type': 'poll', 'icon': Icons.favorite_border},
  ];

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Social Hub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CreateSocialPostScreen(),
                );
              },
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF26A69A), size: 18),
              label: const Text('Create Social', style: TextStyle(color: Color(0xFF26A69A), fontSize: 12)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _tabs.map((tab) {
                bool isSelected = socialProvider.selectedType == tab['type'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => socialProvider.setSelectedType(tab['type']),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF26A69A) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        tab['icon'],
                        color: isSelected ? Colors.white : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildBody(socialProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SocialProvider provider) {
    if (provider.state == SocialState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdni.iconscout.com/illustration/premium/thumb/no-data-found-8867280-7265556.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'No social events found.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check back later or try a different tab.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.filteredPosts.length,
      itemBuilder: (context, index) {
        return SocialPostCard(post: provider.filteredPosts[index]);
      },
    );
  }
}
