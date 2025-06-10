// ignore_for_file: use_super_parameters

import 'dart:io';
import 'widgets/save_button.dart';
import 'package:flutter/material.dart';
import '../../river_pods/home_rp.dart';
import 'widgets/coin_image_widget.dart';
import 'widgets/confidence_indicator.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/coin_identification.dart';
import '../../river_pods/identification_rp.dart';
import 'widgets/identification_details_card.dart';
import '../../../core/constants/app_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final String? existingImageUrl;
  final CoinIdentificationResult? existingResult;

  const ResultScreen({
    Key? key,
    required this.imageFile,
    this.existingImageUrl,
    this.existingResult,
  }) : super(key: key);

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startIdentification();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController.forward();
    _fadeController.forward();
  }

  void _startIdentification() {
    if (widget.existingResult == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(identificationProvider.notifier)
              .identifyCoinFromImage(widget.imageFile);
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identificationState = ref.watch(identificationProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final isMobileSmall = Responsive.isMobileSmall(context);

    final result = widget.existingResult ?? identificationState.result;
    final isLoading =
        widget.existingResult == null && identificationState.isLoading;
    final hasError =
        widget.existingResult == null && identificationState.hasError;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          'Identification Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (result != null && !isLoading)
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.primaryNavy),
              onPressed: () => _shareResult(result),
            ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child:
              !connectivityState.isOnline
                  ? _buildOfflineState(isMobileSmall)
                  : hasError
                  ? _buildErrorState(
                    identificationState.errorMessage,
                    isMobileSmall,
                  )
                  : isLoading
                  ? _buildLoadingState(identificationState, isMobileSmall)
                  : result != null
                  ? _buildResultContent(result, isMobileSmall)
                  : _buildInitialState(isMobileSmall),
        ),
      ),
    );
  }

  Widget _buildOfflineState(bool isMobileSmall) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobileSmall ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: isMobileSmall ? 80 : 100,
              color: AppColors.silver,
            ),
            SizedBox(height: isMobileSmall ? 20 : 32),
            Text(
              'You\'re Offline',
              style: TextStyle(
                fontSize: isMobileSmall ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to identify coin while offline. Please check your internet connection and try again.',
              style: TextStyle(
                fontSize: isMobileSmall ? 16 : 18,
                color: AppColors.primaryNavy.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobileSmall ? 24 : 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                'Go Back',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.primaryNavy,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobileSmall ? 20 : 32,
                  vertical: isMobileSmall ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage, bool isMobileSmall) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobileSmall ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isMobileSmall ? 80 : 100,
              color: AppColors.error,
            ),
            SizedBox(height: isMobileSmall ? 20 : 32),
            Text(
              'Identification Failed',
              style: TextStyle(
                fontSize: isMobileSmall ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ??
                  'An unexpected error occurred while identifying your coin.',
              style: TextStyle(
                fontSize: isMobileSmall ? 16 : 18,
                color: AppColors.primaryNavy.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobileSmall ? 24 : 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(identificationProvider.notifier)
                          .retryIdentification(widget.imageFile);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(IdentificationState state, bool isMobileSmall) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobileSmall ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isMobileSmall ? 200 : 250,
              height: isMobileSmall ? 200 : 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(widget.imageFile, fit: BoxFit.cover),
              ),
            ),

            SizedBox(height: isMobileSmall ? 32 : 48),

            Container(
              width: isMobileSmall ? 60 : 80,
              height: isMobileSmall ? 60 : 80,
              child: CircularProgressIndicator(
                value: state.progress,
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold,
                ),
                backgroundColor: AppColors.silver.withOpacity(0.3),
              ),
            ),

            SizedBox(height: isMobileSmall ? 20 : 32),

            Text(
              state.statusMessage,
              style: TextStyle(
                fontSize: isMobileSmall ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _getLoadingDescription(state.status),
              style: TextStyle(
                fontSize: isMobileSmall ? 14 : 16,
                color: AppColors.primaryNavy.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            if (state.progress != null) ...[
              const SizedBox(height: 16),
              Text(
                '${(state.progress! * 100).toInt()}%',
                style: TextStyle(
                  fontSize: isMobileSmall ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent(
    CoinIdentificationResult result,
    bool isMobileSmall,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobileSmall ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoinImageWidget(
            imageFile: widget.imageFile,
            imageUrl: widget.existingImageUrl,
            coinName: result.coinName,
            isMobileSmall: isMobileSmall,
          ),

          SizedBox(height: isMobileSmall ? 20 : 32),

          ConfidenceIndicator(
            confidenceScore: result.confidenceScore,
            isMobileSmall: isMobileSmall,
          ),

          SizedBox(height: isMobileSmall ? 16 : 24),

          IdentificationDetailsCard(
            result: result,
            isMobileSmall: isMobileSmall,
          ),

          SizedBox(height: isMobileSmall ? 20 : 32),

          SaveButton(
            result: result,
            imageUrl: widget.existingImageUrl,
            isAlreadySaved: widget.existingResult != null,
            isMobileSmall: isMobileSmall,
          ),

          SizedBox(height: isMobileSmall ? 16 : 24),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isMobileSmall) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
      ),
    );
  }

  String _getLoadingDescription(IdentificationStatus status) {
    switch (status) {
      case IdentificationStatus.uploading:
        return 'Securely uploading your coin image to our servers...';
      case IdentificationStatus.processing:
        return 'Our AI is analyzing the coin\'s features, date, and condition...';
      case IdentificationStatus.saving:
        return 'Adding this identification to your collection...';
      default:
        return 'Please wait while we process your coin...';
    }
  }

  void _shareResult(CoinIdentificationResult result) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing feature coming soon!'),
        backgroundColor: AppColors.primaryGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
      ),
    );
  }
}
