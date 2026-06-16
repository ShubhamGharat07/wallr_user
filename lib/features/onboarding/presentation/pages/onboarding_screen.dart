import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';

// ─── Slide Data Model ─────────────────────────────────────────────────────────

class _Slide {
  final String title;
  final String subtitle;
  final List<Color> bgColors;

  const _Slide({
    required this.title,
    required this.subtitle,
    required this.bgColors,
  });
}

const _kSlides = [
  _Slide(
    title: 'Millions of stunning\nwallpapers',
    subtitle:
        'Transform your screen into a cinematic gallery with our curated collection of high-fidelity photography and digital art.',
    bgColors: [Color(0xFF0B1F1C), Color(0xFF050F0A)],
  ),
  _Slide(
    title: 'Curate your\nCollection',
    subtitle:
        'Save your favourites and organise them into beautiful personal collections.',
    bgColors: [Color(0xFF0B1520), Color(0xFF050A12)],
  ),
  _Slide(
    title: 'Set in\nOne Tap',
    subtitle:
        'Crop, preview, and set your wallpaper — home screen, lock screen, or both.',
    bgColors: [Color(0xFF1A110A), Color(0xFF0C0805)],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) => prev.isComplete != curr.isComplete,
      listener: (context, state) {
        if (state.isComplete) {
          if (!mounted) return;
          final selectedTab = state.navigateToSignUp ? 'signup' : 'signin';
          final target = '${RouteNames.auth}?tab=$selectedTab';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            debugPrint('Navigating to $target from onboarding');
            context.go(target);
          });
        }
      },
      builder: (context, state) {
        final slide = _kSlides[state.currentPage];

        return Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Animated gradient background
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: slide.bgColors,
                  ),
                ),
              ),

              // ── 2. Diagonal decorative lines (like the design)
              const RepaintBoundary(
                child: CustomPaint(painter: _LinesPainter()),
              ),

              // ── 3. Bottom-to-mid dark gradient (merges into card)
              const _BottomFade(),

              // ── 4. PageView — transparent, just for swipe gesture
              PageView.builder(
                controller: _pageController,
                itemCount: _kSlides.length,
                onPageChanged: context.read<OnboardingCubit>().changePage,
                itemBuilder: (_, __) => const SizedBox.expand(),
              ),

              // ── 5. SKIP button (top-right, hidden on last slide)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    opacity: state.currentPage < 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: TextButton(
                      onPressed: () => context.read<OnboardingCubit>().skip(),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── 6. Bottom card (overlaid on top of everything)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomCard(
                  slide: slide,
                  currentPage: state.currentPage,
                  onGetStarted: () =>
                      context.read<OnboardingCubit>().complete(signUp: true),
                  onSignIn: () => context.read<OnboardingCubit>().skip(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Bottom Fade Gradient ─────────────────────────────────────────────────────

class _BottomFade extends StatelessWidget {
  const _BottomFade();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.95),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Card ─────────────────────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  final _Slide slide;
  final int currentPage;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const _BottomCard({
    required this.slide,
    required this.currentPage,
    required this.onGetStarted,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        24.h,
        24.w,
        (bottomPadding > 0 ? bottomPadding : 24.h) + 12.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress dots
          _ProgressDots(currentPage: currentPage, total: _kSlides.length),

          SizedBox(height: 28.h),

          // Title — animates on slide change
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              slide.title,
              key: ValueKey('title_$currentPage'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.25,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Subtitle — animates on slide change
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              slide.subtitle,
              key: ValueKey('sub_$currentPage'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),

          SizedBox(height: 36.h),

          // GET STARTED button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer, // #F5C518 gold
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: Text(
                'GET STARTED',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // SIGN IN text button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: TextButton(
              onPressed: onSignIn,
              style: TextButton.styleFrom(
                shape: const StadiumBorder(),
                side: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              child: Text(
                'SIGN IN',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Dots ────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int currentPage;
  final int total;

  const _ProgressDots({required this.currentPage, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 28.w : 8.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryContainer
                : AppColors.navInactive,
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}

// ─── Diagonal Lines Painter ───────────────────────────────────────────────────

class _LinesPainter extends CustomPainter {
  const _LinesPainter();

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final goldPaint = Paint()
      ..color = const Color(0xFFF5C518).withOpacity(0.10)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Regular diagonal lines
    for (double x = -size.height; x < size.width + size.height; x += 36) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    // Gold accent lines (2 prominent ones)
    for (final x in [size.width * 0.22, size.width * 0.65]) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.75, size.height),
        goldPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
