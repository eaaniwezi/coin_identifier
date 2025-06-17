// import 'dart:io';
// import 'package:coin_identifier/presentation/river_pods/home_rp.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/coin_identification.dart';
// import '../../services/firebase_coin_service.dart';

// class IdentificationNotifier extends StateNotifier<IdentificationState> {
//   IdentificationNotifier() : super(const IdentificationState());

//   Future<void> identifyCoinFromImage(File imageFile) async {
//     try {
//       state = const IdentificationState(status: IdentificationStatus.uploading);

//       state = state.copyWith(
//         status: IdentificationStatus.uploading,
//         progress: 0.3,
//       );

//       final imageUrl = await FirebaseCoinService.uploadCoinImage(imageFile);

//       state = state.copyWith(
//         status: IdentificationStatus.processing,
//         progress: 0.7,
//       );

//       final result = await FirebaseCoinService.identifyCoin(imageUrl);

//       state = state.copyWith(
//         status: IdentificationStatus.saving,
//         progress: 0.9,
//       );

//       final savedId = await FirebaseCoinService.saveCoinIdentification(
//         result,
//         imageUrl,
//       );

//       state = state.copyWith(
//         status: IdentificationStatus.completed,
//         progress: 1.0,
//         result: result,
//         savedId: savedId,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: IdentificationStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   Future<void> retryIdentification(File imageFile) async {
//     await identifyCoinFromImage(imageFile);
//   }

//   Future<void> saveResult(
//     CoinIdentificationResult result,
//     String imageUrl,
//   ) async {
//     try {
//       state = state.copyWith(status: IdentificationStatus.saving);

//       final savedId = await FirebaseCoinService.saveCoinIdentification(
//         result,
//         imageUrl,
//       );

//       state = state.copyWith(
//         status: IdentificationStatus.completed,
//         savedId: savedId,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: IdentificationStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   void reset() {
//     state = const IdentificationState();
//   }

//   void clearError() {
//     state = state.copyWith(
//       status: IdentificationStatus.idle,
//       errorMessage: null,
//     );
//   }
// }

// class HistoryState {
//   final List<CoinIdentification> identifications;
//   final bool isLoading;
//   final bool hasMore;
//   final String? errorMessage;
//   final bool isLoadingMore;

//   const HistoryState({
//     this.identifications = const [],
//     this.isLoading = false,
//     this.hasMore = true,
//     this.errorMessage,
//     this.isLoadingMore = false,
//   });

//   HistoryState copyWith({
//     List<CoinIdentification>? identifications,
//     bool? isLoading,
//     bool? hasMore,
//     String? errorMessage,
//     bool? isLoadingMore,
//   }) {
//     return HistoryState(
//       identifications: identifications ?? this.identifications,
//       isLoading: isLoading ?? this.isLoading,
//       hasMore: hasMore ?? this.hasMore,
//       errorMessage: errorMessage,
//       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
//     );
//   }
// }

// class HistoryNotifier extends StateNotifier<HistoryState> {
//   HistoryNotifier() : super(const HistoryState());

//   Future<void> loadIdentifications() async {
//     if (state.isLoading) return;

//     state = state.copyWith(isLoading: true, errorMessage: null);

//     try {
//       final identifications = await FirebaseCoinService.getUserIdentifications(
//         limit: 20,
//       );

//       state = state.copyWith(
//         identifications: identifications,
//         isLoading: false,
//         hasMore: identifications.length >= 20,
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: e.toString());
//     }
//   }

//   Future<void> loadMoreIdentifications() async {
//     if (state.isLoadingMore || !state.hasMore) return;

//     state = state.copyWith(isLoadingMore: true);

//     try {
//       final lastDoc = state.identifications.isNotEmpty ? null : null;

//       final moreIdentifications =
//           await FirebaseCoinService.getUserIdentifications(
//             limit: 20,
//             lastDocument: lastDoc,
//           );

//       final allIdentifications = [
//         ...state.identifications,
//         ...moreIdentifications,
//       ];

//       state = state.copyWith(
//         identifications: allIdentifications,
//         isLoadingMore: false,
//         hasMore: moreIdentifications.length >= 20,
//       );
//     } catch (e) {
//       state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
//     }
//   }

//   Future<void> refreshIdentifications() async {
//     state = const HistoryState();
//     await loadIdentifications();
//   }

//   void addIdentification(CoinIdentification identification) {
//     final updated = [identification, ...state.identifications];
//     state = state.copyWith(identifications: updated);
//   }

//   void removeIdentification(String id) {
//     final updated =
//         state.identifications.where((item) => item.id != id).toList();
//     state = state.copyWith(identifications: updated);
//   }

