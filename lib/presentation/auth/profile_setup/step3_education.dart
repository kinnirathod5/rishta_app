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
// STEP 3 — EDUCATION & CAREER
//
// Fields (updated):
//   Section 1 — Education:
//     1. Highest Qualification  ← required
//     2. College / University   ← optional
//
//   Section 2 — Career:
//     3. Employment Type        ← required
//     4. Occupation / Role      ← conditional
//     5. Company Name           ← optional
//     6. Designation            ← optional
//     7. Annual Income          ← optional
//     8. Working City           ← optional ✅ NEW
//
//   Section 3 — NRI:
//     9. NRI Toggle             ← optional ✅ NEW
//    10. NRI Country            ← conditional on toggle ✅ NEW
// ─────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────
// DATA
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

// ✅ NEW: NRI Countries list
const List<String> _nriCountries = [
  'USA', 'UK', 'Canada', 'Australia',
  'UAE / Dubai', 'Singapore', 'Germany',
  'New Zealand', 'Netherlands', 'France',
  'Italy', 'Switzerland', 'Japan',
  'Malaysia', 'Qatar', 'Saudi Arabia',
  'Bahrain', 'Kuwait', 'Oman', 'Other',
];

const Map<String, List<String>> _occupationsFor = {
  'Private Sector': [
    'Software Engineer', 'Data Scientist', 'Product Manager',
    'Business Analyst', 'HR Manager', 'Marketing Manager',
    'Finance Analyst', 'Sales Manager', 'Operations Manager', 'Other',
  ],
  'Government / PSU': [
    'IAS Officer', 'IPS Officer', 'IFS Officer', 'Bank Officer',
    'Engineer (Govt)', 'Teacher (Govt)', 'PSU Employee', 'Other',
  ],
  'Business / Self-Employed': [
    'Business Owner', 'Entrepreneur', 'Freelancer',
    'Consultant', 'Shop Owner', 'Trader', 'Other',
  ],
  'Doctor / Healthcare': [
    'Doctor (MBBS)', 'Doctor (MD/MS)', 'Dentist',
    'Pharmacist', 'Nurse', 'Physiotherapist', 'Other',
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
    'Army Officer', 'Navy Officer', 'Air Force Officer',
    'Police Officer', 'Paramilitary', 'Other',
  ],
  'Civil Services (IAS/IPS)': [
    'IAS Officer', 'IPS Officer', 'IFS Officer',
    'IRS Officer', 'Other Central Services', 'Other',
  ],
};

// ─────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────

class Step3Education extends ConsumerStatefulWidget {
  const Step3Education({super.key});

  @override
  ConsumerState<Step3Education> createState() => _Step3EducationState();
}

