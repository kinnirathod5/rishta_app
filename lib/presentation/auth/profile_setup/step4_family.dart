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
//
// Fields (updated):
//   Section 1 — Family Background:
//     1. Family Type          ← required
//     2. Family Values        ← required
//     3. Family Status        ← optional ✅ NEW (was missing)
//     4. Family City          ← optional
//
//   Section 2 — Parents:
//     5. Father Status        ← optional
//     6. Father's Occupation  ← optional
//     7. Mother Status        ← optional
//     8. Mother's Occupation  ← optional
//
//   Section 3 — Siblings:
//     9. Brothers count + married count
//    10. Sisters count + married count
// ─────────────────────────────────────────────────────────

class Step4Family extends ConsumerStatefulWidget {
  const Step4Family({super.key});

  @override
  ConsumerState<Step4Family> createState() => _Step4FamilyState();
}

class _Step4FamilyState extends ConsumerState<Step4Family>
    with SingleTickerProviderStateMixin {

  final _formKey        = GlobalKey<FormState>();
  final _fatherOccCtrl  = TextEditingController();
  final _motherOccCtrl  = TextEditingController();
  final _familyCityCtrl = TextEditingController();

  // Dropdown values
  String? _familyType;
  String? _familyValues;
  String? _familyStatus;   // ✅ NEW
  String? _fatherStatus;
  String? _motherStatus;

  // Sibling counts
  int _brothers        = 0;
  int _sisters         = 0;
  int _marriedBrothers = 0;
  int _marriedSisters  = 0;

  // Animation
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

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
      duration: const Duration(milliseconds: 450),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  void _loadExistingData() {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _familyType           = profile.familyType.value;
        _familyValues         = profile.familyValues.value;
        _fatherOccCtrl.text   = profile.fatherOccupation ?? '';
        _motherOccCtrl.text   = profile.motherOccupation ?? '';
        _familyCityCtrl.text  = profile.familyCity ?? '';
        _brothers             = profile.brotherCount;
        _sisters              = profile.sisterCount;
        _marriedBrothers      = profile.marriedBrotherCount;
        _marriedSisters       = profile.marriedSisterCount;
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

  // ── SAVE ──────────────────────────────────────────────

  Future<void> _next() async {
    FocusScope.of(context).unfocus();

    if (_familyType == null) {
      _showError('Please select family type.');
      return;
    }
    if (_familyValues == null) {
      _showError('Please select family values.');
      return;
    }

    final data = {
      'familyType'          : _familyType ?? 'joint',
      'familyValues'        : _familyValues ?? 'moderate',
      'familyStatus'        : _familyStatus ?? '',       // ✅ NEW
      'familyCity'          : _familyCityCtrl.text.trim(),
      'fatherOccupation'    : _fatherStatus == 'passed_away'
          ? 'Late'
          : _fatherOccCtrl.text.trim(),
      'motherOccupation'    : _motherStatus == 'passed_away'
          ? 'Late'
          : _motherOccCtrl.text.trim(),
      'brotherCount'        : _brothers,
      'sisterCount'         : _sisters,
      'marriedBrotherCount' : _marriedBrothers,
      'marriedSisterCount'  : _marriedSisters,
      'setupStep'           : 4,
    };

    final ok = await ref.read(myProfileProvider.notifier).updateProfile(data);
    if (!mounted) return;
    if (ok) {
      context.go('/setup/step5');
    } else {
      final error = ref.read(myProfileProvider).error;
      _showError(error ?? 'Something went wrong.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(myProfileProvider).isSaving;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStepTitle(),
                              const SizedBox(height: 28),

                              // ── Section 1: Family Background ────
                              _buildSectionLabel(
                                icon: Icons.home_outlined,
                                label: 'Family Background',
                              ),
                              const SizedBox(height: 14),

                              // 1. Family Type
                              _buildFamilyType(),
                              const SizedBox(height: 16),

                              // 2. Family Values
                              _buildFamilyValues(),
                              const SizedBox(height: 16),

                              // 3. Family Status ✅ NEW
                              _buildFamilyStatus(),
                              const SizedBox(height: 16),

                              // 4. Family City
                              _buildFamilyCity(),
                              const SizedBox(height: 28),

                              // ── Section 2: Parents ──────────────
                              _buildSectionLabel(
                                icon: Icons.people_outline_rounded,
                                label: 'Parents',
                                isOptional: true,
                              ),
                              const SizedBox(height: 14),

                              // 5 & 7. Father + Mother Status (side by side)
                              _buildParentStatus(),
                              const SizedBox(height: 16),

                              // 6. Father Occupation
                              if (_fatherStatus != 'passed_away') ...[
                                _buildFatherOccupation(),
                                const SizedBox(height: 16),
                              ],

                              // 8. Mother Occupation
                              if (_motherStatus != 'passed_away') ...[
                                _buildMotherOccupation(),
                                const SizedBox(height: 16),
                              ],
                              const SizedBox(height: 12),

                              // ── Section 3: Siblings ─────────────
                              _buildSectionLabel(
                                icon: Icons.group_outlined,
                                label: 'Siblings',
                                isOptional: true,
                              ),
                              const SizedBox(height: 14),

                              // 9. Brothers
                              _buildBrotherSection(),
                              const SizedBox(height: 12),

                              // 10. Sisters
                              _buildSisterSection(),
                              const SizedBox(height: 24),

                              // Gold tip note
                              _buildNote(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomBar(isSaving),
            ),
            if (isSaving)
              const LoadingOverlay(
                message: 'Saving...',
                style: LoadingStyle.dots,
              ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.crimsonGradient,
      ),
      padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
      child: Column(
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => context.go('/setup/step3'),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step 4 of 5',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      )),
                  const Text('Family Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/setup/step5'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Skip for now',
                    style: TextStyle(fontSize: 12, color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(5, (i) {
        final isDone    = i < 3;
        final isCurrent = i == 3;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: (isCurrent || isDone)
                  ? Colors.white
                  : Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // ── STEP TITLE ────────────────────────────────────────

  Widget _buildStepTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏠', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text('Family Details', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Share your family background\nto find compatible matches',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── SECTION LABEL ─────────────────────────────────────

  Widget _buildSectionLabel({
    required IconData icon,
    required String label,
    bool isOptional = false,
  }) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Icon(icon, size: 16, color: AppColors.crimson)),
      ),
      const SizedBox(width: 10),
      Text(label, style: AppTextStyles.labelLarge),
      if (isOptional) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.ivoryDark,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text('Optional',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
        ),
      ],
    ]);
  }

  // ── FORM FIELDS ───────────────────────────────────────

  Widget _buildFamilyType() {
    return AppDropdownField<String>(
      label: 'Family Type',
      hint: 'Select family type',
      value: _familyType,
      required: true,
      items: const ['joint', 'nuclear', 'other'],
      itemLabel: (v) {
        switch (v) {
          case 'joint':   return 'Joint Family';
          case 'nuclear': return 'Nuclear Family';
          default:        return 'Other';
        }
      },
      prefixIcon: Icons.home_outlined,
      validator: (v) => v == null ? 'Please select family type' : null,
      onChanged: (v) => setState(() => _familyType = v),
    );
  }

  Widget _buildFamilyValues() {
    return AppDropdownField<String>(
      label: 'Family Values',
      hint: 'Select family values',
      value: _familyValues,
      required: true,
      items: const ['traditional', 'moderate', 'liberal'],
      itemLabel: (v) {
        switch (v) {
          case 'traditional': return 'Traditional';
          case 'moderate':    return 'Moderate';
          default:            return 'Liberal';
        }
      },
      prefixIcon: Icons.favorite_outline_rounded,
      validator: (v) => v == null ? 'Please select family values' : null,
      onChanged: (v) => setState(() => _familyValues = v),
    );
  }

  // ✅ NEW: Family Status
  Widget _buildFamilyStatus() {
    return AppDropdownField<String>(
      label: 'Family Status',
      hint: 'Select financial status',
      value: _familyStatus,
      items: const [
        'middle_class',
        'upper_middle_class',
        'rich',
        'affluent',
      ],
      itemLabel: (v) {
        switch (v) {
          case 'middle_class':       return 'Middle Class';
          case 'upper_middle_class': return 'Upper Middle Class';
          case 'rich':               return 'Rich';
          case 'affluent':           return 'Affluent / HNI';
          default:                   return v;
        }
      },
      prefixIcon: Icons.account_balance_wallet_outlined,
      helperText: 'Optional',
      onChanged: (v) => setState(() => _familyStatus = v),
    );
  }

  Widget _buildFamilyCity() {
    return AppTextField(
      label: 'Family City / Hometown',
      hint: 'e.g. Lucknow, Patna, Jaipur',
      controller: _familyCityCtrl,
      prefixIcon: Icons.location_on_outlined,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildParentStatus() {
    return Row(children: [
      // Father
      Expanded(
        child: AppDropdownField<String>(
          label: 'Father',
          hint: 'Status',
          value: _fatherStatus,
          items: const [
            'employed', 'retired', 'business', 'passed_away',
          ],
          itemLabel: (v) {
            switch (v) {
              case 'employed':    return 'Employed';
              case 'retired':     return 'Retired';
              case 'business':    return 'Business';
              case 'passed_away': return 'Late';
              default:            return v;
            }
          },
          prefixIcon: Icons.man_outlined,
          onChanged: (v) => setState(() {
            _fatherStatus = v;
            if (v == 'passed_away') _fatherOccCtrl.clear();
          }),
        ),
      ),
      const SizedBox(width: 12),
      // Mother
      Expanded(
        child: AppDropdownField<String>(
          label: 'Mother',
          hint: 'Status',
          value: _motherStatus,
          items: const [
            'homemaker', 'employed', 'retired',
            'business', 'passed_away',
          ],
          itemLabel: (v) {
            switch (v) {
              case 'homemaker':   return 'Homemaker';
              case 'employed':    return 'Employed';
              case 'retired':     return 'Retired';
              case 'business':    return 'Business';
              case 'passed_away': return 'Late';
              default:            return v;
            }
          },
          prefixIcon: Icons.woman_outlined,
          onChanged: (v) => setState(() {
            _motherStatus = v;
            if (v == 'passed_away') _motherOccCtrl.clear();
          }),
        ),
      ),
    ]);
  }

  Widget _buildFatherOccupation() {
    return AppTextField(
      label: "Father's Occupation",
      hint: 'e.g. Retired Engineer, Businessman',
      controller: _fatherOccCtrl,
      prefixIcon: Icons.work_outline_rounded,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildMotherOccupation() {
    return AppTextField(
      label: "Mother's Occupation",
      hint: 'e.g. Homemaker, Teacher, Doctor',
      controller: _motherOccCtrl,
      prefixIcon: Icons.work_outline_rounded,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildBrotherSection() {
    return _SiblingCounter(
      emoji: '👦',
      label: 'Brothers',
      count: _brothers,
      marriedCount: _marriedBrothers,
      onCountChanged: (v) => setState(() {
        _brothers = v;
        if (_marriedBrothers > v) _marriedBrothers = v;
      }),
      onMarriedChanged: (v) => setState(() => _marriedBrothers = v),
    );
  }

  Widget _buildSisterSection() {
    return _SiblingCounter(
      emoji: '👧',
      label: 'Sisters',
      count: _sisters,
      marriedCount: _marriedSisters,
      onCountChanged: (v) => setState(() {
        _sisters = v;
        if (_marriedSisters > v) _marriedSisters = v;
      }),
      onMarriedChanged: (v) => setState(() => _marriedSisters = v),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, size: 15, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profiles with complete family details receive 40% more interest responses.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────

  Widget _buildBottomBar(bool isSaving) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: PrimaryButton(
        label: 'Next  →',
        isLoading: isSaving,
        onPressed: isSaving ? null : _next,
      ),
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
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.labelLarge),
            const Spacer(),
            // Count badge
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.crimson),
                ),
              ),
          ]),
          const SizedBox(height: 14),

          // ── Total count stepper ────────────────
          Row(children: [
            Text('Total', style: AppTextStyles.bodyMedium),
            const Spacer(),
            _StepperButton(
              icon: Icons.remove_rounded,
              onTap: count > 0 ? () => onCountChanged(count - 1) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.add_rounded,
              onTap: count < 10 ? () => onCountChanged(count + 1) : null,
            ),
          ]),

          // ── Married count stepper (only if count > 0) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: count > 0
                ? Column(
              children: [
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(children: [
                  Text(
                    'Married',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.inkSoft),
                  ),
                  const Spacer(),
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onTap: marriedCount > 0
                        ? () => onMarriedChanged(marriedCount - 1)
                        : null,
                    small: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$marriedCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: marriedCount < count
                        ? () => onMarriedChanged(marriedCount + 1)
                        : null,
                    small: true,
                  ),
                ]),
              ],
            )
                : const SizedBox.shrink(),
          ),

          // Summary text
          if (count > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                marriedCount > 0
                    ? '$count $label ($marriedCount Married)'
                    : '$count $label',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.inkSoft,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEPPER BUTTON
// ─────────────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool small;

  const _StepperButton({
    required this.icon,
    this.onTap,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final size   = small ? 32.0 : 38.0;
    final iconSz = small ? 16.0 : 18.0;
    final isActive = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.crimsonSurface
              : AppColors.ivoryDark,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppColors.crimson.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSz,
            color: isActive ? AppColors.crimson : AppColors.muted,
          ),
        ),
      ),
    );
  }
}