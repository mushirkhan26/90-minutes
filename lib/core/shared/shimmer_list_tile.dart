// shimmer_list_tile.dart
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.white),
        title: Container(height: 16, color: Colors.white),
        subtitle: Container(height: 12, color: Colors.white),
      ),
    );
  }
}