//   Future<void> searchIdentifications(String query) async {
//     if (query.trim().isEmpty) {
//       await loadIdentifications();
//       return;
//     }

//     state = state.copyWith(isLoading: true, errorMessage: null);

//     try {
//       final results = await FirebaseCoinService.searchIdentifications(
//         query.trim(),
//       );

//       state = state.copyWith(
//         identifications: results,
//         isLoading: false,
//         hasMore: false,
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: e.toString());
//     }
//   }

//   Future<void> deleteIdentification(String id) async {
//     try {
//       await FirebaseCoinService.deleteCoinIdentification(id);
//       removeIdentification(id);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }
// }

// class FirebaseCollectionStatsNotifier extends StateNotifier<CollectionStats> {
//   FirebaseCollectionStatsNotifier() : super(const CollectionStats());

//   Future<void> loadStats() async {
//     state = state.copyWith(isLoading: true);

//     try {
//       final userStats = await FirebaseCoinService.getUserStats();
//       final recentIdentifications =
//           await FirebaseCoinService.getRecentIdentifications();

//       state = state.copyWith(
//         totalCoins: userStats.totalIdentifications,
//         totalValue: userStats.totalCollectionValue,
//         recentIdentifications: recentIdentifications.length,
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

// class FirebaseRecentIdentificationsNotifier
//     extends StateNotifier<RecentIdentificationsState> {
//   FirebaseRecentIdentificationsNotifier()
//     : super(const RecentIdentificationsState());

//   Future<void> loadRecentIdentifications() async {
//     state = state.copyWith(isLoading: true, errorMessage: null);

//     try {
//       final identifications =
//           await FirebaseCoinService.getRecentIdentifications();

//       final recentIdentifications =
//           identifications
//               .map(
//                 (coin) => RecentIdentification(
//                   id: coin.id,
//                   coinName: coin.coinName,
//                   imageUrl: coin.imageUrl,
//                   priceEstimate: coin.priceEstimate,
//                   identifiedAt: coin.identifiedAt,
//                   rarity: coin.rarity,
//                 ),
//               )
//               .toList();

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
// }

// final identificationProvider =
//     StateNotifierProvider<IdentificationNotifier, IdentificationState>((ref) {
//       return IdentificationNotifier();
//     });

// final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
//   ref,
// ) {
//   return HistoryNotifier();
// });

// final firebaseCollectionStatsProvider =
//     StateNotifierProvider<FirebaseCollectionStatsNotifier, CollectionStats>((
//       ref,
//     ) {
//       return FirebaseCollectionStatsNotifier();
//     });

// final firebaseRecentIdentificationsProvider = StateNotifierProvider<
//   FirebaseRecentIdentificationsNotifier,
//   RecentIdentificationsState
// >((ref) {
//   return FirebaseRecentIdentificationsNotifier();
// });

// final recentIdentificationsStreamProvider =
//     StreamProvider<List<CoinIdentification>>((ref) {
//       return Stream.value(<CoinIdentification>[]);
//     });

import 'dart:io';
import 'package:coin_identifier/presentation/river_pods/home_rp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/coin_identification.dart';
import '../../services/supabase_coin_service.dart';

class IdentificationNotifier extends StateNotifier<IdentificationState> {
  IdentificationNotifier() : super(const IdentificationState());

