// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/river_pods/onboarding_rp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coin_identifier/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coin_identifier/services/apphud_service.dart';
import 'package:coin_identifier/presentation/river_pods/auth_rp.dart';
import 'package:coin_identifier/presentation/screens/auth/auth_screen.dart';
import 'package:coin_identifier/presentation/screens/main/main_navigation_screen.dart';
import 'package:coin_identifier/presentation/screens/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await ApphudService.instance.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.lightGray,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(ProviderScope(child: const CoinIdentifierApp()));
}

class CoinIdentifierApp extends ConsumerWidget {
  const CoinIdentifierApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Coin Identifier Pro',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryGold,
          secondary: AppColors.primaryNavy,
          surface: AppColors.lightGray,
          error: AppColors.error,
          onPrimary: AppColors.primaryNavy,
          onSecondary: Colors.white,
          onSurface: AppColors.primaryNavy,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.lightGray,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColors.primaryNavy),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGold,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryGold,
          secondary: AppColors.primaryNavy,
          surface: Color(0xFF1E1E1E),
          error: AppColors.error,
          onPrimary: AppColors.primaryNavy,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGold,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        useMaterial3: true,
      ),

      home: const AppInitializer(),

      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        MainNavigationScreen.routeName:
            (context) => const MainNavigationScreen(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _logoAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 20));

      if (!mounted) return;

      final onboardingNotifier = ref.read(onboardingProvider.notifier);
      await onboardingNotifier.checkOnboardingStatus();

      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.checkAuthState();

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      final onboardingState = ref.read(onboardingProvider);
      final authState = ref.read(authProvider);

      if (!onboardingState.hasCompletedOnboarding) {
        Navigator.of(context).pushReplacementNamed(OnboardingScreen.routeName);
      } else if (!authState.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
      } else {
        Navigator.of(
          context,
        ).pushReplacementNamed(MainNavigationScreen.routeName);
      }
    } catch (e) {
      if (mounted) {
        _showInitializationError();
      }
    }
  }

  void _showInitializationError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Initialization Error'),
            content: const Text(
              'Something went wrong while starting the app. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold,
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.monetization_on,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                AnimatedBuilder(
                  animation: _textFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFadeAnimation.value,
                      child: Column(
                        children: [
                          const Text(
                            'Coin Identifier Pro',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'AI-Powered Coin Recognition',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryNavy.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGold,
                    ),
                    strokeWidth: 3,
                    value: onboardingState.isLoading ? null : null,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  onboardingState.isLoading ? 'Loading...' : 'Initializing...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryNavy.withOpacity(0.5),
                  ),
                ),

                if (onboardingState.isLoading) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Checking onboarding status',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryNavy.withOpacity(0.3),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
