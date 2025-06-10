import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobileSmall = Responsive.isMobileSmall(context);

    return Column(
      children: [
        Container(
          width: isMobileSmall ? 60 : 80,
          height: isMobileSmall ? 60 : 80,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold,
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.monetization_on,
            size: isMobileSmall ? 30 : 40,
            color: Colors.white,
          ),
        ),

        SizedBox(height: isMobileSmall ? 16 : 24),

        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: Responsive.getResponsiveFontSize(context, 16),
            color: AppColors.primaryNavy.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Coin Identifier Pro',
          style: TextStyle(
            fontSize: Responsive.getResponsiveFontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Your AI-powered numismatic companion',
          style: TextStyle(
            fontSize: Responsive.getResponsiveFontSize(context, 16),
            color: AppColors.primaryGold,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
