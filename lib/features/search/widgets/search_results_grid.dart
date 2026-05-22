import 'package:delivery_90/features/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class SearchResultsGrid extends StatelessWidget {
  final SearchLoaded state;
  final TextEditingController controller;

  const SearchResultsGrid({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No items found for your search', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                controller.clear();
                context.read<SearchBloc>().add(const SearchQueryChanged(''));
              },
              child: const Text('Clear search', style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final product = state.results[index];
        return ProductCard(product: product);
      },
    );
  }
}
