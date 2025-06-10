// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double dotSize;
  final double spacing;

  const PageIndicator({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.dotSize = 8.0,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: index == currentPage ? dotSize * 2 : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dotSize / 2),
            color:
                index == currentPage
                    ? AppColors.primaryGold
                    : AppColors.silver.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
