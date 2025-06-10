// ignore_for_file: empty_catches, avoid_types_as_parameter_names

import 'dart:async';

import 'package:coin_identifier/models/coin_identification.dart';
import 'package:coin_identifier/presentation/river_pods/paywall_rp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryState {
  final List<CoinIdentification> coins;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final String searchQuery;
  final HistoryFilter filter;
  final HistorySortOption sortOption;
  final int totalCoins;
  final double totalValue;

  const HistoryState({
    this.coins = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.searchQuery = '',
    this.filter = const HistoryFilter(),
    this.sortOption = HistorySortOption.dateNewest,
    this.totalCoins = 0,
    this.totalValue = 0.0,
  });

  HistoryState copyWith({
    List<CoinIdentification>? coins,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    String? searchQuery,
    HistoryFilter? filter,
    HistorySortOption? sortOption,
    int? totalCoins,
    double? totalValue,
  }) {
    return HistoryState(
      coins: coins ?? this.coins,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sortOption: sortOption ?? this.sortOption,
      totalCoins: totalCoins ?? this.totalCoins,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}

class HistoryFilter {
  final DateRange? dateRange;
  final PriceRange? priceRange;
  final String? rarity;
  final String? origin;

  const HistoryFilter({
    this.dateRange,
    this.priceRange,
    this.rarity,
    this.origin,
  });

  HistoryFilter copyWith({
    DateRange? dateRange,
    PriceRange? priceRange,
    String? rarity,
    String? origin,
  }) {
    return HistoryFilter(
      dateRange: dateRange ?? this.dateRange,
      priceRange: priceRange ?? this.priceRange,
      rarity: rarity ?? this.rarity,
      origin: origin ?? this.origin,
    );
  }

  bool get hasActiveFilters =>
      dateRange != null ||
      priceRange != null ||
      rarity != null ||
      origin != null;
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;
  const DateRange({required this.startDate, required this.endDate});
}

class PriceRange {
  final double minPrice;
  final double maxPrice;
  const PriceRange({required this.minPrice, required this.maxPrice});
}

enum HistorySortOption {
  dateNewest,
  dateOldest,
  priceHighest,
  priceLowest,
  nameAZ,
  nameZA,
  confidenceHighest,
  confidenceLowest,
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState()) {
    _initRealTimeListener();
  }

  static const int pageSize = 50;
  StreamSubscription<QuerySnapshot>? _subscription;
  List<CoinIdentification> _allCoins = [];

  void _initRealTimeListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    _subscription = FirebaseFirestore.instance
        .collection('coin_identifications')
        .where('user_id', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (querySnapshot) {
            try {
              _allCoins = [];
              for (final doc in querySnapshot.docs) {
                try {
                  final coin = CoinIdentification.fromFirestore(doc);
                  _allCoins.add(coin);
                } catch (e) {}
              }

              _applyCurrentFiltersAndUpdate();
            } catch (e) {
              state = state.copyWith(isLoading: false, error: e.toString());
            }
          },
          onError: (error) {
            state = state.copyWith(isLoading: false, error: error.toString());
          },
        );
  }

  void _applyCurrentFiltersAndUpdate() {
    final filteredCoins = _applyFiltersAndSearch(_allCoins);

    final sortedCoins = _applySorting(filteredCoins);

    final totalCoins = sortedCoins.length;
    final totalValue = sortedCoins.fold<double>(
      0.0,
      (sum, coin) => sum + (coin.priceEstimate),
    );

    state = state.copyWith(
      isLoading: false,
      coins: sortedCoins,
      hasMore: false,
      totalCoins: totalCoins,
      totalValue: totalValue,
      error: null,
    );
  }

  List<CoinIdentification> _applyFiltersAndSearch(
    List<CoinIdentification> coins,
  ) {
    var filteredCoins = List<CoinIdentification>.from(coins);
    if (state.searchQuery.isNotEmpty) {
      filteredCoins =
          filteredCoins.where((coin) {
            final coinName = coin.coinName.toLowerCase();
            final searchQuery = state.searchQuery.toLowerCase();
            final matches = coinName.contains(searchQuery);
            if (matches) {}
            return matches;
          }).toList();
    }

    if (state.filter.rarity != null) {
      final targetRarity = state.filter.rarity!.toLowerCase();
      filteredCoins =
          filteredCoins.where((coin) {
            final coinRarity = coin.rarity.toLowerCase();
            final matches = coinRarity == targetRarity;
            if (matches) {}
            return matches;
          }).toList();
    }

    if (state.filter.origin != null) {
      final targetOrigin = state.filter.origin!.toLowerCase();
      filteredCoins =
          filteredCoins.where((coin) {
            final coinOrigin = coin.origin.toLowerCase();
            final matches = coinOrigin == targetOrigin;
            if (matches) {}
            return matches;
          }).toList();
    }

    if (state.filter.priceRange != null) {
      final minPrice = state.filter.priceRange!.minPrice;
      final maxPrice = state.filter.priceRange!.maxPrice;
      filteredCoins =
          filteredCoins.where((coin) {
            final price = coin.priceEstimate;
            final matches = price >= minPrice && price <= maxPrice;
            if (matches) {}
            return matches;
          }).toList();
    }

    if (state.filter.dateRange != null) {
      final startDate = state.filter.dateRange!.startDate;
      final endDate = state.filter.dateRange!.endDate.add(
        const Duration(days: 1),
      );
      filteredCoins =
          filteredCoins.where((coin) {
            final coinDate = coin.identifiedAt;

            final matches =
                coinDate.isAfter(startDate) && coinDate.isBefore(endDate);
            if (matches) {}
            return matches;
          }).toList();
    }

    return filteredCoins;
  }

  List<CoinIdentification> _applySorting(List<CoinIdentification> coins) {
    final sortedCoins = List<CoinIdentification>.from(coins);

    switch (state.sortOption) {
      case HistorySortOption.dateNewest:
        sortedCoins.sort((a, b) {
          final aDate = a.identifiedAt;
          final bDate = b.identifiedAt;
          return bDate.compareTo(aDate);
        });
        break;
      case HistorySortOption.dateOldest:
        sortedCoins.sort((a, b) {
          final aDate = a.identifiedAt;
          final bDate = b.identifiedAt;
          return aDate.compareTo(bDate);
        });
        break;
      case HistorySortOption.priceHighest:
        sortedCoins.sort((a, b) {
          final aPrice = a.priceEstimate;
          final bPrice = b.priceEstimate;
          return bPrice.compareTo(aPrice);
        });
        break;
      case HistorySortOption.priceLowest:
        sortedCoins.sort((a, b) {
          final aPrice = a.priceEstimate;
          final bPrice = b.priceEstimate;
          return aPrice.compareTo(bPrice);
        });
        break;
      case HistorySortOption.nameAZ:
        sortedCoins.sort((a, b) {
          final aName = a.coinName;
          final bName = b.coinName;
          return aName.compareTo(bName);
        });
        break;
      case HistorySortOption.nameZA:
        sortedCoins.sort((a, b) {
          final aName = a.coinName;
          final bName = b.coinName;
          return bName.compareTo(aName);
        });
        break;
      case HistorySortOption.confidenceHighest:
        sortedCoins.sort((a, b) {
          final aConfidence = a.confidenceScore;
          final bConfidence = b.confidenceScore;
          return bConfidence.compareTo(aConfidence);
        });
        break;
      case HistorySortOption.confidenceLowest:
        sortedCoins.sort((a, b) {
          final aConfidence = a.confidenceScore;
          final bConfidence = b.confidenceScore;
          return aConfidence.compareTo(bConfidence);
        });
        break;
    }

    return sortedCoins;
  }

  void searchCoins(String query) {
    state = state.copyWith(searchQuery: query);
    _applyCurrentFiltersAndUpdate();
  }

  void applyFilter(HistoryFilter filter) {
    state = state.copyWith(filter: filter);
    _applyCurrentFiltersAndUpdate();
  }

  void changeSortOption(HistorySortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
    _applyCurrentFiltersAndUpdate();
  }

  void clearFilters() {
    state = state.copyWith(filter: const HistoryFilter(), searchQuery: '');

    _applyCurrentFiltersAndUpdate();
  }

  Future<void> loadCoins({bool refresh = false}) async {
    if (_subscription == null || refresh) {
      await _subscription?.cancel();
      _initRealTimeListener();
    }
  }

  Future<void> refresh() async {
    await _subscription?.cancel();
    _initRealTimeListener();
  }

  Future<void> loadMoreCoins() async {
    return;
  }

  List<CoinIdentification> getCoinsForFreeUser() {
    return state.coins.take(15).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  return HistoryNotifier();
});

