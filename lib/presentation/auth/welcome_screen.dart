import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';

// ── MODEL ──────────────────────────────────────────────────
class OnboardingSlide {
  const OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color borderColor;
}

// ── SCREEN ─────────────────────────────────────────────────
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      emoji: '💑',
      title: AppStrings.slide1Title,
      subtitle: AppStrings.slide1Subtitle,
      bgColor: AppColors.crimsonSurface,
      borderColor: Color(0xFFFAD4D4),
    ),
    OnboardingSlide(
      emoji: '🛕',
      title: AppStrings.slide2Title,
      subtitle: AppStrings.slide2Subtitle,
      bgColor: AppColors.goldSurface,
      borderColor: Color(0xFFEEDFBB),
    ),
    OnboardingSlide(
      emoji: '🛡️',
      title: AppStrings.slide3Title,
      subtitle: AppStrings.slide3Subtitle,
      bgColor: AppColors.successSurface,
      borderColor: Color(0xFFBBDFCC),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPhone() => context.go(AppRoutePaths.phone);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _slides.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) => _buildSlide(_slides[index]),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.crimson,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('💍', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          // Skip button — hidden on last slide
          AnimatedOpacity(
            opacity: _currentPage < 2 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: _currentPage >= 2,
              child: TextButton(
                onPressed: _goToPhone,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  AppStrings.btnSkip,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SLIDE ─────────────────────────────────────────────────
  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: slide.bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: slide.borderColor, width: 1),
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 100),
              ),
            ),
          ),
          const SizedBox(height: 44),
          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // Subtitle
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM SECTION ────────────────────────────────────────
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        children: [
          // Page indicator dots
          SmoothPageIndicator(
            controller: _pageController,
            count: _slides.length,
            effect: const ExpandingDotsEffect(
              activeDotColor: AppColors.crimson,
              dotColor: AppColors.ivoryDark,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3.5,
              spacing: 6,
            ),
          ),
          const SizedBox(height: 28),
          // Next / Get Started button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentPage == 2
                ? _buildGetStartedButton()
                : _buildNextButton(),
          ),
          const SizedBox(height: 16),
          // Login row — visible only on last slide
          AnimatedOpacity(
            opacity: _currentPage == 2 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: _currentPage != 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.phoneAlreadyAccount,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToPhone,
                    child: const Text(
                      AppStrings.phoneLoginLink,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.crimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── NEXT BUTTON ───────────────────────────────────────────
  Widget _buildNextButton() {
    return SizedBox(
      key: const ValueKey('next'),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.btnNext,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  // ── GET STARTED BUTTON ────────────────────────────────────
  Widget _buildGetStartedButton() {
    return SizedBox(
      key: const ValueKey('getStarted'),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _goToPhone,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          AppStrings.btnGetStarted,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
