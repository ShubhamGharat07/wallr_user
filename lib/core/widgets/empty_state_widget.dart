// lib/core/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../constants/text_styles.dart';
import 'app_button.dart';

/// Empty state — used in Favourites, Downloads, Collections, Search no results

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64.w, color: AppColors.navInactive),
            SizedBox(height: AppDimensions.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSm,
            ),
            SizedBox(height: AppDimensions.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMdMuted,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppDimensions.lg),
              AppButton.secondary(
                label: actionLabel!,
                onTap: onAction,
                isFullWidth: false,
                width: 180.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
