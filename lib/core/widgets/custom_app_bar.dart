import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: AppColors.primaryContainer,
                size: 24,
              ),
              const SizedBox(width: 30),
              Text(
                'WALLR',
                style: AppTextStyles.headlineLgMobile.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(children: actions),
        ],
      ),
    );
  }
}
