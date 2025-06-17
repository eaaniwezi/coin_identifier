// // ignore_for_file: avoid_types_as_parameter_names

// import 'package:coin_identifier/models/coin_identification.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'paywall_rp.dart';
// import 'history_rp.dart';

// class ConnectivityState {
//   final bool isOnline;
//   final bool isLoading;

//   const ConnectivityState({this.isOnline = true, this.isLoading = false});

//   ConnectivityState copyWith({bool? isOnline, bool? isLoading}) {
//     return ConnectivityState(
//       isOnline: isOnline ?? this.isOnline,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }

// class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
//   ConnectivityNotifier() : super(const ConnectivityState()) {
//     _initConnectivity();
//     _listenToConnectivityChanges();
//   }

//   Future<void> _initConnectivity() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       final connectivityResults = await Connectivity().checkConnectivity();
//       final isOnline = _isConnected(connectivityResults);
//       state = state.copyWith(isOnline: isOnline, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isOnline: false, isLoading: false);
//     }
//   }

//   void _listenToConnectivityChanges() {
//     Connectivity().onConnectivityChanged.listen((
//       List<ConnectivityResult> results,
//     ) {
//       final isOnline = _isConnected(results);
//       state = state.copyWith(isOnline: isOnline);
//     });
//   }

//   bool _isConnected(dynamic results) {
//     if (results is List<ConnectivityResult>) {
//       return results.any((result) => result != ConnectivityResult.none);
//     } else if (results is ConnectivityResult) {
//       return results != ConnectivityResult.none;
//     }
//     return false;
//   }
// }

// class CollectionStats {
//   final int totalCoins;
//   final double totalValue;
//   final int recentIdentifications;
//   final bool isLoading;

//   const CollectionStats({
//     this.totalCoins = 0,
//     this.totalValue = 0.0,
//     this.recentIdentifications = 0,
//     this.isLoading = false,
//   });

//   CollectionStats copyWith({
//     int? totalCoins,
//     double? totalValue,
//     int? recentIdentifications,
//     bool? isLoading,
//   }) {
//     return CollectionStats(
//       totalCoins: totalCoins ?? this.totalCoins,
//       totalValue: totalValue ?? this.totalValue,
//       recentIdentifications:
//           recentIdentifications ?? this.recentIdentifications,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }

// class CollectionStatsNotifier extends StateNotifier<CollectionStats> {
//   CollectionStatsNotifier() : super(const CollectionStats());

//   Future<void> loadStats() async {
//     state = state.copyWith(isLoading: true);

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         state = state.copyWith(isLoading: false);
//         return;
//       }

//       final querySnapshot =
//           await FirebaseFirestore.instance
//               .collection('coin_identifications')
//               .where('user_id', isEqualTo: user.uid)
//               .get();

//       final coins =
//           querySnapshot.docs
//               .map((doc) => CoinIdentification.fromFirestore(doc))
//               .toList();

//       final totalCoins = coins.length;
//       final totalValue = coins.fold<double>(
//         0.0,
//         (sum, coin) => sum + (coin.priceEstimate),
//       );

//       final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
//       final recentIdentifications =
//           coins.where((coin) {
//             final identifiedAt = coin.identifiedAt;
//             return identifiedAt.isAfter(sevenDaysAgo);
//           }).length;

