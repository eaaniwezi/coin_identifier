import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState {
  final int currentPage;
  final bool hasCompletedOnboarding;
  final bool isLoading;

  const OnboardingState({
    this.currentPage = 0,
    this.hasCompletedOnboarding = false,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? hasCompletedOnboarding,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.currentPage == currentPage &&
        other.hasCompletedOnboarding == hasCompletedOnboarding &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode =>
      Object.hash(currentPage, hasCompletedOnboarding, isLoading);

  @override
  String toString() {
    return 'OnboardingState(currentPage: $currentPage, hasCompletedOnboarding: $hasCompletedOnboarding, isLoading: $isLoading)';
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  OnboardingNotifier() : super(const OnboardingState());

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);

      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(hasCompletedOnboarding: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> checkOnboardingStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;

      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        hasCompletedOnboarding: hasCompleted,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(hasCompletedOnboarding: false, isLoading: false);
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);

      state = const OnboardingState();
    } catch (e) {
      state = const OnboardingState();
    }
  }

  Future<bool> getCompletionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });
