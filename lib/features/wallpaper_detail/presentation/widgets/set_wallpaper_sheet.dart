// lib/features/wallpaper_detail/presentation/widgets/set_wallpaper_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/wallpaper_service.dart';

/// Bottom sheet that lets the user pick where to apply the wallpaper.
/// Returns the chosen [WallpaperTarget] via `Navigator.pop`, or null if
/// dismissed.
class SetWallpaperSheet extends StatelessWidget {
  const SetWallpaperSheet({super.key});

  static Future<WallpaperTarget?> show(BuildContext context) {
    return showModalBottomSheet<WallpaperTarget>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.pillRadius),
        ),
      ),
      builder: (_) => const SetWallpaperSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.md,
          AppDimensions.md,
          AppDimensions.md,
          AppDimensions.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Grab handle ──────────────────────────────────────
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                ),
              ),
            ),
            Text('Set wallpaper on', style: AppTextStyles.headlineSm),
            SizedBox(height: AppDimensions.s),
            _TargetTile(
              icon: Icons.home_rounded,
              label: 'Home screen',
              target: WallpaperTarget.home,
            ),
            _TargetTile(
              icon: Icons.lock_rounded,
              label: 'Lock screen',
              target: WallpaperTarget.lock,
            ),
            _TargetTile(
              icon: Icons.smartphone_rounded,
              label: 'Both screens',
              target: WallpaperTarget.both,
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final WallpaperTarget target;

  const _TargetTile({
    required this.icon,
    required this.label,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.xs),
      leading: Icon(icon, color: AppColors.primaryContainer),
      title: Text(label, style: AppTextStyles.bodyMd),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: () => Navigator.of(context).pop(target),
    );
  }
}