//       state = state.copyWith(
//         totalCoins: totalCoins,
//         totalValue: totalValue,
//         recentIdentifications: recentIdentifications,
//         isLoading: false,
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   void updateStats({
//     int? totalCoins,
//     double? totalValue,
//     int? recentIdentifications,
//   }) {
//     state = state.copyWith(
//       totalCoins: totalCoins,
//       totalValue: totalValue,
//       recentIdentifications: recentIdentifications,
//     );
//   }
// }

// class RecentIdentification {
//   final String id;
//   final String coinName;
//   final String imageUrl;
//   final double priceEstimate;
//   final DateTime identifiedAt;
//   final String rarity;

//   const RecentIdentification({
//     required this.id,
//     required this.coinName,
//     required this.imageUrl,
//     required this.priceEstimate,
//     required this.identifiedAt,
//     required this.rarity,
//   });

//   factory RecentIdentification.fromCoinIdentification(CoinIdentification coin) {
//     return RecentIdentification(
//       id: coin.id,
//       coinName: coin.coinName,
//       imageUrl: coin.imageUrl,
//       priceEstimate: coin.priceEstimate,
//       identifiedAt: coin.identifiedAt,
//       rarity: coin.rarity,
//     );
//   }
// }

// class RecentIdentificationsState {
//   final List<RecentIdentification> identifications;
//   final bool isLoading;
//   final String? errorMessage;

//   const RecentIdentificationsState({
//     this.identifications = const [],
//     this.isLoading = false,
//     this.errorMessage,
//   });

//   RecentIdentificationsState copyWith({
//     List<RecentIdentification>? identifications,
//     bool? isLoading,
//     String? errorMessage,
//   }) {
//     return RecentIdentificationsState(
//       identifications: identifications ?? this.identifications,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage,
//     );
//   }
// }

// class RecentIdentificationsNotifier
//     extends StateNotifier<RecentIdentificationsState> {
//   RecentIdentificationsNotifier() : super(const RecentIdentificationsState());

//   Future<void> loadRecentIdentifications() async {
//     state = state.copyWith(isLoading: true, errorMessage: null);

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         state = state.copyWith(
//           isLoading: false,
//           errorMessage: 'User not authenticated',
//         );
//         return;
//       }

//       final querySnapshot =
//           await FirebaseFirestore.instance
//               .collection('coin_identifications')
//               .where('user_id', isEqualTo: user.uid)
//               .orderBy('identified_at', descending: true)
//               .limit(5)
//               .get();

//       final recentCoins =
//           querySnapshot.docs
//               .map((doc) => CoinIdentification.fromFirestore(doc))
//               .toList();

//       final recentIdentifications =
//           recentCoins.map((coin) {
//             return RecentIdentification(
//               id: coin.id,
//               coinName: coin.coinName,
//               imageUrl: coin.imageUrl,
//               priceEstimate: coin.priceEstimate,
//               identifiedAt: coin.identifiedAt,
//               rarity: coin.rarity,
//             );
//           }).toList();

//       state = state.copyWith(
//         identifications: recentIdentifications,
//         isLoading: false,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: 'Failed to load recent identifications',
//       );
//     }
//   }

//   void addIdentification(RecentIdentification identification) {
//     final updated = [identification, ...state.identifications];
//     if (updated.length > 10) {
//       updated.removeRange(10, updated.length);
//     }
//     state = state.copyWith(identifications: updated);
//   }

//   void addCoinIdentification(CoinIdentification coin) {
//     final recentIdentification = RecentIdentification.fromCoinIdentification(
//       coin,
//     );
//     addIdentification(recentIdentification);
//   }
// }

// class NavigationState {
//   final int currentIndex;

//   const NavigationState({this.currentIndex = 0});

//   NavigationState copyWith({int? currentIndex}) {
//     return NavigationState(currentIndex: currentIndex ?? this.currentIndex);
//   }
// }

// class NavigationNotifier extends StateNotifier<NavigationState> {
//   NavigationNotifier() : super(const NavigationState());

//   void setIndex(int index) {
//     state = state.copyWith(currentIndex: index);
//   }
// }

// final connectivityProvider =
//     StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
//       return ConnectivityNotifier();
//     });

// final collectionStatsProvider =
//     StateNotifierProvider<CollectionStatsNotifier, CollectionStats>((ref) {
//       return CollectionStatsNotifier();
//     });

// final recentIdentificationsProvider = StateNotifierProvider<
//   RecentIdentificationsNotifier,
//   RecentIdentificationsState
// >((ref) {
//   return RecentIdentificationsNotifier();
// });

// final navigationProvider =
//     StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
//       return NavigationNotifier();
//     });

// final homeCollectionStatsProvider = Provider<Map<String, dynamic>>((ref) {
//   final historyState = ref.watch(historyProvider);
//   final isPremium = ref.watch(isPremiumProvider);

//   final totalCoins = historyState.coins.length;
//   final totalValue = historyState.coins.fold<double>(
//     0.0,
//     (sum, coin) => sum + (coin.priceEstimate),
//   );

//   final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
//   final recentCount =
//       historyState.coins.where((coin) {
//         final identifiedAt = coin.identifiedAt;
//         return identifiedAt.isAfter(sevenDaysAgo);
//       }).length;

//   return {
//     'totalCoins': totalCoins,
//     'totalValue': isPremium ? totalValue : null,
//     'recentIdentifications': recentCount,
//     'isLoading': historyState.isLoading,
//     'isPremium': isPremium,
//   };
// });

// final homeRecentIdentificationsProvider = Provider<List<CoinIdentification>>((
//   ref,
// ) {
//   final historyState = ref.watch(historyProvider);
//   return historyState.coins.take(5).toList();
// });

// final homeRecentIdentificationsLegacyProvider =
//     Provider<List<RecentIdentification>>((ref) {
//       final recentCoins = ref.watch(homeRecentIdentificationsProvider);

//       return recentCoins
//           .map((coin) => RecentIdentification.fromCoinIdentification(coin))
//           .toList();
//     });

// ignore_for_file: avoid_types_as_parameter_names

import 'package:coin_identifier/models/coin_identification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_coin_service.dart';
import 'paywall_rp.dart';
import 'history_rp.dart';

class ConnectivityState {
  final bool isOnline;
  final bool isLoading;

  const ConnectivityState({this.isOnline = true, this.isLoading = false});

  ConnectivityState copyWith({bool? isOnline, bool? isLoading}) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(const ConnectivityState()) {
    _initConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _initConnectivity() async {
    state = state.copyWith(isLoading: true);
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final isOnline = _isConnected(connectivityResults);
      state = state.copyWith(isOnline: isOnline, isLoading: false);
    } catch (e) {
      state = state.copyWith(isOnline: false, isLoading: false);
    }
  }

  void _listenToConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline = _isConnected(results);
      state = state.copyWith(isOnline: isOnline);
    });
  }

  bool _isConnected(dynamic results) {
    if (results is List<ConnectivityResult>) {
      return results.any((result) => result != ConnectivityResult.none);
    } else if (results is ConnectivityResult) {
      return results != ConnectivityResult.none;
    }
    return false;
  }
}

