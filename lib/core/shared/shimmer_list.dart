import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final double borderRadius;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: height,
            width: width,
            margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: .25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 150, color: Colors.white),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(height: 12, width: 100, color: Colors.white),
                          const SizedBox(width: 8),
                          Container(height: 12, width: 60, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 120, color: Colors.white),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  const CircleAvatar(radius: 16, backgroundColor: Colors.white),
                                  const SizedBox(height: 4),
                                  Container(height: 10, width: 50, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 20, width: 60, color: Colors.white),
                          Container(height: 20, width: 20, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}