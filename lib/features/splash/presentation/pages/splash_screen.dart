import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _checkAuthStatus();
    // Pre-decode the login screen's heavy assets during idle time — the day
    // the user signs out and lands on login, the images are already cached
    // and navigation has zero frame drops.
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheAuthAssets());
  }

  /// Pre-decodes the Auth screen's full-screen background + logo so the
  /// splash-to-login / sign-out-to-login navigation stays at 0 jank.
  Future<void> _precacheAuthAssets() async {
    if (!mounted) return;
    await precacheImage(
      const AssetImage('assets/Loginbackground.png'),
      context,
      onError: _ignoreCacheError,
    );
    if (!mounted) return;
    await precacheImage(
      const AssetImage('assets/applogo.png'),
      context,
      onError: _ignoreCacheError,
    );
  }

  static void _ignoreCacheError(Object error, StackTrace? stackTrace) {}

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('session_token');
    final userEmail = prefs.getString('user_email');

    if (sessionToken != null && sessionToken.isNotEmpty && userEmail != null) {
      if (!mounted) return;
      // A session exists — go straight to home.
      context.go(RouteNames.home);
    } else {
      if (!mounted) return;
      // No session — go to onboarding.
      context.go(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('assets/Splashscreen.jpg', fit: BoxFit.cover),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Animated Logo + App Name
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 30.h),

                    // App Name
                    Text(
                      'WALLR',
                      style: AppTextStyles.headlineLgMobile.copyWith(
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Tagline
                    Text(
                      'Your Cinematic Gallery',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.navInactive,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom text and loading indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // WALLR text
                    Text(
                      'WALLR',
                      style: AppTextStyles.headlineLgMobile.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Premium tagline
                    Text(
                      'Premium 4K Wallpapers',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Progress indicator
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFF5C518),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
