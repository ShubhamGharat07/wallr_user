// lib/core/widgets/app_shimmer.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';

/// Generic shimmer loading widget
/// Aspect-ratio locked by parent — zero layout shifts = zero jank
///
/// Usage:
///   AppShimmer()                   → fills parent exactly
///   AppShimmer.card(aspectRatio)   → for standalone cards
///   AppShimmer.text(width, height) → for text line placeholders
class AppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final BoxShape shape;

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  /// Text line shimmer
  const AppShimmer.text({
    super.key,
    required this.width,
    this.height = 14,
    this.borderRadius = 4,
    this.shape = BoxShape.rectangle,
  });

  /// Circular shimmer — avatars, glass buttons
  const AppShimmer.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceHigh,
      highlightColor: AppColors.surfaceBright,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(borderRadius ?? AppDimensions.cardRadius),
        ),
      ),
    );
  }
}

/// Shimmer grid — for home feed masonry loading state
/// Drop this in directly where masonry grid goes
class AppShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const AppShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Alternating heights to mimic masonry — no layout shift
    const heights = [200.0, 280.0, 240.0, 180.0, 260.0, 220.0];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimensions.gutter,
        mainAxisSpacing: AppDimensions.gutter,
        childAspectRatio: 0.7,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) => AppShimmer(
        height: heights[i % heights.length],
        borderRadius: AppDimensions.cardRadius,
      ),
    );
  }
}
