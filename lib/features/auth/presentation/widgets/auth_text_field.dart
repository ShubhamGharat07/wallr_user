import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';

/// Shared auth text field — same visual language (fill, radius, borders,
/// focus/error states) used across Sign In, Sign Up and Forgot Password.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
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