import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Text(
          'Search',
          style: AppTextStyles.headlineLgMobile.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
