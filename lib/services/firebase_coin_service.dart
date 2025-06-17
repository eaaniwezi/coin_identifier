// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/coin_identification.dart';

// class FirebaseCoinService {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static final FirebaseStorage _storage = FirebaseStorage.instance;
//   static final FirebaseAuth _auth = FirebaseAuth.instance;

//   static const String _usersCollection = 'users';
//   static const String _coinIdentificationsCollection = 'coin_identifications';

//   static String? get _currentUserId => _auth.currentUser?.uid;

//   static Future<void> createUserDocument(User user) async {
//     try {
//       final userDoc = _firestore.collection(_usersCollection).doc(user.uid);

//       final docSnapshot = await userDoc.get();

//       if (!docSnapshot.exists) {
//         await userDoc.set({
//           'email': user.email,
//           'display_name': user.displayName ?? user.email?.split('@').first,
//           'created_at': FieldValue.serverTimestamp(),
//           'total_identifications': 0,
//           'total_collection_value': 0.0,
//         });
//       } else {}
//     } catch (e) {
//       throw Exception('Failed to create user document: $e');
//     }
//   }

//   static Future<String> uploadCoinImage(File imageFile) async {
//     try {
//       if (_currentUserId == null) {
//         throw Exception('User not authenticated');
//       }

//       final fileName = 'coin_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final storageRef = _storage
//           .ref()
//           .child('coin_images')
//           .child(_currentUserId!)
//           .child(fileName);

//       final metadata = SettableMetadata(
//         contentType: 'image/jpeg',
//         customMetadata: {
//           'uploadedBy': _currentUserId!,
//           'uploadTime': DateTime.now().toIso8601String(),
//         },
//       );

//       final uploadTask = storageRef.putFile(imageFile, metadata);

//       uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//         snapshot.bytesTransferred / snapshot.totalBytes;
//       });

//       final snapshot = await uploadTask;

//       final downloadUrl = await snapshot.ref.getDownloadURL();

//       return downloadUrl;
//     } catch (e) {
//       throw Exception('Failed to upload image: $e');
//     }
//   }

//   static Future<CoinIdentificationResult> identifyCoin(String imageUrl) async {
//     try {
//       await Future.delayed(const Duration(seconds: 2));
//       final mockResponse = {
//         'coin_name': _getRandomCoinName(),
//         'origin': _getRandomOrigin(),
//         'issue_year': _getRandomYear(),
//         'mint_mark': _getRandomMintMark(),
//         'rarity': _getRandomRarity(),
//         'price_estimate': _getRandomPrice(),
//         'confidence_score': _getRandomConfidence(),
//         'description':
//             'This coin appears to be in good condition with clear details visible.',
//       };

//       return CoinIdentificationResult.fromJson(mockResponse);
//     } catch (e) {
//       throw Exception('Failed to identify coin: $e');
//     }
//   }

//   static Future<String> saveCoinIdentification(
//     CoinIdentificationResult result,
//     String imageUrl,
//   ) async {
//     try {
//       if (_currentUserId == null) {
//         throw Exception('User not authenticated');
//       }

//       final docRef =
//           _firestore.collection(_coinIdentificationsCollection).doc();

//       final coinData = {
//         'id': docRef.id,
//         'user_id': _currentUserId,
//         'image_url': imageUrl,
//         'coin_name': result.coinName,
//         'origin': result.origin,
//         'issue_year': result.issueYear,
//         'mint_mark': result.mintMark,
//         'rarity': result.rarity,
//         'price_estimate': result.priceEstimate,
//         'confidence_score': result.confidenceScore,
//         'description': result.description,
//         'identified_at': FieldValue.serverTimestamp(),
//         'created_at': FieldValue.serverTimestamp(),
//       };

//       await docRef.set(coinData);

//       await _updateUserStats(result.priceEstimate);

//       return docRef.id;
//     } catch (e) {
//       throw Exception('Failed to save identification: $e');
//     }
//   }

//   static Future<void> _updateUserStats(double priceEstimate) async {
//     try {
//       if (_currentUserId == null) return;

//       final userDoc = _firestore
//           .collection(_usersCollection)
//           .doc(_currentUserId);

//       await userDoc.update({
//         'total_identifications': FieldValue.increment(1),
//         'total_collection_value': FieldValue.increment(priceEstimate),
//         'last_identification_at': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {}
//   }

//   static Future<List<CoinIdentification>> getUserIdentifications({
//     int limit = 20,
//     DocumentSnapshot? lastDocument,
//   }) async {
//     try {
//       if (_currentUserId == null) {
//         throw Exception('User not authenticated');
//       }

//       Query query = _firestore
//           .collection(_coinIdentificationsCollection)
//           .where('user_id', isEqualTo: _currentUserId)
//           .orderBy('identified_at', descending: true)
//           .limit(limit);

//       if (lastDocument != null) {
//         query = query.startAfterDocument(lastDocument);
//       }

