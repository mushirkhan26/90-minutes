import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.exploreBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black121212)),
            Text('8 items saved', style: TextStyle(fontSize: 12, color: AppColors.grey707070)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSubHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPriceDropBanner(),
                  const SizedBox(height: 16),
                  _buildWishlistGrid(context),
                  const SizedBox(height: 24),
                  _buildMoreItemsCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildStickyBottomAction(context),
        ],
      ),
    );
  }

  Widget _circleBadgeIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.categoryWomenBg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.categoryWomenText),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Select all', style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold, fontSize: 13)),
          Row(
            children: [
              const Text('Sort: Recently added', style: TextStyle(color: AppColors.grey707070, fontSize: 12)),
              const Icon(Icons.unfold_more, size: 14, color: AppColors.grey707070),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDropBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBadge.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreenBadge),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.lightGreenBadge)),
            child: const Icon(Icons.check, size: 12, color: AppColors.primaryDarkGreen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2 items mein price drop hua!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Cart mein add karo pehle koi le jaaye', style: TextStyle(fontSize: 11, color: AppColors.grey707070)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('See deals', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.65,
      children: [
        _wishlistCard(
          context,
          'Manyavar',
          'Classic Kurta Set',
          '₹2,299',
          '₹2,999',
          '23% off',
          '90 Min',
          const Color(0xFFE8F5E9),
        ),
        _wishlistCard(
          context,
          'Biba',
          'Floral Summer Dress',
          '1,299',
          '₹1,899',
          '32% off',
          '90 Min',
          const Color(0xFFFCE4EC),
          isPriceDrop: true,
        ),
        _wishlistCard(
          context,
          'Jodhpur Couture',
          'Bandhani Saree',
          '₹3,499',
          null,
          null,
          'Local',
          const Color(0xFFF3E5F5),
        ),
        _wishlistCard(
          context,
          'W for Woman',
          'Linen Blazer',
          '₹1,599',
          '₹1,999',
          '20% off',
          '90 Min',
          const Color(0xFFFFF3E0),
          isPriceDrop: true,
        ),
      ],
    );
  }

  Widget _wishlistCard(
    BuildContext context,
    String brand,
    String name,
    String price,
    String? originalPrice,
    String? discount,
    String badgeText,
    Color bgColor, {
    bool isPriceDrop = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPriceDrop ? Border.all(color: AppColors.primaryDarkGreen, width: 1) : Border.all(color: AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(child: Icon(Icons.image_outlined, size: 40, color: AppColors.primaryDarkGreen.withValues(alpha: 0.5))),
                ),
                if (isPriceDrop)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreenBadge,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomRight: Radius.circular(8)),
                      ),
                      child: const Text('Price drop!', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: isPriceDrop ? 25 : 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primaryDarkGreen.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.white, size: 8),
                        const SizedBox(width: 2),
                        Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 14, color: AppColors.grey707070),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand, style: const TextStyle(fontSize: 10, color: AppColors.grey707070)),
                const SizedBox(height: 2),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    if (originalPrice != null) ...[
                      const SizedBox(width: 4),
                      Text(originalPrice, style: const TextStyle(fontSize: 10, color: AppColors.grey707070, decoration: TextDecoration.lineThrough)),
                    ],
                    if (discount != null) ...[
                      const SizedBox(width: 4),
                      Text(discount, style: const TextStyle(fontSize: 10, color: AppColors.successColor, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDarkGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('Add to cart', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.more_horiz, size: 16, color: AppColors.grey707070),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.categoryWomenBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.favorite_outline, color: AppColors.categoryWomenText, size: 24),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aur items save karo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Explore karo aur dil pasand cheezein wishlist mein add karo', style: TextStyle(fontSize: 11, color: AppColors.grey707070)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey707070),
        ],
      ),
    );
  }

  Widget _buildStickyBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.shopping_bag_outlined, size: 20),
          label: const Text('Sab cart mein add karo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDarkGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
