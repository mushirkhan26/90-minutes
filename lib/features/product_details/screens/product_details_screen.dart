import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/cart_model.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_header_section.dart';
import '../widgets/color_selector.dart';
import '../widgets/size_selector.dart';
import '../widgets/ai_try_on_banner.dart';
import '../widgets/product_details_info.dart';
import '../widgets/review_section.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  String _selectedSize = 'M';
  String _selectedColorName = 'Forest green';

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Forest green', 'color': const Color(0xFF004D40)},
    {'name': 'Pink', 'color': AppColors.categoryWomenText},
    {'name': 'Purple', 'color': AppColors.categoryLocalText},
    {'name': 'Mustard', 'color': AppColors.primaryAmber},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _circleIconButton(Icons.close, () => Navigator.pop(context)),
        title: const Text('Product details',
            style: TextStyle(color: AppColors.black121212, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          _circleIconButton(Icons.favorite_border, () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImageCarousel(
                    selectedIndex: _selectedImageIndex,
                    onPageChanged: (i) => setState(() => _selectedImageIndex = i),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ProductHeaderSection(),
                        const SizedBox(height: 24),
                        ColorSelector(
                          colors: _colors,
                          selectedColorName: _selectedColorName,
                          onColorSelected: (name) => setState(() => _selectedColorName = name),
                        ),
                        const SizedBox(height: 24),
                        SizeSelector(
                          sizes: _sizes,
                          selectedSize: _selectedSize,
                          onSizeSelected: (size) => setState(() => _selectedSize = size),
                        ),
                        const SizedBox(height: 24),
                        const AiTryOnBanner(),
                        const SizedBox(height: 32),
                        const ProductDetailsInfo(),
                        const SizedBox(height: 32),
                        const ReviewSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.greyE5E7EB),
          ),
          child: Icon(icon, size: 18, color: AppColors.black121212),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: AppColors.black121212.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.black121212),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartBloc>().add(AddToCart(CartItem(
                          productId: widget.product.id,
                          productName: widget.product.name,
                          productImage: widget.product.images.first,
                          quantity: 1,
                          price: widget.product.price,
                          brand: 'Jodhpur Couture',
                          size: _selectedSize,
                          color: _selectedColorName,
                        )));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${widget.product.name} to bag!'),
                        backgroundColor: AppColors.primaryDarkGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                          child: Text('Cart mein add karo',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black2E2E2E,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text('Buy now ↗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
