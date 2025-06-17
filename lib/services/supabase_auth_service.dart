import 'package:coin_identifier/services/supabase_coin_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static User? get currentUser => _supabase.auth.currentUser;
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
  static bool get isSignedIn => currentUser != null;
  static String? get userEmail => currentUser?.email;
  static String? get userDisplayName =>
      currentUser?.userMetadata?['display_name'];
  static String? get userId => currentUser?.id;

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

  static Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  static Future<AuthResponse> signInWithApple() async {
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

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
        nonce: rawNonce,
      );

      // if (response.user != null) {
      //   await SupabaseCoinService.createUserDocument(response.user!);
      // }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      throw Exception('Apple Sign-In failed: ${e.message}');
    } on AuthException catch (e) {
      throw Exception('Supabase error: ${e.message}');
    } catch (e) {
      throw Exception('Something went wrong during Apple Sign-In.');
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'your-app-scheme://reset-password',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email');
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
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
        final updates = <String, dynamic>{};
        if (displayName != null) {
          updates['display_name'] = displayName;
        }
        if (photoURL != null) {
          updates['avatar_url'] = photoURL;
        }

        if (updates.isNotEmpty) {
          await _supabase.auth.updateUser(UserAttributes(data: updates));
        }
      }
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  static Future<void> deleteAccount() async {
    try {
      // Note: Supabase doesn't have a direct delete user method in the client
      // You would typically handle this through your backend or use the admin API
      // For now, we'll sign out and throw an informative message
      await signOut();
      throw Exception(
        'Account deletion must be handled through support. Please contact us.',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account');
    }
  }

  static bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  static Future<void> sendEmailVerification() async {
    try {
      if (currentUser?.email != null) {
        await _supabase.auth.resend(
          type: OtpType.signup,
          email: currentUser!.email!,
        );
      } else {
        throw Exception('No email address found');
      }
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send verification email');
    }
  }

  static Future<void> reloadUser() async {
    try {
      await _supabase.auth.refreshSession();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to reload user data');
    }
  }

  // Additional Supabase-specific methods
  static Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password');
    }
  }

  static Future<void> sendOTP({
    required String email,
    OtpType type = OtpType.signup,
  }) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        emailRedirectTo:
            'your-app-scheme://login-callback', // Update with your app scheme
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send OTP');
    }
  }

  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    OtpType type = OtpType.signup,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: token,
        type: type,
      );

      if (response.user != null) {
        await SupabaseCoinService.createUserDocument(response.user!);
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to verify OTP');
    }
  }

  static String _handleAuthException(AuthException e) {
    switch (e.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Invalid email or password';
      case 'email not confirmed':
        return 'Please check your email and confirm your account';
      case 'user not found':
        return 'No account found with this email address';
      case 'invalid email':
        return 'Email address is invalid';
      case 'signup disabled':
        return 'Account creation is currently disabled';
      case 'too many requests':
        return 'Too many attempts. Please try again later';
      case 'weak password':
        return 'Password is too weak. Use at least 6 characters';
      case 'password is too short':
        return 'Password must be at least 6 characters long';
      case 'email address already in use':
        return 'An account already exists with this email';
      case 'email rate limit exceeded':
        return 'Too many emails sent. Please wait before requesting another';
      case 'invalid token':
        return 'Invalid or expired verification token';
      case 'token expired':
        return 'Verification token has expired. Please request a new one';
      case 'invalid otp':
        return 'Invalid verification code';
      case 'session not found':
        return 'Session expired. Please sign in again';
      case 'refresh token not found':
        return 'Session expired. Please sign in again';
      default:
        // Handle common patterns
        if (e.message.contains('network')) {
          return 'Network error. Please check your connection';
        } else if (e.message.contains('timeout')) {
          return 'Request timed out. Please try again';
        } else if (e.message.contains('rate limit')) {
          return 'Too many requests. Please try again later';
        }
        return e.message;
    }
  }
}
