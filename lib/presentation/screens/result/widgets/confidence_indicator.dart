// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class ConfidenceIndicator extends StatefulWidget {
  final double confidenceScore;
  final bool isMobileSmall;

  const ConfidenceIndicator({
    Key? key,
    required this.confidenceScore,
    required this.isMobileSmall,
  }) : super(key: key);

  @override
  State<ConfidenceIndicator> createState() => _ConfidenceIndicatorState();
}

class _ConfidenceIndicatorState extends State<ConfidenceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.confidenceScore / 100.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.isMobileSmall ? 16 : 20),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence Score',
                style: TextStyle(
                  fontSize: widget.isMobileSmall ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getConfidenceLabel(),
                  style: TextStyle(
                    fontSize: widget.isMobileSmall ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: _getConfidenceColor(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(widget.confidenceScore * _progressAnimation.value).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: widget.isMobileSmall ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(),
                        ),
                      ),
                      Icon(
                        _getConfidenceIcon(),
                        color: _getConfidenceColor(),
                        size: widget.isMobileSmall ? 20 : 24,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: AppColors.silver.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getConfidenceColor(),
                    ),
                    minHeight: 6,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            _getConfidenceDescription(),
            style: TextStyle(
              fontSize: widget.isMobileSmall ? 14 : 16,
              color: AppColors.primaryNavy.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    if (widget.confidenceScore >= 90) {
      return const Color(0xFF4CAF50);
    } else if (widget.confidenceScore >= 75) {
      return AppColors.primaryGold;
    } else if (widget.confidenceScore >= 60) {
      return const Color(0xFFFF9800);
    } else {
      return AppColors.error;
    }
  }

  String _getConfidenceLabel() {
    if (widget.confidenceScore >= 90) {
      return 'Excellent';
    } else if (widget.confidenceScore >= 75) {
      return 'Very Good';
    } else if (widget.confidenceScore >= 60) {
      return 'Good';
    } else {
      return 'Fair';
    }
  }

  IconData _getConfidenceIcon() {
    if (widget.confidenceScore >= 90) {
      return Icons.verified;
    } else if (widget.confidenceScore >= 75) {
      return Icons.thumb_up;
    } else if (widget.confidenceScore >= 60) {
      return Icons.help_outline;
    } else {
      return Icons.warning_outlined;
    }
  }

  String _getConfidenceDescription() {
    if (widget.confidenceScore >= 90) {
      return 'Our AI is highly confident in this identification';
    } else if (widget.confidenceScore >= 75) {
      return 'This identification appears to be accurate';
    } else if (widget.confidenceScore >= 60) {
      return 'Please verify this identification with an expert';
    } else {
      return 'This identification may not be accurate - consider retaking the photo';
    }
  }
}
