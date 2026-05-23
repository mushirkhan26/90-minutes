import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../screens/order_tracking_screen.dart';
import 'map_painters.dart';

class LiveMapViewer extends StatelessWidget {
  final DeliveryStage currentStage;

  const LiveMapViewer({super.key, required this.currentStage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightGreenBadge, // Light green map background
      child: Stack(
        children: [
          // Simulated Grid/Road lines
          CustomPaint(
            size: Size.infinite,
            painter: MapPainter(),
          ),
          // Route Line (Dashed)
          Center(
            child: CustomPaint(
              size: const Size(300, 200),
              painter: RoutePainter(),
            ),
          ),
          // Store Marker
          const Positioned(
            top: 180,
            right: 120,
            child: Icon(Icons.location_on, size: 40, color: AppColors.primaryDarkGreen),
          ),
          // Rider Marker (Changes position based on stage)
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            bottom: currentStage == DeliveryStage.preparing ? 400 : (currentStage == DeliveryStage.eightMin ? 450 : 250),
            left: currentStage == DeliveryStage.preparing ? 50 : (currentStage == DeliveryStage.eightMin ? 80 : 220),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.primaryDarkGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
