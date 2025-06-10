// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

enum RarityBadgeSize { small, medium, large }

class RarityBadge extends StatelessWidget {
  final String rarity;
  final RarityBadgeSize size;

  const RarityBadge({
    Key? key,
    required this.rarity,
    this.size = RarityBadgeSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getRarityConfig(rarity);
    final sizeConfig = _getSizeConfig(size);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConfig.horizontalPadding,
        vertical: sizeConfig.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.iconColor, size: sizeConfig.iconSize),
          SizedBox(width: sizeConfig.spacing),
          Text(
            rarity.toUpperCase(),
            style: TextStyle(
              fontSize: sizeConfig.fontSize,
              fontWeight: FontWeight.w600,
              color: config.textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  RarityConfig _getRarityConfig(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return RarityConfig(
          backgroundColor: Colors.grey[100]!,
          borderColor: Colors.grey[300]!,
          textColor: Colors.grey[700]!,
          iconColor: Colors.grey[600]!,
          icon: Icons.circle,
        );
      case 'uncommon':
        return RarityConfig(
          backgroundColor: Colors.green[50]!,
          borderColor: Colors.green[300]!,
          textColor: Colors.green[700]!,
          iconColor: Colors.green[600]!,
          icon: Icons.circle,
        );
      case 'rare':
        return RarityConfig(
          backgroundColor: Colors.blue[50]!,
          borderColor: Colors.blue[300]!,
          textColor: Colors.blue[700]!,
          iconColor: Colors.blue[600]!,
          icon: Icons.diamond,
        );
      case 'very rare':
        return RarityConfig(
          backgroundColor: Colors.purple[50]!,
          borderColor: Colors.purple[300]!,
          textColor: Colors.purple[700]!,
          iconColor: Colors.purple[600]!,
          icon: Icons.diamond,
        );
      case 'error':
        return RarityConfig(
          backgroundColor: Colors.red[50]!,
          borderColor: Colors.red[300]!,
          textColor: Colors.red[700]!,
          iconColor: Colors.red[600]!,
          icon: Icons.warning,
        );
      case 'legendary':
        return RarityConfig(
          backgroundColor: Colors.amber[50]!,
          borderColor: Colors.amber[300]!,
          textColor: Colors.amber[800]!,
          iconColor: Colors.amber[600]!,
          icon: Icons.star,
        );
      default:
        return RarityConfig(
          backgroundColor: Colors.grey[100]!,
          borderColor: Colors.grey[300]!,
          textColor: Colors.grey[700]!,
          iconColor: Colors.grey[600]!,
          icon: Icons.help_outline,
        );
    }
  }

  SizeConfig _getSizeConfig(RarityBadgeSize size) {
    switch (size) {
      case RarityBadgeSize.small:
        return SizeConfig(
          fontSize: 10,
          iconSize: 12,
          horizontalPadding: 6,
          verticalPadding: 2,
          borderRadius: 8,
          spacing: 3,
        );
      case RarityBadgeSize.medium:
        return SizeConfig(
          fontSize: 12,
          iconSize: 14,
          horizontalPadding: 8,
          verticalPadding: 4,
          borderRadius: 10,
          spacing: 4,
        );
      case RarityBadgeSize.large:
        return SizeConfig(
          fontSize: 14,
          iconSize: 16,
          horizontalPadding: 12,
          verticalPadding: 6,
          borderRadius: 12,
          spacing: 6,
        );
    }
  }
}

class RarityConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  RarityConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}

class SizeConfig {
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double spacing;

  SizeConfig({
    required this.fontSize,
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.spacing,
  });
}
