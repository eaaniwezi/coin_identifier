// ignore_for_file: use_super_parameters

import 'package:coin_identifier/presentation/river_pods/auth_form_rp.dart';
import 'package:coin_identifier/presentation/river_pods/auth_rp.dart';
import 'package:coin_identifier/presentation/screens/main/main_navigation_screen.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

class EmailPasswordForm extends ConsumerWidget {
  const EmailPasswordForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(authFormProvider);
    final authState = ref.watch(authProvider);

    return Column(
      children: [
        _buildTextField(
          context: context,
          ref: ref,
          label: 'Email',
          value: formState.email,
          onChanged:
              (value) => ref.read(authFormProvider.notifier).updateEmail(value),
          keyboardType: TextInputType.emailAddress,
          errorText: formState.fieldErrors['email'],
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 16),

        _buildTextField(
          context: context,
          ref: ref,
          label: 'Password',
          value: formState.password,
          onChanged:
              (value) =>
                  ref.read(authFormProvider.notifier).updatePassword(value),
          obscureText: formState.obscurePassword,
          errorText: formState.fieldErrors['password'],
          prefixIcon: Icons.lock_outline,
          textInputAction:
              formState.isSignUp ? TextInputAction.next : TextInputAction.done,
          suffixIcon: IconButton(
            onPressed:
                () =>
                    ref
                        .read(authFormProvider.notifier)
                        .togglePasswordVisibility(),
            icon: Icon(
              formState.obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.silver,
            ),
            tooltip:
                formState.obscurePassword ? 'Show password' : 'Hide password',
          ),
        ),

        if (formState.isSignUp) ...[
          const SizedBox(height: 16),
          _buildTextField(
            context: context,
            ref: ref,
            label: 'Confirm Password',
            value: formState.confirmPassword,
            onChanged:
                (value) => ref
                    .read(authFormProvider.notifier)
                    .updateConfirmPassword(value),
            obscureText: formState.obscureConfirmPassword,
            errorText: formState.fieldErrors['confirmPassword'],
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              onPressed:
                  () =>
                      ref
                          .read(authFormProvider.notifier)
                          .toggleConfirmPasswordVisibility(),
              icon: Icon(
                formState.obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.silver,
              ),
              tooltip:
                  formState.obscureConfirmPassword
                      ? 'Show password'
                      : 'Hide password',
            ),
          ),
        ],

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          child: ElevatedButton(
            onPressed:
                (authState.isLoading || !formState.isValid)
                    ? null
                    : () {
                      _handleSubmit(context, ref, formState);
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.primaryNavy,
              disabledBackgroundColor: AppColors.silver.withOpacity(0.3),
              disabledForegroundColor: AppColors.silver,
              elevation: formState.isValid && !authState.isLoading ? 3 : 0,
              shadowColor: AppColors.primaryGold.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
            ),
            child: _buildButtonContent(authState, formState),
          ),
        ),

        if (formState.isSignUp) ...[
          const SizedBox(height: 16),
          _buildPasswordRequirements(formState.password),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    String? errorText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color:
                  hasError
                      ? AppColors.error
                      : AppColors.primaryNavy.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon:
                prefixIcon != null
                    ? Icon(
                      prefixIcon,
                      color: hasError ? AppColors.error : AppColors.silver,
                      size: 22,
                    )
                    : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor:
                hasError ? AppColors.error.withOpacity(0.05) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.silver,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.silver,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primaryGold,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
            errorText: null,
          ),
          onFieldSubmitted: (value) {
            if (textInputAction == TextInputAction.done) {
              final formState = ref.read(authFormProvider);
              if (formState.isValid) {
                _handleSubmit(context, ref, formState);
              }
            }
          },
        ),

        if (hasError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildButtonContent(AuthState authState, AuthFormState formState) {
    final isEmailPasswordLoading =
        authState.isLoading &&
        authState.lastAuthMethod == AuthMethod.emailPassword;

    if (isEmailPasswordLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Please wait...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(formState.isSignUp ? Icons.person_add : Icons.login, size: 20),
        const SizedBox(width: 8),
        Text(
          formState.isSignUp ? 'Create Account' : 'Sign In',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(String password) {
    final requirements = [
      _PasswordRequirement(
        text: 'At least 6 characters',
        isMet: password.length >= 6,
      ),
      _PasswordRequirement(
        text: 'Contains a letter',
        isMet: password.contains(RegExp(r'[a-zA-Z]')),
      ),
      _PasswordRequirement(
        text: 'Contains a number',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: AppColors.silver.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: TextStyle(
              color: AppColors.primaryNavy.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...requirements.map((req) => _buildRequirementItem(req)),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(_PasswordRequirement requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            requirement.isMet
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: requirement.isMet ? AppColors.success : AppColors.silver,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            requirement.text,
            style: TextStyle(
              color:
                  requirement.isMet
                      ? AppColors.success
                      : AppColors.primaryNavy.withOpacity(0.6),
              fontSize: 14,
              fontWeight:
                  requirement.isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    AuthFormState formState,
  ) async {
    ref.read(authProvider.notifier).clearError();

    if (!ref.read(authFormProvider.notifier).validateForm()) {
      return;
    }

    bool success = false;

    if (formState.isSignUp) {
      success = await ref
          .read(authProvider.notifier)
          .signUpWithEmail(
            formState.email,
            formState.password,
            formState.confirmPassword,
          );
    } else {
      success = await ref
          .read(authProvider.notifier)
          .signInWithEmail(formState.email, formState.password);
    }

    if (success && context.mounted) {
      Navigator.of(
        context,
      ).pushReplacementNamed(MainNavigationScreen.routeName);
    }
  }
}

class _PasswordRequirement {
  final String text;
  final bool isMet;

  _PasswordRequirement({required this.text, required this.isMet});
}
