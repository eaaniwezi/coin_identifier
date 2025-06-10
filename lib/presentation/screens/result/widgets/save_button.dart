// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../../river_pods/home_rp.dart';
import '../../../../models/coin_identification.dart';
import '../../../river_pods/identification_rp.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaveButton extends ConsumerWidget {
  final CoinIdentificationResult result;
  final String? imageUrl;
  final bool isAlreadySaved;
  final bool isMobileSmall;

  const SaveButton({
    Key? key,
    required this.result,
    this.imageUrl,
    this.isAlreadySaved = false,
    required this.isMobileSmall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identificationState = ref.watch(identificationProvider);
    final isSaving = identificationState.status == IdentificationStatus.saving;
    final isSaved = identificationState.isCompleted || isAlreadySaved;

    return Column(
      children: [
        isSaved || isSaving
            ? SizedBox.shrink()
            : SizedBox(
              width: double.infinity,
              height: isMobileSmall ? 50 : 56,
              child: ElevatedButton.icon(
                onPressed: () => _handleSave(context, ref),
                icon: _buildButtonIcon(isSaved, isSaving),
                label: Text(
                  _getButtonText(isSaved, isSaving),
                  style: TextStyle(
                    fontSize: isMobileSmall ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSaved
                          ? AppColors.success
                          : isSaving
                          ? AppColors.silver
                          : AppColors.primaryGold,
                  foregroundColor:
                      isSaved
                          ? Colors.white
                          : isSaving
                          ? AppColors.primaryNavy.withOpacity(0.7)
                          : AppColors.primaryNavy,
                  disabledBackgroundColor:
                      isSaved
                          ? AppColors.success
                          : AppColors.silver.withOpacity(0.5),
                  disabledForegroundColor:
                      isSaved
                          ? Colors.white
                          : AppColors.primaryNavy.withOpacity(0.5),
                  elevation: isSaved || isSaving ? 0 : 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                  ),
                ),
              ),
            ),

        if (isSaved) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: isMobileSmall ? 16 : 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Saved to your collection',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: isMobileSmall ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        _buildActionButtons(context, ref, isSaved),
      ],
    );
  }

  Widget _buildButtonIcon(bool isSaved, bool isSaving) {
    if (isSaving) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primaryNavy.withOpacity(0.7),
          ),
        ),
      );
    } else if (isSaved) {
      return const Icon(Icons.check_circle, size: 20);
    } else {
      return const Icon(Icons.save, size: 20);
    }
  }

  String _getButtonText(bool isSaved, bool isSaving) {
    if (isSaving) {
      return 'Saving...';
    } else if (isSaved) {
      return 'Saved to Collection';
    } else {
      return 'Save to Collection';
    }
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    bool isSaved,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleIdentifyAnother(context, ref),
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text(
              'Identify Another',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryNavy,
              side: const BorderSide(color: AppColors.primaryNavy),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              padding: EdgeInsets.symmetric(vertical: isMobileSmall ? 12 : 16),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleViewCollection(context, ref),
            icon: const Icon(Icons.history, size: 18),
            label: const Text(
              'View Collection',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              padding: EdgeInsets.symmetric(vertical: isMobileSmall ? 12 : 16),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave(BuildContext context, WidgetRef ref) {
    if (imageUrl != null) {
      ref.read(identificationProvider.notifier).saveResult(result, imageUrl!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to save - image not available'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
        ),
      );
    }
  }

  void _handleIdentifyAnother(BuildContext context, WidgetRef ref) {
    ref.read(identificationProvider.notifier).reset();

    ref.read(navigationProvider.notifier).setIndex(1);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleViewCollection(BuildContext context, WidgetRef ref) {
    ref.read(navigationProvider.notifier).setIndex(2);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
