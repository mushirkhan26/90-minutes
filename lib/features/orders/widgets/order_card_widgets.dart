import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class BaseOrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final int itemsCount;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final Widget child;

  const BaseOrderCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.itemsCount,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('$date • $itemsCount items',
                      style: const TextStyle(color: AppColors.grey707070, fontSize: 10)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(status,
                        style: TextStyle(
                            color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.dividerColor),
          child,
        ],
      ),
    );
  }
}

class OrderActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const OrderActionButton({
    super.key,
    required this.label,
    required this.isPrimary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isPrimary ? AppColors.primaryDarkGreen : AppColors.greyOutline),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : AppColors.black121212,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class ItemThumbnails extends StatelessWidget {
  final List<String> colors;
  final String? extra;

  const ItemThumbnails({super.key, required this.colors, this.extra});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...colors.map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _itemThumbnail(c),
            )),
        if (extra != null)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.3)),
            ),
            child: Center(
                child:
                    Text(extra!, style: const TextStyle(fontSize: 12, color: AppColors.grey707070))),
          ),
      ],
    );
  }

  Widget _itemThumbnail(String colorHex) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(int.parse(colorHex.replaceFirst('#', '0xFF'))),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
    );
  }
}
extension ColorExtension on Color {
  String toHexString() {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
