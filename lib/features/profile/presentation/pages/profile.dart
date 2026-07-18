import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppDimensions.lg),

              // ── Profile Header ────────────────────────────────────
              Container(
                padding: EdgeInsets.all(AppDimensions.md),
                child: Column(
                  children: [
                    // Avatar with simple gold border
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryContainer,
                          width: 3.w,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.surfaceHigh,
                        child: Icon(
                          Icons.person,
                          size: 56.w,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: AppDimensions.lg),

                    // Name
                    Text(
                      'Alex Rivera',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),

                    SizedBox(height: AppDimensions.xs),

                    // Username
                    Text(
                      '@arivera',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: AppDimensions.md),

                    // Premium Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primaryContainer,
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            size: 16.w,
                            color: AppColors.primaryContainer,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'PREMIUM MEMBER',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.lg),

              // ── Main Options ──────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Column(
                  children: [
                    // Options Card
                    _OptionsCard(
                      children: [
                        _OptionItem(
                          icon: Icons.favorite_rounded,
                          title: 'My Favourites',
                          trailing: '128',
                          onTap: () {
                            context.go(RouteNames.favourites);
                          },
                        ),
                        _Divider(),
                        _OptionItem(
                          icon: Icons.collections_bookmark_rounded,
                          title: 'My Collections',
                          trailing: '12',
                          onTap: () {},
                        ),
                        _Divider(),
                        _OptionItem(
                          icon: Icons.download_rounded,
                          title: 'My Downloads',
                          trailing: '42',
                          onTap: () {},
                        ),
                        _Divider(),
                        _OptionItem(
                          icon: Icons.thumb_up_rounded,
                          title: 'Liked by me',
                          onTap: () {},
                        ),
                      ],
                    ),

                    SizedBox(height: AppDimensions.md),

                    // Settings Card
                    _OptionsCard(
                      children: [
                        _OptionItem(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          onTap: () {},
                        ),
                      ],
                    ),

                    SizedBox(height: AppDimensions.md),

                    // Sign Out Card
                    _OptionsCard(
                      children: [
                        _OptionItem(
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          isDestructive: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Options Card ─────────────────────────────────────────────────────────

class _OptionsCard extends StatelessWidget {
  final List<Widget> children;

  const _OptionsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
        border: Border.all(
          color: AppColors.surfaceHigh,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

// ─── Option Item ──────────────────────────────────────────────────────────

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isDestructive;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.w,
              color: isDestructive ? AppColors.error : AppColors.primaryContainer,
            ),
            SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.onSurface,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: AppDimensions.md),
            ],
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.w,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Divider(
        height: 0.5.h,
        color: AppColors.surfaceHigh,
      ),
    );
  }
}
