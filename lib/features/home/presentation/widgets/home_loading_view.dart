// lib/features/home/presentation/widgets/home_loading_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Full Home-screen shimmer skeleton — shown only on the very first
/// load. Mirrors the real layout (greeting → carousel → category rows)
/// so there's zero layout shift once data arrives.
class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer.text(width: 160.w, height: 28.h),
          SizedBox(height: AppDimensions.xs),
          AppShimmer.text(width: 200.w, height: 16.h),
          SizedBox(height: AppDimensions.lg),
          AppShimmer.text(width: 140.w, height: 22.h),
          SizedBox(height: AppDimensions.md),
          _HorizontalShimmerRow(height: 300.h, cardWidth: 220.w),
          SizedBox(height: AppDimensions.lg),
          AppShimmer.text(width: 120.w, height: 22.h),
          SizedBox(height: AppDimensions.md),
          _HorizontalShimmerRow(height: 220.h, cardWidth: 160.w),
          SizedBox(height: AppDimensions.lg),
          AppShimmer.text(width: 120.w, height: 22.h),
          SizedBox(height: AppDimensions.md),
          _HorizontalShimmerRow(height: 220.h, cardWidth: 160.w),
        ],
      ),
    );
  }
}

class _HorizontalShimmerRow extends StatelessWidget {
  final double height;
  final double cardWidth;

  const _HorizontalShimmerRow({required this.height, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(right: AppDimensions.md),
          child: AppShimmer(width: cardWidth, height: height),
        ),
      ),
    );
  }
}
