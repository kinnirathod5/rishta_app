// lib/presentation/auth/profile_setup/step4_family.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/core/widgets/custom_text_field.dart';
import 'package:rishta_app/core/widgets/loading_overlay.dart';
import 'package:rishta_app/data/models/profile_model.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// STEP 4 — FAMILY DETAILS
// Fields: Family Type, Family Values,
//         Father Occupation, Mother Occupation,
//         Brothers, Sisters, Family City, About Family
// ─────────────────────────────────────────────────────────

class Step4Family extends ConsumerStatefulWidget {
  const Step4Family({super.key});

  @override
  ConsumerState<Step4Family> createState() =>
      _Step4FamilyState();
}

class _Step4FamilyState
    extends ConsumerState<Step4Family>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fatherOccCtrl = TextEditingController();
  final _motherOccCtrl = TextEditingController();
  final _familyCityCtrl = TextEditingController();

  // Dropdown values
  String? _familyType;
  String? _familyValues;
  String? _fatherStatus;
  String? _motherStatus;

  // Sibling counts
  int _brothers = 0;
  int _sisters = 0;
  int _marriedBrothers = 0;
  int _marriedSisters = 0;

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _ctrl.forward();
    _loadExistingData();
  }

  void _setupAnimation() {
    _ctrl = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut));
  }

  void _loadExistingData() {
    final profile =
    ref.read(currentProfileProvider);
    if (profile == null) return;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _familyType =
            profile.familyType.value;
        _familyValues =
            profile.familyValues.value;
        _fatherOccCtrl.text =
            profile.fatherOccupation ?? '';
        _motherOccCtrl.text =
            profile.motherOccupation ?? '';
        _familyCityCtrl.text =
            profile.familyCity ?? '';
        _brothers = profile.brotherCount;
        _sisters = profile.sisterCount;
        _marriedBrothers =
            profile.marriedBrotherCount;
        _marriedSisters =
            profile.marriedSisterCount;
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fatherOccCtrl.dispose();
    _motherOccCtrl.dispose();
    _familyCityCtrl.dispose();
    super.dispose();
  }

  // ── SUBMIT ────────────────────────────────────────────

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ??
        false)) return;

    final profileId =
        ref.read(currentProfileProvider)?.id;
    if (profileId == null) {
      _showError(
          'Profile not found. Please go back.');
      return;
    }

    final data = {
      'familyType': _familyType ?? 'joint',
      'familyValues':
      _familyValues ?? 'traditional',
      'fatherOccupation':
      _fatherOccCtrl.text.trim(),
      'motherOccupation':
      _motherOccCtrl.text.trim(),
      'familyCity':
      _familyCityCtrl.text.trim(),
      'brotherCount': _brothers,
      'sisterCount': _sisters,
      'marriedBrotherCount': _marriedBrothers,
      'marriedSisterCount': _marriedSisters,
    };

    final ok = await ref
        .read(myProfileProvider.notifier)
        .updateProfile(data);

    if (!mounted) return;
    if (ok) {
      context.go('/setup/step5');
    } else {
      final error =
          ref.read(myProfileProvider).error;
      _showError(
          error ?? 'Something went wrong.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving =
        ref.watch(myProfileProvider).isSaving;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProgressBar(),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding:
                          const EdgeInsets
                              .fromLTRB(
                              24, 24,
                              24, 100),
                          physics:
                          const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              _buildStepTitle(),
                              const SizedBox(
                                  height: 24),

                              // ── FAMILY TYPE ─
                              _buildSectionHeader(
                                  '🏠',
                                  'Family Background',
                                  'Tell us about your family'),
                              const SizedBox(
                                  height: 14),
                              _buildFamilyType(),
                              const SizedBox(
                                  height: 18),
                              _buildFamilyValues(),
                              const SizedBox(
                                  height: 18),
                              _buildFamilyCity(),

                              const SizedBox(
                                  height: 28),

                              // ── PARENTS ─────
                              _buildSectionHeader(
                                  '👨‍👩‍👧‍👦',
                                  'Parents',
                                  'Optional details'),
                              const SizedBox(
                                  height: 14),
                              _buildParentStatus(),
                              const SizedBox(
                                  height: 18),
                              _buildFatherOccupation(),
                              const SizedBox(
                                  height: 18),
                              _buildMotherOccupation(),

                              const SizedBox(
                                  height: 28),

                              // ── SIBLINGS ────
                              _buildSectionHeader(
                                  '👬',
                                  'Siblings',
                                  'Optional'),
                              const SizedBox(
                                  height: 14),
                              _buildBrotherSection(),
                              const SizedBox(
                                  height: 18),
                              _buildSisterSection(),
                              const SizedBox(
                                  height: 24),
                              _buildNote(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomBar(isSaving),
                  ],
                ),
              ),
            ),
          ),
          if (isSaving)
            const LoadingOverlay(
              message: 'Saving...',
              style: LoadingStyle.dots,
            ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () =>
              context.go('/setup/step3'),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Step 4 of 5',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Family Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () =>
              context.go('/setup/step5'),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(100),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white
                    .withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── PROGRESS BAR ──────────────────────────────────────

  Widget _buildProgressBar() {
    return Container(
      color: AppColors.crimson,
      padding: const EdgeInsets.fromLTRB(
          16, 0, 16, 12),
      child: Row(
        children: List.generate(5, (i) {
          final isDone = i < 3;
          final isCurrent = i == 3;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: i < 4 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.white
                    : isCurrent
                    ? Colors.white
                    .withOpacity(0.9)
                    : Colors.white
                    .withOpacity(0.25),
                borderRadius:
                BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── STEP TITLE ────────────────────────────────────────

  Widget _buildStepTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏠',
            style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text('Family Details',
            style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Share your family background\nto find compatible matches',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── SECTION HEADER ────────────────────────────────────

  Widget _buildSectionHeader(
      String emoji,
      String title,
      String subtitle,
      ) {
    return Row(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(emoji,
              style:
              const TextStyle(fontSize: 20)),
        ),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.h5),
          Text(subtitle,
              style: AppTextStyles.bodySmall),
        ],
      ),
    ]);
  }

  // ── FAMILY TYPE ───────────────────────────────────────

  Widget _buildFamilyType() {
    return AppDropdownField<String>(
      label: 'Family Type',
      hint: 'Select family type',
      value: _familyType,
      items: const [
        'joint', 'nuclear', 'other',
      ],
      itemLabel: (v) {
        switch (v) {
          case 'joint':
            return 'Joint Family';
          case 'nuclear':
            return 'Nuclear Family';
          default:
            return 'Other';
        }
      },
      prefixIcon: Icons.home_outlined,
      onChanged: (v) =>
          setState(() => _familyType = v),
    );
  }

  Widget _buildFamilyValues() {
    return AppDropdownField<String>(
      label: 'Family Values',
      hint: 'Select family values',
      value: _familyValues,
      items: const [
        'traditional', 'moderate', 'liberal',
      ],
      itemLabel: (v) {
        switch (v) {
          case 'traditional':
            return 'Traditional';
          case 'moderate':
            return 'Moderate';
          default:
            return 'Liberal';
        }
      },
      prefixIcon: Icons.people_outline_rounded,
      onChanged: (v) =>
          setState(() => _familyValues = v),
    );
  }

  Widget _buildFamilyCity() {
    return AppTextField(
      label: 'Family City / Hometown',
      hint: 'e.g. Lucknow, Patna, Jaipur',
      controller: _familyCityCtrl,
      prefixIcon: Icons.location_on_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  // ── PARENT STATUS ─────────────────────────────────────

  Widget _buildParentStatus() {
    return Row(children: [
      // Father status
      Expanded(
        child: AppDropdownField<String>(
          label: 'Father',
          hint: 'Status',
          value: _fatherStatus,
          items: const [
            'employed', 'retired',
            'business', 'passed_away',
          ],
          itemLabel: (v) {
            switch (v) {
              case 'employed':  return 'Employed';
              case 'retired':   return 'Retired';
              case 'business':  return 'Business';
              case 'passed_away': return 'Late';
              default: return v;
            }
          },
          prefixIcon: Icons.man_outlined,
          onChanged: (v) =>
              setState(() => _fatherStatus = v),
        ),
      ),
      const SizedBox(width: 12),
      // Mother status
      Expanded(
        child: AppDropdownField<String>(
          label: 'Mother',
          hint: 'Status',
          value: _motherStatus,
          items: const [
            'homemaker', 'employed',
            'retired', 'business',
            'passed_away',
          ],
          itemLabel: (v) {
            switch (v) {
              case 'homemaker': return 'Homemaker';
              case 'employed':  return 'Employed';
              case 'retired':   return 'Retired';
              case 'business':  return 'Business';
              case 'passed_away': return 'Late';
              default: return v;
            }
          },
          prefixIcon: Icons.woman_outlined,
          onChanged: (v) =>
              setState(() => _motherStatus = v),
        ),
      ),
    ]);
  }

  Widget _buildFatherOccupation() {
    return AppTextField(
      label: "Father's Occupation",
      hint: 'e.g. Retired Engineer, Businessman',
      controller: _fatherOccCtrl,
      prefixIcon: Icons.man_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildMotherOccupation() {
    return AppTextField(
      label: "Mother's Occupation",
      hint: 'e.g. Homemaker, Teacher',
      controller: _motherOccCtrl,
      prefixIcon: Icons.woman_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  // ── SIBLING SECTIONS ──────────────────────────────────

  Widget _buildBrotherSection() {
    return _SiblingCounter(
      emoji: '👦',
      label: 'Brothers',
      count: _brothers,
      marriedCount: _marriedBrothers,
      onCountChanged: (v) {
        setState(() {
          _brothers = v;
          // Ensure married <= total
          if (_marriedBrothers > v) {
            _marriedBrothers = v;
          }
        });
      },
      onMarriedChanged: (v) =>
          setState(() => _marriedBrothers = v),
    );
  }

  Widget _buildSisterSection() {
    return _SiblingCounter(
      emoji: '👧',
      label: 'Sisters',
      count: _sisters,
      marriedCount: _marriedSisters,
      onCountChanged: (v) {
        setState(() {
          _sisters = v;
          if (_marriedSisters > v) {
            _marriedSisters = v;
          }
        });
      },
      onMarriedChanged: (v) =>
          setState(() => _marriedSisters = v),
    );
  }

  // ── NOTE ──────────────────────────────────────────────

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_rounded,
            size: 15,
            color: AppColors.gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profiles with complete family '
                  'details receive 40% more '
                  'interest responses.',
              style: AppTextStyles.bodySmall
                  .copyWith(
                  color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────

  Widget _buildBottomBar(bool isSaving) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 12, 24,
        MediaQuery.of(context).padding.bottom +
            16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
              color: AppColors.border,
              width: 1),
        ),
        boxShadow: AppColors.modalShadow,
      ),
      child: Row(children: [
        // Progress dots
        Expanded(
          child: Row(
            children: List.generate(5, (i) {
              final isDone = i < 3;
              final isCurrent = i == 3;
              return Container(
                margin: const EdgeInsets.only(
                    right: 6),
                width: isCurrent ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (isDone || isCurrent)
                      ? AppColors.crimson
                      : AppColors.border,
                  borderRadius:
                  BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 140,
          height: 48,
          child: PrimaryButton(
            label:
            isSaving ? 'Saving...' : 'Next',
            icon: isSaving
                ? null
                : Icons.arrow_forward_rounded,
            isLoading: isSaving,
            onPressed: isSaving ? null : _next,
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SIBLING COUNTER WIDGET
// ─────────────────────────────────────────────────────────

class _SiblingCounter extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final int marriedCount;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<int> onMarriedChanged;

  const _SiblingCounter({
    required this.emoji,
    required this.label,
    required this.count,
    required this.marriedCount,
    required this.onCountChanged,
    required this.onMarriedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Total count row
          Row(children: [
            Text(
              emoji,
              style:
              const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLarge,
              ),
            ),
            _CounterButtons(
              value: count,
              min: 0,
              max: 10,
              onChanged: onCountChanged,
            ),
          ]),

          // Married count row (only if count > 0)
          if (count > 0) ...[
            const SizedBox(height: 12),
            const Divider(
                color: AppColors.border,
                height: 1),
            const SizedBox(height: 12),
            Row(children: [
              const SizedBox(width: 32),
              const Icon(
                Icons.favorite_rounded,
                size: 14,
                color: AppColors.crimson,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Married',
                  style: AppTextStyles
                      .bodySmall
                      .copyWith(
                      color:
                      AppColors.inkSoft),
                ),
              ),
              _CounterButtons(
                value: marriedCount,
                min: 0,
                max: count,
                onChanged: onMarriedChanged,
                small: true,
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// COUNTER BUTTONS WIDGET
// ─────────────────────────────────────────────────────────

class _CounterButtons extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool small;

  const _CounterButtons({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final btnSize = small ? 28.0 : 34.0;
    final iconSize = small ? 14.0 : 18.0;
    final fontSize = small ? 13.0 : 16.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minus
        GestureDetector(
          onTap: value > min
              ? () {
            HapticFeedback.selectionClick();
            onChanged(value - 1);
          }
              : null,
          child: AnimatedContainer(
            duration: const Duration(
                milliseconds: 150),
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              color: value > min
                  ? AppColors.crimsonSurface
                  : AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(8),
              border: Border.all(
                color: value > min
                    ? AppColors.crimson
                    .withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.remove_rounded,
                size: iconSize,
                color: value > min
                    ? AppColors.crimson
                    : AppColors.muted,
              ),
            ),
          ),
        ),

        // Count display
        SizedBox(
          width: small ? 32 : 40,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(
                  milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(
                      scale: anim, child: child),
              child: Text(
                '$value',
                key: ValueKey(value),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: value > 0
                      ? AppColors.ink
                      : AppColors.muted,
                ),
              ),
            ),
          ),
        ),

        // Plus
        GestureDetector(
          onTap: value < max
              ? () {
            HapticFeedback.selectionClick();
            onChanged(value + 1);
          }
              : null,
          child: AnimatedContainer(
            duration: const Duration(
                milliseconds: 150),
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              color: value < max
                  ? AppColors.crimson
                  : AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(8),
              border: Border.all(
                color: value < max
                    ? AppColors.crimson
                    : AppColors.border,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                size: iconSize,
                color: value < max
                    ? Colors.white
                    : AppColors.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}