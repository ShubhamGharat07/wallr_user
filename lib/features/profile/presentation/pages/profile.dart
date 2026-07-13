import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Text(
          'Profile',
          style: AppTextStyles.headlineLgMobile.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
