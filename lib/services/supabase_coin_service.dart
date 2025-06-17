import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coin_identification.dart';

class SupabaseCoinService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Table names
  static const String _usersTable = 'users';
  static const String _coinIdentificationsTable = 'coin_identifications';

  // Storage buckets
  static const String _coinImagesBucket = 'coin-images';

  static String? get _currentUserId => _supabase.auth.currentUser?.id;

  static Future<void> createUserDocument(User user) async {
    try {
      // Check if user profile already exists
      final existingUser =
          await _supabase
              .from(_usersTable)
              .select('id')
              .eq('id', user.id)
              .maybeSingle();

      if (existingUser == null) {
        await _supabase.from(_usersTable).insert({
          'id': user.id,
          'email': user.email,
          'display_name':
              user.userMetadata?['display_name'] ??
              user.email?.split('@').first ??
              'User',
          'total_identifications': 0,
          'total_collection_value': 0.0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Failed to create user document: $e');
      throw Exception('Failed to create user document: $e');
    }
  }

  static Future<String> uploadCoinImage(File imageFile) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = 'coin_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$_currentUserId/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage
          .from(_coinImagesBucket)
          .upload(filePath, imageFile);

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_coinImagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<CoinIdentificationResult> identifyCoin(String imageUrl) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      final mockResponse = {
        'coin_name': _getRandomCoinName(),
        'origin': _getRandomOrigin(),
        'issue_year': _getRandomYear(),
        'mint_mark': _getRandomMintMark(),
        'rarity': _getRandomRarity(),
        'price_estimate': _getRandomPrice(),
        'confidence_score': _getRandomConfidence(),
        'description':
            'This coin appears to be in good condition with clear details visible.',
      };

      return CoinIdentificationResult.fromJson(mockResponse);
    } catch (e) {
      print('Failed to identify coin: $e');
      throw Exception('Failed to identify coin: $e');
    }
  }

  static Future<String> saveCoinIdentification(
    CoinIdentificationResult result,
    String imageUrl,
  ) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response =
          await _supabase
              .from(_coinIdentificationsTable)
              .insert({
                'user_id': _currentUserId,
                'image_url': imageUrl,
                'coin_name': result.coinName,
                'origin': result.origin,
                'issue_year': result.issueYear,
                'mint_mark': result.mintMark,
                'rarity': result.rarity,
                'price_estimate': result.priceEstimate,
                'confidence_score': result.confidenceScore,
                'description': result.description,
                'identified_at': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      // Update user stats
      await _updateUserStats(result.priceEstimate);

      return response['id'];
    } catch (e) {
      print('Failed to save identification: $e');
      throw Exception('Failed to save identification: $e');
    }
  }

  static Future<void> _updateUserStats(double priceEstimate) async {
    try {
      if (_currentUserId == null) return;

      // Get current user stats
      final currentStats =
          await _supabase
              .from(_usersTable)
              .select('total_identifications, total_collection_value')
              .eq('id', _currentUserId!)
              .single();

      // Update with new values
      await _supabase
          .from(_usersTable)
          .update({
            'total_identifications':
                (currentStats['total_identifications'] ?? 0) + 1,
            'total_collection_value':
                (currentStats['total_collection_value'] ?? 0.0) + priceEstimate,
            'last_identification_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUserId!);
    } catch (e) {
      print('Failed to update user stats: $e');
      // Silently fail for stats update
    }
  }

  static Future<List<CoinIdentification>> getUserIdentifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from(_coinIdentificationsTable)
          .select()
          .eq('user_id', _currentUserId!)
          .order('identified_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((data) => CoinIdentification.fromSupabase(data))
          .toList();
    } catch (e) {
      print('Failed to load identifications: $e');
      throw Exception('Failed to load identifications: $e');
    }
  }

  static Future<List<CoinIdentification>> getRecentIdentifications() async {
    try {
      if (_currentUserId == null) return [];

      final response = await _supabase
          .from(_coinIdentificationsTable)
          .select()
          .eq('user_id', _currentUserId!)
          .order('identified_at', ascending: false)
          .limit(5);

      return response
          .map((data) => CoinIdentification.fromSupabase(data))
          .toList();
    } catch (e) {
      print('Failed to load recent identifications: $e');
      return [];
    }
  }

  static Future<UserCollectionStats> getUserStats() async {
    try {
      if (_currentUserId == null) {
        return const UserCollectionStats();
      }

      final response =
          await _supabase
              .from(_usersTable)
              .select(
                'total_identifications, total_collection_value, last_identification_at',
              )
              .eq('id', _currentUserId!)
              .single();

      return UserCollectionStats(
        totalIdentifications: response['total_identifications'] ?? 0,
        totalCollectionValue:
            (response['total_collection_value'] ?? 0.0).toDouble(),
        lastIdentificationAt:
            response['last_identification_at'] != null
                ? DateTime.parse(response['last_identification_at'])
                : null,
      );
    } catch (e) {
      print(e);
      return const UserCollectionStats();
    }
  }

  static Future<void> deleteCoinIdentification(String identificationId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get the identification to check ownership and get price estimate
      final identification =
          await _supabase
              .from(_coinIdentificationsTable)
              .select('user_id, price_estimate')
              .eq('id', identificationId)
              .single();

      if (identification['user_id'] != _currentUserId) {
        throw Exception('Unauthorized to delete this identification');
      }

      final priceEstimate =
          (identification['price_estimate'] ?? 0.0).toDouble();

      // Delete the identification
      await _supabase
          .from(_coinIdentificationsTable)
          .delete()
          .eq('id', identificationId);

      // Update user stats
      final currentStats =
          await _supabase
              .from(_usersTable)
              .select('total_identifications, total_collection_value')
              .eq('id', _currentUserId!)
              .single();

      await _supabase
          .from(_usersTable)
          .update({
            'total_identifications':
                (currentStats['total_identifications'] ?? 1) - 1,
            'total_collection_value':
                (currentStats['total_collection_value'] ?? priceEstimate) -
                priceEstimate,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUserId!);
    } catch (e) {
      print(e);
      throw Exception('Failed to delete identification: $e');
    }
  }

  static Future<List<CoinIdentification>> searchIdentifications(
    String query,
  ) async {
    try {
      if (_currentUserId == null) return [];

      final response = await _supabase
          .from(_coinIdentificationsTable)
          .select()
          .eq('user_id', _currentUserId!)
          .textSearch('coin_name', "'$query'")
          .order('coin_name')
          .limit(20);

      return response
          .map((data) => CoinIdentification.fromSupabase(data))
          .toList();
    } catch (e) {
      // If text search fails, fallback to ilike
      try {
        final response = await _supabase
            .from(_coinIdentificationsTable)
            .select()
            .eq('user_id', _currentUserId!)
            .ilike('coin_name', '%$query%')
            .order('coin_name')
            .limit(20);

        return response
            .map((data) => CoinIdentification.fromSupabase(data))
            .toList();
      } catch (e) {
        print(e);
        return [];
      }
    }
  }

  // Helper methods for mock data (unchanged from original)
  static String _getRandomCoinName() {
    final coins = [
      '1956 Canadian Silver Dollar',
      '1943 Lincoln Penny',
      '1921 Morgan Silver Dollar',
      '1964 Kennedy Half Dollar',
      '1916 Mercury Dime',
      '1909 Indian Head Penny',
      '1881 Morgan Silver Dollar',
      '1937 Buffalo Nickel',
      '1942 Walking Liberty Half Dollar',
      '1893 Columbian Exposition Half Dollar',
    ];
    return coins[DateTime.now().millisecond % coins.length];
  }

  static String _getRandomOrigin() {
    final origins = [
      'United States',
      'Canada',
      'United Kingdom',
      'Australia',
      'Germany',
    ];
    return origins[DateTime.now().millisecond % origins.length];
  }

  static int _getRandomYear() {
    return 1900 + (DateTime.now().millisecond % 125);
  }

  static String? _getRandomMintMark() {
    final mintMarks = [null, 'D', 'S', 'P', 'O', 'CC'];
    return mintMarks[DateTime.now().millisecond % mintMarks.length];
  }

  static String _getRandomRarity() {
    final rarities = ['Common', 'Uncommon', 'Rare', 'Very Rare', 'Error'];
    return rarities[DateTime.now().millisecond % rarities.length];
  }

  static double _getRandomPrice() {
    return (DateTime.now().millisecond % 1000 + 1) / 10.0;
  }

  static double _getRandomConfidence() {
    return 75.0 + (DateTime.now().millisecond % 25);
  }
}

class UserCollectionStats {
  final int totalIdentifications;
  final double totalCollectionValue;
  final DateTime? lastIdentificationAt;

  const UserCollectionStats({
    this.totalIdentifications = 0,
    this.totalCollectionValue = 0.0,
    this.lastIdentificationAt,
  });
}
