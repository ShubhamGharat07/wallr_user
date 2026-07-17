import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: AppColors.primaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 24),
                Text(
                  'WALLR',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Row(children: actions),
          ],
        ),
      ),
    );
  }
}
