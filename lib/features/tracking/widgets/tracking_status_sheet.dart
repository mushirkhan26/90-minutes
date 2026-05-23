import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../screens/order_tracking_screen.dart';
import 'tracking_widgets.dart';

class TrackingStatusSheet extends StatelessWidget {
  final DeliveryStage currentStage;

  const TrackingStatusSheet({super.key, required this.currentStage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Main Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getHeadline(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _getSubHeadline(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              LiveBadge(currentStage: currentStage),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Steps
          StepProgressIndicator(currentStage: currentStage),
          const SizedBox(height: 32),

          // Rider Info
          RiderInfoCard(currentStage: currentStage),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(child: SecondaryActionBtn(icon: Icons.receipt_long_outlined, label: "View order")),
              const SizedBox(width: 12),
              Expanded(child: SecondaryActionBtn(icon: Icons.help_outline, label: "Need help?")),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _getHeadline() {
    switch (currentStage) {
      case DeliveryStage.preparing: return "Preparing";
      case DeliveryStage.eightMin: return "8 min";
      case DeliveryStage.oneMin: return "1 min";
      case DeliveryStage.delivered: return "Delivered";
    }
  }

  String _getSubHeadline() {
    switch (currentStage) {
      case DeliveryStage.preparing: return "Order ab pack ho raha hai";
      case DeliveryStage.eightMin: return "Arriving by 11:20 PM";
      case DeliveryStage.oneMin: return "Rider aapke paas hai!";
      case DeliveryStage.delivered: return "Order successfully delivered";
    }
  }
}
