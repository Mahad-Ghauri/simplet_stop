// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkInitialRoute();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo fade in first
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Main content fade in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Scale animation for logo
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Slide animation for text
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkInitialRoute() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final storageService = StorageService.instance;
    final authService = AuthService.instance;

    String initialRoute;

    // Check if user is signed in
    if (authService.isSignedIn) {
      initialRoute = AppRoutes.dashboard;
    } else {
      // Check if it's first time
      if (storageService.isFirstTime()) {
        initialRoute = AppRoutes.onboarding;
      } else {
        initialRoute = AppRoutes.login;
      }
    }

    // Navigate to the appropriate screen
    AppRoutes.pushAndRemoveUntil(context, initialRoute);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  children: [
                    // Header with SIMPELT STOP logo at top left
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SIMPELT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'STOP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Main content centered
                    Expanded(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // App Logo (small version for center)
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.smoke_free,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Tagline in Danish
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: Text(
                                          'Din rejse til et røgfrit liv starter her',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Loading indicator with glassmorphism
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              const Color(0xFF7DD3FC),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom text
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          '© 2025 Ryge Stop. Alle rettigheder forbeholdes.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}