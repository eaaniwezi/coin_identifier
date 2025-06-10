import 'package:coin_identifier/services/firebase_coin_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static bool get isSignedIn => currentUser != null;
  static String? get userEmail => currentUser?.email;
  static String? get userDisplayName => currentUser?.displayName;
  static String? get userId => currentUser?.uid;

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (userCredential.user != null) {
        await FirebaseCoinService.createUserDocument(userCredential.user!);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  static Future<UserCredential> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );

      if (userCredential.user != null) {
        await FirebaseCoinService.createUserDocument(userCredential.user!);
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      throw Exception('Apple Sign-In failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Something went wrong during Apple Sign-In.');
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out');
    }
  }

  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
      }
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  static Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please sign in again to delete your account');
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account');
    }
  }

  static bool get isEmailVerified => currentUser?.emailVerified ?? false;

  static Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email');
    }
  }

  static Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw Exception('Failed to reload user data');
    }
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Email address is invalid';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled';
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled';
      case 'popup-blocked':
        return 'Sign-in popup was blocked';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}
