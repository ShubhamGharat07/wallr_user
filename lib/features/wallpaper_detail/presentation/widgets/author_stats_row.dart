// lib/features/wallpaper_detail/presentation/widgets/author_stats_row.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';

/// Author avatar + name/handle on the left, download & view counts on the
/// right. Counts are formatted compactly (12400 → "12.4K").
class AuthorStatsRow extends StatelessWidget {
  final String authorName;
  final String authorHandle;
  final String authorAvatarUrl;
  final int downloadCount;
  final int viewCount;

  const AuthorStatsRow({
    super.key,
    required this.authorName,
    required this.authorHandle,
    required this.authorAvatarUrl,
    required this.downloadCount,
    required this.viewCount,
  });

  static String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = authorName.isNotEmpty ? authorName : 'WALLR Artist';

    return Row(
      children: [
        // ── Avatar ───────────────────────────────────────────────
        ClipOval(
          child: SizedBox(
            width: AppDimensions.avatarSm,
            height: AppDimensions.avatarSm,
            child: authorAvatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: authorAvatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceHigh),
                    errorWidget: (_, __, ___) => _AvatarFallback(),
                  )
                : _AvatarFallback(),
          ),
        ),
        SizedBox(width: AppDimensions.s),

        // ── Name + handle ────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (authorHandle.isNotEmpty)
                Text(
                  authorHandle.startsWith('@')
                      ? authorHandle
                      : '@$authorHandle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmMuted,
                ),
            ],
          ),
        ),

        // ── Stats ────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatItem(
              icon: Icons.download_rounded,
              value: _compact(downloadCount),
            ),
            SizedBox(height: AppDimensions.xs),
            _StatItem(
              icon: Icons.visibility_outlined,
              value: _compact(viewCount),
            ),
          ],
        ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceHigh,
      child: Icon(
        Icons.person_rounded,
        size: AppDimensions.iconSm,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: AppColors.onSurfaceVariant),
        SizedBox(width: AppDimensions.xs),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
