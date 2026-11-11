import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/screens/auth_screen.dart';
import 'package:tokona/features/dashboard/presentation/screens/dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _textFadeController;
  late final Animation<double> _textFadeAnimation;

  late final AnimationController _bounceController;
  late final Animation<double> _jumpAnimation;
  late final Animation<double> _squashAnimation;
  late final Animation<double> _shadowAnimation;

  bool _minDurationElapsed = false;

  @override
  void initState() {
    super.initState();

    // Text & bottom info fade-in controller
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFadeAnimation = CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut);
    _textFadeController.forward();

    // Bouncing/jumping loop ("lompat-lompat")
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _jumpAnimation = Tween<double>(begin: 0.0, end: -28.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOutQuad),
    );

    _squashAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 1.0, end: 0.55).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Start jumping animation smoothly after cold-start display
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _bounceController.repeat(reverse: true);
      }
    });

    // Snappy splash duration (1.7s) before seamless fade into dashboard/login
    Timer(const Duration(milliseconds: 1700), () {
      if (mounted) {
        _minDurationElapsed = true;
        _checkAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _textFadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _checkAndNavigate() {
    final authState = ref.read(authProvider);
    if (!authState.isInitialized || !_minDurationElapsed) return;

    final targetScreen = authState.isAuthenticated ? const DashboardScreen() : const AuthScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => targetScreen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Widget _buildLogo(double logoSize) {
    return Image.asset(
      'assets/images/splash_screen.png',
      fit: BoxFit.contain,
      width: logoSize,
      height: logoSize,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/splash_screen.jpeg',
        fit: BoxFit.contain,
        width: logoSize,
        height: logoSize,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/splash_screen.jpeg',
          fit: BoxFit.contain,
          width: logoSize,
          height: logoSize,
          errorBuilder: (_, __, ___) => Icon(
            Icons.storefront_rounded,
            size: logoSize * 0.6,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) {
      if (next.isInitialized && _minDurationElapsed) {
        _checkAndNavigate();
      }
    });

    final size = MediaQuery.of(context).size;
    final logoSize = min(size.width * 0.40, 160.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Centered animated bouncing logo (seamless from Android native cold start)
          Center(
            child: AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                final jumpY = _jumpAnimation.value;
                final squash = _squashAnimation.value;
                final shadowScale = _shadowAnimation.value;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouncing logo with squash & stretch
                    Transform.translate(
                      offset: Offset(0, jumpY),
                      child: Transform.scale(
                        scaleY: squash,
                        scaleX: 2.0 - squash,
                        child: _buildLogo(logoSize),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Dynamic ground shadow that shrinks when jumping up
                    Container(
                      width: logoSize * 0.62 * shadowScale,
                      height: 9 * shadowScale,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.08 * (2.0 - shadowScale)),
                        borderRadius: BorderRadius.all(Radius.elliptical(logoSize * 0.6, 9)),
                      ),
                    ),
                    const SizedBox(height: 22),
                    // App Brand Title & Subtitle with fade-in
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TOKONA',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.5,
                              color: const Color(0xFF0F766E),
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF0F766E).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Smart Retail & POS Point of Sale',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.45),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom loading indicator & version
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF0F766E).withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tokona POS Retail • v1.0.0',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.35),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
