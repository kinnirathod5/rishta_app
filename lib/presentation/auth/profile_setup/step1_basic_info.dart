// lib/presentation/auth/profile_setup/step1_basic_info.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/utils/validators.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/core/widgets/custom_text_field.dart';
import 'package:rishta_app/core/widgets/loading_overlay.dart';
import 'package:rishta_app/data/models/profile_model.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// STEP 1 — BASIC INFO
//
// Fields (updated order):
//   1. Full Name         ← required
//   2. Gender            ← required
//   3. Marital Status    ← required (moved up — key filter)
//   4. Date of Birth     ← required
//   5. Height            ← required
//   6. Current City      ← required
//   7. Native City       ← optional
//   8. About Me          ← optional
//
// REMOVED from Step 1:
//   - Mother Tongue  → now in Step 2 (Religion & Community)
// ─────────────────────────────────────────────────────────

class Step1BasicInfo extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const Step1BasicInfo({super.key, this.extra});

  @override
  ConsumerState<Step1BasicInfo> createState() =>
      _Step1BasicInfoState();
}

class _Step1BasicInfoState
    extends ConsumerState<Step1BasicInfo>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl      = TextEditingController();
  final _cityCtrl      = TextEditingController();
  final _nativeCityCtrl = TextEditingController();
  final _aboutCtrl     = TextEditingController();

  // Focus nodes
  final _nameFocus  = FocusNode();
  final _cityFocus  = FocusNode();
  final _aboutFocus = FocusNode();

  // Values
  DateTime? _dob;
  int? _heightFeet;
  int? _heightInches;
  String? _gender;
  String? _maritalStatus;   // ← moved up

  // Errors
  String? _dobError;
  String? _heightError;

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double>  _fade;
  late Animation<Offset>  _slide;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _ctrl.forward();
    _gender = _detectGender();
    _loadExisting();
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

  // Gender auto-detect from profileFor
  String? _detectGender() {
    final profileFor = widget.extra?['profileFor'] as String?;
    if (profileFor == null) return null;
    switch (profileFor.toLowerCase()) {
      case 'myself':
      case 'son':
        return 'Male';
      case 'daughter':
      case 'sister':
        return 'Female';
      default:
        return null;
    }
  }

  void _loadExisting() {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _nameCtrl.text    = profile.fullName;
        _cityCtrl.text    = profile.currentCity;
        _aboutCtrl.text   = profile.about;
        // gender field ProfileModel mein nahi hai — profileFor se detect hota hai
        _maritalStatus    = profile.maritalStatus.value;
        if (profile.dateOfBirth != null) {
          _dob = profile.dateOfBirth;
        }
        if (profile.heightInInches > 0) {
          _heightFeet   = profile.heightInInches ~/ 12;
          _heightInches = profile.heightInInches % 12;
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _nativeCityCtrl.dispose();
    _aboutCtrl.dispose();
    _nameFocus.dispose();
    _cityFocus.dispose();
    _aboutFocus.dispose();
    super.dispose();
  }

  // ── VALIDATION ────────────────────────────────────────

  bool _validate() {
    bool ok = _formKey.currentState!.validate();

    // DOB validation
    if (_dob == null) {
      setState(() => _dobError = 'Date of birth is required');
      ok = false;
    } else {
      final age = DateTime.now().difference(_dob!).inDays ~/ 365;
      if (age < 18) {
        setState(() => _dobError = 'You must be at least 18 years old');
        ok = false;
      } else {
        setState(() => _dobError = null);
      }
    }

    // Height validation
    if (_heightFeet == null || _heightInches == null) {
      setState(() => _heightError = 'Please select height');
      ok = false;
    } else {
      setState(() => _heightError = null);
    }

    return ok;
  }

  // ── SAVE ──────────────────────────────────────────────

  Future<void> _saveAndNext() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final heightInInches = (_heightFeet! * 12) + _heightInches!;
    final data = {
      'fullName'      : _nameCtrl.text.trim(),
      'gender'        : _gender!,
      'maritalStatus' : _maritalStatus ?? 'never_married',
      'dateOfBirth'   : _dob!.toIso8601String(),
      'heightInInches': heightInInches,
      'currentCity'   : _cityCtrl.text.trim(),
      'nativeCity'    : _nativeCityCtrl.text.trim(),
      'about'         : _aboutCtrl.text.trim(),
      'setupStep'     : 1,
    };

    final ok = await ref.read(myProfileProvider.notifier).updateProfile(data);
    if (!mounted) return;
    if (ok) {
      context.go('/setup/step2');
    } else {
      final error = ref.read(myProfileProvider).error ?? 'Kuch galat hua. Dobara try karein.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── DATE PICKER ───────────────────────────────────────

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now  = DateTime.now();
    final max  = DateTime(now.year - 18, now.month, now.day);
    final init = _dob ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: init.isBefore(max) ? init : max,
      firstDate: DateTime(1950),
      lastDate: max,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.crimson,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobError = null;
      });
    }
  }

  // ── AGE HELPER ────────────────────────────────────────

  String _formatDob(DateTime dob) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final age = DateTime.now().difference(dob).inDays ~/ 365;
    return '${dob.day} ${months[dob.month - 1]} ${dob.year}  •  $age yrs';
  }

  // ── BUILD ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(myProfileProvider.select((s) => s.isSaving));

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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        physics: const BouncingScrollPhysics(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStepTitle(),
                              const SizedBox(height: 28),

                              // 1. Full Name
                              _buildNameField(),
                              const SizedBox(height: 16),

                              // 2. Gender
                              _buildGenderField(),
                              const SizedBox(height: 16),

                              // 3. Marital Status ← MOVED UP (key filter)
                              _buildMaritalStatusField(),
                              const SizedBox(height: 20),

                              // 4. Date of Birth
                              _buildDobField(),
                              const SizedBox(height: 16),

                              // 5. Height
                              _buildHeightField(),
                              const SizedBox(height: 16),

                              // 6. Current City
                              _buildCityField(),
                              const SizedBox(height: 16),

                              // 7. Native City (optional)
                              _buildNativeCityField(),
                              const SizedBox(height: 16),

                              // 8. About Me (optional)
                              _buildAboutField(),
                              const SizedBox(height: 6),
                              _buildAboutCounter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
              onTap: () => context.go('/profile-type'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
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
                  Text(
                    'Step 1 of 5',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Skip
            GestureDetector(
              onTap: () => context.go('/setup/step2'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        final isDone    = i < 0;
        final isCurrent = i == 0;
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
        const Text('🌺', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text('Meri Jankari', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Apne baare mein sahi jankari bharein\ntaaki achha rishta mile',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── FORM FIELDS ───────────────────────────────────────

  Widget _buildNameField() {
    return AppTextField(
      label: AppStrings.fullName,
      hint: 'e.g. Ramesh Rathod',
      controller: _nameCtrl,
      focusNode: _nameFocus,
      required: true,
      prefixIcon: Icons.person_outline_rounded,
      textCapitalization: TextCapitalization.words,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\']"))  ,
        LengthLimitingTextInputFormatter(60),
      ],
      validator: Validators.name,
    );
  }

  Widget _buildGenderField() {
    return AppDropdownField<String>(
      label: 'Gender',
      hint: 'Select your gender',
      value: _gender,
      required: true,
      items: const ['Male', 'Female', 'Other'],
      prefixIcon: Icons.wc_rounded,
      validator: (v) => Validators.dropdown(v, errorMessage: 'Please select your gender'),
      onChanged: (v) => setState(() => _gender = v),
    );
  }

  // ✅ MOVED UP — was last, now 3rd field
  Widget _buildMaritalStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdownField<String>(
          label: 'Marital Status',
          hint: 'Select marital status',
          value: _maritalStatus,
          required: true,
          items: const [
            'never_married',
            'divorced',
            'widowed',
            'separated',
          ],
          itemLabel: (v) {
            switch (v) {
              case 'never_married': return 'Never Married';
              case 'divorced':      return 'Divorced';
              case 'widowed':       return 'Widowed';
              case 'separated':     return 'Separated';
              default:              return v;
            }
          },
          prefixIcon: Icons.favorite_outline_rounded,
          validator: (v) => Validators.dropdown(v, errorMessage: 'Please select marital status'),
          onChanged: (v) => setState(() => _maritalStatus = v),
        ),
        // Helpful note for divorced/widowed users
        if (_maritalStatus == 'divorced' || _maritalStatus == 'widowed' || _maritalStatus == 'separated') ...[
          const SizedBox(height: 8),
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
                    'Banjara samaj mein doosra vivah ke rishte bhi uplabdh hain. Apni details sahi bharein.',
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

  Widget _buildDobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(AppStrings.dateOfBirth, style: AppTextStyles.inputLabel),
          Text(' *', style: AppTextStyles.inputLabel.copyWith(color: AppColors.crimson)),
        ]),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: _pickDob,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _dobError != null ? AppColors.error : AppColors.border,
                width: _dobError != null ? 2 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: ColoredBox(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _dob != null ? AppColors.crimson : AppColors.muted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dob != null ? _formatDob(_dob!) : 'DD / MM / YYYY',
                        style: TextStyle(
                          fontSize: 15,
                          color: _dob != null ? AppColors.ink : AppColors.muted,
                          fontWeight: _dob != null ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                    // Age badge
                    if (_dob != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.crimsonSurface,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${DateTime.now().difference(_dob!).inDays ~/ 365} yrs',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.crimson,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.muted),
                  ]),
                ),
              ),
            ),
          ),
        ),
        if (_dobError != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 13, color: AppColors.error),
            const SizedBox(width: 4),
            Text(_dobError!, style: AppTextStyles.inputError),
          ]),
        ],
      ],
    );
  }

  Widget _buildHeightField() {
    // 4'5" to 6'5" — feet: 4-6, inches: 0-11
    final feetOptions   = List.generate(4, (i) => i + 4); // 4,5,6,7
    final inchesOptions = List.generate(12, (i) => i);    // 0-11

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Height', style: AppTextStyles.inputLabel),
          Text(' *', style: AppTextStyles.inputLabel.copyWith(color: AppColors.crimson)),
        ]),
        const SizedBox(height: 7),
        Row(children: [
          // Feet
          Expanded(
            child: AppDropdownField<int>(
              hint: 'Feet',
              value: _heightFeet,
              items: feetOptions,
              itemLabel: (v) => "$v'  feet",
              onChanged: (v) => setState(() {
                _heightFeet   = v;
                _heightInches ??= 0;
                _heightError  = null;
              }),
            ),
          ),
          const SizedBox(width: 12),
          // Inches
          Expanded(
            child: AppDropdownField<int>(
              hint: 'Inches',
              value: _heightInches,
              items: inchesOptions,
              itemLabel: (v) => '$v"  inches',
              enabled: _heightFeet != null,
              onChanged: (v) => setState(() {
                _heightInches = v;
                _heightError  = null;
              }),
            ),
          ),
        ]),
        // Height in cm hint
        if (_heightFeet != null && _heightInches != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 13, color: AppColors.success),
            const SizedBox(width: 5),
            Text(
              "$_heightFeet' $_heightInches\"  (${((_heightFeet! * 12 + _heightInches!) * 2.54).round()} cm)",
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
            ),
          ]),
        ],
        if (_heightError != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 13, color: AppColors.error),
            const SizedBox(width: 4),
            Text(_heightError!, style: AppTextStyles.inputError),
          ]),
        ],
      ],
    );
  }

  Widget _buildCityField() {
    return AppTextField(
      label: 'Current City',
      hint: 'e.g. Hyderabad, Nagpur, Solapur',
      controller: _cityCtrl,
      focusNode: _cityFocus,
      required: true,
      prefixIcon: Icons.location_on_outlined,
      textCapitalization: TextCapitalization.words,
      validator: Validators.city,
      helperText: 'Banjara community is spread across Telangana, Maharashtra, Karnataka',
    );
  }

  Widget _buildNativeCityField() {
    return AppTextField(
      label: 'Native Place / Tanda',
      hint: 'e.g. Tanda name, village, district',
      controller: _nativeCityCtrl,
      keyboardType: TextInputType.text,
      prefixIcon: Icons.home_outlined,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional — aapka Tanda / mool sthan',
    );
  }

  // ✅ Mother Tongue REMOVED from Step 1 — moved to Step 2

  Widget _buildAboutField() {
    return AppTextField.multiline(
      label: 'Apne Baare Mein (About)',
      hint: 'Apne baare mein likhein — interests, values, Banjara culture se lagaav...',
      controller: _aboutCtrl,
      maxLines: 4,
      maxLength: 300,
      showCounter: false,
      validator: Validators.about,
    );
  }

  Widget _buildAboutCounter() {
    final count = _aboutCtrl.text.length;
    final isNear = count > 270;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$count / 300',
        style: AppTextStyles.bodySmall.copyWith(
          color: isNear ? AppColors.error : AppColors.muted,
          fontWeight: isNear ? FontWeight.w600 : FontWeight.w400,
        ),
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