class _Step3EducationState extends ConsumerState<Step3Education>
    with SingleTickerProviderStateMixin {

  final _formKey         = GlobalKey<FormState>();
  final _collegeCtrl     = TextEditingController();
  final _companyCtrl     = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _workingCityCtrl = TextEditingController(); // ✅ NEW

  // Values
  String? _qualification;
  String? _employmentType;
  String? _occupation;
  String? _annualIncome;
  bool    _isNri       = false;              // ✅ NEW
  String? _nriCountry;                       // ✅ NEW

  bool get _isWorking =>
      _employmentType != null && _employmentType != 'Not Working';

  List<String> get _availableOccupations =>
      _employmentType != null
          ? (_occupationsFor[_employmentType] ?? ['Other'])
          : [];

  // Animation
  late AnimationController _ctrl;
  late Animation<double>  _fade;
  late Animation<Offset>  _slide;

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
        _qualification  = profile.qualification.isNotEmpty ? profile.qualification : null;
        _employmentType = profile.employmentType.label;
        _occupation     = profile.designation;
        _annualIncome   = profile.annualIncome.isNotEmpty ? profile.annualIncome : null;
        _collegeCtrl.text     = profile.collegeName ?? '';
        _companyCtrl.text     = profile.companyName ?? '';
        _designationCtrl.text = profile.designation ?? '';
        // NRI fields — stored in companyName with prefix if needed
        // Phase 3 mein separate fields honge
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _collegeCtrl.dispose();
    _companyCtrl.dispose();
    _designationCtrl.dispose();
    _workingCityCtrl.dispose();
    super.dispose();
  }

  // ── SAVE ──────────────────────────────────────────────

  Future<void> _saveAndNext() async {
    FocusScope.of(context).unfocus();

    if (_qualification == null) {
      _showError('Please select your highest qualification.');
      return;
    }
    if (_employmentType == null) {
      _showError('Please select your employment type.');
      return;
    }

    final data = {
      'qualification' : _qualification ?? '',
      'collegeName'   : _collegeCtrl.text.trim(),
      'employmentType': _mapEmploymentType(_employmentType),
      'companyName'   : _companyCtrl.text.trim(),
      'designation'   : _isWorking
          ? (_designationCtrl.text.trim().isNotEmpty
          ? _designationCtrl.text.trim()
          : _occupation ?? '')
          : '',
      'annualIncome'  : _annualIncome ?? '',
      'workingCity'   : _workingCityCtrl.text.trim(),  // ✅ NEW
      'isNri'         : _isNri,                         // ✅ NEW
      'nriCountry'    : _isNri ? (_nriCountry ?? '') : '', // ✅ NEW
      'setupStep'     : 3,
    };

    final ok = await ref.read(myProfileProvider.notifier).updateProfile(data);
    if (!mounted) return;
    if (ok) {
      context.go('/setup/step4');
    } else {
      final error = ref.read(myProfileProvider).error;
      _showError(error ?? 'Something went wrong.');
    }
  }

  String _mapEmploymentType(String? label) {
    switch (label) {
      case 'Private Sector':           return 'private';
      case 'Government / PSU':         return 'govt';
      case 'Business / Self-Employed': return 'business';
      case 'Not Working':              return 'not_working';
      case 'Defence / Armed Forces':   return 'govt';
      case 'Civil Services (IAS/IPS)': return 'govt';
      default:                         return 'self_employed';
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

                              // ── Section 1: Education ────────────
                              _buildSectionLabel(
                                icon: Icons.school_outlined,
                                label: 'Education',
                              ),
                              const SizedBox(height: 14),

                              // 1. Qualification
                              _buildQualification(),
                              const SizedBox(height: 16),

                              // 2. College
                              _buildCollege(),
                              const SizedBox(height: 28),

                              // ── Section 2: Career ───────────────
                              _buildSectionLabel(
                                icon: Icons.work_outline_rounded,
                                label: 'Career',
                              ),
                              const SizedBox(height: 14),

                              // 3. Employment Type
                              _buildEmploymentType(),
                              const SizedBox(height: 16),

                              // 4. Occupation (conditional)
                              if (_isWorking &&
                                  _availableOccupations.isNotEmpty) ...[
                                _buildOccupation(),
                                const SizedBox(height: 16),
                              ],

                              // 5. Company Name
                              if (_isWorking) ...[
                                _buildCompanyName(),
                                const SizedBox(height: 16),
                              ],

                              // 6. Designation
                              if (_isWorking) ...[
                                _buildDesignation(),
                                const SizedBox(height: 16),
                              ],

                              // 7. Annual Income
                              _buildIncome(),
                              const SizedBox(height: 16),

                              // 8. Working City ✅ NEW
                              _buildWorkingCity(),
                              const SizedBox(height: 28),

                              // ── Section 3: NRI ✅ NEW ───────────
                              _buildSectionLabel(
                                icon: Icons.flight_outlined,
                                label: 'NRI / Abroad',
                                isOptional: true,
                              ),
                              const SizedBox(height: 14),
                              _buildNriSection(),
                              const SizedBox(height: 24),

                              // Privacy note
                              _buildPrivacyNote(),
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
              onTap: () => context.go('/setup/step2'),
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
                  Text('Step 3 of 5',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      )),
                  const Text('Education & Career',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/setup/step4'),
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
        final isDone    = i < 2;
        final isCurrent = i == 2;
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
        const Text('🎓', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text('Education & Career', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Share your educational and\nprofessional background',
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

  Widget _buildQualification() {
    return AppDropdownField<String>(
      label: 'Highest Qualification',
      hint: 'Select your qualification',
      value: _qualification,
      required: true,
      items: _qualifications,
      prefixIcon: Icons.school_outlined,
      validator: (v) => Validators.dropdown(v,
          errorMessage: 'Please select qualification'),
      onChanged: (v) => setState(() => _qualification = v),
    );
  }

  Widget _buildCollege() {
    return AppTextField(
      label: 'College / University',
      hint: 'e.g. Delhi University, IIT Bombay',
      controller: _collegeCtrl,
      prefixIcon: Icons.account_balance_outlined,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional',
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
      validator: (v) => Validators.dropdown(v,
          errorMessage: 'Please select employment type'),
      onChanged: (v) => setState(() {
        _employmentType = v;
        _occupation     = null; // reset occupation when type changes
      }),
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
      onChanged: (v) => setState(() => _occupation = v),
    );
  }

  Widget _buildCompanyName() {
    return AppTextField(
      label: 'Company / Organisation',
      hint: 'e.g. TCS, Infosys, ISRO, SBI',
      controller: _companyCtrl,
      prefixIcon: Icons.business_outlined,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildDesignation() {
    return AppTextField(
      label: 'Designation / Role',
      hint: 'e.g. Software Engineer, Sr. Manager',
      controller: _designationCtrl,
      prefixIcon: Icons.work_history_outlined,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildIncome() {
    return AppDropdownField<String>(
      label: 'Annual Income',
      hint: 'Select income range',
      value: _annualIncome,
      items: _incomeRanges,
      prefixIcon: Icons.currency_rupee_rounded,
      helperText: 'Shared only with your matches',
      onChanged: (v) => setState(() => _annualIncome = v),
    );
  }

  // ✅ NEW: Working City
  Widget _buildWorkingCity() {
    return AppTextField(
      label: 'Working City',
      hint: 'e.g. Bangalore, Mumbai, Gurugram',
      controller: _workingCityCtrl,
      prefixIcon: Icons.location_city_outlined,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional — if different from current city',
    );
  }

  // ✅ NEW: NRI Section — toggle + country dropdown
  Widget _buildNriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NRI Toggle tile
        GestureDetector(
          onTap: () => setState(() {
            _isNri = !_isNri;
            if (!_isNri) _nriCountry = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isNri ? AppColors.crimsonSurface : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isNri
                    ? AppColors.crimson.withOpacity(0.4)
                    : AppColors.border,
                width: _isNri ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _isNri
                      ? AppColors.crimson.withOpacity(0.1)
                      : AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.flight_takeoff_rounded,
                    size: 18,
                    color: _isNri ? AppColors.crimson : AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I am an NRI / Living Abroad',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _isNri ? AppColors.crimson : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Currently residing outside India',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isNri,
                onChanged: (v) => setState(() {
                  _isNri = v;
                  if (!v) _nriCountry = null;
                }),
                activeColor: AppColors.crimson,
              ),
            ]),
          ),
        ),

        // Country dropdown — shown only when NRI is ON
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: _isNri
              ? Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AppDropdownField<String>(
              label: 'Country of Residence',
              hint: 'Select country',
              value: _nriCountry,
              required: true,
              items: _nriCountries,
              prefixIcon: Icons.public_outlined,
              validator: _isNri
                  ? (v) => Validators.dropdown(v,
                  errorMessage: 'Please select your country')
                  : null,
              onChanged: (v) => setState(() => _nriCountry = v),
            ),
          )
              : const SizedBox.shrink(),
        ),

        // NRI info note
        if (_isNri) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your NRI status will be shown on your profile. Matches from the same country will be prioritized.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your income details are kept private and only shown to profiles that you match with.',
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
        onPressed: isSaving ? null : _saveAndNext,
      ),
    );
  }
}