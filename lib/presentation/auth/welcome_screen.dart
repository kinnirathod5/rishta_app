// lib/presentation/auth/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';

// ─────────────────────────────────────────────────────────
// SLIDE DATA MODEL
// ─────────────────────────────────────────────────────────

class _Slide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

const List<_Slide> _slides = [
  _Slide(
    emoji: '💍',
    title: AppStrings.slide1Title,
    subtitle: AppStrings.slide1Sub,
    accentColor: AppColors.crimson,
  ),
  _Slide(
    emoji: '🛕',
    title: AppStrings.slide2Title,
    subtitle: AppStrings.slide2Sub,
    accentColor: AppColors.gold,
  ),
  _Slide(
    emoji: '🔐',
    title: AppStrings.slide3Title,
    subtitle: AppStrings.slide3Sub,
    accentColor: AppColors.success,
  ),
];

// ─────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() =>
      _WelcomeScreenState();
}

class _WelcomeScreenState
    extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  final _pageCtrl = PageController();
  int _currentPage = 0;

  // Entry animation
  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  // Page content animation
  late AnimationController _pageCtrl2;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _entryCtrl.forward();
  }

  void _setupAnimations() {
    // Entry fade+slide (screen loads)
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOut,
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOut,
    ));

    // Page content animation
    _pageCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _contentFade = CurvedAnimation(
      parent: _pageCtrl2,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageCtrl2,
      curve: Curves.easeOut,
    ));
    _pageCtrl2.forward();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _pageCtrl2.reset();
    _pageCtrl2.forward();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration:
        const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/phone');
    }
  }

  void _skipToLogin() {
    context.go('/phone');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    _pageCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: FadeTransition(
        opacity: _entryFade,
        child: SlideTransition(
          position: _entrySlide,
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildSlider()),
                _buildDots(),
                const SizedBox(height: 28),
                _buildButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, 16, 20, 0),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          // Logo row
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.crimsonGradient,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('💍',
                    style:
                    TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.appName,
              style: AppTextStyles.h5.copyWith(
                  color: AppColors.crimson),
            ),
          ]),
          // Skip button
          if (_currentPage < _slides.length - 1)
            GestureDetector(
              onTap: _skipToLogin,
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(100),
                  border: Border.all(
                      color: AppColors.border),
                ),
                child: Text(
                  AppStrings.skip,
                  style: AppTextStyles.labelMedium
                      .copyWith(
                      color: AppColors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SLIDER ────────────────────────────────────────────

  Widget _buildSlider() {
    return PageView.builder(
      controller: _pageCtrl,
      onPageChanged: _onPageChanged,
      itemCount: _slides.length,
      itemBuilder: (_, i) =>
          _buildSlide(_slides[i]),
    );
  }

  Widget _buildSlide(_Slide slide) {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 32),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              // Illustration
              _buildIllustration(slide),
              const SizedBox(height: 40),
              // Title
              Text(
                slide.title,
                style: AppTextStyles.onboardTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // Subtitle
              Text(
                slide.subtitle,
                style:
                AppTextStyles.onboardSubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(_Slide slide) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: slide.accentColor
                .withOpacity(0.06),
          ),
        ),
        // Inner ring
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: slide.accentColor
                .withOpacity(0.1),
          ),
        ),
        // Emoji container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                slide.accentColor
                    .withOpacity(0.15),
                slide.accentColor
                    .withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: slide.accentColor
                  .withOpacity(0.25),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              slide.emoji,
              style: const TextStyle(
                  fontSize: 56),
            ),
          ),
        ),
      ],
    );
  }

  // ── DOTS ──────────────────────────────────────────────

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
            (i) => AnimatedContainer(
          duration:
          const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(
              horizontal: 4),
          width: i == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentPage
                ? AppColors.crimson
                : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // ── BUTTONS ───────────────────────────────────────────

  Widget _buildButtons() {
    final isLast =
        _currentPage == _slides.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 24),
      child: Column(
        children: [
          // Primary CTA
          PrimaryButton(
            label: isLast
                ? AppStrings.getStarted
                : AppStrings.next,
            icon: isLast
                ? null
                : Icons.arrow_forward_rounded,
            onPressed: _nextPage,
          ),

        ],
      ),
    );
  }

}