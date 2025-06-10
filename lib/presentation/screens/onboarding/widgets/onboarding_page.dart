// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class OnboardingPage extends StatefulWidget {
  final Widget illustration;
  final String title;
  final String subtitle;
  final String description;

  const OnboardingPage({
    Key? key,
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.description,
  }) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = Responsive.getResponsivePadding(context);
    final isMobileSmall = Responsive.isMobileSmall(context);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      padding: EdgeInsets.symmetric(horizontal: responsivePadding),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: isMobileSmall ? 200 : 240,
                      width: isMobileSmall ? 200 : 240,
                      margin: EdgeInsets.only(
                        bottom:
                            isMobileSmall
                                ? AppDimensions.paddingL
                                : AppDimensions.paddingXL,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: widget.illustration,
                    ),
                  ),

                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: Responsive.getResponsiveFontSize(
                                context,
                                28,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height:
                        isMobileSmall
                            ? AppDimensions.paddingS
                            : AppDimensions.paddingM,
                  ),

                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delayedAnimation = Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(
                            0.3,
                            0.9,
                            curve: Curves.easeOut,
                          ),
                        ),
                      );

                      return Transform.translate(
                        offset: Offset(0, 15 * (1 - delayedAnimation.value)),
                        child: Opacity(
                          opacity: delayedAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold.withOpacity(0.1),
                                  AppColors.primaryGold.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primaryGold.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: Responsive.getResponsiveFontSize(
                                  context,
                                  18,
                                ),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGold,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height:
                        isMobileSmall
                            ? AppDimensions.paddingM
                            : AppDimensions.paddingL,
                  ),

                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final finalAnimation = Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(
                            0.5,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                      );

                      return Transform.translate(
                        offset: Offset(0, 10 * (1 - finalAnimation.value)),
                        child: Opacity(
                          opacity: finalAnimation.value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  isMobileSmall
                                      ? AppDimensions.paddingS
                                      : AppDimensions.paddingM,
                            ),
                            child: Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: Responsive.getResponsiveFontSize(
                                  context,
                                  12,
                                ),
                                color: AppColors.primaryNavy.withOpacity(0.7),
                                height: 1.6,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppDimensions.paddingXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
