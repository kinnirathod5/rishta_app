// lib/presentation/auth/profile_setup/step3_education.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/utils/validators.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/core/widgets/custom_text_field.dart';
import 'package:rishta_app/core/widgets/loading_overlay.dart';
import 'package:rishta_app/data/models/profile_model.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// EDUCATION DATA
// ─────────────────────────────────────────────────────────

const List<String> _qualifications = [
  'High School (10th)',
  'Intermediate (12th)',
  'Diploma',
  'Graduate (B.A / B.Sc / B.Com)',
  'Graduate (B.Tech / B.E)',
  'Graduate (BBA / BMS)',
  'Graduate (MBBS / BDS)',
  'Graduate (LLB)',
  'Post Graduate (M.A / M.Sc)',
  'Post Graduate (M.Tech / M.E)',
  'Post Graduate (MBA / PGDM)',
  'Post Graduate (MD / MS)',
  'Doctorate (PhD)',
  'CA / CS / CFA / CMA',
  'Other',
];

const List<String> _employmentTypes = [
  'Private Sector',
  'Government / PSU',
  'Business / Self-Employed',
  'Defence / Armed Forces',
  'Civil Services (IAS/IPS)',
  'Teaching / Academia',
  'Doctor / Healthcare',
  'Lawyer / Legal',
  'Not Working',
  'Other',
];

const List<String> _incomeRanges = [
  'Below ₹3 LPA',
  '₹3 – 5 LPA',
  '₹5 – 8 LPA',
  '₹8 – 12 LPA',
  '₹12 – 20 LPA',
  '₹20 – 30 LPA',
  '₹30 – 50 LPA',
  '₹50 LPA and above',
  'Prefer not to say',
];

// Occupation mapping per employment type
const Map<String, List<String>>
_occupationsFor = {
  'Private Sector': [
    'Software Engineer', 'Data Scientist',
    'Product Manager', 'Business Analyst',
    'HR Manager', 'Marketing Manager',
    'Finance Analyst', 'Sales Manager',
    'Operations Manager', 'Other',
  ],
  'Government / PSU': [
    'IAS Officer', 'IPS Officer', 'IFS Officer',
    'Bank Officer', 'Engineer (Govt)',
    'Teacher (Govt)', 'PSU Employee', 'Other',
  ],
  'Business / Self-Employed': [
    'Business Owner', 'Entrepreneur',
    'Freelancer', 'Consultant',
    'Shop Owner', 'Trader', 'Other',
  ],
  'Doctor / Healthcare': [
    'Doctor (MBBS)', 'Doctor (MD/MS)',
    'Dentist', 'Pharmacist',
    'Nurse', 'Physiotherapist', 'Other',
  ],
  'Teaching / Academia': [
    'School Teacher', 'College Professor',
    'Private Tutor', 'Principal', 'Other',
  ],
  'Lawyer / Legal': [
    'Advocate', 'Judge', 'Legal Consultant',
    'Company Secretary', 'Other',
  ],
  'Defence / Armed Forces': [
    'Army Officer', 'Navy Officer',
    'Air Force Officer', 'Police Officer',
    'Paramilitary', 'Other',
  ],
};

// ─────────────────────────────────────────────────────────
// STEP 3 — EDUCATION & CAREER
// ─────────────────────────────────────────────────────────

class Step3Education extends ConsumerStatefulWidget {
  const Step3Education({super.key});

  @override
  ConsumerState<Step3Education> createState() =>
      _Step3EducationState();
}