class CollectionStats {
  final int totalCoins;
  final double totalValue;
  final int recentIdentifications;
  final bool isLoading;

  const CollectionStats({
    this.totalCoins = 0,
    this.totalValue = 0.0,
    this.recentIdentifications = 0,
    this.isLoading = false,
  });

  CollectionStats copyWith({
    int? totalCoins,
    double? totalValue,
    int? recentIdentifications,
    bool? isLoading,
  }) {
    return CollectionStats(
      totalCoins: totalCoins ?? this.totalCoins,
      totalValue: totalValue ?? this.totalValue,
      recentIdentifications:
          recentIdentifications ?? this.recentIdentifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CollectionStatsNotifier extends StateNotifier<CollectionStats> {
  CollectionStatsNotifier() : super(const CollectionStats());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Get user stats from Supabase
      final userStats = await SupabaseCoinService.getUserStats();
      final recentIdentifications =
          await SupabaseCoinService.getRecentIdentifications();

      // Calculate recent identifications (last 7 days)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentCount =
          recentIdentifications.where((coin) {
            return coin.identifiedAt.isAfter(sevenDaysAgo);
          }).length;

      state = state.copyWith(
        totalCoins: userStats.totalIdentifications,
        totalValue: userStats.totalCollectionValue,
        recentIdentifications: recentCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateStats({
    int? totalCoins,
    double? totalValue,
    int? recentIdentifications,
  }) {
    state = state.copyWith(
      totalCoins: totalCoins,
      totalValue: totalValue,
      recentIdentifications: recentIdentifications,
    );
  }
}

class RecentIdentification {
  final String id;
  final String coinName;
  final String imageUrl;
  final double priceEstimate;
  final DateTime identifiedAt;
  final String rarity;

  const RecentIdentification({
    required this.id,
    required this.coinName,
    required this.imageUrl,
    required this.priceEstimate,
    required this.identifiedAt,
    required this.rarity,
  });

  factory RecentIdentification.fromCoinIdentification(CoinIdentification coin) {
    return RecentIdentification(
      id: coin.id,
      coinName: coin.coinName,
      imageUrl: coin.imageUrl,
      priceEstimate: coin.priceEstimate,
      identifiedAt: coin.identifiedAt,
      rarity: coin.rarity,
    );
  }
}

class RecentIdentificationsState {
  final List<RecentIdentification> identifications;
  final bool isLoading;
  final String? errorMessage;

  const RecentIdentificationsState({
    this.identifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RecentIdentificationsState copyWith({
    List<RecentIdentification>? identifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RecentIdentificationsState(
      identifications: identifications ?? this.identifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RecentIdentificationsNotifier
    extends StateNotifier<RecentIdentificationsState> {
  RecentIdentificationsNotifier() : super(const RecentIdentificationsState());

  Future<void> loadRecentIdentifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User not authenticated',
        );
        return;
      }

      final recentCoins = await SupabaseCoinService.getRecentIdentifications();

      final recentIdentifications =
          recentCoins.map((coin) {
            return RecentIdentification(
              id: coin.id,
              coinName: coin.coinName,
              imageUrl: coin.imageUrl,
              priceEstimate: coin.priceEstimate,
              identifiedAt: coin.identifiedAt,
              rarity: coin.rarity,
            );
          }).toList();

      state = state.copyWith(
        identifications: recentIdentifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recent identifications',
      );
    }
  }

  void addIdentification(RecentIdentification identification) {
    final updated = [identification, ...state.identifications];
    if (updated.length > 10) {
      updated.removeRange(10, updated.length);
    }
    state = state.copyWith(identifications: updated);
  }

  void addCoinIdentification(CoinIdentification coin) {
    final recentIdentification = RecentIdentification.fromCoinIdentification(
      coin,
    );
    addIdentification(recentIdentification);
  }
}

class NavigationState {
  final int currentIndex;

  const NavigationState({this.currentIndex = 0});

  NavigationState copyWith({int? currentIndex}) {
    return NavigationState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

// Providers
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
      return ConnectivityNotifier();
    });

final collectionStatsProvider =
    StateNotifierProvider<CollectionStatsNotifier, CollectionStats>((ref) {
      return CollectionStatsNotifier();
    });

final recentIdentificationsProvider = StateNotifierProvider<
  RecentIdentificationsNotifier,
  RecentIdentificationsState
>((ref) {
  return RecentIdentificationsNotifier();
});

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });

// Enhanced providers that work with Supabase data
final homeCollectionStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final historyState = ref.watch(historyProvider);
  final isPremium = ref.watch(isPremiumProvider);

  final totalCoins = historyState.identifications.length;
  final totalValue = historyState.identifications.fold<double>(
    0.0,
    (sum, coin) => sum + (coin.priceEstimate),
  );

  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  final recentCount =
      historyState.identifications.where((coin) {
        final identifiedAt = coin.identifiedAt;
        return identifiedAt.isAfter(sevenDaysAgo);
      }).length;

  return {
    'totalCoins': totalCoins,
    'totalValue': isPremium ? totalValue : null,
    'recentIdentifications': recentCount,
    'isLoading': historyState.isLoading,
    'isPremium': isPremium,
  };
});

final homeRecentIdentificationsProvider = Provider<List<CoinIdentification>>((
  ref,
) {
  final historyState = ref.watch(historyProvider);
  return historyState.identifications.take(5).toList();
});

final homeRecentIdentificationsLegacyProvider =
    Provider<List<RecentIdentification>>((ref) {
      final recentCoins = ref.watch(homeRecentIdentificationsProvider);

      return recentCoins
          .map((coin) => RecentIdentification.fromCoinIdentification(coin))
          .toList();
    });

// Additional Supabase-specific providers
final supabaseCollectionStatsProvider = FutureProvider<CollectionStats>((
  ref,
) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const CollectionStats();
    }

    final userStats = await SupabaseCoinService.getUserStats();
    final recentIdentifications =
        await SupabaseCoinService.getRecentIdentifications();

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentCount =
        recentIdentifications.where((coin) {
          return coin.identifiedAt.isAfter(sevenDaysAgo);
        }).length;

    return CollectionStats(
      totalCoins: userStats.totalIdentifications,
      totalValue: userStats.totalCollectionValue,
      recentIdentifications: recentCount,
      isLoading: false,
    );
  } catch (e) {
    return const CollectionStats(isLoading: false);
  }
});

