import 'package:flutter/material.dart';

/// Shared full-screen background for all auth flows (Sign In, Sign Up,
/// Forgot Password). Uses the same Loginbackground.png resized on decode
/// (1200px) with the same gradient + dim overlays everywhere, so every
/// auth screen looks identical and navigation stays 0-jank.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/Loginbackground.png',
              fit: BoxFit.cover,
              cacheWidth: 1200,
              filterQuality: FilterQuality.low,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x77000000), Color(0xDD000000)],
                ),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}