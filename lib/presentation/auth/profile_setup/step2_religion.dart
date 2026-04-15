// lib/presentation/auth/profile_setup/step2_religion.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/utils/validators.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/core/widgets/custom_text_field.dart';
import 'package:rishta_app/core/widgets/loading_overlay.dart';
import 'package:rishta_app/providers/auth_provider.dart';
import 'package:rishta_app/data/models/profile_model.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// RELIGION / CASTE DATA
// ─────────────────────────────────────────────────────────

// Religion → Caste mapping
const Map<String, List<String>> _castesFor = {
  'Hindu': [
    'Brahmin', 'Kshatriya', 'Vaishya', 'Kayastha',
    'Rajput', 'Bania', 'Patel / Patidar',
    'Yadav', 'Jat', 'Reddy', 'Nair', 'Iyer',
    'Iyengar', 'Naidu', 'Lingayat', 'Maratha',
    'Khatri', 'Arora', 'Aggarwal', 'Gupta',
    'Kurmi', 'Kumhar', 'Other',
  ],
  'Muslim': [
    'Syed', 'Sheikh', 'Mughal', 'Pathan',
    'Ansari', 'Qureshi', 'Rajput', 'Malik',
    'Khoja', 'Bohra', 'Memon', 'Other',
  ],
  'Christian': [
    'Catholic', 'Protestant', 'CSI', 'CNI',
    'Pentecostal', 'Methodist', 'Baptist',
    'Jacobite', 'Other',
  ],
  'Sikh': [
    'Jat Sikh', 'Khatri Sikh', 'Arora Sikh',
    'Ramgarhia', 'Saini', 'Ramdasia', 'Other',
  ],
  'Jain': [
    'Digambar', 'Shwetambar', 'Oswal',
    'Porwal', 'Srimali', 'Other',
  ],
  'Buddhist': [
    'Mahayana', 'Theravada', 'Vajrayana',
    'Ambedkarite', 'Other',
  ],
  'Parsi': ['Parsi', 'Other'],
  'Other': ['Other'],
};

const List<String> _religions = [
  'Hindu', 'Muslim', 'Christian', 'Sikh',
  'Jain', 'Buddhist', 'Parsi', 'Other',
];

const List<String> _motherTongues = [
  'Hindi', 'Bengali', 'Telugu', 'Marathi',
  'Tamil', 'Gujarati', 'Kannada', 'Malayalam',
  'Punjabi', 'Odia', 'Urdu', 'English', 'Other',
];

// ─────────────────────────────────────────────────────────
// STEP 2 — RELIGION
// Fields: Religion, Caste, Sub-Caste,
//         Gotra, Manglik Status
// ─────────────────────────────────────────────────────────

class Step2Religion extends ConsumerStatefulWidget {
  const Step2Religion({super.key});

  @override
  ConsumerState<Step2Religion> createState() =>
      _Step2ReligionState();
}

