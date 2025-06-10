import 'package:coin_identifier/models/coin_identification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectionStatsHeader extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isPremium;
  final VoidCallback onUpgradePressed;

  const CollectionStatsHeader({
    Key? key,
    required this.stats,
    required this.isPremium,
    required this.onUpgradePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalCoins = stats['totalCoins'] as int;
    final totalValue = stats['totalValue'] as double;
    final averageConfidence = stats['averageConfidence'] as double;
    final mostValuable = stats['mostValuable'] as CoinIdentification?;

    if (totalCoins == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isPremium
                  ? [Colors.blue[50]!, Colors.indigo[50]!]
                  : [Colors.grey[50]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: isPremium ? Colors.blue[700] : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Collection Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.blue[800] : Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (!isPremium) _buildUpgradeButton(),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.monetization_on,
                    label: 'Total Coins',
                    value: totalCoins.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Total Value',
                    value: NumberFormat.currency(
                      symbol: '\$',
                    ).format(totalValue),
                    color: Colors.green,
                    isBlurred: !isPremium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.verified,
                    label: 'Avg Confidence',
                    value: '${averageConfidence.toInt()}%',
                    color: Colors.orange,
                    isBlurred: !isPremium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    label: 'Most Valuable',
                    value:
                        mostValuable != null
                            ? NumberFormat.currency(
                              symbol: '\$',
                            ).format(mostValuable.priceEstimate)
                            : '-',
                    color: Colors.purple,
                    isBlurred: !isPremium,
                  ),
                ),
              ],
            ),

            if (!isPremium) ...[
              const SizedBox(height: 12),
              _buildPremiumNotice(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isBlurred = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(.6), size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(.7),
                ),
                textAlign: TextAlign.center,
              ),
              if (isBlurred)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300]?.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: InkWell(
        onTap: onUpgradePressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber[700]),
            const SizedBox(width: 4),
            Text(
              'Pro',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.amber[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumNotice() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, size: 16, color: Colors.amber[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Upgrade to Pro to unlock detailed collection analytics',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onUpgradePressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Upgrade',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
