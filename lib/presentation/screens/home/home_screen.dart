import 'package:flutter/material.dart';
import '../../river_pods/auth_rp.dart';
import '../../river_pods/home_rp.dart';
import '../paywall/paywall_screen.dart';
import '../../river_pods/paywall_rp.dart';
import 'widgets/collection_stats_card.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coin_identifier/services/apphud_service.dart';
import 'package:coin_identifier/presentation/screens/home/widgets/main_action_buttons.dart';
import 'package:coin_identifier/presentation/screens/home/widgets/premium_prompt_banner.dart';
import 'package:coin_identifier/presentation/screens/home/widgets/recent_identifications_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(collectionStatsProvider.notifier).loadStats();
      ref
          .read(recentIdentificationsProvider.notifier)
          .loadRecentIdentifications();

      ref.read(paywallProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final authState = ref.watch(authProvider);
    ref.watch(connectivityProvider);
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final responsivePadding = Responsive.getResponsivePadding(context);
    final isMobileSmall = Responsive.isMobileSmall(context);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primaryGold,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(
                  authState,
                  subscriptionStatus,
                  isMobileSmall,
                ),

                SizedBox(height: isMobileSmall ? 16 : 24),

                const CollectionStatsCard(),

                SizedBox(height: isMobileSmall ? 20 : 32),

                const MainActionButtons(),

                SizedBox(height: isMobileSmall ? 20 : 32),

                if (!subscriptionStatus.isPremium) ...[
                  PremiumPromptBanner(),
                  SizedBox(height: isMobileSmall ? 16 : 24),
                ],

                const RecentIdentificationsSection(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(
    AuthState authState,
    SubscriptionStatus subscriptionStatus,
    bool isMobileSmall,
  ) {
    final userName =
        authState.userDisplayName ??
        authState.userEmail?.split('@').first ??
        'Collector';

    final timeOfDay = _getTimeOfDay();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '$timeOfDay, $userName',
                      style: TextStyle(
                        fontSize: Responsive.getResponsiveFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                  if (subscriptionStatus.isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: isMobileSmall ? 11 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subscriptionStatus.isPremium
                    ? 'Enjoy unlimited access to all features!'
                    : 'Ready to identify some coins?',
                style: TextStyle(
                  fontSize: Responsive.getResponsiveFontSize(context, 16),
                  color: AppColors.primaryNavy.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        if (!subscriptionStatus.isPremium) ...[
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showPaywall(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobileSmall ? 12 : 16,
                    vertical: isMobileSmall ? 8 : 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Upgrade',
                        style: TextStyle(
                          fontSize: isMobileSmall ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(source: 'home'),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(collectionStatsProvider.notifier).loadStats(),
      ref
          .read(recentIdentificationsProvider.notifier)
          .loadRecentIdentifications(),
      ref.read(paywallProvider.notifier).loadProducts(),
    ]);
  }
}
