// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class PremiumFeaturesList extends StatelessWidget {
  final bool isMobileSmall;

  const PremiumFeaturesList({Key? key, required this.isMobileSmall})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Features',
                      style: TextStyle(
                        fontSize: isMobileSmall ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Text(
                      'Everything you need for serious collecting',
                      style: TextStyle(
                        fontSize: isMobileSmall ? 12 : 14,
                        color: AppColors.primaryNavy.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isMobileSmall ? 20 : 24),

          _buildComparisonSection(),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(flex: 2, child: SizedBox()),
            Expanded(
              child: Text(
                'Free',
                style: TextStyle(
                  fontSize: isMobileSmall ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Pro',
                  style: TextStyle(
                    fontSize: isMobileSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildFeatureRow(
          'Coin identifications',
          'Limited',
          'Unlimited',
          Icons.camera_enhance,
        ),
        _buildFeatureRow(
          'Collection history',
          '15 coins',
          'Full history',
          Icons.history,
        ),
        _buildFeatureRow(
          'Collection value tracking',
          '❌',
          '✅',
          Icons.account_balance_wallet,
        ),
        _buildFeatureRow('Advanced search & filters', '❌', '✅', Icons.search),
        _buildFeatureRow('Collection analytics', '❌', '✅', Icons.analytics),
        _buildFeatureRow('Export collection data', '❌', '✅', Icons.download),
        _buildFeatureRow('Priority support', '❌', '✅', Icons.support_agent),
      ],
    );
  }

  Widget _buildFeatureRow(
    String feature,
    String freeValue,
    String proValue,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: isMobileSmall ? 13 : 15,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Text(
              freeValue,
              style: TextStyle(
                fontSize: isMobileSmall ? 12 : 14,
                color:
                    freeValue.contains('❌')
                        ? Colors.red[600]
                        : AppColors.primaryNavy.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                proValue,
                style: TextStyle(
                  fontSize: isMobileSmall ? 12 : 14,
                  color:
                      proValue.contains('✅')
                          ? Colors.green[600]
                          : AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
