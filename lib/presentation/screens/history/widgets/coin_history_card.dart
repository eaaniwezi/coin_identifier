// ignore_for_file: unnecessary_null_comparison

import 'package:coin_identifier/presentation/screens/history/widgets/rarity_badge.dart';
import 'package:coin_identifier/models/coin_identification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CoinHistoryCard extends StatelessWidget {
  final CoinIdentification coin;
  final VoidCallback onTap;
  final bool isPremium;

  const CoinHistoryCard({
    Key? key,
    required this.coin,
    required this.onTap,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildCoinImage(),

                const SizedBox(width: 16),

                Expanded(child: _buildCoinDetails(context)),

                _buildPriceSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            coin.imageUrl != null
                ? CachedNetworkImage(
                  imageUrl: coin.imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      ),
                )
                : Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.monetization_on,
                    color: Colors.grey[400],
                    size: 30,
                  ),
                ),
      ),
    );
  }

  Widget _buildCoinDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          coin.coinName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            Flexible(
              child: Text(
                coin.origin,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (coin.issueYear != null) ...[
              Text(
                ' • ${coin.issueYear}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 2),
            Text(
              coin.identifiedAt != null
                  ? DateFormat('MMM dd, yyyy').format(coin.identifiedAt)
                  : 'Unknown date',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),

            const SizedBox(width: 5),
            RarityBadge(rarity: coin.rarity, size: RarityBadgeSize.small),
          ],
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            Icon(
              Icons.verified,
              size: 14,
              color: _getConfidenceColor(coin.confidenceScore),
            ),
            const SizedBox(width: 4),
            Text(
              '${(coin.confidenceScore).toInt()}% confident',
              style: TextStyle(
                fontSize: 12,
                color: _getConfidenceColor(coin.confidenceScore),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Text(
            NumberFormat.currency(symbol: '\$').format(coin.priceEstimate),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ],
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
