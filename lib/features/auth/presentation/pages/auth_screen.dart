// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../config/routes/route_names.dart';
// import '../../../../core/constants/appstring.dart';
// import '../../../../core/constants/colors.dart';
// import '../../../../core/constants/dimensions.dart';
// import '../../../../core/constants/text_styles.dart';
// import '../../../../core/utils/validators.dart';
// import '../bloc/auth_bloc.dart';
// import '../bloc/auth_event.dart';
// import '../bloc/auth_state.dart';

// class AuthScreen extends StatefulWidget {
//   final int initialTabIndex;

//   const AuthScreen({super.key, this.initialTabIndex = 0});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(
//       length: 2,
//       vsync: this,
//       initialIndex: widget.initialTabIndex.clamp(0, 1).toInt(),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthSuccess) {
//           context.go(RouteNames.home);
//         } else if (state is AuthFailureState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               backgroundColor: AppColors.errorContainer,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         } else if (state is ForgotPasswordSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Reset link sent! Check your inbox.'),
//               backgroundColor: AppColors.surfaceHigh,
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.black,
//         resizeToAvoidBottomInset: true,
//         body: Stack(
//           fit: StackFit.expand,
//           children: [
//             const _BackgroundCollage(),
//             DraggableScrollableSheet(
//               initialChildSize: 0.62,
//               minChildSize: 0.62,
//               maxChildSize: 0.95,
//               builder: (_, scrollController) => _BottomSheet(
//                 tabController: _tabController,
//                 scrollController: scrollController,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Background Collage ───────────────────────────────────────────────────────

// class _BackgroundCollage extends StatelessWidget {
//   const _BackgroundCollage();

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.asset(
//             'assets/images/login_background.png',
//             fit: BoxFit.cover,
//             cacheWidth: 1200,
//           ),
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0x77000000), Color(0xDD000000)],
//               ),
//             ),
//           ),
//           Container(color: Colors.black.withOpacity(0.35)),
//         ],
//       ),
//     );
//   }
// }

// // ─── Bottom Sheet ─────────────────────────────────────────────────────────────

// class _BottomSheet extends StatelessWidget {
//   final TabController tabController;
//   final ScrollController scrollController;

//   const _BottomSheet({
//     required this.tabController,
//     required this.scrollController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF0D0D0D),
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.35),
//             blurRadius: 24,
//             offset: const Offset(0, -8),
//           ),
//         ],
//       ),
//       child: ListView(
//         controller: scrollController,
//         padding: EdgeInsets.zero,
//         physics: const ClampingScrollPhysics(),
//         children: [
//           // Drag handle
//           Center(
//             child: Container(
//               margin: EdgeInsets.only(top: 12.h),
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: AppColors.outlineVariant,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//           ),

//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 24.h),

//                 const _WallrLogoMark(),

//                 SizedBox(height: 16.h),

//                 // Title + subtitle — rebuilds on tab change
//                 AnimatedBuilder(
//                   animation: tabController,
//                   builder: (_, __) => Column(
//                     children: [
//                       Text(
//                         tabController.index == 0
//                             ? AppStrings.authWelcomeBack
//                             : AppStrings.authCreateAccount,
//                         style: AppTextStyles.headlineLgMobile.copyWith(
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         'Enter your details to access your cinematic gallery.',
//                         textAlign: TextAlign.center,
//                         style: AppTextStyles.bodyMdMuted,
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 28.h),

//                 const _SocialButtonsRow(),

//                 SizedBox(height: 24.h),

//                 const _OrDivider(),

//                 SizedBox(height: 24.h),

//                 _AuthTabBar(controller: tabController),

//                 SizedBox(height: 20.h),

//                 SizedBox(
//                   height: 420.h,
//                   child: TabBarView(
//                     controller: tabController,
//                     physics: const NeverScrollableScrollPhysics(),
//                     children: [
//                       _SignInForm(tabController: tabController),
//                       _SignUpForm(tabController: tabController),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: MediaQuery.paddingOf(context).bottom + 16.h),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── WALLR Logo Mark ─────────────────────────────────────────────────────────

// class _WallrLogoMark extends StatelessWidget {
//   const _WallrLogoMark();

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(size: Size(28.w, 32.h), painter: _DiamondPainter());
//   }
// }

// class _DiamondPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFFF5C518)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0
//       ..strokeJoin = StrokeJoin.round;