class _Step3EducationState
    extends ConsumerState<Step3Education>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _collegeCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _designationCtrl =
  TextEditingController();

  // Dropdown values
  String? _qualification;
  String? _employmentType;
  String? _occupation;
  String? _annualIncome;

  // Available occupations based on employment
  List<String> get _availableOccupations =>
      _employmentType != null
          ? (_occupationsFor[_employmentType] ??
          ['Other'])
          : [];

  bool get _isWorking =>
      _employmentType != null &&
          _employmentType != 'Not Working';

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
        _qualification =
        profile.qualification.isNotEmpty
            ? profile.qualification
            : null;
        _employmentType =
            profile.employmentType.label;
        _occupation = profile.designation;
        _annualIncome =
        profile.annualIncome.isNotEmpty
            ? profile.annualIncome
            : null;
        _collegeCtrl.text =
            profile.collegeName ?? '';
        _companyCtrl.text =
            profile.companyName ?? '';
        _designationCtrl.text =
            profile.designation ?? '';
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _collegeCtrl.dispose();
    _companyCtrl.dispose();
    _designationCtrl.dispose();
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

    // Map display label → model value
    final empTypeValue =
    _mapEmploymentType(_employmentType);

    final data = {
      'qualification': _qualification ?? '',
      'collegeName': _collegeCtrl.text.trim(),
      'employmentType': empTypeValue,
      'companyName': _companyCtrl.text.trim(),
      'designation':
      _designationCtrl.text.trim().isNotEmpty
          ? _designationCtrl.text.trim()
          : _occupation ?? '',
      'annualIncome': _annualIncome ?? '',
    };

    final ok = await ref
        .read(myProfileProvider.notifier)
        .updateProfile(data);

    if (!mounted) return;
    if (ok) {
      context.go('/setup/step4');
    } else {
      final error =
          ref.read(myProfileProvider).error;
      _showError(
          error ?? 'Something went wrong.');
    }
  }

  String _mapEmploymentType(String? label) {
    switch (label) {
      case 'Private Sector':
        return 'private';
      case 'Government / PSU':
        return 'govt';
      case 'Business / Self-Employed':
        return 'business';
      case 'Not Working':
        return 'not_working';
      default:
        return 'self_employed';
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

                              // ── EDUCATION ──
                              _buildSectionHeader(
                                '🎓',
                                'Education',
                                'Your academic background',
                              ),
                              const SizedBox(
                                  height: 14),
                              _buildQualification(),
                              const SizedBox(
                                  height: 18),
                              _buildCollege(),

                              const SizedBox(
                                  height: 28),

                              // ── CAREER ─────
                              _buildSectionHeader(
                                '💼',
                                'Career',
                                'Your professional background',
                              ),
                              const SizedBox(
                                  height: 14),
                              _buildEmploymentType(),
                              const SizedBox(
                                  height: 18),
                              if (_isWorking) ...[
                                _buildOccupation(),
                                const SizedBox(
                                    height: 18),
                                _buildCompany(),
                                const SizedBox(
                                    height: 18),
                                _buildDesignation(),
                                const SizedBox(
                                    height: 18),
                              ],
                              _buildIncome(),
                              const SizedBox(
                                  height: 24),
                              _buildPrivacyNote(),
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
              context.go('/setup/step2'),
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
                'Step 3 of 5',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Education & Career',
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
              context.go('/setup/step4'),
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
          final isDone = i < 2;
          final isCurrent = i == 2;
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
        const Text('🎓',
            style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text(
          'Education & Career',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 6),
        Text(
          'Share your educational and\nprofessional background',
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
              style: const TextStyle(
                  fontSize: 20)),
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

  // ── FORM FIELDS ───────────────────────────────────────

  Widget _buildQualification() {
    return AppDropdownField<String>(
      label: 'Highest Qualification',
      hint: 'Select your qualification',
      value: _qualification,
      required: true,
      items: _qualifications,
      prefixIcon: Icons.school_outlined,
      validator: Validators.qualification,
      onChanged: (v) =>
          setState(() => _qualification = v),
    );
  }

  Widget _buildCollege() {
    return AppTextField(
      label: 'College / University',
      hint: 'e.g. Delhi University, IIT Bombay',
      controller: _collegeCtrl,
      prefixIcon:
      Icons.account_balance_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
      validator: Validators.college,
    );
  }

  Widget _buildEmploymentType() {
    return AppDropdownField<String>(
      label: 'Employment Type',
      hint: 'Select employment type',
      value: _employmentType,
      required: true,
      items: _employmentTypes,
      prefixIcon: Icons.work_outline_rounded,
      validator: Validators.employmentType,
      onChanged: (v) {
        setState(() {
          _employmentType = v;
          // Reset occupation when type changes
          _occupation = null;
          _companyCtrl.clear();
          _designationCtrl.clear();
        });
      },
    );
  }

  Widget _buildOccupation() {
    return AppDropdownField<String>(
      label: 'Occupation',
      hint: 'Select your occupation',
      value: _occupation,
      items: _availableOccupations,
      prefixIcon: Icons.badge_outlined,
      helperText: 'Optional',
      onChanged: (v) {
        setState(() {
          _occupation = v;
          // Auto-fill designation
          if (v != null &&
              _designationCtrl.text.isEmpty) {
            _designationCtrl.text = v;
          }
        });
      },
    );
  }

  Widget _buildCompany() {
    return AppTextField(
      label: 'Company / Organization',
      hint: 'e.g. TCS, Infosys, ISRO, SBI',
      controller: _companyCtrl,
      prefixIcon: Icons.business_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
      validator: Validators.company,
    );
  }

  Widget _buildDesignation() {
    return AppTextField(
      label: 'Designation / Role',
      hint: 'e.g. Software Engineer, Sr. Manager',
      controller: _designationCtrl,
      prefixIcon: Icons.work_history_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildIncome() {
    return Column(
      children: [
        AppDropdownField<String>(
          label: 'Annual Income',
          hint: 'Select income range',
          value: _annualIncome,
          items: _incomeRanges,
          prefixIcon:
          Icons.currency_rupee_rounded,
          helperText:
          'This is only shared with your matches',
          onChanged: (v) =>
              setState(() => _annualIncome = v),
        ),
      ],
    );
  }

  // ── PRIVACY NOTE ──────────────────────────────────────

  Widget _buildPrivacyNote() {
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
              'Your income details are kept '
                  'private and only shown to '
                  'profiles that you match with.',
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
              final isDone = i < 2;
              final isCurrent = i == 2;
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