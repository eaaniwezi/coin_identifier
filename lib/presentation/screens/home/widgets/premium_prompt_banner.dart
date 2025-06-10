import 'package:flutter/material.dart';
import '../../../river_pods/home_rp.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:coin_identifier/presentation/screens/paywall/paywall_screen.dart';

class PremiumPromptBanner extends ConsumerWidget {
  final VoidCallback? onUpgradePressed;

  const PremiumPromptBanner({super.key, this.onUpgradePressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobileSmall = Responsive.isMobileSmall(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryNavy,
            AppColors.primaryNavy.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isMobileSmall ? 40 : 48,
            height: isMobileSmall ? 40 : 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.workspace_premium,
              color: AppColors.primaryGold,
              size: isMobileSmall ? 20 : 24,
            ),
          ),

          SizedBox(width: isMobileSmall ? 12 : 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock Pro Features',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobileSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track unlimited coins & collection value',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isMobileSmall ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () => _handleUpgradePressed(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.primaryNavy,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobileSmall ? 12 : 16,
                vertical: isMobileSmall ? 6 : 8,
              ),
            ),
            child: Text(
              'Upgrade',
              style: TextStyle(
                fontSize: isMobileSmall ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgradePressed(BuildContext context, WidgetRef ref) {
    if (onUpgradePressed != null) {
      onUpgradePressed!();
      return;
    }

    ref.read(navigationProvider.notifier).setIndex(3);
    _showUpgradeModal(context);
  }

  void _showUpgradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.silver,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Unlock the full potential of your coin collection',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryNavy.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildFeatureItem(
                          Icons.account_balance_wallet,
                          'Collection Value Tracking',
                          'See the total estimated value of your coin collection',
                        ),
                        _buildFeatureItem(
                          Icons.history,
                          'Unlimited History',
                          'Access your complete identification history',
                        ),
                        _buildFeatureItem(
                          Icons.insights,
                          'Detailed Analytics',
                          'Get insights into your collection trends',
                        ),
                        _buildFeatureItem(
                          Icons.cloud_sync,
                          'Cloud Sync',
                          'Sync your collection across all devices',
                        ),
                        _buildFeatureItem(
                          Icons.priority_high,
                          'Priority Support',
                          'Get faster response times for support',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const PaywallScreen(source: 'home'),
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
                          ),
                          child: const Text(
                            'Start Free Trial',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: AppColors.primaryNavy.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 20),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryNavy.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
