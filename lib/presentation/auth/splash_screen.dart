// lib/presentation/auth/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {

  // ── ANIMATIONS ────────────────────────────────────────
  late AnimationController _ctrl;
  late Animation<double>  _logoScale;
  late Animation<double>  _logoFade;
  late Animation<double>  _textFade;
  late Animation<Offset>  _textSlide;
  late Animation<double>  _taglineFade;
  late Animation<double>  _bottomFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _ctrl.forward();
    _scheduleNavigation();
  }

  void _setupAnimations() {
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Logo — scale up with spring bounce
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
          0.0, 0.45, curve: Curves.elasticOut),
    ));

    // Logo — fade in
    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
          0.0, 0.3, curve: Curves.easeOut),
    ));

    // App name — fade in
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
          0.35, 0.6, curve: Curves.easeOut),
    ));

    // App name — slide up
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
          0.35, 0.65, curve: Curves.easeOut),
    ));

    // Tagline — fade in
    _taglineFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
          0.55, 0.75, curve: Curves.easeOut),
    ));

    // Bottom content — fade in
    _bottomFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(
          0.70, 0.90, curve: Curves.easeOut),
    ));
  }

  // ── NAVIGATION ────────────────────────────────────────

  void _scheduleNavigation() {
    Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      _navigate();
    });
  }

  void _navigate() {
    final authState = ref.read(authProvider);

    if (authState.isLoggedIn) {
      if (authState.hasCompletedSetup) {
        context.go('/home');
      } else {
        context.go('/setup/step1');
      }
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── CENTER CONTENT ───────────────
              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 28),
                    _buildAppName(),
                    const SizedBox(height: 10),
                    _buildTagline(),
                  ],
                ),
              ),
              // ── BOTTOM ───────────────────────
              _buildBottom(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── LOGO ──────────────────────────────────────────────

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FadeTransition(
        opacity: _logoFade,
        child: ScaleTransition(
          scale: _logoScale,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.goldLight
                    .withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.goldLight
                      .withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '💍',
                style: TextStyle(fontSize: 54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── APP NAME ──────────────────────────────────────────

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FadeTransition(
        opacity: _textFade,
        child: SlideTransition(
          position: _textSlide,
          child: Column(
            children: [
              Text(
                AppStrings.appName,
                style: AppTextStyles.splashTitle,
              ),
              const SizedBox(height: 6),
              // Gold underline accent
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius:
                  BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAGLINE ───────────────────────────────────────────

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FadeTransition(
        opacity: _taglineFade,
        child: Text(
          AppStrings.appTagline,
          style: AppTextStyles.splashTagline,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ── BOTTOM ────────────────────────────────────────────

  Widget _buildBottom() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FadeTransition(
        opacity: _bottomFade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading dots
            _LoadingDots(),
            const SizedBox(height: 28),
            // Version text
            Text(
              AppStrings.appVersion.toUpperCase(),
              style: AppTextStyles.versionText,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LOADING DOTS WIDGET
// ─────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() =>
      _LoadingDotsState();
}

class _LoadingDotsState
    extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final delay = i * 0.2;
            final progress =
            ((_ctrl.value - delay) % 1.0)
                .clamp(0.0, 1.0);
            final opacity = progress < 0.5
                ? progress * 2
                : (1.0 - progress) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withOpacity(
                    0.3 + (opacity * 0.7)),
              ),
            );
          },
        );
      }),
    );
  }
}