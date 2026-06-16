import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Categories',
        style: AppTextStyles.headlineLgMobile.copyWith(
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
