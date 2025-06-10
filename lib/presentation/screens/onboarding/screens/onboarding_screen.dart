// ignore_for_file: use_super_parameters, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coin_identifier/core/utils/responsive.dart';
import 'package:coin_identifier/core/constants/app_colors.dart';
import 'package:coin_identifier/core/constants/app_dimensions.dart';
import 'package:coin_identifier/presentation/river_pods/onboarding_rp.dart';
import 'package:coin_identifier/presentation/screens/auth/auth_screen.dart';
import 'package:coin_identifier/presentation/screens/onboarding/widgets/page_indicator.dart';
import 'package:coin_identifier/presentation/screens/onboarding/widgets/onboarding_page.dart';
import 'package:coin_identifier/presentation/screens/onboarding/widgets/onboarding_svg_assets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      illustration: OnboardingSvgAssets.aiIdentificationSvg(),
      title: 'AI-Powered Identification',
      subtitle: 'Instant Coin Recognition',
      description:
          'Simply snap a photo and our advanced AI instantly identifies your coin, providing detailed information about its origin, year, and unique characteristics.',
    ),
    OnboardingPageData(
      illustration: OnboardingSvgAssets.collectionTrackingSvg(),
      title: 'Track Your Collection',
      subtitle: 'Organize & Manage',
      description:
          'Build and organize your digital coin collection with detailed records, personal notes, and comprehensive tracking of your numismatic journey.',
    ),
    OnboardingPageData(
      illustration: OnboardingSvgAssets.marketPricesSvg(),
      title: 'Real-Time Market Prices',
      subtitle: 'Stay Informed',
      description:
          'Get up-to-date market valuations and price trends for your coins, helping you make informed decisions about your collection.',
    ),
    OnboardingPageData(
      illustration: OnboardingSvgAssets.secureStorageSvg(),
      title: 'Secure Cloud Storage',
      subtitle: 'Safe & Accessible',
      description:
          'Your collection data is securely stored in the cloud and synced across all your devices, ensuring your records are always safe and accessible.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final state = ref.read(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    if (state.currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final notifier = ref.read(onboardingProvider.notifier);
    await notifier.completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = Responsive.getResponsivePadding(context);
    final isMobileSmall = Responsive.isMobileSmall(context);

    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildTopNavigation(responsivePadding, onboardingState),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    ref.read(onboardingProvider.notifier).setCurrentPage(page);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      illustration: _pages[index].illustration,
                      title: _pages[index].title,
                      subtitle: _pages[index].subtitle,
                      description: _pages[index].description,
                    );
                  },
                ),
              ),
              _buildBottomNavigation(
                responsivePadding,
                isMobileSmall,
                onboardingState,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(double padding, OnboardingState state) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CoinID Pro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          state.currentPage < _pages.length - 1
              ? TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(
    double padding,
    bool isMobileSmall,
    OnboardingState state,
  ) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PageIndicator(
            currentPage: state.currentPage,
            totalPages: _pages.length,
            dotSize: isMobileSmall ? 6 : 8,
          ),
          SizedBox(
            height:
                isMobileSmall
                    ? AppDimensions.paddingL
                    : AppDimensions.paddingXL,
          ),
          _buildNavigationButtons(state, isMobileSmall),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(OnboardingState state, bool isMobileSmall) {
    final isLastPage = state.currentPage == _pages.length - 1;

    return Row(
      children: [
        if (state.currentPage > 0)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primaryGold,
                elevation: 0,
                side: const BorderSide(color: AppColors.primaryGold, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadius,
                  ),
                ),
                minimumSize: Size.fromHeight(
                  isMobileSmall ? 48 : AppDimensions.buttonHeight,
                ),
              ),
              child: const Text(
                'Previous',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

        if (state.currentPage > 0)
          const SizedBox(width: AppDimensions.paddingM),

        Expanded(
          flex: state.currentPage > 0 ? 1 : 2,
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.primaryNavy,
              elevation: 3,
              shadowColor: AppColors.primaryGold.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              minimumSize: Size.fromHeight(
                isMobileSmall ? 48 : AppDimensions.buttonHeight,
              ),
            ),
            child:
                state.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryNavy,
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isLastPage
                              ? Icons.rocket_launch
                              : Icons.arrow_forward,
                          size: 20,
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPageData {
  final Widget illustration;
  final String title;
  final String subtitle;
  final String description;

  OnboardingPageData({
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
