// ignore_for_file: use_super_parameters, sized_box_for_whitespace

import 'package:flutter/material.dart';
import '../../river_pods/home_rp.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IdentifyScreen extends ConsumerWidget {
  const IdentifyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    final isMobileSmall = Responsive.isMobileSmall(context);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          'How to Identify Coins',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobileSmall ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isMobileSmall),

            SizedBox(height: isMobileSmall ? 24 : 32),

            _buildHowItWorksSection(isMobileSmall),

            SizedBox(height: isMobileSmall ? 24 : 32),

            _buildPhotographyTips(isMobileSmall),

            SizedBox(height: isMobileSmall ? 24 : 32),

            _buildWhatWeIdentify(isMobileSmall),

            SizedBox(height: isMobileSmall ? 24 : 32),

            _buildQuickStartButton(
              context,
              ref,
              connectivityState.isOnline,
              isMobileSmall,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobileSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 20 : 28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: isMobileSmall ? 48 : 60,
            color: Colors.white,
          ),

          SizedBox(height: isMobileSmall ? 16 : 20),

          Text(
            'AI-Powered Coin Recognition',
            style: TextStyle(
              fontSize: isMobileSmall ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Our advanced AI technology can identify coins from around the world with high accuracy and provide detailed information including estimated values.',
            style: TextStyle(
              fontSize: isMobileSmall ? 14 : 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isMobileSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: TextStyle(
            fontSize: isMobileSmall ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),

        SizedBox(height: isMobileSmall ? 16 : 20),

        _buildStep(
          stepNumber: '1',
          title: 'Take or Upload Photo',
          description:
              'Capture a clear image of your coin or select one from your gallery',
          icon: Icons.camera_alt,
          isMobileSmall: isMobileSmall,
        ),

        const SizedBox(height: 16),

        _buildStep(
          stepNumber: '2',
          title: 'AI Analysis',
          description:
              'Our AI analyzes the coin\'s features, date, mint marks, and condition',
          icon: Icons.psychology,
          isMobileSmall: isMobileSmall,
        ),

        const SizedBox(height: 16),

        _buildStep(
          stepNumber: '3',
          title: 'Get Results',
          description:
              'Receive detailed information including origin, year, rarity, and estimated value',
          icon: Icons.analytics,
          isMobileSmall: isMobileSmall,
        ),

        const SizedBox(height: 16),

        _buildStep(
          stepNumber: '4',
          title: 'Save to Collection',
          description:
              'Add identified coins to your personal collection for tracking and analysis',
          icon: Icons.bookmark_add,
          isMobileSmall: isMobileSmall,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required bool isMobileSmall,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isMobileSmall ? 40 : 48,
            height: isMobileSmall ? 40 : 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobileSmall ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: isMobileSmall ? 12 : 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobileSmall ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobileSmall ? 14 : 16,
                    color: AppColors.primaryNavy.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            icon,
            color: AppColors.primaryGold,
            size: isMobileSmall ? 24 : 28,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotographyTips(bool isMobileSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primaryGold,
                size: isMobileSmall ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Photography Tips for Best Results',
                  style: TextStyle(
                    fontSize: isMobileSmall ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobileSmall ? 12 : 16),

          ..._getPhotographyTips().map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: isMobileSmall ? 14 : 16,
                        color: AppColors.primaryNavy.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatWeIdentify(bool isMobileSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What We Can Identify',
          style: TextStyle(
            fontSize: isMobileSmall ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),

        SizedBox(height: isMobileSmall ? 16 : 20),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _getIdentifiableTypes()
                  .map(
                    (type) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: isMobileSmall ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickStartButton(
    BuildContext context,
    WidgetRef ref,
    bool isOnline,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      height: isMobileSmall ? 50 : 56,
      child: ElevatedButton.icon(
        onPressed:
            isOnline
                ? () {
                  ref.read(navigationProvider.notifier).setIndex(0);
                }
                : null,
        icon: Icon(Icons.camera_enhance, size: isMobileSmall ? 20 : 24),
        label: Text(
          isOnline ? 'Start Identifying Coins' : 'Requires Internet Connection',
          style: TextStyle(
            fontSize: isMobileSmall ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOnline
                  ? AppColors.primaryGold
                  : AppColors.silver.withOpacity(0.3),
          foregroundColor: isOnline ? AppColors.primaryNavy : AppColors.silver,
          elevation: isOnline ? 3 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
        ),
      ),
    );
  }

  List<String> _getPhotographyTips() {
    return [
      'Use good lighting - natural daylight works best',
      'Keep the coin flat and centered in the frame',
      'Avoid shadows, glare, and reflections on the surface',
      'Fill most of the frame with the coin',
      'Focus on the side with the clearest details',
      'Hold the camera steady to avoid blur',
      'Clean the coin gently before photographing',
    ];
  }

  List<String> _getIdentifiableTypes() {
    return [
      'US Coins',
      'World Coins',
      'Ancient Coins',
      'Commemorative Coins',
      'Error Coins',
      'Tokens',
      'Medals',
      'Foreign Currency',
    ];
  }
}
