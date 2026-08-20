import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../wallpaper_download/presentation/bloc/downloads_bloc.dart';
import '../../../wallpaper_download/presentation/bloc/downloads_event.dart';
import '../../../wallpaper_download/presentation/bloc/downloads_state.dart';
import '../../../wallpaper_favourite/presentation/bloc/favorites_bloc.dart';
import '../../../wallpaper_favourite/presentation/bloc/favorites_event.dart';
import '../../../wallpaper_favourite/presentation/bloc/favorites_state.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  /// Production sign-out flow: confirmation dialog first, then the real
  /// sign-out only fires when the user explicitly confirms.
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.containerRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 40.w,
                color: AppColors.error,
              ),
              SizedBox(height: AppDimensions.md),
              Text(
                'Sign Out',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.sm),
              Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppDimensions.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(dialogContext, false),
                      isFullWidth: true,
                    ),
                  ),
                  SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: SizedBox(
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: StadiumBorder(),
                        ),
                        child: Text(
                          'Sign Out',
                          style: AppTextStyles.labelLg.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      // ── 0-jank ticket ──
      // Pre-warm the login screen's 2 assets while sign-out runs. The
      // splash-time precache can't be trusted — the home screen's dozens
      // of wallpaper images fill the shared ImageCache and may EVICT the
      // login background. So re-warm the decode right before navigating,
      // and when AuthScreen opens the image is already ready with zero
      // frame drops on the transition.
      _prewarmAuthAssets(context);
      context.read<AuthBloc>().add(const SignOutRequested());
    }
  }

  /// Fire-and-forget — decode background + logo NOW while sign-out runs,
  /// so navigation has zero decode work left.
  void _prewarmAuthAssets(BuildContext context) {
    for (final asset in const [
      'assets/Loginbackground.png',
      'assets/applogo.png',
    ]) {
      precacheImage(
        AssetImage(asset),
        context,
        onError: _ignoreCacheError,
      );
    }
  }

  static void _ignoreCacheError(Object error, StackTrace? stackTrace) {}

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DownloadsBloc>()..add(const DownloadsRequested()),
        ),
        BlocProvider(
          create: (_) => sl<FavoritesBloc>()..add(const FavoritesRequested()),
        ),
        BlocProvider(
          create: (_) => sl<AuthBloc>(),
        ),
      ],
      child: Scaffold(
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
                          BlocBuilder<FavoritesBloc, FavoritesState>(
                            builder: (context, state) {
                              String count = '0';
                              if (state is FavoritesLoaded) {
                                count = state.wallpapers.length.toString();
                              }
                              return _OptionItem(
                                icon: Icons.favorite_rounded,
                                title: 'My Favourites',
                                trailing: count,
                                onTap: () {
                                  context.go(RouteNames.favourites);
                                },
                              );
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
                          BlocBuilder<DownloadsBloc, DownloadsState>(
                            builder: (context, state) {
                              String count = '0';
                              if (state is DownloadsLoaded) {
                                count = state.wallpapers.length.toString();
                              }
                              return _OptionItem(
                                icon: Icons.download_rounded,
                                title: 'My Downloads',
                                trailing: count,
                                onTap: () {
                                  context.go(RouteNames.downloads);
                                },
                              );
                            },
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
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is SignOutSuccess) {
                                // Session cleared — go straight to the login page.
                                context.go(RouteNames.auth);
                              } else if (state is AuthFailureState) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.error,
                                      content: Text(
                                        'Couldn\'t sign out. Please try again.',
                                        style: AppTextStyles.bodyMd.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                              }
                            },
                            builder: (context, state) {
                              final isSigningOut = state is AuthLoading;
                              return _OptionItem(
                                icon: Icons.logout_rounded,
                                title: 'Sign Out',
                                isDestructive: true,
                                showLoading: isSigningOut,
                                onTap: isSigningOut
                                    ? () {}
                                    : () => _confirmSignOut(context),
                              );
                            },
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
  final bool showLoading;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.isDestructive = false,
    this.showLoading = false,
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
            if (showLoading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            else if (trailing != null) ...[
              Text(
                trailing!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: AppDimensions.md),
            ],
            if (!showLoading)
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
