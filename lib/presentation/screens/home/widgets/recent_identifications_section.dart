// ignore_for_file: use_super_parameters, unnecessary_null_comparison

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../river_pods/home_rp.dart';
import '../../../river_pods/history_rp.dart';
import '../../../../core/utils/responsive.dart';
import '../../history/history_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coin_identifier/models/coin_identification.dart';

class RecentIdentificationsSection extends ConsumerWidget {
  const RecentIdentificationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final isMobileSmall = Responsive.isMobileSmall(context);

    final recentCoins = historyState.coins.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Identifications',
              style: TextStyle(
                fontSize: Responsive.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            if (recentCoins.isNotEmpty)
              TextButton(
                onPressed: () {
                  ref.read(navigationProvider.notifier).setIndex(2);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGold,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),

        SizedBox(height: isMobileSmall ? 12 : 16),

        if (historyState.isLoading && recentCoins.isEmpty)
          _buildLoadingState(isMobileSmall)
        else if (historyState.error != null && recentCoins.isEmpty)
          _buildErrorState(context, ref, historyState.error!, isMobileSmall)
        else if (recentCoins.isEmpty)
          _buildEmptyState(context, ref, isMobileSmall)
        else
          _buildIdentificationsList(recentCoins, isMobileSmall, context),
      ],
    );
  }

  Widget _buildLoadingState(bool isMobileSmall) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: isMobileSmall ? 140 : 160,
            margin: EdgeInsets.only(right: isMobileSmall ? 12 : 16),
            child: _buildSkeletonCard(isMobileSmall),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonCard(bool isMobileSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobileSmall ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: isMobileSmall ? 60 : 70,
              decoration: BoxDecoration(
                color: AppColors.silver.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGold,
                  ),
                ),
              ),
            ),

            SizedBox(height: isMobileSmall ? 8 : 12),

            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.silver.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.silver.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String error,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: isMobileSmall ? 40 : 50,
            color: AppColors.error,
          ),
          SizedBox(height: isMobileSmall ? 12 : 16),
          Text(
            'Failed to load identifications',
            style: TextStyle(
              fontSize: isMobileSmall ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.length > 50 ? '${error.substring(0, 50)}...' : error,
            style: TextStyle(
              fontSize: isMobileSmall ? 12 : 14,
              color: AppColors.primaryNavy.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobileSmall ? 12 : 16),
          ElevatedButton(
            onPressed: () {
              ref.read(historyProvider.notifier).refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.primaryNavy,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    bool isMobileSmall,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobileSmall ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(
          color: AppColors.silver.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: isMobileSmall ? 60 : 80,
            height: isMobileSmall ? 60 : 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_enhance,
              size: isMobileSmall ? 30 : 40,
              color: AppColors.primaryGold,
            ),
          ),

          SizedBox(height: isMobileSmall ? 16 : 20),

          Text(
            'No coins identified yet',
            style: TextStyle(
              fontSize: isMobileSmall ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Start by taking a photo or selecting one from your gallery to identify your first coin!',
            style: TextStyle(
              fontSize: isMobileSmall ? 14 : 16,
              color: AppColors.primaryNavy.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isMobileSmall ? 16 : 20),

          ElevatedButton.icon(
            onPressed: () {
              ref.read(navigationProvider.notifier).setIndex(0);
            },
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text(
              'Identify First Coin',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobileSmall ? 16 : 20,
                vertical: isMobileSmall ? 8 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentificationsList(
    List<CoinIdentification> identifications,
    bool isMobileSmall,
    BuildContext context,
  ) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: identifications.length,
        itemBuilder: (context, index) {
          final identification = identifications[index];
          return Container(
            width: isMobileSmall ? 140 : 160,
            margin: EdgeInsets.only(right: isMobileSmall ? 12 : 16),
            child: _buildIdentificationCard(
              identification,
              isMobileSmall,
              context,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdentificationCard(
    CoinIdentification identification,
    bool isMobileSmall,
    BuildContext context,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM d');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryDetailScreen(coin: identification),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Padding(
            padding: EdgeInsets.all(isMobileSmall ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: isMobileSmall ? 60 : 70,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        identification.imageUrl != null &&
                                identification.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: identification.imageUrl,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: AppColors.silver.withOpacity(0.3),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primaryGold,
                                            ),
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(
                                    Icons.monetization_on,
                                    color: AppColors.silver,
                                    size: isMobileSmall ? 24 : 28,
                                  ),
                            )
                            : Icon(
                              Icons.monetization_on,
                              color: AppColors.silver,
                              size: isMobileSmall ? 24 : 28,
                            ),
                  ),
                ),

                SizedBox(height: isMobileSmall ? 8 : 12),

                Text(
                  identification.coinName,
                  style: TextStyle(
                    fontSize: isMobileSmall ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(identification.priceEstimate),
                      style: TextStyle(
                        fontSize: isMobileSmall ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    Text(
                      identification.identifiedAt != null
                          ? dateFormat.format(identification.identifiedAt)
                          : 'Unknown',
                      style: TextStyle(
                        fontSize: isMobileSmall ? 10 : 12,
                        color: AppColors.silver,
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
}
