import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthFormState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool isSignUp;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final Map<String, String> fieldErrors;

  const AuthFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isSignUp = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.fieldErrors = const {},
  });

  AuthFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isSignUp,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    Map<String, String>? fieldErrors,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSignUp: isSignUp ?? this.isSignUp,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  bool get isValid {
    return email.isNotEmpty &&
        email.contains('@') &&
        password.length >= 6 &&
        (!isSignUp ||
            (confirmPassword.isNotEmpty && password == confirmPassword));
  }
}

class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier() : super(const AuthFormState());

  void toggleMode() {
    state = state.copyWith(
      isSignUp: !state.isSignUp,
      fieldErrors: {},
      confirmPassword: '',
    );
  }

  void updateEmail(String email) {
    final errors = Map<String, String>.from(state.fieldErrors);
    errors.remove('email');

    state = state.copyWith(email: email, fieldErrors: errors);
  }

  void updatePassword(String password) {
    final errors = Map<String, String>.from(state.fieldErrors);
    errors.remove('password');

    state = state.copyWith(password: password, fieldErrors: errors);
  }

  void updateConfirmPassword(String confirmPassword) {
    final errors = Map<String, String>.from(state.fieldErrors);
    errors.remove('confirmPassword');

    state = state.copyWith(
      confirmPassword: confirmPassword,
      fieldErrors: errors,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  bool validateForm() {
    final errors = <String, String>{};

    if (state.email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!state.email.contains('@')) {
      errors['email'] = 'Please enter a valid email';
    }

    if (state.password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (state.password.length < 6) {
      errors['password'] = 'Password must be at least 6 characters';
    }

    if (state.isSignUp) {
      if (state.confirmPassword.isEmpty) {
        errors['confirmPassword'] = 'Please confirm your password';
      } else if (state.password != state.confirmPassword) {
        errors['confirmPassword'] = 'Passwords do not match';
      }
    }

    state = state.copyWith(fieldErrors: errors);
    return errors.isEmpty;
  }

  void clearForm() {
    state = const AuthFormState();
  }
}

final authFormProvider = StateNotifierProvider<AuthFormNotifier, AuthFormState>(
  (ref) {
    return AuthFormNotifier();
  },
);
