import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../widgets/live_map_viewer.dart';
import '../widgets/tracking_status_sheet.dart';

enum DeliveryStage { preparing, eightMin, oneMin, delivered }

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, this.orderId = "#FD29847"});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  DeliveryStage _currentStage = DeliveryStage.eightMin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Map Background (Simulated)
          LiveMapViewer(currentStage: _currentStage),

          // 2. Top Navigation & State Toggles (For Testing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 10),
                  _buildStateToggles(),
                ],
              ),
            ),
          ),

          // 3. Status Badge on Map
          Positioned(
            top: 140,
            left: 20,
            child: _buildMapStatusBadge(),
          ),

          // 4. Bottom Draggable Status Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: TrackingStatusSheet(currentStage: _currentStage),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.bottomNavIconColor),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.bottomNavIconColor),
            onPressed: () {},
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.bottomNavIconColor),
            onPressed: () {},
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStateToggles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text("Dev State:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _stateBtn("Packed", DeliveryStage.preparing),
          _stateBtn("8 min", DeliveryStage.eightMin),
          _stateBtn("1 min", DeliveryStage.oneMin),
          _stateBtn("Done", DeliveryStage.delivered),
        ],
      ),
    );
  }

  Widget _stateBtn(String label, DeliveryStage stage) {
    bool isSelected = _currentStage == stage;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _currentStage = stage),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildMapStatusBadge() {
    String text = "Preparing...";
    if (_currentStage == DeliveryStage.eightMin) text = "8 min away";
    if (_currentStage == DeliveryStage.oneMin) text = "Almost here!";
    if (_currentStage == DeliveryStage.delivered) text = "Delivered";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 14),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
