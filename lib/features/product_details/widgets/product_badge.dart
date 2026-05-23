import 'package:flutter/material.dart';

class ProductBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const ProductBadge({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: textColor, size: 12),
          if (icon != null) const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
