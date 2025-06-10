import 'package:coin_identifier/presentation/screens/auth/auth_screen.dart';
import 'package:coin_identifier/presentation/river_pods/home_rp.dart'
    as home_rp;
import 'package:coin_identifier/services/apphud_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../river_pods/paywall_rp.dart';
import '../../river_pods/history_rp.dart';
import '../paywall/paywall_screen.dart';
import '../../river_pods/auth_rp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final collectionStats = ref.watch(collectionStatsProvider);
    final isMobileSmall = Responsive.isMobileSmall(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobileSmall ? 16 : 24),
        child: Column(
          children: [
            _buildUserProfileCard(
              context,
              authState,
              subscriptionStatus,
              isMobileSmall,
            ),

            SizedBox(height: isMobileSmall ? 20 : 24),

            _buildSubscriptionCard(
              context,
              ref,
              subscriptionStatus,
              isMobileSmall,
            ),

            SizedBox(height: isMobileSmall ? 20 : 24),

            _buildCollectionAnalytics(
              context,
              ref,
              collectionStats,
              subscriptionStatus.isPremium,
              isMobileSmall,
            ),

            SizedBox(height: isMobileSmall ? 20 : 24),

            _buildQuickActions(context, ref, isMobileSmall),

            SizedBox(height: isMobileSmall ? 20 : 24),

            _buildDebugSection(context, ref, isMobileSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(
    BuildContext context,
    AuthState authState,
    SubscriptionStatus subscriptionStatus,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 20 : 24),
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
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: isMobileSmall ? 35 : 40,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person,
                  size: isMobileSmall ? 35 : 40,
                  color: Colors.white,
                ),
              ),
              if (subscriptionStatus.isPremium)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: isMobileSmall ? 16 : 20),

          Text(
            authState.userDisplayName ??
                authState.userEmail?.split('@').first ??
                'Coin Collector',
            style: TextStyle(
              fontSize: isMobileSmall ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: isMobileSmall ? 4 : 8),

          Text(
            authState.userEmail ?? 'user@example.com',
            style: TextStyle(
              fontSize: isMobileSmall ? 14 : 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),

          SizedBox(height: isMobileSmall ? 8 : 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              subscriptionStatus.isPremium ? 'Premium Member' : 'Free Account',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatus subscriptionStatus,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                subscriptionStatus.isPremium
                    ? Icons.workspace_premium
                    : Icons.lock,
                color:
                    subscriptionStatus.isPremium
                        ? AppColors.primaryGold
                        : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Subscription Status',
                style: TextStyle(
                  fontSize: isMobileSmall ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (subscriptionStatus.isPremium) ...[
            _buildStatusRow('Status', 'Premium Active', Colors.green),
            if (subscriptionStatus.isTrialPeriod)
              _buildStatusRow('Trial', 'Free Trial Period', Colors.blue),
            if (subscriptionStatus.expirationDate != null) ...[
              _buildStatusRow(
                'Expires',
                DateFormat(
                  'MMM dd, yyyy',
                ).format(subscriptionStatus.expirationDate!),
                AppColors.primaryNavy,
              ),
              Builder(
                builder: (context) {
                  final daysRemaining = ref.watch(
                    subscriptionDaysRemainingProvider,
                  );
                  if (daysRemaining != null && daysRemaining > 0) {
                    return _buildStatusRow(
                      'Days Remaining',
                      '$daysRemaining days',
                      AppColors.primaryGold,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ] else ...[
            _buildStatusRow('Status', 'Free Account', Colors.grey),
            _buildStatusRow(
              'Limitations',
              '15 coin limit in history',
              Colors.orange,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showPaywall(context),
                icon: const Icon(Icons.star),
                label: const Text('Upgrade to Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionAnalytics(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> stats,
    bool isPremium,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: isPremium ? AppColors.primaryGold : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Collection Analytics',
                style: TextStyle(
                  fontSize: isMobileSmall ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              if (!isPremium) ...[
                const Spacer(),
                Icon(Icons.lock, color: Colors.grey[400], size: 20),
              ],
            ],
          ),

          const SizedBox(height: 16),

          if (isPremium) ...[
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Total Coins',
                    '${stats['totalCoins'] ?? 0}',
                    Icons.monetization_on,
                    isMobileSmall,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Total Value',
                    '\$${(stats['totalValue'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    isMobileSmall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Avg Confidence',
                    '${(stats['averageConfidence'] ?? 0.0).toInt()}%',
                    Icons.verified,
                    isMobileSmall,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: _buildAnalyticsCard(
                    'Most Valuable',
                    _getMostValuablePrice(stats['mostValuable']),
                    Icons.star,
                    isMobileSmall,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.lock, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Premium Analytics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your collection value, average confidence scores, and detailed insights',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showPaywall(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.primaryNavy,
                    ),
                    child: const Text('Unlock Analytics'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    bool isMobileSmall,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobileSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryGold,
            size: isMobileSmall ? 20 : 24,
          ),
          SizedBox(height: isMobileSmall ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobileSmall ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobileSmall ? 11 : 12,
              color: AppColors.primaryNavy.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: isMobileSmall ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),

          const SizedBox(height: 16),

          _buildQuickActionButton(
            'View History',
            Icons.history,
            () => ref.read(home_rp.navigationProvider.notifier).setIndex(2),
          ),

          const SizedBox(height: 8),

          _buildQuickActionButton(
            'Export Collection',
            Icons.download,
            () => _showExportOptions(context, ref),
          ),

          const SizedBox(height: 8),

          _buildQuickActionButton(
            'Contact Support',
            Icons.support_agent,
            () => _contactSupport(context),
          ),

          const SizedBox(height: 8),

          _buildQuickActionButton(
            'Sign Out',
            Icons.logout,
            () => _signOut(context, ref),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red[600] : AppColors.primaryNavy,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? Colors.red[600] : AppColors.primaryNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection(
    BuildContext context,
    WidgetRef ref,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(
                'Debug Controls',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ref.debugGrantPremium(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Grant Premium',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ref.debugResetSubscription(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset to Free'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'These buttons simulate premium/free states for testing',
            style: TextStyle(fontSize: 12, color: Colors.amber[700]),
          ),
        ],
      ),
    );
  }

  String _getMostValuablePrice(dynamic mostValuable) {
    if (mostValuable == null) return '\$0.00';

    try {
      double? price;
      if (mostValuable is Map<String, dynamic>) {
        price = (mostValuable['priceEstimate'] as num?)?.toDouble();
      } else {
        price = (mostValuable.priceEstimate as num?)?.toDouble();
      }
      return '\$${(price ?? 0.0).toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(source: 'profile'),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    final isPremium = ref.read(isPremiumProvider);

    if (!isPremium) {
      _showPaywall(context);
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Collection'),
            content: const Text('Export functionality coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contact Support'),
            content: const Text('Support system coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }
}
