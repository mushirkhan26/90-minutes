import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/navigation/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../widgets/order_summary_cards.dart';
import '../widgets/order_filter_tabs.dart';
import '../widgets/order_card_widgets.dart';
import '../widgets/order_empty_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.exploreBackground,
      appBar: AppBar(
        title: const Text('My orders',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const OrderFilterTabs(),
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Abhi ke liye true rakha hai empty screen dikhane ke liye
    // Isse false karke aap purani orders list dekh sakte hain
    bool isEmpty = false;

    if (isEmpty) {
      return const OrderEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const OrderSummaryCards(),
        const SizedBox(height: 16),
        _buildActiveOrderCard(context),
        const SizedBox(height: 16),
        _buildDeliveredOrderCard(context),
        const SizedBox(height: 16),
        _buildReturnInitiatedCard(context),
        const SizedBox(height: 16),
        _buildCancelledOrderCard(context),
      ],
    );
  }

  Widget _buildActiveOrderCard(BuildContext context) {
    return BaseOrderCard(
      orderId: '#FD29847',
      date: 'Today, 11:12 AM',
      itemsCount: 4,
      status: 'On the way',
      statusColor: AppColors.infoColor,
      statusBg: AppColors.infoColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightGreenBadge,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: AppColors.primaryDarkGreen),
                SizedBox(width: 8),
                Text('Arriving in 8 minutes',
                    style: TextStyle(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                Spacer(),
                Text('by 12:42 PM', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              ItemThumbnails(colors: ['#E8F5E9', '#FCE4EC'], extra: '+2'),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kurta Set + 3 more', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Manyavar, Biba, Jodhpur Couture',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('₹9,096', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OrderActionButton(
                    label: 'Track order ↗',
                    isPrimary: true,
                    onPressed: () {
                      context.push(AppRoutes.trackOrderRoute, extra: '#FD29847');
                    }),
              ),
              const SizedBox(width: 12),
              const Expanded(child: OrderActionButton(label: 'Help', isPrimary: false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveredOrderCard(BuildContext context) {
    return BaseOrderCard(
      orderId: '#FD28341',
      date: 'Yesterday, 3:45 PM',
      itemsCount: 2,
      status: 'Delivered',
      statusColor: AppColors.successColor,
      statusBg: AppColors.successColor.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              ItemThumbnails(colors: [
                AppColors.categoryMenBg.toHexString(),
                AppColors.categoryBridalBg.toHexString()
              ]),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bandhani Saree + Blazer', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Jodhpur Couture, W for Woman',
                        style: TextStyle(fontSize: 12, color: AppColors.grey707070)),
                    Row(
                      children: [
                        Text('₹5,298', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Text('Saved ₹600',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.successColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: OrderActionButton(label: 'Reorder', isPrimary: true)),
              SizedBox(width: 8),
              Expanded(child: OrderActionButton(label: 'Return', isPrimary: false)),
              SizedBox(width: 8),
              Expanded(child: OrderActionButton(label: 'Rate', isPrimary: false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnInitiatedCard(BuildContext context) {
    return BaseOrderCard(
      orderId: '#FD27190',
      date: 'May 20',
      itemsCount: 1,
      status: 'Return initiated',
      statusColor: AppColors.warningColor,
      statusBg: AppColors.warningColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ItemThumbnails(colors: [AppColors.categoryWomenBg.toHexString()]),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Floral Summer Dress', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Biba • Size S • Pink',
                        style: TextStyle(fontSize: 12, color: AppColors.grey707070)),
                    Row(
                      children: [
                        Text('₹1,499', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Text('Refund pending',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.warningColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.warningColor),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rider kal aayega pickup ke liye',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Refund ₹1,499 • 2-3 business days',
                          style: TextStyle(fontSize: 10, color: AppColors.grey707070)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledOrderCard(BuildContext context) {
    return BaseOrderCard(
      orderId: '#FD24110',
      date: 'May 15',
      itemsCount: 1,
      status: 'Cancelled',
      statusColor: AppColors.errorRed,
      statusBg: AppColors.errorRed.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              ItemThumbnails(colors: [AppColors.categoryWomenBg.toHexString()]),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Printed Kurti', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Global Desi • Size M',
                        style: TextStyle(fontSize: 12, color: AppColors.grey707070)),
                    Text('₹899', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const OrderActionButton(label: 'Reorder', isPrimary: false),
        ],
      ),
    );
  }
}
