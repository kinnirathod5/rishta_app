// lib/presentation/auth/profile_type_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/data/models/profile_model.dart';

// ─────────────────────────────────────────────────────────
// PROFILE FOR OPTION MODEL
// ─────────────────────────────────────────────────────────

class _ProfileOption {
  final ProfileFor value;
  final String emoji;
  final String title;
  final String subtitle;
  final String ageInfo;

  const _ProfileOption({
    required this.value,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.ageInfo,
  });
}

const List<_ProfileOption> _mainOptions = [
  _ProfileOption(
    value: ProfileFor.self,
    emoji: '🙋',
    title: AppStrings.forMyself,
    subtitle: AppStrings.forMyselfSub,
    ageInfo: AppStrings.ageRange,
  ),
  _ProfileOption(
    value: ProfileFor.son,
    emoji: '👦',
    title: 'For My Son',
    subtitle: 'Looking for a match for my son',
    ageInfo: 'Family-oriented • Traditional values',
  ),
  _ProfileOption(
    value: ProfileFor.daughter,
    emoji: '👧',
    title: 'For My Daughter',
    subtitle: 'Looking for a match for my daughter',
    ageInfo: 'Family-oriented • Traditional values',
  ),
];

const List<_ProfileOption> _moreOptions = [
  _ProfileOption(
    value: ProfileFor.brother,
    emoji: '👨',
    title: 'For My Brother',
    subtitle: 'Looking for a match for my brother',
    ageInfo: 'Help your sibling find love',
  ),
  _ProfileOption(
    value: ProfileFor.sister,
    emoji: '👩',
    title: 'For My Sister',
    subtitle: 'Looking for a match for my sister',
    ageInfo: 'Help your sibling find love',
  ),
  _ProfileOption(
    value: ProfileFor.relative,
    emoji: '👨‍👩‍👧‍👦',
    title: 'For A Relative',
    subtitle: 'Looking for a match for a relative',
    ageInfo: 'Family extended search',
  ),
  _ProfileOption(
    value: ProfileFor.friend,
    emoji: '🤝',
    title: 'For A Friend',
    subtitle: 'Helping a friend find their match',
    ageInfo: 'Friendly matchmaking',
  ),
];

// ─────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────

class ProfileTypeScreen extends ConsumerStatefulWidget {
  const ProfileTypeScreen({super.key});

  @override
  ConsumerState<ProfileTypeScreen> createState() =>
      _ProfileTypeScreenState();
}

