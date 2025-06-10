// ignore_for_file: use_super_parameters

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../models/coin_identification.dart';

class IdentificationDetailsCard extends StatelessWidget {
  final CoinIdentificationResult result;
  final bool isMobileSmall;

  const IdentificationDetailsCard({
    Key? key,
    required this.result,
    required this.isMobileSmall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coin Details',
              style: TextStyle(
                fontSize: isMobileSmall ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),

            SizedBox(height: isMobileSmall ? 16 : 20),

            _buildPriceSection(),

            const SizedBox(height: 20),

            _buildDetailsGrid(),

            if (result.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDescription(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Estimated Value',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isMobileSmall ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(result.priceEstimate),
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobileSmall ? 28 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'USD',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isMobileSmall ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem('Origin', result.origin, Icons.public),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                'Year',
                result.issueYear.toString(),
                Icons.calendar_today,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Rarity',
                result.rarity,
                Icons.diamond,
                color: _getRarityColor(result.rarity),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                'Mint Mark',
                result.mintMark ?? 'None',
                Icons.location_on,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobileSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isMobileSmall ? 16 : 18,
                color: color ?? AppColors.primaryGold,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobileSmall ? 12 : 14,
                  color: AppColors.primaryNavy.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobileSmall ? 14 : 16,
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                size: isMobileSmall ? 16 : 18,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 6),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: isMobileSmall ? 12 : 14,
                  color: AppColors.primaryNavy.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.description,
            style: TextStyle(
              fontSize: isMobileSmall ? 14 : 16,
              color: AppColors.primaryNavy,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF4CAF50);
      case 'uncommon':
        return const Color(0xFF2196F3);
      case 'rare':
        return const Color(0xFF9C27B0);
      case 'very rare':
        return const Color(0xFFFF9800);
      case 'error':
        return const Color(0xFFF44336);
      default:
        return AppColors.primaryGold;
    }
  }
}
