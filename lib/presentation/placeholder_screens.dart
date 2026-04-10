import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';

// ─────────────────────────────────────────────────────────────
// TEMPORARY PLACEHOLDER SCREENS
// Ek ek karke real screens se replace karenge
// ─────────────────────────────────────────────────────────────

// ── BASE PLACEHOLDER ──────────────────────────────────────
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String emoji;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.emoji = '🚧',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: Text(title),
        leading: context.canPop()
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        )
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yeh screen jald aayegi!',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SPLASH PLACEHOLDER ────────────────────────────────────
// Yeh real splash screen se replace hogi
class SplashPlaceholder extends StatefulWidget {
  const SplashPlaceholder({super.key});

  @override
  State<SplashPlaceholder> createState() => _SplashPlaceholderState();
}

class _SplashPlaceholderState extends State<SplashPlaceholder> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutePaths.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.crimsonGradient,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💍', style: TextStyle(fontSize: 72)),
              SizedBox(height: 16),
              Text(
                'RishtaApp',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Apna Rishta, Apni Pasand',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── WELCOME PLACEHOLDER ───────────────────────────────────
// Yeh real welcome screen se replace hogi
class WelcomePlaceholder extends StatelessWidget {
  const WelcomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👋', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              const Text(
                'RishtaApp mein\nAapka Swagat Hai!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apna perfect rishta dhundho',
                style: TextStyle(fontSize: 16, color: AppColors.muted),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.go(AppRoutePaths.phone),
                child: const Text('Shuru Karein 🎉'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}