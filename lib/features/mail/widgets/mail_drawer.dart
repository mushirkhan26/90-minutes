import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';

class MailDrawer extends StatelessWidget {
  final String selectedFolder;
  final ValueChanged<String> onFolderSelected;

  const MailDrawer({super.key, required this.selectedFolder, required this.onFolderSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary2),
            child: Text(
              'Mail',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // 📥 Inbox
          _buildDrawerItem(
            icon: Icons.inbox_rounded,
            label: 'Inbox',
            selected: selectedFolder == 'Inbox',
            onTap: () => onFolderSelected('Inbox'),
          ),
          // 📤 Sent
          _buildDrawerItem(
            icon: Icons.send_rounded,
            label: 'Sent',
            selected: selectedFolder == 'Sent',
            onTap: () => onFolderSelected('Sent'),
          ),
          // ⭐ Starred
          _buildDrawerItem(
            icon: Icons.star_rounded,
            label: 'Starred',
            selected: selectedFolder == 'Starred',
            onTap: () => onFolderSelected('Starred'),
          ),
          // 🗑️ Trash
          _buildDrawerItem(
            icon: Icons.delete_rounded,
            label: 'Trash',
            selected: selectedFolder == 'Trash',
            onTap: () => onFolderSelected('Trash'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : Colors.black54),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? AppColors.primary : Colors.black87,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}