//     final path = Path()
//       ..moveTo(size.width / 2, 0)
//       ..lineTo(size.width, size.height * 0.38)
//       ..lineTo(size.width / 2, size.height)
//       ..lineTo(0, size.height * 0.38)
//       ..close();

//     final innerPath = Path()
//       ..moveTo(size.width * 0.25, size.height * 0.38)
//       ..lineTo(size.width / 2, size.height * 0.6)
//       ..lineTo(size.width * 0.75, size.height * 0.38);

//     canvas.drawPath(path, paint);
//     canvas.drawPath(innerPath, paint..strokeWidth = 1.5);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }

// // ─── Social Buttons Row ───────────────────────────────────────────────────────

// class _SocialButtonsRow extends StatelessWidget {
//   const _SocialButtonsRow();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         final isLoading = state is AuthLoading;
//         return Row(
//           children: [
//             Expanded(
//               child: _SocialButton(
//                 label: AppStrings.authGoogleSignIn,
//                 icon: const Icon(
//                   Icons.account_circle_outlined,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 onTap: isLoading
//                     ? null
//                     : () => context.read<AuthBloc>().add(
//                         const SignInWithGoogleRequested(),
//                       ),
//               ),
//             ),
//             SizedBox(width: AppDimensions.sm),
//             Expanded(
//               child: _SocialButton(
//                 label: AppStrings.authAppleSignIn,
//                 icon: const Icon(Icons.apple, color: Colors.white, size: 22),
//                 onTap: null,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _SocialButton extends StatelessWidget {
//   final String label;
//   final Widget icon;
//   final VoidCallback? onTap;

//   const _SocialButton({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: AppDimensions.buttonHeight,
//         decoration: BoxDecoration(
//           color: AppColors.inputSurface,
//           borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
//           border: Border.all(
//             color: AppColors.cardBorder,
//             width: AppDimensions.borderThin,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             icon,
//             SizedBox(width: AppDimensions.xs + 2),
//             Text(label, style: AppTextStyles.labelLg),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── OR Divider ───────────────────────────────────────────────────────────────

// class _OrDivider extends StatelessWidget {
//   const _OrDivider();

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Divider(
//             color: AppColors.outlineVariant,
//             thickness: AppDimensions.borderThin,
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: AppDimensions.sm),
//           child: Text(
//             AppStrings.authOrContinueWith.toUpperCase(),
//             style: AppTextStyles.labelMd.copyWith(
//               color: AppColors.navInactive,
//               letterSpacing: 2,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Divider(
//             color: AppColors.outlineVariant,
//             thickness: AppDimensions.borderThin,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─── Tab Bar ──────────────────────────────────────────────────────────────────

// class _AuthTabBar extends StatelessWidget {
//   final TabController controller;

//   const _AuthTabBar({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44.h,
//       decoration: BoxDecoration(
//         color: AppColors.inputSurface,
//         borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
//         border: Border.all(color: AppColors.cardBorder),
//       ),
//       child: TabBar(
//         controller: controller,
//         dividerColor: Colors.transparent,
//         indicator: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//         labelStyle: AppTextStyles.labelLg.copyWith(color: AppColors.black),
//         unselectedLabelStyle: AppTextStyles.labelLg.copyWith(
//           color: AppColors.navInactive,
//         ),
//         tabs: [
//           Tab(text: AppStrings.authSignIn),
//           Tab(text: AppStrings.authSignUp),
//         ],
//       ),
//     );
//   }
// }

// // ─── Sign In Form ─────────────────────────────────────────────────────────────

// class _SignInForm extends StatefulWidget {
//   final TabController tabController;
//   const _SignInForm({required this.tabController});

//   @override
//   State<_SignInForm> createState() => _SignInFormState();
// }

// class _SignInFormState extends State<_SignInForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passwordCtrl.dispose();
//     super.dispose();
//   }

//   void _onSignIn() {
//     if (!_formKey.currentState!.validate()) return;
//     context.read<AuthBloc>().add(
//       SignInWithEmailRequested(
//         email: _emailCtrl.text.trim(),
//         password: _passwordCtrl.text,
//       ),
//     );
//   }

//   void _onForgotPassword() {
//     if (_emailCtrl.text.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Enter your email first')));
//       return;
//     }
//     context.read<AuthBloc>().add(
//       ForgotPasswordRequested(_emailCtrl.text.trim()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         final isLoading = state is AuthLoading;
//         return Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               _AuthTextField(
//                 controller: _emailCtrl,
//                 hint: AppStrings.authEmailHint,
//                 prefixIcon: Icons.mail_outline,
//                 keyboardType: TextInputType.emailAddress,
//                 validator: Validators.email,
//               ),

