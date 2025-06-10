import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coin_identifier/core/utils/responsive.dart';
import 'package:coin_identifier/services/apphud_service.dart';
import 'package:coin_identifier/core/constants/app_colors.dart';
import 'package:coin_identifier/core/constants/app_dimensions.dart';
import 'package:coin_identifier/presentation/river_pods/home_rp.dart';
import 'package:coin_identifier/presentation/river_pods/history_rp.dart';
import 'package:coin_identifier/presentation/river_pods/paywall_rp.dart';

class CollectionStatsCard extends ConsumerWidget {
  const CollectionStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final isMobileSmall = Responsive.isMobileSmall(context);

    final totalCoins = historyState.coins.length;
    final totalValue = historyState.coins.fold<double>(
      0.0,
      (sum, coin) => sum + (coin.priceEstimate),
    );

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentIdentifications =
        historyState.coins.where((coin) {
          final identifiedAt = coin.identifiedAt;
          return identifiedAt.isAfter(sevenDaysAgo);
        }).length;

    final stats = CollectionStats(
      totalCoins: totalCoins,
      totalValue: totalValue,
      recentIdentifications: recentIdentifications,
      isLoading: historyState.isLoading,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        gradient:
            subscriptionStatus.isPremium
                ? AppColors.primaryGradient
                : LinearGradient(
                  colors: [Colors.grey[600]!, Colors.grey[700]!],
                ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: (subscriptionStatus.isPremium
                    ? AppColors.primaryGold
                    : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          historyState.isLoading && historyState.coins.isEmpty
              ? _buildLoadingState(isMobileSmall)
              : _buildStatsContent(
                stats,
                subscriptionStatus.isPremium,
                isMobileSmall,
                recentIdentifications,
                subscriptionStatus,
              ),
    );
  }

  Widget _buildLoadingState(bool isMobileSmall) {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
        SizedBox(height: isMobileSmall ? 12 : 16),
        const Text(
          'Loading your collection...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContent(
    CollectionStats stats,
    bool isPremium,
    bool isMobileSmall,
    int recentIdentifications,
    SubscriptionStatus subscriptionStatus,
  ) {
    return Column(
      children: [
        if (isPremium) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Premium Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobileSmall ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobileSmall ? 12 : 16),
        ],

        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                title: 'Coins Identified',
                value: stats.totalCoins.toString(),
                icon: Icons.monetization_on,
                isMobileSmall: isMobileSmall,
              ),
            ),
            Container(
              width: 1,
              height: isMobileSmall ? 40 : 50,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _buildStatItem(
                title: 'Collection Value',
                value:
                    isPremium
                        ? '\$${stats.totalValue.toStringAsFixed(2)}'
                        : '🔒 Pro',
                icon: Icons.account_balance_wallet,
                isLocked: !isPremium,
                isMobileSmall: isMobileSmall,
              ),
            ),
          ],
        ),

        if (recentIdentifications > 0) ...[
          SizedBox(height: isMobileSmall ? 12 : 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: isMobileSmall ? 14 : 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$recentIdentifications new this week',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobileSmall ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        if (!isPremium &&
            recentIdentifications == 0 &&
            stats.totalCoins > 0) ...[
          SizedBox(height: isMobileSmall ? 12 : 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: isMobileSmall ? 14 : 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Upgrade to see collection value',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobileSmall ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    bool isLocked = false,
    required bool isMobileSmall,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: isMobileSmall ? 24 : 28),
        SizedBox(height: isMobileSmall ? 8 : 12),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobileSmall ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: isMobileSmall ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
