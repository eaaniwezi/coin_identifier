// ignore_for_file: use_super_parameters, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:coin_identifier/presentation/river_pods/auth_form_rp.dart';

class AuthFooter extends ConsumerStatefulWidget {
  const AuthFooter({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthFooter> createState() => _AuthFooterState();
}

class _AuthFooterState extends ConsumerState<AuthFooter> {
  final TextEditingController _resetEmailController = TextEditingController();
  bool _isResetLoading = false;

  @override
  void dispose() {
    _resetEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormProvider);

    return Column(
      children: [
        if (!formState.isSignUp) ...[
          TextButton(
            onPressed: () {
              _showForgotPasswordDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Forgot your password?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],

        _buildAlternativeActionText(formState.isSignUp),

        const SizedBox(height: 24),

        _buildTermsAndPrivacy(),
      ],
    );
  }

  Widget _buildAlternativeActionText(bool isSignUp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
          style: TextStyle(
            color: AppColors.primaryNavy.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            ref.read(authFormProvider.notifier).toggleMode();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGold,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isSignUp ? 'Sign In' : 'Sign Up',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'By continuing, you agree to our ',
          style: TextStyle(
            color: AppColors.primaryNavy.withOpacity(0.6),
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => _showTermsDialog(context),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' and '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => _showPrivacyDialog(context),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    _resetEmailController.clear();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                  ),
                  title: const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter your email address and we\'ll send you a link to reset your password.',
                        style: TextStyle(
                          color: AppColors.primaryNavy.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryNavy,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            color: AppColors.primaryNavy.withOpacity(0.7),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.silver,
                          ),
                          filled: true,
                          fillColor: AppColors.lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadius,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.silver,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadius,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.silver,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadius,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGold,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingM,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          _isResetLoading
                              ? null
                              : () {
                                Navigator.of(context).pop();
                              },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryNavy.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          _isResetLoading
                              ? null
                              : () async {
                                final email = _resetEmailController.text.trim();

                                if (email.isEmpty || !email.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid email address',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isResetLoading = true);

                                await Future.delayed(
                                  const Duration(milliseconds: 1500),
                                );

                                setState(() => _isResetLoading = false);

                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reset link sent to $email'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.borderRadius,
                                      ),
                                    ),
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadius,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child:
                          _isResetLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryNavy,
                                  ),
                                ),
                              )
                              : const Text(
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            title: const Text(
              'Terms of Service',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Coin Identifier Pro. By using our app, you agree to these terms:',
                    style: TextStyle(
                      color: AppColors.primaryNavy.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTermItem(
                    '1. Use of Service',
                    'You may use our AI-powered coin identification service for personal, non-commercial purposes.',
                  ),
                  _buildTermItem(
                    '2. Accuracy',
                    'While we strive for accuracy, coin identifications are estimates and should not be used for formal appraisals.',
                  ),
                  _buildTermItem(
                    '3. Privacy',
                    'Your uploaded images and data are processed securely and not shared with third parties.',
                  ),
                  _buildTermItem(
                    '4. Subscription',
                    'Premium features require an active subscription with automatic renewal.',
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your privacy is important to us. Here\'s how we handle your data:',
                    style: TextStyle(
                      color: AppColors.primaryNavy.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTermItem(
                    'Data Collection',
                    'We collect images you upload for coin identification and basic account information.',
                  ),
                  _buildTermItem(
                    'Data Use',
                    'Your data is used solely to provide our coin identification service and improve accuracy.',
                  ),
                  _buildTermItem(
                    'Data Storage',
                    'All data is encrypted and stored securely on our servers.',
                  ),
                  _buildTermItem(
                    'Data Sharing',
                    'We never sell or share your personal data with third parties.',
                  ),
                  _buildTermItem(
                    'Data Deletion',
                    'You can request deletion of your data at any time through the app settings.',
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                  ),
                ),
                child: const Text(
                  'Understood',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTermItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: AppColors.primaryNavy.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