class _ProfileTypeScreenState
    extends ConsumerState<ProfileTypeScreen>
    with SingleTickerProviderStateMixin {

  ProfileFor? _selected;
  bool _showMore = false;

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 500),
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

  void _selectOption(ProfileFor value) {
    HapticFeedback.selectionClick();
    setState(() => _selected = value);
  }

  void _proceed() {
    if (_selected == null) return;
    // Pass selected profileFor to step1
    context.go(
      '/setup/step1',
      extra: {'profileFor': _selected!.value},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                    const EdgeInsets.fromLTRB(
                        24, 16, 24, 24),
                    physics:
                    const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 28),
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildMainOptions(),
                        const SizedBox(height: 12),
                        _buildMoreToggle(),
                        if (_showMore) ...[
                          const SizedBox(height: 12),
                          _buildMoreOptions(),
                        ],
                        const SizedBox(height: 24),
                        if (_selected != null)
                          _buildSelectedSummary(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        // Back
        GestureDetector(
          onTap: () => context.go('/phone'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.border),
            ),
            child: const Center(
              child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.ink),
            ),
          ),
        ),
        // Step indicator
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.crimsonSurface,
            borderRadius:
            BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.crimson
                  .withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_add_outlined,
                size: 13,
                color: AppColors.crimson,
              ),
              const SizedBox(width: 5),
              Text(
                'Profile Setup',
                style: AppTextStyles
                    .labelSmall
                    .copyWith(
                    color:
                    AppColors.crimson),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👤',
          style: TextStyle(fontSize: 44),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.profileForWho,
          style: AppTextStyles.onboardTitle,
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.rightChoiceBetter,
          style: AppTextStyles.onboardSubtitle,
        ),
      ],
    );
  }

  // ── MAIN OPTIONS ──────────────────────────────────────

  Widget _buildMainOptions() {
    return Column(
      children: _mainOptions.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: 10),
          child: _OptionCard(
            option: opt,
            isSelected: _selected == opt.value,
            onTap: () =>
                _selectOption(opt.value),
          ),
        );
      }).toList(),
    );
  }

  // ── MORE TOGGLE ───────────────────────────────────────

  Widget _buildMoreToggle() {
    return GestureDetector(
      onTap: () =>
          setState(() => _showMore = !_showMore),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('➕',
                  style:
                  TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'More Options',
                  style: AppTextStyles
                      .labelLarge,
                ),
                Text(
                  'Brother, Sister, Relative, Friend',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: _showMore ? 0.5 : 0,
            duration: const Duration(
                milliseconds: 250),
            child: const Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              size: 22,
              color: AppColors.muted,
            ),
          ),
        ]),
      ),
    );
  }

  // ── MORE OPTIONS ──────────────────────────────────────

  Widget _buildMoreOptions() {
    return AnimatedSize(
      duration:
      const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: _moreOptions.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(
                bottom: 10),
            child: _OptionCard(
              option: opt,
              isSelected:
              _selected == opt.value,
              onTap: () =>
                  _selectOption(opt.value),
              isCompact: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── SELECTED SUMMARY ──────────────────────────────────

  Widget _buildSelectedSummary() {
    final all = [
      ..._mainOptions,
      ..._moreOptions
    ];
    final selected = all.firstWhere(
            (o) => o.value == _selected);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
            AppColors.crimson.withOpacity(0.2),
          ),
        ),
        child: Row(children: [
          Text(
            selected.emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile for: ${selected.title}',
                  style: AppTextStyles
                      .labelLarge
                      .copyWith(
                      color:
                      AppColors.crimson),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tap Continue to start setup',
                  style: AppTextStyles
                      .bodySmall
                      .copyWith(
                      color: AppColors
                          .crimson
                          .withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 22,
            color: AppColors.crimson,
          ),
        ]),
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom +
            16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
              color: AppColors.border, width: 1),
        ),
        boxShadow: AppColors.modalShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress dots
          _buildProgressDots(),
          const SizedBox(height: 16),
          // Continue button
          PrimaryButton(
            label: _selected == null
                ? 'Select an Option'
                : AppStrings.continueBtn,
            icon: _selected != null
                ? Icons.arrow_forward_rounded
                : null,
            onPressed: _selected != null
                ? _proceed
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        // Step 0 — profile type (current)
        Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.crimson,
            borderRadius:
            BorderRadius.circular(4),
          ),
        ),
        // Steps 1-5 — inactive
        ...List.generate(5, (_) =>
            Container(
              margin: const EdgeInsets.only(
                  left: 6),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius:
                BorderRadius.circular(4),
              ),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// OPTION CARD WIDGET
// ─────────────────────────────────────────────────────────

class _OptionCard extends StatefulWidget {
  final _ProfileOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  State<_OptionCard> createState() =>
      _OptionCardState();
}

class _OptionCardState
    extends State<_OptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ctrl.forward()
            .then((_) => _ctrl.reverse());
        widget.onTap();
      },
      onTapDown: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(
              milliseconds: 200),
          padding: EdgeInsets.all(
              widget.isCompact ? 14 : 18),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.crimsonSurface
                : AppColors.white,
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.crimson
                  : AppColors.border,
              width:
              widget.isSelected ? 2 : 1.5,
            ),
            boxShadow: widget.isSelected
                ? AppColors.softShadow
                : AppColors.softShadow,
          ),
          child: Row(children: [
            // Emoji
            AnimatedContainer(
              duration: const Duration(
                  milliseconds: 200),
              width:
              widget.isCompact ? 40 : 50,
              height:
              widget.isCompact ? 40 : 50,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.crimson
                    .withOpacity(0.12)
                    : AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(
                    widget.isCompact
                        ? 10
                        : 12),
              ),
              child: Center(
                child: Text(
                  widget.option.emoji,
                  style: TextStyle(
                      fontSize: widget
                          .isCompact
                          ? 20
                          : 26),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.option.title,
                    style: widget.isSelected
                        ? AppTextStyles
                        .labelLarge
                        .copyWith(
                        color: AppColors
                            .crimson)
                        : AppTextStyles
                        .labelLarge,
                  ),
                  if (!widget.isCompact) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.option.subtitle,
                      style: AppTextStyles
                          .bodySmall,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration:
                      BoxDecoration(
                        color: widget.isSelected
                            ? AppColors.crimson
                            .withOpacity(
                            0.1)
                            : AppColors
                            .ivoryDark,
                        borderRadius:
                        BorderRadius
                            .circular(
                            100),
                      ),
                      child: Text(
                        widget.option.ageInfo,
                        style: AppTextStyles
                            .labelSmall
                            .copyWith(
                          color: widget
                              .isSelected
                              ? AppColors
                              .crimson
                              : AppColors
                              .muted,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.option.subtitle,
                      style: AppTextStyles
                          .bodySmall,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(
                  milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.crimson
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.crimson
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: widget.isSelected
                  ? const Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              )
                  : null,
            ),
          ]),
        ),
      ),
    );
  }
}