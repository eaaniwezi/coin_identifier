// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../../../services/apphud_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionProduct product;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMobileSmall;

  const SubscriptionCard({
    Key? key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.isMobileSmall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? AppColors.primaryGold.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
              child: Row(
                children: [
                  _buildSelectionIndicator(),

                  SizedBox(width: isMobileSmall ? 12 : 16),

                  Expanded(child: _buildProductDetails()),

                  _buildPriceSection(),
                ],
              ),
            ),

            if (product.isPopular) _buildPopularBadge(),

            if (product.trialPeriod.inDays > 0) _buildTrialIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primaryGold : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primaryGold : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child:
          isSelected
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: TextStyle(
            fontSize: isMobileSmall ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),

        SizedBox(height: isMobileSmall ? 4 : 6),

        Text(
          product.description,
          style: TextStyle(
            fontSize: isMobileSmall ? 12 : 14,
            color: AppColors.primaryNavy.withOpacity(0.7),
          ),
        ),

        if (product.trialPeriod.inDays > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              '${product.trialPeriod.inDays}-day free trial',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          product.price,
          style: TextStyle(
            fontSize: isMobileSmall ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),

        if (product.originalPrice != null) ...[
          const SizedBox(height: 2),
          Text(
            product.originalPrice!,
            style: TextStyle(
              fontSize: isMobileSmall ? 12 : 14,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],

        if (product.savings != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.savings!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPopularBadge() {
    return Positioned(
      top: -1,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.red[400]!],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: const Text(
          'MOST POPULAR',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTrialIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryGold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'Free Trial',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
