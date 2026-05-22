import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';

class RecentSearchesWidget extends StatelessWidget {
  final List<String> searches;
  final TextEditingController controller;

  const RecentSearchesWidget({
    super.key,
    required this.searches,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent searches',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              OutlinedButton(
                onPressed: () => context.read<SearchBloc>().add(const ClearRecentSearches()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text('Clear all', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: searches.map((query) => _buildRecentChip(context, query)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChip(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        controller.text = label;
        context.read<SearchBloc>().add(SearchQueryChanged(label));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => context.read<SearchBloc>().add(RemoveRecentSearch(label)),
              child: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
