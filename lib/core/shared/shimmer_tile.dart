// shimmer_tile.dart
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerTile extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ShimmerTile({super.key, this.width, this.height, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}