//       final querySnapshot = await query.get();

//       return querySnapshot.docs
//           .map((doc) => CoinIdentification.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load identifications: $e');
//     }
//   }

//   static Future<List<CoinIdentification>> getRecentIdentifications() async {
//     try {
//       if (_currentUserId == null) return [];

//       final querySnapshot =
//           await _firestore
//               .collection(_coinIdentificationsCollection)
//               .where('user_id', isEqualTo: _currentUserId)
//               .orderBy('identified_at', descending: true)
//               .limit(5)
//               .get();

//       return querySnapshot.docs
//           .map((doc) => CoinIdentification.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   static Future<UserCollectionStats> getUserStats() async {
//     try {
//       if (_currentUserId == null) {
//         return const UserCollectionStats();
//       }

//       final userDoc =
//           await _firestore
//               .collection(_usersCollection)
//               .doc(_currentUserId)
//               .get();

//       if (!userDoc.exists) {
//         return const UserCollectionStats();
//       }

//       final data = userDoc.data()!;
//       return UserCollectionStats(
//         totalIdentifications: data['total_identifications'] ?? 0,
//         totalCollectionValue:
//             (data['total_collection_value'] ?? 0.0).toDouble(),
//         lastIdentificationAt:
//             (data['last_identification_at'] as Timestamp?)?.toDate(),
//       );
//     } catch (e) {
//       return const UserCollectionStats();
//     }
//   }

//   static Future<void> deleteCoinIdentification(String identificationId) async {
//     try {
//       if (_currentUserId == null) {
//         throw Exception('User not authenticated');
//       }

//       final doc =
//           await _firestore
//               .collection(_coinIdentificationsCollection)
//               .doc(identificationId)
//               .get();

//       if (doc.exists && doc.data()?['user_id'] == _currentUserId) {
//         final priceEstimate = (doc.data()?['price_estimate'] ?? 0.0).toDouble();

//         await doc.reference.delete();

//         final userDoc = _firestore
//             .collection(_usersCollection)
//             .doc(_currentUserId);
//         await userDoc.update({
//           'total_identifications': FieldValue.increment(-1),
//           'total_collection_value': FieldValue.increment(-priceEstimate),
//         });
//       }
//     } catch (e) {
//       throw Exception('Failed to delete identification: $e');
//     }
//   }

//   static Future<List<CoinIdentification>> searchIdentifications(
//     String query,
//   ) async {
//     try {
//       if (_currentUserId == null) return [];

//       final querySnapshot =
//           await _firestore
//               .collection(_coinIdentificationsCollection)
//               .where('user_id', isEqualTo: _currentUserId)
//               .where('coin_name', isGreaterThanOrEqualTo: query)
//               .where('coin_name', isLessThanOrEqualTo: query + '\uf8ff')
//               .orderBy('coin_name')
//               .limit(20)
//               .get();

//       return querySnapshot.docs
//           .map((doc) => CoinIdentification.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   static String _getRandomCoinName() {
//     final coins = [
//       '1956 Canadian Silver Dollar',
//       '1943 Lincoln Penny',
//       '1921 Morgan Silver Dollar',
//       '1964 Kennedy Half Dollar',
//       '1916 Mercury Dime',
//       '1909 Indian Head Penny',
//       '1881 Morgan Silver Dollar',
//       '1937 Buffalo Nickel',
//       '1942 Walking Liberty Half Dollar',
//       '1893 Columbian Exposition Half Dollar',
//     ];
//     return coins[DateTime.now().millisecond % coins.length];
//   }

//   static String _getRandomOrigin() {
//     final origins = [
//       'United States',
//       'Canada',
//       'United Kingdom',
//       'Australia',
//       'Germany',
//     ];
//     return origins[DateTime.now().millisecond % origins.length];
//   }

//   static int _getRandomYear() {
//     return 1900 + (DateTime.now().millisecond % 125);
//   }

//   static String? _getRandomMintMark() {
//     final mintMarks = [null, 'D', 'S', 'P', 'O', 'CC'];
//     return mintMarks[DateTime.now().millisecond % mintMarks.length];
//   }

//   static String _getRandomRarity() {
//     final rarities = ['Common', 'Uncommon', 'Rare', 'Very Rare', 'Error'];
//     return rarities[DateTime.now().millisecond % rarities.length];
//   }

//   static double _getRandomPrice() {
//     return (DateTime.now().millisecond % 1000 + 1) / 10.0;
//   }

//   static double _getRandomConfidence() {
//     return 75.0 + (DateTime.now().millisecond % 25);
//   }
// }

// class UserCollectionStats {
//   final int totalIdentifications;
//   final double totalCollectionValue;
//   final DateTime? lastIdentificationAt;

//   const UserCollectionStats({
//     this.totalIdentifications = 0,
//     this.totalCollectionValue = 0.0,
//     this.lastIdentificationAt,
//   });
// }
