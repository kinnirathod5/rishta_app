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
// Fields: Full Name, Gender, DOB, Height,
//         Current City, Native City,
//         Mother Tongue, Marital Status, About Me
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
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _nativeCityCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  // Focus nodes
  final _nameFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _aboutFocus = FocusNode();

  // Values
  DateTime? _dob;
  int? _heightFeet;
  int? _heightInches;
  String? _gender;
  String? _motherTongue;
  String? _maritalStatus;

  // Errors
  String? _dobError;
  String? _heightError;

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

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
      duration:
      const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut));
  }

  // Gender auto-detect from profileFor
  String? _detectGender() {
    final profileFor =
    widget.extra?['profileFor'] as String?;
    switch (profileFor) {
      case 'daughter':
      case 'sister':
        return 'Female';
      case 'son':
      case 'brother':
        return 'Male';
      default:
        return null;
    }
  }

  void _loadExisting() {
    final profile =
    ref.read(currentProfileProvider);
    if (profile == null) return;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = profile.fullName;
        _cityCtrl.text = profile.currentCity;
        _nativeCityCtrl.text =
            profile.nativeCity ?? '';
        _aboutCtrl.text = profile.about ?? '';
        if (profile.heightInInches > 0) {
          _heightFeet =
              profile.heightInInches ~/ 12;
          _heightInches =
              profile.heightInInches % 12;
        }
        _motherTongue =
        profile.motherTongue.isNotEmpty
            ? profile.motherTongue
            : null;
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
    final formValid =
        _formKey.currentState?.validate() ??
            false;

    final dobErr = Validators.dateOfBirth(_dob);
    setState(() => _dobError = dobErr);

    if (_heightFeet == null) {
      setState(() =>
      _heightError =
          AppStrings.heightRequired);
    } else {
      setState(() => _heightError = null);
    }

    return formValid &&
        dobErr == null &&
        _heightFeet != null;
  }

  // ── DATE PICKER ───────────────────────────────────────

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ??
        DateTime(
            now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(
          now.year - 18, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.crimson,
            onPrimary: Colors.white,
            surface: AppColors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor:
                AppColors.crimson),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobError =
            Validators.dateOfBirth(picked);
      });
    }
  }

  // ── SUBMIT ────────────────────────────────────────────

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final totalInches =
        (_heightFeet! * 12) +
            (_heightInches ?? 0);

    final profileFor =
        widget.extra?['profileFor']
        as String? ??
            ProfileFor.self.value;

    final data = {
      'profileFor': profileFor,
      'fullName': _nameCtrl.text.trim(),
      'dateOfBirth': _dob!.toIso8601String(),
      'heightInInches': totalInches,
      'currentCity': _cityCtrl.text.trim(),
      'nativeCity':
      _nativeCityCtrl.text.trim(),
      'about': _aboutCtrl.text.trim(),
      if (_gender != null) 'gender': _gender,
      if (_motherTongue != null)
        'motherTongue': _motherTongue,
      if (_maritalStatus != null)
        'maritalStatus': _maritalStatus,
    };

    final ok = await ref
        .read(myProfileProvider.notifier)
        .updateProfile(data);

    if (!mounted) return;
    if (ok) {
      context.go('/setup/step2');
    } else {
      final error =
          ref.read(myProfileProvider).error;
      _showError(
          error ?? 'Kuch galat hua. Dobara try karein.');
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
        duration:
        const Duration(seconds: 3),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────

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
                            20, 20,
                            20, 100),
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
                            _buildNameField(),
                            const SizedBox(
                                height: 16),
                            _buildGenderField(),
                            const SizedBox(
                                height: 20),
                            _buildDobField(),
                            const SizedBox(
                                height: 16),
                            _buildHeightField(),
                            const SizedBox(
                                height: 16),
                            _buildCityField(),
                            const SizedBox(
                                height: 16),
                            _buildNativeCityField(),
                            const SizedBox(
                                height: 16),
                            _buildMotherTongueField(),
                            const SizedBox(
                                height: 16),
                            _buildMaritalStatusField(),
                            const SizedBox(
                                height: 16),
                            _buildAboutField(),
                            const SizedBox(
                                height: 6),
                            _buildAboutCounter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isSaving),
          ),
          // Loading overlay
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
    final topPad =
        MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(
          16, topPad + 10, 16, 12),
      child: Row(children: [
        // Back button
        GestureDetector(
          onTap: () =>
              context.go('/profile-type'),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.18),
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
        // Step info
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Step 1 of 5',
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.white.withOpacity(0.7),
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
          onTap: () => context.go('/home'),
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
          final isDone = i < 0;
          final isCurrent = i == 0;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: i < 4 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isCurrent || isDone
                    ? Colors.white
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
        const Text('👤',
            style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text(AppStrings.basicInfo,
            style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          AppStrings.basicInfoSub,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── FORM FIELDS ───────────────────────────────────────

  Widget _buildNameField() {
    return AppTextField.name(
      label: AppStrings.fullName,
      controller: _nameCtrl,
      focusNode: _nameFocus,
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
      validator: (v) => Validators.dropdown(
          v,
          errorMessage:
          'Please select your gender'),
      onChanged: (v) =>
          setState(() => _gender = v),
    );
  }

  Widget _buildDobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label — same style as AppDropdownField
        Row(children: [
          Text(
            AppStrings.dateOfBirth,
            style: AppTextStyles.inputLabel,
          ),
          Text(
            ' *',
            style: AppTextStyles.inputLabel
                .copyWith(color: AppColors.crimson),
          ),
        ]),
        const SizedBox(height: 7),

        // Date picker — styled exactly like dropdown
        GestureDetector(
          onTap: _pickDob,
          child: AnimatedContainer(
            duration:
            const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
              BorderRadius.circular(10),
              border: Border.all(
                color: _dobError != null
                    ? AppColors.error
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: _dob != null
                      ? AppColors.crimson
                      : AppColors.muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dob != null
                        ? _formatDob(_dob!)
                        : AppStrings.dobHint,
                    style: _dob != null
                        ? AppTextStyles.inputText
                        : AppTextStyles.inputHint,
                  ),
                ),
                if (_dob != null) ...[
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3),
                    decoration: BoxDecoration(
                      color:
                      AppColors.crimsonSurface,
                      borderRadius:
                      BorderRadius.circular(
                          100),
                    ),
                    child: Text(
                      '${_calculateAge(_dob!)} yrs',
                      style: AppTextStyles
                          .labelSmall
                          .copyWith(
                          color:
                          AppColors.crimson),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
              ]),
            ),
          ),
        ),

        // Error text
        if (_dobError != null)
          Padding(
            padding: const EdgeInsets.only(
                top: 6, left: 4),
            child: Row(children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 13,
                color: AppColors.error,
              ),
              const SizedBox(width: 5),
              Text(
                _dobError!,
                style: AppTextStyles.inputError,
              ),
            ]),
          ),
      ],
    );
  }

  Widget _buildHeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(children: [
          Text(
            AppStrings.height,
            style: AppTextStyles.inputLabel,
          ),
          Text(' *',
              style: AppTextStyles.inputLabel
                  .copyWith(
                  color: AppColors.crimson)),
        ]),
        const SizedBox(height: 7),
        // Two dropdowns
        Row(children: [
          Expanded(
            child: AppDropdownField<int>(
              hint: "Feet",
              value: _heightFeet,
              items:
              List.generate(4, (i) => i + 4),
              itemLabel: (v) => "$v'  feet",
              onChanged: (v) => setState(() {
                _heightFeet = v;
                _heightError = null;
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppDropdownField<int>(
              hint: 'Inches',
              value: _heightInches,
              items: List.generate(12, (i) => i),
              itemLabel: (v) => '$v"  inches',
              onChanged: (v) => setState(
                      () => _heightInches = v),
            ),
          ),
        ]),
        // Live cm display
        if (_heightFeet != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 13,
              color: AppColors.success,
            ),
            const SizedBox(width: 5),
            Text(
              "$_heightFeet' ${_heightInches ?? 0}\"  "
                  "(${((_heightFeet! * 12 + (_heightInches ?? 0)) * 2.54).round()} cm)",
              style: AppTextStyles.bodySmall
                  .copyWith(
                  color: AppColors.success),
            ),
          ]),
        ],
        // Error
        if (_heightError != null)
          Padding(
            padding: const EdgeInsets.only(
                top: 6, left: 4),
            child: Row(children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 13,
                color: AppColors.error,
              ),
              const SizedBox(width: 5),
              Text(_heightError!,
                  style:
                  AppTextStyles.inputError),
            ]),
          ),
      ],
    );
  }

  Widget _buildCityField() {
    return AppTextField.city(
      controller: _cityCtrl,
      focusNode: _cityFocus,
      validator: Validators.city,
    );
  }

  Widget _buildNativeCityField() {
    return AppTextField(
      label: 'Native City / Hometown',
      hint: 'e.g. Lucknow, Patna, Jaipur',
      controller: _nativeCityCtrl,
      prefixIcon: Icons.location_city_outlined,
      textCapitalization:
      TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildMotherTongueField() {
    return AppDropdownField<String>(
      label: AppStrings.motherTongue,
      hint: AppStrings.motherTongueHint,
      value: _motherTongue,
      items: const [
        'Hindi', 'Bengali', 'Telugu',
        'Marathi', 'Tamil', 'Gujarati',
        'Kannada', 'Malayalam', 'Punjabi',
        'Odia', 'Urdu', 'English', 'Other',
      ],
      prefixIcon: Icons.language_outlined,
      helperText: 'Optional',
      onChanged: (v) =>
          setState(() => _motherTongue = v),
    );
  }

  Widget _buildMaritalStatusField() {
    return AppDropdownField<String>(
      label: 'Marital Status',
      hint: 'Select marital status',
      value: _maritalStatus,
      items: const [
        'never_married',
        'divorced',
        'widowed',
        'separated',
      ],
      itemLabel: (v) {
        switch (v) {
          case 'never_married':
            return 'Never Married';
          case 'divorced':
            return 'Divorced';
          case 'widowed':
            return 'Widowed';
          case 'separated':
            return 'Separated';
          default:
            return v;
        }
      },
      prefixIcon: Icons.favorite_outline_rounded,
      helperText: 'Optional',
      onChanged: (v) =>
          setState(() => _maritalStatus = v),
    );
  }

  Widget _buildAboutField() {
    return AppTextField.multiline(
      label: AppStrings.aboutMe,
      hint: AppStrings.aboutMeHint,
      controller: _aboutCtrl,
      maxLines: 5,
      maxLength: 300,
      showCounter: false,
      validator: Validators.about,
    );
  }

  Widget _buildAboutCounter() {
    return AnimatedBuilder(
      animation: _aboutCtrl,
      builder: (_, __) {
        final count = _aboutCtrl.text.length;
        final isNear = count > 260;
        return Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Optional — Good bio pe zyada reply',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              '$count/300',
              style: AppTextStyles.labelSmall
                  .copyWith(
                color: isNear
                    ? AppColors.warning
                    : AppColors.muted,
                fontWeight: isNear
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────

  Widget _buildBottomBar(bool isSaving) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom +
            16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            top: BorderSide(
                color: AppColors.border,
                width: 1)),
        boxShadow: AppColors.modalShadow,
      ),
      child: Row(children: [
        // Progress dots
        Expanded(
          child: Row(
            children: List.generate(5, (i) {
              final isCurrent = i == 0;
              return Container(
                margin: const EdgeInsets.only(
                    right: 6),
                width: isCurrent ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCurrent
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
          height: 50,
          child: PrimaryButton(
            label: isSaving
                ? 'Saving...'
                : 'Next',
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

  // ── HELPERS ───────────────────────────────────────────

  String _formatDob(DateTime dob) {
    final d =
    dob.day.toString().padLeft(2, '0');
    final m =
    dob.month.toString().padLeft(2, '0');
    return '$d / $m / ${dob.year}';
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month &&
            now.day < dob.day)) {
      age--;
    }
    return age;
  }
}