//               SizedBox(height: AppDimensions.sm),

//               _AuthTextField(
//                 controller: _passwordCtrl,
//                 hint: AppStrings.authPasswordHint,
//                 prefixIcon: Icons.lock_outline,
//                 obscureText: _obscurePassword,
//                 validator: Validators.password,
//                 suffixIcon: GestureDetector(
//                   onTap: () =>
//                       setState(() => _obscurePassword = !_obscurePassword),
//                   child: Icon(
//                     _obscurePassword
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     color: AppColors.navInactive,
//                     size: AppDimensions.iconSm,
//                   ),
//                 ),
//               ),

//               SizedBox(height: AppDimensions.xs),

//               // Forgot password — right aligned
//               TextButton(
//                 onPressed: isLoading ? null : _onForgotPassword,
//                 child: Text(
//                   AppStrings.authForgotPassword,
//                   style: AppTextStyles.labelLg.copyWith(
//                     color: AppColors.primaryContainer,
//                   ),
//                 ),
//               ),

//               SizedBox(height: AppDimensions.sm),

//               // Sign In button
//               SizedBox(
//                 width: double.infinity,
//                 height: AppDimensions.buttonHeight,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : _onSignIn,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryContainer,
//                     foregroundColor: AppColors.onPrimary,
//                     disabledBackgroundColor: AppColors.primaryContainer
//                         .withOpacity(0.5),
//                     elevation: 0,
//                     shape: const StadiumBorder(),
//                   ),
//                   child: isLoading
//                       ? SizedBox(
//                           width: 20.w,
//                           height: 20.w,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.onPrimary,
//                           ),
//                         )
//                       : Text(
//                           AppStrings.authSignIn,
//                           style: AppTextStyles.labelLg.copyWith(
//                             color: AppColors.onPrimary,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                 ),
//               ),

//               SizedBox(height: AppDimensions.md),

//               // Don't have account link
//               Center(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       AppStrings.authDontHaveAccount,
//                       style: AppTextStyles.bodySmMuted,
//                     ),
//                     GestureDetector(
//                       onTap: () => widget.tabController.animateTo(1),
//                       child: Text(
//                         'Create one',
//                         style: AppTextStyles.labelLg.copyWith(
//                           color: AppColors.primaryContainer,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ─── Sign Up Form ─────────────────────────────────────────────────────────────

// class _SignUpForm extends StatefulWidget {
//   final TabController tabController;
//   const _SignUpForm({required this.tabController});

//   @override
//   State<_SignUpForm> createState() => _SignUpFormState();
// }

// class _SignUpFormState extends State<_SignUpForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _passwordCtrl.dispose();
//     super.dispose();
//   }

//   void _onSignUp() {
//     if (!_formKey.currentState!.validate()) return;
//     context.read<AuthBloc>().add(
//       SignUpWithEmailRequested(
//         name: _nameCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         password: _passwordCtrl.text,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         final isLoading = state is AuthLoading;
//         return Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _AuthTextField(
//                 controller: _nameCtrl,
//                 hint: AppStrings.authNameHint,
//                 prefixIcon: Icons.person_outline,
//                 validator: Validators.fullName,
//               ),

//               SizedBox(height: AppDimensions.sm),

//               _AuthTextField(
//                 controller: _emailCtrl,
//                 hint: AppStrings.authEmailHint,
//                 prefixIcon: Icons.mail_outline,
//                 keyboardType: TextInputType.emailAddress,
//                 validator: Validators.email,
//               ),

//               SizedBox(height: AppDimensions.sm),

//               _AuthTextField(
//                 controller: _passwordCtrl,
//                 hint: AppStrings.authPasswordHint,
//                 prefixIcon: Icons.lock_outline,
//                 obscureText: _obscurePassword,
//                 validator: Validators.password,
//                 suffixIcon: GestureDetector(
//                   onTap: () =>
//                       setState(() => _obscurePassword = !_obscurePassword),
//                   child: Icon(
//                     _obscurePassword
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     color: AppColors.navInactive,
//                     size: AppDimensions.iconSm,
//                   ),
//                 ),
//               ),

//               SizedBox(height: AppDimensions.lg),

