import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/appstring.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  /// Pre-fills the email field when the user already typed it on Sign In.
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context
        .read<AuthBloc>()
        .add(ForgotPasswordRequested(_emailCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is ForgotPasswordSuccess || curr is AuthFailureState,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        if (state is ForgotPasswordSuccess) {
          final email = _emailCtrl.text.trim();
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              content: Text(
                '${AppStrings.authResetSent} $email\n'
                '${AppStrings.authResetCheckInbox}. '
                '${AppStrings.authResetSpamHint}',
              ),
              backgroundColor: AppColors.surfaceHigh,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        } else if (state is AuthFailureState) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorContainer,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.black,
          resizeToAvoidBottomInset: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const AuthBackground(),

              // Back button — top left
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w, top: 4.h),
                    child: IconButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: AppDimensions.iconMd,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom card — same sheet language as the auth screen
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    24.w,
                    24.h,
                    24.w,
                    MediaQuery.paddingOf(context).bottom + 24.h,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/applogo.png',
                          width: 44.w,
                          height: 44.h,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: 16.h),

                        Text(
                          AppStrings.authForgotTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineLgMobile.copyWith(
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          AppStrings.authForgotSubtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMdMuted,
                        ),

                        SizedBox(height: 28.h),

                        Form(
                          key: _formKey,
                          child: AuthTextField(
                            controller: _emailCtrl,
                            hint: AppStrings.authEmailHint,
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator: Validators.email,
                            onFieldSubmitted: (_) {
                              if (!isLoading) _onSendResetLink();
                            },
                          ),
                        ),

                        SizedBox(height: 24.h),

                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onSendResetLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.onPrimary,
                              disabledBackgroundColor:
                                  AppColors.primaryContainer.withOpacity(0.5),
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
                                    AppStrings.authSendResetLink,
                                    style: AppTextStyles.labelLg.copyWith(
                                      color: AppColors.onPrimary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        GestureDetector(
                          onTap: isLoading ? null : () => context.pop(),
                          child: Text(
                            AppStrings.authBackToSignIn,
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.primaryContainer,
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
      },
    );
  }
}