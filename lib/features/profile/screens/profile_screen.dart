import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/navigation/app_routes.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_summary_cards.dart';
import '../widgets/profile_referral_banner.dart';
import '../widgets/profile_menu_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _locationAccess = true;
  bool _aiStylist = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.exploreBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            const ProfileSummaryCards(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const ProfileReferralBanner(),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'MY ACTIVITY'),
                  _buildActivitySection(),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'ACCOUNT'),
                  _buildAccountSection(),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'PREFERENCES'),
                  _buildPreferencesSection(),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'SUPPORT'),
                  _buildSupportSection(),
                  const SizedBox(height: 32),
                  const Text(
                    '90-Minutes v1.0.0 • Made with love in Jodhpur',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return SectionCard(children: [
      ProfileTile(
        icon: Icons.receipt_long_outlined,
        iconBg: AppColors.lightGreenBadge,
        iconColor: AppColors.primaryDarkGreen,
        title: 'My orders',
        subtitle: '12 orders · 2 active',
        trailing: const CountBadge(text: '2 active', bg: AppColors.categoryLocalBg, textCol: AppColors.categoryLocalText),
        onTap: () => context.push(AppRoutes.ordersRoute),
      ),
      ProfileTile(
        icon: Icons.favorite_border,
        iconBg: AppColors.categoryWomenBg,
        iconColor: AppColors.categoryWomenText,
        title: 'Wishlist',
        subtitle: '8 items saved',
        trailing: const CountBadge(text: '8', bg: AppColors.categoryWomenBg, textCol: AppColors.categoryWomenText),
        onTap: () => context.push(AppRoutes.wishlistRoute),
      ),
      ProfileTile(
        icon: Icons.star_outline,
        iconBg: AppColors.categoryBridalBg,
        iconColor: AppColors.categoryBridalText,
        title: 'My reviews',
        subtitle: '4 reviews diye',
        onTap: () {},
      ),
      ProfileTile(
        icon: Icons.confirmation_number_outlined,
        iconBg: AppColors.categoryMenBg,
        iconColor: AppColors.categoryMenText,
        title: 'Coupons & offers',
        subtitle: '3 coupons available',
        trailing: const CountBadge(text: '3 new', bg: AppColors.lightGreenBadge, textCol: AppColors.successColor),
        onTap: () {},
        isLast: true,
      ),
    ]);
  }

  Widget _buildAccountSection() {
    return SectionCard(children: [
      ProfileTile(
        icon: Icons.location_on_outlined,
        iconBg: AppColors.categoryLocalBg,
        iconColor: AppColors.categoryLocalText,
        title: 'Saved addresses',
        subtitle: 'Home, Office',
        onTap: () {},
      ),
      ProfileTile(
        icon: Icons.payment_outlined,
        iconBg: const Color(0xFFF3E5F5),
        iconColor: Colors.deepPurple,
        title: 'Payment methods',
        subtitle: 'GPay, HDFC Card',
        onTap: () {},
      ),
      ProfileTile(
        icon: Icons.person_outline,
        iconBg: AppColors.gray50,
        iconColor: AppColors.grey707070,
        title: 'Personal details',
        subtitle: 'Name, phone, email',
        onTap: () {},
        isLast: true,
      ),
    ]);
  }

  Widget _buildPreferencesSection() {
    return SectionCard(children: [
      SwitchTile(
        icon: Icons.notifications_none,
        iconBg: AppColors.categoryBridalBg,
        iconColor: AppColors.categoryBridalText,
        title: 'Notifications',
        subtitle: 'Order updates, offers',
        value: _notificationsEnabled,
        onChanged: (v) => setState(() => _notificationsEnabled = v),
      ),
      SwitchTile(
        icon: Icons.location_on_outlined,
        iconBg: AppColors.lightGreenBadge,
        iconColor: AppColors.primaryDarkGreen,
        title: 'Location access',
        subtitle: 'Fast delivery detection',
        value: _locationAccess,
        onChanged: (v) => setState(() => _locationAccess = v),
      ),
      SwitchTile(
        icon: Icons.auto_awesome_outlined,
        iconBg: const Color(0xFFE8EAF6),
        iconColor: Colors.indigo,
        title: 'AI stylist suggestions',
        subtitle: 'Personalized recommendations',
        value: _aiStylist,
        onChanged: (v) => setState(() => _aiStylist = v),
      ),
      SwitchTile(
        icon: Icons.dark_mode_outlined,
        iconBg: AppColors.gray50,
        iconColor: AppColors.black121212,
        title: 'Dark mode',
        subtitle: 'App theme',
        value: _darkMode,
        onChanged: (v) => setState(() => _darkMode = v),
        isLast: true,
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return SectionCard(children: [
      ProfileTile(
        icon: Icons.headset_mic_outlined,
        iconBg: AppColors.lightGreenBadge,
        iconColor: AppColors.primaryDarkGreen,
        title: 'Help & support',
        subtitle: 'Chat, call, FAQ',
        onTap: () {},
      ),
      ProfileTile(
        icon: Icons.description_outlined,
        iconBg: AppColors.gray50,
        iconColor: AppColors.grey707070,
        title: 'Terms & privacy',
        subtitle: 'Policies aur conditions',
        onTap: () {},
      ),
      ProfileTile(
        icon: Icons.logout,
        iconBg: const Color(0xFFFFEBEE),
        iconColor: AppColors.errorRed,
        title: 'Log out',
        subtitle: 'rahul.sharma@gmail.com',
        onTap: () {},
        isLast: true,
      ),
    ]);
  }
}
