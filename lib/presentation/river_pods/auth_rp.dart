import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';

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
  String? get userDisplayName => user?.displayName;
  String? get userId => user?.uid;
  bool get isEmailVerified => user?.emailVerified ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.user?.uid == user?.uid &&
        other.lastAuthMethod == lastAuthMethod;
  }

  @override
  int get hashCode => Object.hash(
    isAuthenticated,
    isLoading,
    errorMessage,
    user?.uid,
    lastAuthMethod,
  );
}

enum AuthMethod { emailPassword, appleSignIn }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    FirebaseAuthService.authStateChanges.listen((user) {
      state = state.copyWith(isAuthenticated: user != null, user: user);
    });

    _initializeAuthState();
  }

  void _initializeAuthState() {
    final user = FirebaseAuthService.currentUser;
    state = state.copyWith(isAuthenticated: user != null, user: user);
  }

  Future<void> checkAuthState() async {
    state = state.copyWith(isLoading: true);

    try {
      await FirebaseAuthService.reloadUser();
      final user = FirebaseAuthService.currentUser;

      state = state.copyWith(
        isAuthenticated: user != null,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
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

      final userCredential =
          await FirebaseAuthService.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: userCredential.user,
        lastAuthMethod: AuthMethod.emailPassword,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String confirmPassword,
  ) async {
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

      final userCredential =
          await FirebaseAuthService.signUpWithEmailAndPassword(
            email: email,
            password: password,
          );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: userCredential.user,
        lastAuthMethod: AuthMethod.emailPassword,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAuthMethod: AuthMethod.appleSignIn,
    );

    try {
      final userCredential = await FirebaseAuthService.signInWithApple();

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: userCredential.user,
        lastAuthMethod: AuthMethod.appleSignIn,
      );
      return true;
    } catch (e) {
      var error = "Apple Sign-In requires Apple Developer Program membership";
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      await FirebaseAuthService.sendPasswordResetEmail(email);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await FirebaseAuthService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out. Please try again.',
      );
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await FirebaseAuthService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      await FirebaseAuthService.reloadUser();
      final user = FirebaseAuthService.currentUser;

      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update profile. Please try again.',
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);

    try {
      await FirebaseAuthService.deleteAccount();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await FirebaseAuthService.sendEmailVerification();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send verification email.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final authStateStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuthService.authStateChanges;
});
