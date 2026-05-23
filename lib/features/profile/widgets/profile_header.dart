import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        color: AppColors.primaryDarkGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My profile',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.lightGreenBadge,
                child: const Text(
                  'RS',
                  style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rahul Sharma',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'rahul.sharma@gmail.com',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      HeaderBadge(label: 'Style Star', icon: Icons.star),
                      SizedBox(width: 8),
                      HeaderBadge(label: 'Member since 2024'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderBadge extends StatelessWidget {
  final String label;
  final IconData? icon;

  const HeaderBadge({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: AppColors.primaryAmber, size: 10),
          if (icon != null) const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