//               // Sign Up button
//               SizedBox(
//                 width: double.infinity,
//                 height: AppDimensions.buttonHeight,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : _onSignUp,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryContainer,
//                     foregroundColor: AppColors.onPrimary,
//                     disabledBackgroundColor: AppColors.primaryContainer
//                         .withOpacity(0.5),
//                     elevation: 0,
//                     shape: const StadiumBorder(),
//                   ),
//                   child: isLoading
//                       ? SizedBox(
//                           width: 20.w,
//                           height: 20.w,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.onPrimary,
//                           ),
//                         )
//                       : Text(
//                           AppStrings.authSignUp,
//                           style: AppTextStyles.labelLg.copyWith(
//                             color: AppColors.onPrimary,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                 ),
//               ),

//               SizedBox(height: AppDimensions.md),

//               // Already have account link
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     AppStrings.authAlreadyHaveAccount,
//                     style: AppTextStyles.bodySmMuted,
//                   ),
//                   GestureDetector(
//                     onTap: () => widget.tabController.animateTo(0),
//                     child: Text(
//                       AppStrings.authSignIn,
//                       style: AppTextStyles.labelLg.copyWith(
//                         color: AppColors.primaryContainer,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ─── Shared Auth TextField ────────────────────────────────────────────────────

// class _AuthTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final IconData prefixIcon;
//   final bool obscureText;
//   final TextInputType? keyboardType;
//   final String? Function(String?)? validator;
//   final Widget? suffixIcon;

//   const _AuthTextField({
//     required this.controller,
//     required this.hint,
//     required this.prefixIcon,
//     this.obscureText = false,
//     this.keyboardType,
//     this.validator,
//     this.suffixIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: AppTextStyles.bodyMd,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.navInactive),
//         prefixIcon: Icon(
//           prefixIcon,
//           color: AppColors.navInactive,
//           size: AppDimensions.iconSm,
//         ),
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: AppColors.inputSurface,
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: AppDimensions.md,
//           vertical: AppDimensions.sm,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
//           borderSide: BorderSide(
//             color: AppColors.cardBorder,
//             width: AppDimensions.borderThin,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
//           borderSide: BorderSide(
//             color: AppColors.cardBorder,
//             width: AppDimensions.borderThin,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
//           borderSide: BorderSide(
//             color: AppColors.primaryContainer,
//             width: AppDimensions.borderMedium,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
//           borderSide: BorderSide(
//             color: AppColors.error,
//             width: AppDimensions.borderThin,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
//           borderSide: BorderSide(
//             color: AppColors.error,
//             width: AppDimensions.borderMedium,
//           ),
//         ),
//         errorStyle: AppTextStyles.labelSm.copyWith(color: AppColors.error),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/appstring.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  final int initialTabIndex;

  const AuthScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1).toInt(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(RouteNames.home);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorContainer,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        // } else if (state is ForgotPasswordSuccess) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: const Text('Reset link sent! Check your inbox.'),
        //       backgroundColor: AppColors.surfaceHigh,
        //       behavior: SnackBarBehavior.floating,
        //     ),
        //   );
        // }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _BackgroundCollage(),
            DraggableScrollableSheet(
              initialChildSize: 0.62,
              minChildSize: 0.62,
              maxChildSize: 0.95,
              builder: (_, scrollController) => _BottomSheet(
                tabController: _tabController,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Background Collage ───────────────────────────────────────────────────────

class _BackgroundCollage extends StatelessWidget {
  const _BackgroundCollage();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/Loginbackground.png', fit: BoxFit.cover),
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
    );
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final TabController tabController;
  final ScrollController scrollController;

  const _BottomSheet({
    required this.tabController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),

                // ── App Logo from assets ──────────────────────────────────
                Image.asset(
                  'assets/applogo.png',
                  width: 44.w,
                  height: 44.h,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 16.h),

                // Title + subtitle — rebuilds on tab change
                AnimatedBuilder(
                  animation: tabController,
                  builder: (_, __) => Column(
                    children: [
                      Text(
                        tabController.index == 0
                            ? AppStrings.authWelcomeBack
                            : AppStrings.authCreateAccount,
                        style: AppTextStyles.headlineLgMobile.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Enter your details to access your cinematic gallery.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMdMuted,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                const _SocialButtonsRow(),

                SizedBox(height: 24.h),

                const _OrDivider(),

                SizedBox(height: 24.h),

                // ── TabBarView (no visible pill tab bar) ─────────────────
                // Switching handled via "Create one" / "Sign in" links
                SizedBox(
                  height: 420.h,
                  child: TabBarView(
                    controller: tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _SignInForm(tabController: tabController),
                      _SignUpForm(tabController: tabController),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.paddingOf(context).bottom + 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Social Buttons Row ───────────────────────────────────────────────────────

class _SocialButtonsRow extends StatelessWidget {
  const _SocialButtonsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: AppStrings.authGoogleSignIn,
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: isLoading
                    ? null
                    : () => context.read<AuthBloc>().add(
                        const SignInWithGoogleRequested(),
                      ),
              ),
            ),
            SizedBox(width: AppDimensions.sm),
            Expanded(
              child: _SocialButton(
                label: AppStrings.authAppleSignIn,
                icon: const Icon(Icons.apple, color: Colors.white, size: 22),
                onTap: null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.inputSurface,
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          border: Border.all(
            color: AppColors.cardBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: AppDimensions.xs + 2),
            Text(label, style: AppTextStyles.labelLg),
          ],
        ),
      ),
    );
  }
}

// ─── OR Divider ───────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant,
            thickness: AppDimensions.borderThin,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.sm),
          child: Text(
            AppStrings.authOrContinueWith.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.navInactive,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant,
            thickness: AppDimensions.borderThin,
          ),
        ),
      ],
    );
  }
}

