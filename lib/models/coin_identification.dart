import 'package:flutter/material.dart';

class CoinIdentificationResult {
  final String coinName;
  final String origin;
  final int issueYear;
  final String? mintMark;
  final String rarity;
  final double priceEstimate;
  final int confidenceScore; // Changed from double to int
  final String description;

  const CoinIdentificationResult({
    required this.coinName,
    required this.origin,
    required this.issueYear,
    this.mintMark,
    required this.rarity,
    required this.priceEstimate,
    required this.confidenceScore,
    required this.description,
  });

  factory CoinIdentificationResult.fromJson(Map<String, dynamic> json) {
    return CoinIdentificationResult(
      coinName: json['coin_name'] ?? 'Unknown Coin',
      origin: json['origin'] ?? 'Unknown',
      issueYear: json['issue_year'] ?? 0,
      mintMark: json['mint_mark'],
      rarity: json['rarity'] ?? 'Unknown',
      priceEstimate: (json['price_estimate'] ?? 0.0).toDouble(),
      confidenceScore:
          (json['confidence_score'] ?? 0).toInt(), // Convert to int
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coin_name': coinName,
      'origin': origin,
      'issue_year': issueYear,
      'mint_mark': mintMark,
      'rarity': rarity,
      'price_estimate': priceEstimate,
      'confidence_score': confidenceScore,
      'description': description,
    };
  }
}

class CoinIdentification {
  final String id;
  final String userId;
  final String imageUrl;
  final String coinName;
  final String origin;
  final int issueYear;
  final String? mintMark;
  final String rarity;
  final double priceEstimate;
  final int confidenceScore; // Changed from double to int
  final String description;
  final DateTime identifiedAt;
  final DateTime createdAt;

  const CoinIdentification({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.coinName,
    required this.origin,
    required this.issueYear,
    this.mintMark,
    required this.rarity,
    required this.priceEstimate,
    required this.confidenceScore,
    required this.description,
    required this.identifiedAt,
    required this.createdAt,
  });

  factory CoinIdentification.fromSupabase(Map<String, dynamic> data) {
    return CoinIdentification(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      imageUrl: data['image_url'] ?? '',
      coinName: data['coin_name'] ?? 'Unknown Coin',
      origin: data['origin'] ?? 'Unknown',
      issueYear: data['issue_year'] ?? 0,
      mintMark: data['mint_mark'],
      rarity: data['rarity'] ?? 'Unknown',
      priceEstimate: (data['price_estimate'] ?? 0.0).toDouble(),
      confidenceScore:
          (data['confidence_score'] ?? 0).toInt(), // Convert to int
      description: data['description'] ?? '',
      identifiedAt:
          data['identified_at'] != null
              ? DateTime.parse(data['identified_at'])
              : DateTime.now(),
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'image_url': imageUrl,
      'coin_name': coinName,
      'origin': origin,
      'issue_year': issueYear,
      'mint_mark': mintMark,
      'rarity': rarity,
      'price_estimate': priceEstimate,
      'confidence_score': confidenceScore,
      'description': description,
      'identified_at': identifiedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  CoinIdentificationResult toResult() {
    return CoinIdentificationResult(
      coinName: coinName,
      origin: origin,
      issueYear: issueYear,
      mintMark: mintMark,
      rarity: rarity,
      priceEstimate: priceEstimate,
      confidenceScore: confidenceScore,
      description: description,
    );
  }

  String get displayName => coinName;
  String get displayOrigin => '$origin ($issueYear)';
  String get displayPrice => '\$${priceEstimate.toStringAsFixed(2)}';
  String get displayConfidence =>
      '$confidenceScore%'; // Removed toStringAsFixed since it's now int

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(identifiedAt).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  Color get rarityColor {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF4CAF50);
      case 'uncommon':
        return const Color(0xFF2196F3);
      case 'rare':
        return const Color(0xFF9C27B0);
      case 'very rare':
        return const Color(0xFFFF9800);
      case 'error':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinIdentification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum IdentificationStatus {
  idle,
  uploading,
  processing,
  saving,
  completed,
  error,
}

class IdentificationState {
  final IdentificationStatus status;
  final String? errorMessage;
  final double? progress;
  final CoinIdentificationResult? result;
  final String? savedId;

  const IdentificationState({
    this.status = IdentificationStatus.idle,
    this.errorMessage,
    this.progress,
    this.result,
    this.savedId,
  });

  IdentificationState copyWith({
    IdentificationStatus? status,
    String? errorMessage,
    double? progress,
    CoinIdentificationResult? result,
    String? savedId,
  }) {
    return IdentificationState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      savedId: savedId ?? this.savedId,
    );
  }

  bool get isLoading =>
      status == IdentificationStatus.uploading ||
      status == IdentificationStatus.processing ||
      status == IdentificationStatus.saving;

  bool get hasError => status == IdentificationStatus.error;
  bool get isCompleted => status == IdentificationStatus.completed;

  String get statusMessage {
    switch (status) {
      case IdentificationStatus.idle:
        return 'Ready to identify';
      case IdentificationStatus.uploading:
        return 'Uploading image...';
      case IdentificationStatus.processing:
        return 'Analyzing coin...';
      case IdentificationStatus.saving:
        return 'Saving to collection...';
      case IdentificationStatus.completed:
        return 'Identification complete';
      case IdentificationStatus.error:
        return errorMessage ?? 'An error occurred';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IdentificationState &&
        other.status == status &&
        other.errorMessage == errorMessage &&
        other.progress == progress &&
        other.result == result &&
        other.savedId == savedId;
  }

  @override
  int get hashCode =>
      Object.hash(status, errorMessage, progress, result, savedId);
}
