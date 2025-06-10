// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionProduct {
  final String id;
  final String title;
  final String description;
  final String price;
  final String? originalPrice;
  final String? savings;
  final bool isPopular;
  final List<String> features;
  final Duration trialPeriod;

  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    this.savings,
    this.isPopular = false,
    required this.features,
    this.trialPeriod = Duration.zero,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'savings': savings,
      'isPopular': isPopular,
      'features': features,
      'trialPeriod': trialPeriod.inDays,
    };
  }

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) {
    return SubscriptionProduct(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      originalPrice: json['originalPrice'],
      savings: json['savings'],
      isPopular: json['isPopular'] ?? false,
      features: List<String>.from(json['features']),
      trialPeriod: Duration(days: json['trialPeriod'] ?? 0),
    );
  }
}

class PurchaseResult {
  final bool success;
  final String? error;
  final String? transactionId;
  final SubscriptionProduct? product;

  const PurchaseResult({
    required this.success,
    this.error,
    this.transactionId,
    this.product,
  });
}

class SubscriptionStatus {
  final bool isPremium;
  final String? productId;
  final DateTime? purchaseDate;
  final DateTime? expirationDate;
  final bool isTrialPeriod;

  const SubscriptionStatus({
    this.isPremium = false,
    this.productId,
    this.purchaseDate,
    this.expirationDate,
    this.isTrialPeriod = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'productId': productId,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'isTrialPeriod': isTrialPeriod,
    };
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isPremium: json['isPremium'] ?? false,
      productId: json['productId'],
      purchaseDate:
          json['purchaseDate'] != null
              ? DateTime.parse(json['purchaseDate'])
              : null,
      expirationDate:
          json['expirationDate'] != null
              ? DateTime.parse(json['expirationDate'])
              : null,
      isTrialPeriod: json['isTrialPeriod'] ?? false,
    );
  }
}

class ApphudService {
  static ApphudService? _instance;
  static ApphudService get instance => _instance ??= ApphudService._();

  ApphudService._();

  // Mock subscription products
  static const List<SubscriptionProduct> _mockProducts = [
    SubscriptionProduct(
      id: 'pro_monthly',
      title: 'Monthly Pro',
      description: 'Full access to all premium features',
      price: '\$4.99/month',
      isPopular: false,
      features: [
        'Unlimited coin identifications',
        'Full collection history',
        'Collection value tracking',
        'Advanced search & filters',
        'Export collection data',
        'Priority customer support',
      ],
    ),
    SubscriptionProduct(
      id: 'pro_yearly',
      title: 'Yearly Pro',
      description: 'Best value - save 33% with annual billing',
      price: '\$39.99/year',
      originalPrice: '\$59.88',
      savings: 'Save 33%',
      isPopular: true,
      trialPeriod: Duration(days: 7),
      features: [
        'Everything in Monthly Pro',
        '7-day free trial',
        'Advanced collection analytics',
        'Coin rarity insights',
        'Market trend notifications',
        'Premium coin database access',
        'Exclusive collector community',
      ],
    ),
  ];

  final StreamController<SubscriptionStatus> _subscriptionController =
      StreamController<SubscriptionStatus>.broadcast();

  SubscriptionStatus _currentStatus = const SubscriptionStatus();

  Future<bool> initialize() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));

      await _loadSubscriptionStatus();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<SubscriptionProduct>> getProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 80));

      return _mockProducts;
    } catch (e) {
      throw Exception('Failed to load subscription products');
    }
  }

  SubscriptionStatus get subscriptionStatus => _currentStatus;

  Stream<SubscriptionStatus> get subscriptionStream =>
      _subscriptionController.stream;

  bool get isPremium => _currentStatus.isPremium;

  Future<PurchaseResult> purchaseProduct(SubscriptionProduct product) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      final purchaseDate = DateTime.now();
      final expirationDate =
          product.id == 'pro_monthly'
              ? purchaseDate.add(const Duration(days: 30))
              : purchaseDate.add(const Duration(days: 365));

      _currentStatus = SubscriptionStatus(
        isPremium: true,
        productId: product.id,
        purchaseDate: purchaseDate,
        expirationDate: expirationDate,
        isTrialPeriod: product.trialPeriod.inDays > 0,
      );

      await _saveSubscriptionStatus();

      _subscriptionController.add(_currentStatus);

      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';

      return PurchaseResult(
        success: true,
        transactionId: transactionId,
        product: product,
      );
    } catch (e) {
      return PurchaseResult(success: false, error: e.toString());
    }
  }

  Future<PurchaseResult> restorePurchases() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (_currentStatus.isPremium) {
        return PurchaseResult(success: true);
      } else {
        return PurchaseResult(
          success: false,
          error: 'No active subscriptions found',
        );
      }
    } catch (e) {
      return PurchaseResult(success: false, error: e.toString());
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = prefs.getString('apphud_subscription_status');

      if (statusJson != null) {
        final statusMap = jsonDecode(statusJson);
        _currentStatus = SubscriptionStatus.fromJson(statusMap);

        if (_currentStatus.isPremium && _currentStatus.expirationDate != null) {
          if (DateTime.now().isAfter(_currentStatus.expirationDate!)) {
            _currentStatus = const SubscriptionStatus();
            await _saveSubscriptionStatus();
          }
        }
      }

      _subscriptionController.add(_currentStatus);
    } catch (e) {}
  }

  Future<void> _saveSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = jsonEncode(_currentStatus.toJson());
      await prefs.setString('apphud_subscription_status', statusJson);
    } catch (e) {}
  }

  Future<void> resetSubscription() async {
    _currentStatus = const SubscriptionStatus();
    await _saveSubscriptionStatus();
    _subscriptionController.add(_currentStatus);
  }

  Future<void> grantPremiumAccess() async {
    final purchaseDate = DateTime.now();
    _currentStatus = SubscriptionStatus(
      isPremium: true,
      productId: 'debug_premium',
      purchaseDate: purchaseDate,
      expirationDate: purchaseDate.add(const Duration(days: 365)),
      isTrialPeriod: false,
    );
    await _saveSubscriptionStatus();
    _subscriptionController.add(_currentStatus);
  }

  void dispose() {
    _subscriptionController.close();
  }
}
