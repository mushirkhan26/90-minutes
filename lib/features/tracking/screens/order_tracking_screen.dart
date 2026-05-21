import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, this.orderId = "#90MIN-1234"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Delivery',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '15 - 20 Minutes',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Icon(Icons.timer_outlined, size: 40, color: AppColors.primary),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order ID: $orderId', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const Text('90-Min Express', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Delivery Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Tracking Timeline
            _buildTimelineStep(
              icon: Icons.receipt_long_outlined,
              title: 'Order Confirmed',
              subtitle: 'We have received your order',
              isCompleted: true,
              isLast: false,
            ),
            _buildTimelineStep(
              icon: Icons.inventory_2_outlined,
              title: 'Order Packed',
              subtitle: 'Seller has packed your items',
              isCompleted: true,
              isLast: false,
            ),
            _buildTimelineStep(
              icon: Icons.delivery_dining_outlined,
              title: 'Out for Delivery',
              subtitle: 'Our delivery partner is on the way',
              isCompleted: true,
              isLast: false,
              isActive: true,
            ),
            _buildTimelineStep(
              icon: Icons.home_outlined,
              title: 'Delivered',
              subtitle: 'Enjoy your 90-min delivery!',
              isCompleted: false,
              isLast: true,
            ),
            
            const SizedBox(height: 32),
            
            // Delivery Partner Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rahul Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Your delivery partner', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.message_outlined, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
    bool isActive = false,
  }) {
    final color = isCompleted ? AppColors.primary : Colors.grey[300];
    
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : Colors.white,
                  border: Border.all(color: color!),
                  shape: BoxShape.circle,
                  boxShadow: isActive 
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)] 
                    : null,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isCompleted ? Colors.white : Colors.grey[400],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
