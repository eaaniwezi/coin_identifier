// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:coin_identifier/presentation/river_pods/auth_form_rp.dart';

class AuthModeToggle extends ConsumerWidget {
  const AuthModeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(authFormProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              context: context,
              ref: ref,
              title: 'Sign In',
              isSelected: !formState.isSignUp,
              onTap: () {
                if (formState.isSignUp) {
                  ref.read(authFormProvider.notifier).toggleMode();
                }
              },
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              context: context,
              ref: ref,
              title: 'Sign Up',
              isSelected: formState.isSignUp,
              onTap: () {
                if (!formState.isSignUp) {
                  ref.read(authFormProvider.notifier).toggleMode();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryNavy : AppColors.silver,
          ),
        ),
      ),
    );
  }
}
