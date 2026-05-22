import 'package:delivery_90/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_list.dart';
import '../widgets/trending_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ProductBloc>()
        .add(FetchProductsByCategory('Women'));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryDarkGreen, // Status bar area green
        body: SafeArea(
          bottom: false,
          child: Container(
            color: Colors.white, // White background for the whole scrollable area
            child: CustomScrollView(
              slivers: [
                // 1. Scrolling Location Header
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.primaryDarkGreen,
                    child: const HomeHeader(),
                  ),
                ),
                // 2. Sticky Search Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickySearchBarDelegate(
                    child: Container(
                      color: AppColors.primaryDarkGreen,
                      child: const HomeSearchBar(),
                    ),
                  ),
                ),
                // 3. Category List & Transition
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryDarkGreen,
                          Colors.white,
                        ],
                        stops: [0.0, 0.4],
                      ),
                    ),
                    child: const Column(
                      children: [
                        CategoryList(),
                        PromoBanner(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // 4. Products Section
                SliverToBoxAdapter(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is ProductLoaded) {
                        return TrendingSection(products: state.products);
                      } else if (state is ProductError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(child: Text('Initializing...'));
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 61.0; // SearchBar height (45) + Vertical padding (16)

  @override
  double get minExtent => 61.0;

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