final supabaseRecentIdentificationsProvider =
    FutureProvider<List<RecentIdentification>>((ref) async {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          return <RecentIdentification>[];
        }

        final recentCoins =
            await SupabaseCoinService.getRecentIdentifications();

        return recentCoins.map((coin) {
          return RecentIdentification(
            id: coin.id,
            coinName: coin.coinName,
            imageUrl: coin.imageUrl,
            priceEstimate: coin.priceEstimate,
            identifiedAt: coin.identifiedAt,
            rarity: coin.rarity,
          );
        }).toList();
      } catch (e) {
        return <RecentIdentification>[];
      }
    });

// Stream providers for real-time updates (if using Supabase realtime)
final realtimeCollectionStatsProvider = StreamProvider<CollectionStats>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return Stream.value(const CollectionStats());
  }

  // Listen to changes in coin_identifications table
  return Supabase.instance.client
      .from('coin_identifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .asyncMap((data) async {
        try {
          final userStats = await SupabaseCoinService.getUserStats();
          final identifications =
              data
                  .map((item) => CoinIdentification.fromSupabase(item))
                  .toList();

          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
          final recentCount =
              identifications.where((coin) {
                return coin.identifiedAt.isAfter(sevenDaysAgo);
              }).length;

          return CollectionStats(
            totalCoins: userStats.totalIdentifications,
            totalValue: userStats.totalCollectionValue,
            recentIdentifications: recentCount,
            isLoading: false,
          );
        } catch (e) {
          return const CollectionStats(isLoading: false);
        }
      });
});
