// lib/features/wallpaper_detail/presentation/widgets/pro_upsell_banner.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';

/// "WALLR Pro" upsell banner shown on the detail screen.
/// [onUpgrade] is wired to the paywall once that flow exists.
class ProUpsellBanner extends StatelessWidget {
  final VoidCallback onUpgrade;

  const ProUpsellBanner({super.key, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
        border: Border.all(
          color: AppColors.primaryContainer.withOpacity(0.35),
          width: AppDimensions.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.primaryContainer,
                      size: AppDimensions.iconSm,
                    ),
                    SizedBox(width: AppDimensions.xs),
                    Text(
                      'WALLR Pro',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.xs),
                Text(
                  'Unlock exclusive 8K resolution & live variants.',
                  style: AppTextStyles.bodySmMuted,
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.s),
          GestureDetector(
            onTap: onUpgrade,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.s,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
              ),
              child: Text(
                'Upgrade',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
