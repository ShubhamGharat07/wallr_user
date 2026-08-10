import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _typeIcon() {
    switch (notification.type) {
      case 'new_wallpaper':
        return Icons.wallpaper_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  Color _typeIconColor() {
    if (!notification.isRead) return AppColors.primaryContainer;
    return AppColors.navInactive;
  }

  String _timeAgo() {
    final now = DateTime.now();
    final diff = now.difference(notification.sentAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(notification.sentAt);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : AppColors.surfaceLow.withOpacity(0.5),
          border: Border(
            bottom: BorderSide(
              color: AppColors.surfaceHigh,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? AppColors.surfaceHigh
                    : AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
              ),
              child: Icon(
                _typeIcon(),
                color: _typeIconColor(),
                size: 20.w,
              ),
            ),
            SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: (notification.isRead
                                  ? AppTextStyles.bodyMd
                                  : AppTextStyles.bodyMd
                                      .copyWith(fontWeight: FontWeight.w600))
                              .copyWith(color: AppColors.onSurface),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppDimensions.xs),
                      Text(
                        _timeAgo(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Padding(
                padding: EdgeInsets.only(left: AppDimensions.xs, top: 4.h),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
