import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/apphud_service.dart';

class PaywallState {
  final List<SubscriptionProduct> products;
  final bool isLoading;
  final bool isPurchasing;
  final String? error;
  final SubscriptionProduct? selectedProduct;
  final PurchaseResult? lastPurchaseResult;

  const PaywallState({
    this.products = const [],
    this.isLoading = false,
    this.isPurchasing = false,
    this.error,
    this.selectedProduct,
    this.lastPurchaseResult,
  });

  PaywallState copyWith({
    List<SubscriptionProduct>? products,
    bool? isLoading,
    bool? isPurchasing,
    String? error,
    SubscriptionProduct? selectedProduct,
    PurchaseResult? lastPurchaseResult,
  }) {
    return PaywallState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      error: error,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      lastPurchaseResult: lastPurchaseResult ?? this.lastPurchaseResult,
    );
  }
}

class PaywallNotifier extends StateNotifier<PaywallState> {
  PaywallNotifier() : super(const PaywallState()) {
    loadProducts();
  }

  final ApphudService _apphudService = ApphudService.instance;

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await _apphudService.getProducts();

      final popularProduct = products.firstWhere(
        (product) => product.isPopular,
        orElse: () => products.first,
      );

      state = state.copyWith(
        isLoading: false,
        products: products,
        selectedProduct: popularProduct,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectProduct(SubscriptionProduct product) {
    state = state.copyWith(selectedProduct: product);
  }

  Future<void> purchaseSelectedProduct() async {
    if (state.selectedProduct == null) {
      return;
    }

    await purchaseProduct(state.selectedProduct!);
  }

  Future<void> purchaseProduct(SubscriptionProduct product) async {
    state = state.copyWith(isPurchasing: true, error: null);

    try {
      final result = await _apphudService.purchaseProduct(product);

      state = state.copyWith(isPurchasing: false, lastPurchaseResult: result);

      if (result.success) {
      } else {
        state = state.copyWith(error: result.error);
      }
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apphudService.restorePurchases();

      state = state.copyWith(isLoading: false, lastPurchaseResult: result);

      if (!result.success) {
        state = state.copyWith(error: result.error);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearLastPurchaseResult() {
    state = state.copyWith(lastPurchaseResult: null);
  }
}

class SubscriptionStatusNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionStatusNotifier() : super(const SubscriptionStatus()) {
    _initializeSubscriptionListener();
  }

  final ApphudService _apphudService = ApphudService.instance;

  void _initializeSubscriptionListener() {
    state = _apphudService.subscriptionStatus;

    _apphudService.subscriptionStream.listen((status) {
      state = status;
    });
  }

  bool get isPremium => state.isPremium;

  SubscriptionProduct? get currentProduct {
    if (state.productId == null) return null;

    return SubscriptionProduct(
      id: state.productId!,
      title: state.productId == 'pro_monthly' ? 'Monthly Pro' : 'Yearly Pro',
      description: 'Premium subscription',
      price: state.productId == 'pro_monthly' ? '\$4.99/month' : '\$39.99/year',
      features: [],
    );
  }

  bool get isInTrial => state.isTrialPeriod;

  int? get daysRemaining {
    if (!state.isPremium || state.expirationDate == null) return null;

    final now = DateTime.now();
    final expiration = state.expirationDate!;

    if (now.isAfter(expiration)) return 0;

    return expiration.difference(now).inDays;
  }

  String? get formattedExpirationDate {
    if (state.expirationDate == null) return null;

    final date = state.expirationDate!;
    return '${date.day}/${date.month}/${date.year}';
  }
}

final paywallProvider = StateNotifierProvider<PaywallNotifier, PaywallState>((
  ref,
) {
  return PaywallNotifier();
});

final subscriptionStatusProvider =
    StateNotifierProvider<SubscriptionStatusNotifier, SubscriptionStatus>((
      ref,
    ) {
      return SubscriptionStatusNotifier();
    });

final isPremiumProvider = Provider<bool>((ref) {
  final subscriptionStatus = ref.watch(subscriptionStatusProvider);
  return subscriptionStatus.isPremium;
});

final currentSubscriptionProductProvider = Provider<SubscriptionProduct?>((
  ref,
) {
  final subscriptionStatus = ref.watch(subscriptionStatusProvider.notifier);
  return subscriptionStatus.currentProduct;
});

final subscriptionDaysRemainingProvider = Provider<int?>((ref) {
  final subscriptionStatus = ref.watch(subscriptionStatusProvider.notifier);
  return subscriptionStatus.daysRemaining;
});

final debugPremiumProvider = Provider<void>((ref) {
  return null;
});

extension PaywallDebugActions on WidgetRef {
  Future<void> debugGrantPremium() async {
    await ApphudService.instance.grantPremiumAccess();
  }

  Future<void> debugResetSubscription() async {
    await ApphudService.instance.resetSubscription();
  }
}