final filteredCoinsProvider = Provider<List<CoinIdentification>>((ref) {
  final historyState = ref.watch(historyProvider);
  final isPremium = ref.watch(isPremiumProvider);

  if (isPremium) {
    return historyState.coins;
  } else {
    return historyState.coins.take(15).toList();
  }
});

final collectionStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final historyState = ref.watch(historyProvider);
  final isPremium = ref.watch(isPremiumProvider);

  if (!isPremium) {
    final freeCoins = historyState.coins.take(15);
    return {
      'totalCoins': freeCoins.length,
      'totalValue': freeCoins.fold<double>(
        0.0,
        (sum, coin) => sum + (coin.priceEstimate),
      ),
      'averageConfidence':
          freeCoins.isEmpty
              ? 0.0
              : freeCoins.fold<double>(
                    0.0,
                    (sum, coin) => sum + (coin.confidenceScore),
                  ) /
                  freeCoins.length,
      'mostValuable':
          freeCoins.isEmpty
              ? null
              : freeCoins.reduce(
                (curr, next) =>
                    (curr.priceEstimate) > (next.priceEstimate) ? curr : next,
              ),
    };
  }

  return {
    'totalCoins': historyState.totalCoins,
    'totalValue': historyState.totalValue,
    'averageConfidence':
        historyState.coins.isEmpty
            ? 0.0
            : historyState.coins.fold<double>(
                  0.0,
                  (sum, coin) => sum + (coin.confidenceScore),
                ) /
                historyState.coins.length,
    'mostValuable':
        historyState.coins.isEmpty
            ? null
            : historyState.coins.reduce(
              (curr, next) =>
                  (curr.priceEstimate) > (next.priceEstimate) ? curr : next,
            ),
  };
});
