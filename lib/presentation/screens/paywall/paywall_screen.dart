import 'widgets/feature_list.dart';
import 'package:flutter/material.dart';
import 'widgets/subscription_card.dart';
import '../../river_pods/paywall_rp.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/purchase_success_overlay.dart';
import '../../../core/constants/app_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final bool showCloseButton;
  final String? source;

  const PaywallScreen({super.key, this.showCloseButton = true, this.source});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _purchaseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _purchaseController = AnimationController(
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _purchaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paywallState = ref.watch(paywallProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final isMobileSmall = Responsive.isMobileSmall(context);

    ref.listen<PaywallState>(paywallProvider, (previous, current) {
      if (current.lastPurchaseResult?.success == true) {
        _showPurchaseSuccess();
      }
    });

    if (isPremium) {
      return _buildAlreadyPremiumScreen(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildMainContent(
                      context,
                      paywallState,
                      isMobileSmall,
                    ),
                  ),
                );
              },
            ),
          ),

          if (widget.showCloseButton)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(child: _buildCloseButton(context)),
            ),

          if (paywallState.isPurchasing) _buildPurchaseLoadingOverlay(),

          AnimatedBuilder(
            animation: _purchaseController,
            builder: (context, child) {
              return PurchaseSuccessOverlay(
                animation: _purchaseController,
                onComplete: () => Navigator.of(context).pop(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    PaywallState paywallState,
    bool isMobileSmall,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobileSmall ? 16 : 24),
      child: Column(
        children: [
          SizedBox(height: widget.showCloseButton ? 40 : 20),

          _buildHeroSection(isMobileSmall),

          SizedBox(height: isMobileSmall ? 32 : 40),

          PremiumFeaturesList(isMobileSmall: isMobileSmall),

          SizedBox(height: isMobileSmall ? 32 : 40),

          if (paywallState.isLoading)
            _buildLoadingCards(isMobileSmall)
          else if (paywallState.products.isNotEmpty)
            _buildSubscriptionCards(context, paywallState, isMobileSmall)
          else
            _buildErrorState(context, ref),

          SizedBox(height: isMobileSmall ? 24 : 32),

          _buildPurchaseButton(context, paywallState, isMobileSmall),

          SizedBox(height: isMobileSmall ? 16 : 24),

          _buildFooterLinks(context, isMobileSmall),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobileSmall) {
    return Column(
      children: [
        Container(
          width: isMobileSmall ? 80 : 100,
          height: isMobileSmall ? 80 : 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.workspace_premium,
            size: isMobileSmall ? 40 : 50,
            color: Colors.white,
          ),
        ),

        SizedBox(height: isMobileSmall ? 24 : 32),

        Text(
          'Unlock Premium Features',
          style: TextStyle(
            fontSize: isMobileSmall ? 28 : 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isMobileSmall ? 12 : 16),

        Text(
          'Get unlimited access to your complete coin collection and advanced features',
          style: TextStyle(
            fontSize: isMobileSmall ? 16 : 18,
            color: AppColors.primaryNavy.withValues(alpha: 0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isMobileSmall ? 16 : 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTrustIndicator(Icons.security, 'Secure'),
            const SizedBox(width: 24),
            _buildTrustIndicator(Icons.cancel, 'Cancel Anytime'),
            const SizedBox(width: 24),
            _buildTrustIndicator(Icons.star, '4.8★ Rating'),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustIndicator(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGold),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primaryNavy.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCards(bool isMobileSmall) {
    return Column(
      children: [
        _buildSkeletonCard(isMobileSmall),
        const SizedBox(height: 12),
        _buildSkeletonCard(isMobileSmall),
      ],
    );
  }

  Widget _buildSkeletonCard(bool isMobileSmall) {
    return Container(
      width: double.infinity,
      height: isMobileSmall ? 120 : 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCards(
    BuildContext context,
    PaywallState paywallState,
    bool isMobileSmall,
  ) {
    return Column(
      children:
          paywallState.products.map((product) {
            final isSelected = paywallState.selectedProduct?.id == product.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: SubscriptionCard(
                product: product,
                isSelected: isSelected,
                onTap:
                    () => ref
                        .read(paywallProvider.notifier)
                        .selectProduct(product),
                isMobileSmall: isMobileSmall,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPurchaseButton(
    BuildContext context,
    PaywallState paywallState,
    bool isMobileSmall,
  ) {
    final selectedProduct = paywallState.selectedProduct;
    final isPurchasing = paywallState.isPurchasing;

    return Container(
      width: double.infinity,
      height: isMobileSmall ? 56 : 64,
      decoration: BoxDecoration(
        gradient:
            selectedProduct != null && !isPurchasing
                ? AppColors.primaryGradient
                : LinearGradient(
                  colors: [Colors.grey[400]!, Colors.grey[400]!],
                ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow:
            selectedProduct != null && !isPurchasing
                ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
                : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              selectedProduct != null && !isPurchasing
                  ? () => _handlePurchase(ref)
                  : null,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Center(
            child:
                isPurchasing
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      selectedProduct != null
                          ? 'Start Your Premium Journey'
                          : 'Select a Plan',
                      style: TextStyle(
                        fontSize: isMobileSmall ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context, bool isMobileSmall) {
    return Column(
      children: [
        TextButton(
          onPressed: () => _handleRestore(context),
          child: Text(
            'Restore Purchases',
            style: TextStyle(
              fontSize: isMobileSmall ? 14 : 16,
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () => _showTerms(context),
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryNavy.withValues(alpha: 0.6),
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(
                color: AppColors.primaryNavy.withValues(alpha: 0.6),
              ),
            ),
            TextButton(
              onPressed: () => _showPrivacy(context),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryNavy.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: const Icon(
            Icons.close,
            size: 20,
            color: AppColors.primaryNavy,
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Processing your purchase...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Unable to load subscription plans',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(paywallProvider.notifier).loadProducts(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyPremiumScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'You\'re Already Premium!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Enjoy unlimited access to all premium features',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePurchase(WidgetRef ref) {
    ref.read(paywallProvider.notifier).purchaseSelectedProduct();
  }

  void _handleRestore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore purchases feature coming soon!')),
    );
  }

  void _showPurchaseSuccess() {
    _purchaseController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terms of Service'),
            content: const Text('Terms of Service content would go here...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const Text('Privacy Policy content would go here...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
