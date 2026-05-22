import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _currentView = 'Default'; // 'Default', 'Typing', 'Results'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.exploreBackground,
      body: SafeArea(
        child: Column(
          children: [
            // State Switcher (Mock from image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildStateTab('Default'),
                  const SizedBox(width: 8),
                  _buildStateTab('Typing...'),
                  const SizedBox(width: 8),
                  _buildStateTab('Results'),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search fashion, brands...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: (query) {
                    context.read<SearchBloc>().add(SearchQueryChanged(query));
                  },
                ),
              ),
            ),

            Expanded(
              child: _currentView == 'Results' 
                ? _buildResultsView() 
                : _buildDefaultView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateTab(String label) {
    bool isActive = _currentView == (label.contains('...') ? 'Typing' : label);
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentView = label.contains('...') ? 'Typing' : label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.grey.shade300 : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Searches
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Trending searches',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTrendingChip('Bandhani saree', hasFlame: true),
              _buildTrendingChip('Wedding kurta', hasFlame: true),
              _buildTrendingChip('Floral dress', hasFlame: false),
              _buildTrendingChip('Linen blazer', hasFlame: false),
              _buildTrendingChip('Lehenga under 5000'),
              _buildTrendingChip('Jodhpur local'),
              _buildTrendingChip('Office wear men'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Shop by Category
          Text(
            'Shop by category',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildCategoryCard('Women', '1,240 items', Icons.woman, AppColors.categoryWomenBg, AppColors.categoryWomenText),
              _buildCategoryCard('Men', '860 items', Icons.man, AppColors.categoryMenBg, AppColors.categoryMenText),
              _buildCategoryCard('Bridal', '320 items', Icons.workspace_premium, AppColors.categoryBridalBg, AppColors.categoryBridalText),
              _buildCategoryCard('Local designers', '48 boutiques', Icons.storefront, AppColors.categoryLocalBg, AppColors.categoryLocalText),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Searches
          Row(
            children: [
              const Icon(Icons.history, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent searches',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentSearchItem('Floral summer dress'),
          _buildRecentSearchItem('Classic kurta under 2000'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTrendingChip(String label, {bool hasFlame = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasFlame) ...[
            const Icon(Icons.whatshot, color: Colors.orange, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              ),
            ),
            const Icon(Icons.north_west, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Results grid ready ho rahi hai...', style: TextStyle(color: Colors.orange)),
              ],
            ),
          );
        } else if (state is SearchLoaded) {
          if (state.results.isEmpty) {
            return const Center(child: Text('No results found'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final product = state.results[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(product.images.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('₹${product.price}', style: TextStyle(color: Colors.grey.shade600)),
                ],
              );
            },
          );
        }
        return const Center(child: Text('Start searching for trends'));
      },
    );
  }
}
