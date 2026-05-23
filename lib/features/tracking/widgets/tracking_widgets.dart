import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../screens/order_tracking_screen.dart';

class LiveBadge extends StatelessWidget {
  final DeliveryStage currentStage;
  const LiveBadge({super.key, required this.currentStage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBadge,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryDarkGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            currentStage == DeliveryStage.delivered ? "Done" : "Live",
            style: const TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final DeliveryStage currentStage;
  const StepProgressIndicator({super.key, required this.currentStage});

  @override
  Widget build(BuildContext context) {
    int activeStep = 0;
    if (currentStage == DeliveryStage.preparing) activeStep = 1;
    if (currentStage == DeliveryStage.eightMin || currentStage == DeliveryStage.oneMin) activeStep = 2;
    if (currentStage == DeliveryStage.delivered) activeStep = 3;

    return Column(
      children: [
        Row(
          children: [
            _stepCircle(true, true),
            _stepLine(activeStep >= 1),
            _stepCircle(activeStep >= 1, activeStep >= 1, "2"),
            _stepLine(activeStep >= 2),
            _stepCircle(activeStep >= 2, activeStep >= 2),
            _stepLine(activeStep >= 3),
            _stepCircle(activeStep >= 3, activeStep >= 3, "4"),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Order\nplaced", style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text("Packed", style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text("On\nthe\nway", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text("Delivered", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _stepCircle(bool isReached, bool isFilled, [String? label]) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primaryDarkGreen : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isReached ? AppColors.primaryDarkGreen : Colors.grey.shade300),
      ),
      child: Center(
        child: label != null
            ? Text(label, style: TextStyle(color: isFilled ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))
            : Icon(Icons.check, size: 14, color: isFilled ? Colors.white : Colors.transparent),
      ),
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primaryDarkGreen : Colors.grey.shade300,
      ),
    );
  }
}

class RiderInfoCard extends StatelessWidget {
  final DeliveryStage currentStage;
  const RiderInfoCard({super.key, required this.currentStage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.shade50,
            child: const Text("RS", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ramesh Singh", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _getRiderStatus(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          _iconBtn(Icons.message_outlined),
          const SizedBox(width: 8),
          _iconBtn(Icons.call_outlined),
        ],
      ),
    );
  }

  String _getRiderStatus() {
    switch (currentStage) {
      case DeliveryStage.preparing: return "Rider assign ho raha hai...";
      case DeliveryStage.eightMin: return "750 m away • Hero Splendor • RJ14";
      case DeliveryStage.oneMin: return "Aapke gate par hai";
      case DeliveryStage.delivered: return "Delivery complete";
    }
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 18, color: Colors.black),
    );
  }
}

class SecondaryActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const SecondaryActionBtn({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