// ─── Sign In Form ─────────────────────────────────────────────────────────────

class _SignInForm extends StatefulWidget {
  final TabController tabController;
  const _SignInForm({required this.tabController});

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignInWithEmailRequested(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  void _onForgotPassword() {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your email first')));
      return;
    }
    context.read<AuthBloc>().add(
      ForgotPasswordRequested(_emailCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AuthTextField(
                controller: _emailCtrl,
                hint: AppStrings.authEmailHint,
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),

              SizedBox(height: AppDimensions.sm),

              _AuthTextField(
                controller: _passwordCtrl,
                hint: AppStrings.authPasswordHint,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                validator: Validators.password,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.navInactive,
                    size: AppDimensions.iconSm,
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.xs),

              // Forgot password — right aligned
              TextButton(
                onPressed: isLoading ? null : _onForgotPassword,
                child: Text(
                  AppStrings.authForgotPassword,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.sm),

              // Sign In button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.primaryContainer
                        .withOpacity(0.5),
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          AppStrings.authSignIn,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.onPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              SizedBox(height: AppDimensions.md),

              // Don't have account link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.authDontHaveAccount,
                      style: AppTextStyles.bodySmMuted,
                    ),
                    GestureDetector(
                      onTap: () => widget.tabController.animateTo(1),
                      child: Text(
                        'Create one',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sign Up Form ─────────────────────────────────────────────────────────────

class _SignUpForm extends StatefulWidget {
  final TabController tabController;
  const _SignUpForm({required this.tabController});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignUpWithEmailRequested(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              _AuthTextField(
                controller: _nameCtrl,
                hint: AppStrings.authNameHint,
                prefixIcon: Icons.person_outline,
                validator: Validators.fullName,
              ),

              SizedBox(height: AppDimensions.sm),

              _AuthTextField(
                controller: _emailCtrl,
                hint: AppStrings.authEmailHint,
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),

              SizedBox(height: AppDimensions.sm),

              _AuthTextField(
                controller: _passwordCtrl,
                hint: AppStrings.authPasswordHint,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                validator: Validators.password,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.navInactive,
                    size: AppDimensions.iconSm,
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.lg),

              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.primaryContainer
                        .withOpacity(0.5),
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          AppStrings.authSignUp,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.onPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              SizedBox(height: AppDimensions.md),

              // Already have account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.authAlreadyHaveAccount,
                    style: AppTextStyles.bodySmMuted,
                  ),
                  GestureDetector(
                    onTap: () => widget.tabController.animateTo(0),
                    child: Text(
                      AppStrings.authSignIn,
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Shared Auth TextField ────────────────────────────────────────────────────

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMd,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.navInactive),
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.navInactive,
          size: AppDimensions.iconSm,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          borderSide: BorderSide(
            color: AppColors.cardBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          borderSide: BorderSide(
            color: AppColors.cardBorder,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          borderSide: BorderSide(
            color: AppColors.primaryContainer,
            width: AppDimensions.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderMedium,
          ),
        ),
        errorStyle: AppTextStyles.labelSm.copyWith(color: AppColors.error),
      ),
    );
  }
}
