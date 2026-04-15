// lib/presentation/auth/explore_first_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/providers/auth_provider.dart';

class ExploreFirstScreen
    extends ConsumerStatefulWidget {
  const ExploreFirstScreen({super.key});

  @override
  ConsumerState<ExploreFirstScreen> createState() =>
      _ExploreFirstScreenState();
}

class _ExploreFirstScreenState
    extends ConsumerState<ExploreFirstScreen>
    with SingleTickerProviderStateMixin {

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _exploreAsGuest() async {
    final ok = await ref
        .read(authProvider.notifier)
        .signInAnonymously();
    if (!mounted) return;
    if (ok) context.go('/home');
  }

  void _createAccount() =>
      context.go('/phone');

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
        authProvider.select((s) => s.isLoading));

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  24, 16, 24, 32),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildBackButton(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics:
                      const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const SizedBox(
                              height: 28),
                          _buildHeader(),
                          const SizedBox(
                              height: 36),
                          _buildBrowseCard(
                              isLoading),
                          const SizedBox(
                              height: 16),
                          _buildCreateCard(),
                          const SizedBox(
                              height: 32),
                          _buildFeatureCompare(),
                          const SizedBox(
                              height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButtons(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── BACK BUTTON ───────────────────────────────────────

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.go('/welcome'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚀',
          style: TextStyle(fontSize: 44),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.howToStart,
          style: AppTextStyles.onboardTitle,
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.chooseBestOption,
          style: AppTextStyles.onboardSubtitle,
        ),
      ],
    );
  }

  // ── BROWSE CARD ───────────────────────────────────────

  Widget _buildBrowseCard(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _exploreAsGuest,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.border, width: 1.5),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('👀',
                      style: TextStyle(
                          fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.browseFirst,
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppStrings.browseFirstSub,
                      style: AppTextStyles
                          .bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.muted,
              ),
            ]),
            const SizedBox(height: 16),
            const Divider(
                color: AppColors.border,
                height: 1),
            const SizedBox(height: 14),
            // Restrictions
            _buildLimitationRow(
                AppStrings.photosBlurred),
            const SizedBox(height: 8),
            _buildLimitationRow(
                AppStrings.contactHidden),
            const SizedBox(height: 8),
            _buildLimitationRow(
                AppStrings.chatDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitationRow(String text) {
    return Row(children: [
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.lock_outline_rounded,
            size: 11,
            color: AppColors.muted,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.muted,
        ),
      ),
    ]);
  }

  // ── CREATE ACCOUNT CARD ───────────────────────────────

  Widget _buildCreateCard() {
    return GestureDetector(
      onTap: _createAccount,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.crimson,
              AppColors.crimsonDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.crimsonShadow,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Recommended badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldLight
                    .withOpacity(0.2),
                borderRadius:
                BorderRadius.circular(100),
                border: Border.all(
                    color: AppColors.goldLight
                        .withOpacity(0.4)),
              ),
              child: Text(
                AppStrings.recommended,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldLight,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Header row
            Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.15),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('✨',
                      style: TextStyle(
                          fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.createAccount,
                      style:
                      AppTextStyles.h4.copyWith(
                          color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppStrings.createAccountSub,
                      style: AppTextStyles
                          .bodySmall
                          .copyWith(
                          color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white54,
              ),
            ]),
            const SizedBox(height: 16),
            Divider(
              color: Colors.white.withOpacity(0.2),
              height: 1,
            ),
            const SizedBox(height: 14),
            // Benefits
            _buildBenefitRow(
                AppStrings.viewPhotos),
            const SizedBox(height: 8),
            _buildBenefitRow(
                AppStrings.sendInterests),
            const SizedBox(height: 8),
            _buildBenefitRow(
                AppStrings.chatDirectly),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(children: [
      Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            size: 12,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        text,
        style:
        AppTextStyles.bodySmall.copyWith(
            color: Colors.white),
      ),
    ]);
  }

  // ── FEATURE COMPARE ───────────────────────────────────

  Widget _buildFeatureCompare() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header row
          Row(children: [
            const Expanded(child: SizedBox()),
            Expanded(
              child: Center(
                child: Text(
                  'Guest',
                  style: AppTextStyles
                      .labelSmall
                      .copyWith(
                      color:
                      AppColors.muted),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Member',
                  style: AppTextStyles
                      .labelSmall
                      .copyWith(
                      color:
                      AppColors.crimson,
                      fontWeight:
                      FontWeight.w700),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Divider(color: AppColors.border),
          const SizedBox(height: 4),
          // Feature rows
          ..._compareRows.map(
                  (row) => _FeatureRow(
                feature: row[0],
                guestValue: row[1],
                memberValue: row[2],
              )),
        ],
      ),
    );
  }

  static const List<List<String>> _compareRows =
  [
    ['Browse profiles', '✓', '✓'],
    ['View photos', '🔒', '✓'],
    ['Send interests', '✗', '✓'],
    ['Chat', '✗', '✓'],
    ['Contact details', '🔒', '✓'],
    ['Save shortlist', '✗', '✓'],
  ];

  // ── BOTTOM BUTTONS ────────────────────────────────────

  Widget _buildBottomButtons(bool isLoading) {
    return Column(
      children: [
        PrimaryButton(
          label: AppStrings.createAccount,
          icon: Icons.arrow_forward_rounded,
          onPressed: _createAccount,
        ),
        const SizedBox(height: 10),
        AppTextButton(
          label: AppStrings.browseFirst,
          icon: Icons.explore_outlined,
          color: AppColors.muted,
          onPressed:
          isLoading ? null : _exploreAsGuest,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// FEATURE COMPARE ROW
// ─────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final String feature;
  final String guestValue;
  final String memberValue;

  const _FeatureRow({
    required this.feature,
    required this.guestValue,
    required this.memberValue,
  });

  Widget _cell(String value) {
    final isCheck = value == '✓';
    final isCross = value == '✗';
    final isLock = value == '🔒';

    return Center(
      child: isCheck
          ? Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.successSurface,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            size: 13,
            color: AppColors.success,
          ),
        ),
      )
          : isCross
          ? Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.errorSurface,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.close_rounded,
            size: 13,
            color: AppColors.error,
          ),
        ),
      )
          : Text(
        value,
        style: const TextStyle(
            fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Expanded(
          child: Text(
            feature,
            style: AppTextStyles.bodySmall
                .copyWith(
                color: AppColors.inkSoft),
          ),
        ),
        Expanded(child: _cell(guestValue)),
        Expanded(child: _cell(memberValue)),
      ]),
    );
  }
}