class _Step2ReligionState
    extends ConsumerState<Step2Religion>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _subCasteCtrl = TextEditingController();
  final _gotraCtrl = TextEditingController();

  // Dropdown values
  String? _religion;
  String? _caste;
  String? _manglik;

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // Available castes based on selected religion
  List<String> get _availableCastes =>
      _religion != null
          ? (_castesFor[_religion] ?? ['Other'])
          : [];

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
    // Load from existing profile if editing
    final profile =
    ref.read(currentProfileProvider);
    if (profile == null) return;

    setState(() {
      _religion = profile.religion.isNotEmpty
          ? profile.religion
          : null;
      _caste = profile.caste.isNotEmpty
          ? profile.caste
          : null;
      _subCasteCtrl.text =
          profile.subCaste ?? '';
      _gotraCtrl.text = profile.gotra ?? '';
      _manglik = profile.manglik.value != 'no'
          ? profile.manglik.value
          : null;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _subCasteCtrl.dispose();
    _gotraCtrl.dispose();
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
      _showError('Profile not found. Please go back.');
      return;
    }

    final data = {
      'religion': _religion ?? '',
      'caste': _caste ?? '',
      'subCaste': _subCasteCtrl.text.trim(),
      'gotra': _gotraCtrl.text.trim(),
      'manglik': _manglik ?? 'no',
    };

    final ok = await ref
        .read(myProfileProvider.notifier)
        .updateProfile(data);

    if (!mounted) return;
    if (ok) {
      context.go('/setup/step3');
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
                              _buildReligionField(),
                              const SizedBox(
                                  height: 18),
                              _buildCasteField(),
                              const SizedBox(
                                  height: 18),
                              _buildSubCasteField(),
                              const SizedBox(
                                  height: 18),
                              _buildGotraField(),
                              const SizedBox(
                                  height: 18),
                              _buildManglikField(),
                              const SizedBox(
                                  height: 24),
                              _buildInfoNote(),
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
          onTap: () => context.go('/setup/step1'),
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
                color: Colors.white,
              ),
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
                'Step 2 of 5',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Religion & Community',
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
              context.go('/setup/step3'),
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
                color:
                Colors.white.withOpacity(0.9),
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
          final isDone = i < 1;
          final isCurrent = i == 1;
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
        const Text('🛕',
            style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text(
          'Religion & Community',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 6),
        Text(
          'This helps us find the best\nmatches within your community',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── FORM FIELDS ───────────────────────────────────────

  Widget _buildReligionField() {
    return AppDropdownField<String>(
      label: 'Religion',
      hint: 'Select your religion',
      value: _religion,
      required: true,
      items: _religions,
      prefixIcon: Icons.temple_hindu_outlined,
      validator: Validators.religion,
      onChanged: (v) {
        setState(() {
          _religion = v;
          // Reset caste when religion changes
          _caste = null;
        });
      },
    );
  }

  Widget _buildCasteField() {
    return Column(
      children: [
        AppDropdownField<String>(
          label: 'Caste',
          hint: _religion == null
              ? 'Select religion first'
              : 'Select your caste',
          value: _caste,
          required: true,
          enabled: _religion != null,
          items: _availableCastes,
          prefixIcon: Icons.groups_outlined,
          validator: Validators.caste,
          onChanged: (v) =>
              setState(() => _caste = v),
        ),
        // Religion hint
        if (_religion == null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              'Please select religion first',
              style: AppTextStyles.bodySmall,
            ),
          ]),
        ],
      ],
    );
  }

  Widget _buildSubCasteField() {
    return AppTextField(
      label: 'Sub Caste',
      hint: 'e.g. Kanyakubja, Mathur, Deshastha',
      controller: _subCasteCtrl,
      prefixIcon: Icons.account_tree_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
      validator: Validators.subCaste,
    );
  }

  Widget _buildGotraField() {
    return AppTextField(
      label: 'Gotra',
      hint: 'e.g. Kashyap, Bharadwaj, Sandilya',
      controller: _gotraCtrl,
      prefixIcon: Icons.family_restroom_rounded,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
      validator: Validators.gotra,
    );
  }

  Widget _buildManglikField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdownField<String>(
          label: 'Manglik Status',
          hint: 'Select your manglik status',
          value: _manglik,
          items: const [
            'no',
            'yes',
            'partial',
            'dont_know',
          ],
          itemLabel: (v) {
            switch (v) {
              case 'no':
                return 'Non-Manglik';
              case 'yes':
                return 'Manglik';
              case 'partial':
                return 'Partial Manglik';
              case 'dont_know':
                return "Don't Know";
              default:
                return v;
            }
          },
          prefixIcon: Icons.stars_rounded,
          helperText: 'Optional',
          onChanged: (v) =>
              setState(() => _manglik = v),
        ),
        // Manglik info note
        if (_manglik == 'yes' ||
            _manglik == 'partial') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius:
              BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.gold
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You will be matched with '
                        'other Manglik profiles '
                        'for better compatibility.',
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                        color:
                        AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── INFO NOTE ─────────────────────────────────────────

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 15,
            color: AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your religion and caste details '
                  'are only shared with profiles '
                  'that match your preferences.',
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
              final isDone = i < 1;
              final isCurrent = i == 1;
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
        // Next button
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