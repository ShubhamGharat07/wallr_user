import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';

class Favourites extends StatelessWidget {
  const Favourites({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Favourites',
        style: AppTextStyles.headlineLgMobile.copyWith(
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