  Future<void> identifyCoinFromImage(File imageFile) async {
    try {
      state = const IdentificationState(status: IdentificationStatus.uploading);

      state = state.copyWith(
        status: IdentificationStatus.uploading,
        progress: 0.3,
      );

      final imageUrl = await SupabaseCoinService.uploadCoinImage(imageFile);

      state = state.copyWith(
        status: IdentificationStatus.processing,
        progress: 0.7,
      );

      final result = await SupabaseCoinService.identifyCoin(imageUrl);

      state = state.copyWith(
        status: IdentificationStatus.saving,
        progress: 0.9,
      );

      final savedId = await SupabaseCoinService.saveCoinIdentification(
        result,
        imageUrl,
      );

      state = state.copyWith(
        status: IdentificationStatus.completed,
        progress: 1.0,
        result: result,
        savedId: savedId,
      );
    } catch (e) {
      state = state.copyWith(
        status: IdentificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> retryIdentification(File imageFile) async {
    await identifyCoinFromImage(imageFile);
  }

  Future<void> saveResult(
    CoinIdentificationResult result,
    String imageUrl,
  ) async {
    try {
      state = state.copyWith(status: IdentificationStatus.saving);

      final savedId = await SupabaseCoinService.saveCoinIdentification(
        result,
        imageUrl,
      );

      state = state.copyWith(
        status: IdentificationStatus.completed,
        savedId: savedId,
      );
    } catch (e) {
      state = state.copyWith(
        status: IdentificationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const IdentificationState();
  }

  void clearError() {
    state = state.copyWith(
      status: IdentificationStatus.idle,
      errorMessage: null,
    );
  }
}

class HistoryState {
  final List<CoinIdentification> identifications;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final bool isLoadingMore;
  final int currentOffset;

  const HistoryState({
    this.identifications = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.isLoadingMore = false,
    this.currentOffset = 0,
  });

  HistoryState copyWith({
    List<CoinIdentification>? identifications,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    bool? isLoadingMore,
    int? currentOffset,
  }) {
    return HistoryState(
      identifications: identifications ?? this.identifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState());

  Future<void> loadIdentifications() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOffset: 0,
    );

    try {
      final identifications = await SupabaseCoinService.getUserIdentifications(
        limit: 20,
        offset: 0,
      );

      state = state.copyWith(
        identifications: identifications,
        isLoading: false,
        hasMore: identifications.length >= 20,
        currentOffset: identifications.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMoreIdentifications() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final moreIdentifications =
          await SupabaseCoinService.getUserIdentifications(
            limit: 20,
            offset: state.currentOffset,
          );

      final allIdentifications = [
        ...state.identifications,
        ...moreIdentifications,
      ];

      state = state.copyWith(
        identifications: allIdentifications,
        isLoadingMore: false,
        hasMore: moreIdentifications.length >= 20,
        currentOffset: allIdentifications.length,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  Future<void> refreshIdentifications() async {
    state = const HistoryState();
    await loadIdentifications();
  }

  void addIdentification(CoinIdentification identification) {
    final updated = [identification, ...state.identifications];
    state = state.copyWith(
      identifications: updated,
      currentOffset: updated.length,
    );
  }

  void removeIdentification(String id) {
    final updated =
        state.identifications.where((item) => item.id != id).toList();
    state = state.copyWith(
      identifications: updated,
      currentOffset: updated.length,
    );
  }

  Future<void> searchIdentifications(String query) async {
    if (query.trim().isEmpty) {
      await loadIdentifications();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await SupabaseCoinService.searchIdentifications(
        query.trim(),
      );

      state = state.copyWith(
        identifications: results,
        isLoading: false,
        hasMore: false,
        currentOffset: results.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteIdentification(String id) async {
    try {
      await SupabaseCoinService.deleteCoinIdentification(id);
      removeIdentification(id);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

class SupabaseCollectionStatsNotifier extends StateNotifier<CollectionStats> {
  SupabaseCollectionStatsNotifier() : super(const CollectionStats());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);

    try {
      final userStats = await SupabaseCoinService.getUserStats();
      final recentIdentifications =
          await SupabaseCoinService.getRecentIdentifications();

      state = state.copyWith(
        totalCoins: userStats.totalIdentifications,
        totalValue: userStats.totalCollectionValue,
        recentIdentifications: recentIdentifications.length,
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

class SupabaseRecentIdentificationsNotifier
    extends StateNotifier<RecentIdentificationsState> {
  SupabaseRecentIdentificationsNotifier()
    : super(const RecentIdentificationsState());

  Future<void> loadRecentIdentifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final identifications =
          await SupabaseCoinService.getRecentIdentifications();

      final recentIdentifications =
          identifications
              .map(
                (coin) => RecentIdentification(
                  id: coin.id,
                  coinName: coin.coinName,
                  imageUrl: coin.imageUrl,
                  priceEstimate: coin.priceEstimate,
                  identifiedAt: coin.identifiedAt,
                  rarity: coin.rarity,
                ),
              )
              .toList();

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
}

// Updated providers for Supabase
final identificationProvider =
    StateNotifierProvider<IdentificationNotifier, IdentificationState>((ref) {
      return IdentificationNotifier();
    });

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  return HistoryNotifier();
});

final supabaseCollectionStatsProvider =
    StateNotifierProvider<SupabaseCollectionStatsNotifier, CollectionStats>((
      ref,
    ) {
      return SupabaseCollectionStatsNotifier();
    });

final supabaseRecentIdentificationsProvider = StateNotifierProvider<
  SupabaseRecentIdentificationsNotifier,
  RecentIdentificationsState
>((ref) {
  return SupabaseRecentIdentificationsNotifier();
});

final recentIdentificationsStreamProvider =
    StreamProvider<List<CoinIdentification>>((ref) {
      return Stream.value(<CoinIdentification>[]);
    });

// Convenience providers for easier migration
final collectionStatsProvider = supabaseCollectionStatsProvider;
final recentIdentificationsProvider = supabaseRecentIdentificationsProvider;
