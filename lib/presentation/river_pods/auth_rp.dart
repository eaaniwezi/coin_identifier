import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import '../../services/supabase_auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final AuthMethod? lastAuthMethod;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.lastAuthMethod,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    User? user,
    AuthMethod? lastAuthMethod,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      lastAuthMethod: lastAuthMethod ?? this.lastAuthMethod,
    );
  }

  String? get userEmail => user?.email;
  String? get userDisplayName => user?.userMetadata?['display_name'];
  String? get userId => user?.id;
  bool get isEmailVerified => user?.emailConfirmedAt != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.user?.id == user?.id &&
        other.lastAuthMethod == lastAuthMethod;
  }

  @override
  int get hashCode => Object.hash(
    isAuthenticated,
    isLoading,
    errorMessage,
    user?.id,
    lastAuthMethod,
  );
}

enum AuthMethod { emailPassword, appleSignIn }

class AuthNotifier extends StateNotifier<AuthState> {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _sessionKey = 'supabase_session';

  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  void _log(String message) {
    developer.log(message, name: 'AuthNotifier');
  }

  void _initializeAuth() async {
    _log('Initializing auth...');

    // First check if there's already a current session in Supabase
    final currentSession = Supabase.instance.client.auth.currentSession;
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentSession != null && currentUser != null) {
      _log('Found existing Supabase session for: ${currentUser.email}');
      state = state.copyWith(isAuthenticated: true, user: currentUser);
    } else {
      _log('No existing session, checking stored session...');
      await _restoreStoredSession();
    }

    // Set up listener for future auth state changes
    SupabaseAuthService.authStateChanges.listen((authChangeEvent) async {
      final user = authChangeEvent.session?.user;
      final session = authChangeEvent.session;
      final isAuthenticated = user != null;

      _log('Auth state changed: $isAuthenticated, User: ${user?.email}');

      if (isAuthenticated && session != null) {
        await _saveSessionToSecureStorage(session);
        state = state.copyWith(isAuthenticated: true, user: user);
      } else {
        await _clearStoredSession();
        state = state.copyWith(isAuthenticated: false, user: null);
      }
    });
  }

  Future<void> _saveSessionToSecureStorage(Session session) async {
    try {
      _log('Saving session to secure storage...');

      // Save the session as JSON to secure storage
      final sessionJson = jsonEncode({
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'expires_at': session.expiresAt,
        'expires_in': session.expiresIn,
        'token_type': session.tokenType,
        'user': {
          'id': session.user.id,
          'email': session.user.email,
          'created_at': session.user.createdAt,
          'email_confirmed_at': session.user.emailConfirmedAt,
          'user_metadata': session.user.userMetadata,
        },
      });

      await _secureStorage.write(key: _sessionKey, value: sessionJson);
      _log('Session saved successfully');
    } catch (e) {
      _log('Error saving session: $e');
    }
  }

  Future<void> _restoreStoredSession() async {
    try {
      _log('Checking for stored session...');

      final sessionJson = await _secureStorage.read(key: _sessionKey);

      if (sessionJson == null) {
        _log('No stored session found');
        return;
      }

      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      final refreshToken = sessionData['refresh_token'] as String?;
      final expiresAt = sessionData['expires_at'] as int?;

      if (refreshToken == null || refreshToken.isEmpty) {
        _log('No valid refresh token found in stored session');
        await _clearStoredSession();
        return;
      }

      // Check if session is still valid (with 5 minute buffer)
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final expiryBuffer = 300; // 5 minutes buffer

      if (expiresAt != null && expiresAt <= (now + expiryBuffer)) {
        _log('Stored session expired, removing...');
        await _clearStoredSession();
        return;
      }

      _log('Stored session is valid, attempting restore...');

      // Restore session using refresh token
      try {
        final response = await Supabase.instance.client.auth.setSession(
          refreshToken,
        );

        if (response.session != null && response.user != null) {
          _log('Session restored successfully for: ${response.user!.email}');
          state = state.copyWith(isAuthenticated: true, user: response.user);
        } else {
          _log('Session restoration returned null session/user');
          await _clearStoredSession();
        }
      } catch (e) {
        _log('Failed to restore session: $e');
        await _clearStoredSession();
      }
    } catch (e) {
      _log('Error restoring stored session: $e');
      await _clearStoredSession();
    }
  }

  Future<void> _clearStoredSession() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
      _log('Stored session cleared');
    } catch (e) {
      _log('Error clearing stored session: $e');
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAuthMethod: AuthMethod.emailPassword,
    );

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final response = await SupabaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _log('Sign in response user: ${response.user?.email}');

      if (response.user != null && response.session != null) {
        // Auth state listener will handle the state update and session saving
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        throw Exception('Sign in failed - no user or session returned');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String confirmPassword, {
    String? displayName,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAuthMethod: AuthMethod.emailPassword,
    );

    try {
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      final response = await SupabaseAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      _log('Sign up response user: ${response.user?.email}');

      if (response.user != null && response.session != null) {
        // Since email confirmation is disabled, user should be immediately authenticated
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Account created but authentication failed. Please try signing in.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await SupabaseAuthService.signOut();
      await _clearStoredSession();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out. Please try again.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Debug method to check stored session (for development only)
  Future<void> debugStoredSession() async {
    try {
      final sessionJson = await _secureStorage.read(key: _sessionKey);
      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson);
        _log('Stored session debug:');
        _log('- User email: ${sessionData['user']?['email']}');
        _log('- Expires at: ${sessionData['expires_at']}');
        _log('- Has refresh token: ${sessionData['refresh_token'] != null}');
      } else {
        _log('No stored session found');
      }
    } catch (e) {
      _log('Error debugging stored session: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final authStateStreamProvider = StreamProvider<User?>((ref) {
  return SupabaseAuthService.authStateChanges.map(
    (authChangeEvent) => authChangeEvent.session?.user,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isEmailVerified;
});
