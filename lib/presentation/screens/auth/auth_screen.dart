// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coin_identifier/core/utils/responsive.dart';
import 'package:coin_identifier/core/constants/app_colors.dart';
import 'package:coin_identifier/core/constants/app_dimensions.dart';
import 'package:coin_identifier/presentation/river_pods/auth_rp.dart';
import 'package:coin_identifier/presentation/screens/auth/widgets/auth_header.dart';
import 'package:coin_identifier/presentation/screens/auth/widgets/auth_footer.dart';
import 'package:coin_identifier/presentation/screens/main/main_navigation_screen.dart';
import 'package:coin_identifier/presentation/screens/auth/widgets/auth_mode_toggle.dart';
import 'package:coin_identifier/presentation/screens/auth/widgets/email_password_form.dart';
import 'package:coin_identifier/presentation/screens/auth/widgets/apple_sign_in_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  static const String routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleAuthSuccess() {
    Navigator.of(context).pushReplacementNamed(MainNavigationScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = Responsive.getResponsivePadding(context);
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        _handleAuthSuccess();
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsivePadding),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const AuthHeader(),

                    const SizedBox(height: 40),

                    const AuthModeToggle(),

                    const SizedBox(height: 32),

                    const AppleSignInButton(),

                    const SizedBox(height: 24),

                    _buildDivider(),
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(authState.errorMessage!),
                    ],

                    const SizedBox(height: 24),

                    const EmailPasswordForm(),

                    const SizedBox(height: 32),

                    const AuthFooter(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.silver, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with email',
            style: TextStyle(
              color: AppColors.primaryNavy.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.silver, thickness: 1)),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).clearError(),
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}
