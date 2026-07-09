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
  }

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

    // Agar session exist kare toh AuthBloc ko check kar de
    if (sessionToken != null && sessionToken.isNotEmpty && userEmail != null) {
      if (!mounted) return;
      // Session exist karta hai - directly home par jao
      context.go(RouteNames.home);
    } else {
      if (!mounted) return;
      // Session nahi hai - onboarding par jao
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
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black,
                  const Color(0xFF1A1A1A),
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
                    // App Logo
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFF5C518),
                            const Color(0xFFFAD94E),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF5C518).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: Size(40.w, 40.w),
                          painter: _DiamondLogoPainter(),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

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

          // Loading indicator at bottom
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diamond Logo Painter ─────────────────────────────────────────────────

class _DiamondLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Outer diamond
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.38)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.38)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    // Inner detail
    final innerPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.38)
      ..lineTo(size.width / 2, size.height * 0.6)
      ..lineTo(size.width * 0.75, size.height * 0.38);

    canvas.drawPath(innerPath, strokePaint..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
