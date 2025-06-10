// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import '../../result/result_screen.dart';
import '../../../river_pods/home_rp.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainActionButtons extends ConsumerWidget {
  const MainActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    final isMobileSmall = Responsive.isMobileSmall(context);

    return Column(
      children: [
        _buildMainIdentifyButton(
          context,
          ref,
          connectivityState.isOnline,
          isMobileSmall,
        ),
      ],
    );
  }

  Widget _buildMainIdentifyButton(
    BuildContext context,
    WidgetRef ref,
    bool isOnline,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      height: isMobileSmall ? 60 : 70,
      decoration: BoxDecoration(
        gradient:
            isOnline
                ? AppColors.primaryGradient
                : LinearGradient(
                  colors: [AppColors.silver, AppColors.silver.withOpacity(0.8)],
                ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow:
            isOnline
                ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
                : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOnline ? () => _showIdentifyOptions(context, ref) : null,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_enhance,
                  color: Colors.white,
                  size: isMobileSmall ? 28 : 32,
                ),
                SizedBox(width: isMobileSmall ? 12 : 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identify Coin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileSmall ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isOnline)
                      Text(
                        'Requires internet connection',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isMobileSmall ? 12 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIdentifyOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text(
                  'How would you like to identify your coin?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your preferred method to capture the coin image',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryNavy.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildModalOption(
                  context,
                  ref,
                  'Take Photo',
                  Icons.camera_alt,
                  'Use your camera to capture the coin',
                  () => _handleTakePhoto(context, ref),
                ),
                const SizedBox(height: 12),
                _buildModalOption(
                  context,
                  ref,
                  'Choose from Gallery',
                  Icons.photo_library,
                  'Select an existing photo from your gallery',
                  () => _handleChooseFromGallery(context, ref),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _buildModalOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.silver.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 24),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryNavy.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.silver, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleChooseFromGallery(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        Navigator.pop(context);

        await Future.delayed(const Duration(milliseconds: 100));

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(imageFile: File(image.path)),
            ),
          );
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);

      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Failed to select image. Please try again.',
        );
      }
    }
  }

  Future<void> _handleTakePhoto(BuildContext context, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 100));

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(imageFile: File(image.path)),
            ),
          );
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);

      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to take photo. Please try again.');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
      ),
    );
  }
}
