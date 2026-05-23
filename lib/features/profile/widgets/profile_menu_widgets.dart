import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, left: 4),
        child: Text(
          title,
          style: const TextStyle(color: AppColors.grey707070, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final List<Widget> children;
  const SectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.2)),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black121212)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.grey707070)),
          trailing: trailing ?? const Icon(Icons.chevron_right, size: 18, color: AppColors.greyOutline),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        if (!isLast) Divider(height: 1, indent: 60, endIndent: 12, color: AppColors.greyOutline.withValues(alpha: 0.2)),
      ],
    );
  }
}

class SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const SwitchTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black121212)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.grey707070)),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.successColor,
            activeTrackColor: AppColors.lightGreenBadge,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
        if (!isLast) Divider(height: 1, indent: 60, endIndent: 12, color: AppColors.greyOutline.withValues(alpha: 0.2)),
      ],
    );
  }
}

class CountBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textCol;

  const CountBadge({
    super.key,
    required this.text,
    required this.bg,
    required this.textCol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
