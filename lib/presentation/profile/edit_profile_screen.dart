// lib/presentation/profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
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
// EDIT SECTION ENUM
// ─────────────────────────────────────────────────────────

enum EditSection {
  basic,
  religion,
  education,
  family,
  about,
  photos,
}

extension EditSectionX on EditSection {
  String get label {
    switch (this) {
      case EditSection.basic:     return 'Basic Info';
      case EditSection.religion:  return 'Religion';
      case EditSection.education: return 'Education';
      case EditSection.family:    return 'Family';
      case EditSection.about:     return 'About Me';
      case EditSection.photos:    return 'Photos';
    }
  }

  IconData get icon {
    switch (this) {
      case EditSection.basic:
        return Icons.person_outline_rounded;
      case EditSection.religion:
        return Icons.temple_hindu_outlined;
      case EditSection.education:
        return Icons.school_outlined;
      case EditSection.family:
        return Icons.home_outlined;
      case EditSection.about:
        return Icons.edit_note_rounded;
      case EditSection.photos:
        return Icons.photo_library_outlined;
    }
  }

  String get route {
    switch (this) {
      case EditSection.basic:     return '/setup/step1';
      case EditSection.religion:  return '/setup/step2';
      case EditSection.education: return '/setup/step3';
      case EditSection.family:    return '/setup/step4';
      case EditSection.about:     return '/setup/step1';
      case EditSection.photos:    return '/setup/step5';
    }
  }
}

// ─────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _subCasteCtrl = TextEditingController();
  final _gotraCtrl = TextEditingController();
  final _nativeCityCtrl = TextEditingController();
  final _familyCityCtrl = TextEditingController();

  // Dropdown values
  String? _religion;
  String? _caste;
  String? _qualification;
  String? _employmentType;
  String? _annualIncome;
  String? _familyType;
  String? _familyValues;
  String? _maritalStatus;
  String? _motherTongue;
  String? _manglik;

  // Height
  int? _heightFeet;
  int? _heightInches;

  bool _hasChanges = false;
  bool _initialized = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: EditSection.values.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _aboutCtrl.dispose();
    _collegeCtrl.dispose();
    _companyCtrl.dispose();
    _designationCtrl.dispose();
    _subCasteCtrl.dispose();
    _gotraCtrl.dispose();
    _nativeCityCtrl.dispose();
    _familyCityCtrl.dispose();
    super.dispose();
  }

  void _initControllers(ProfileModel profile) {
    if (_initialized) return;
    _initialized = true;

    _nameCtrl.text = profile.fullName;
    _cityCtrl.text = profile.currentCity;
    _aboutCtrl.text = profile.about;
    _collegeCtrl.text = profile.collegeName ?? '';
    _companyCtrl.text = profile.companyName ?? '';
    _designationCtrl.text = profile.designation ?? '';
    _subCasteCtrl.text = profile.subCaste ?? '';
    _gotraCtrl.text = profile.gotra ?? '';
    _nativeCityCtrl.text = profile.nativeCity;
    _familyCityCtrl.text = profile.familyCity ?? '';

    _religion = profile.religion.isNotEmpty
        ? profile.religion
        : null;
    _caste = profile.caste.isNotEmpty
        ? profile.caste
        : null;
    _qualification =
    profile.qualification.isNotEmpty
        ? profile.qualification
        : null;
    _employmentType = profile.employmentType.value;
    _annualIncome = profile.annualIncome.isNotEmpty
        ? profile.annualIncome
        : null;
    _familyType = profile.familyType.value;
    _familyValues = profile.familyValues.value;
    _maritalStatus = profile.maritalStatus.value;
    _motherTongue = profile.motherTongue.isNotEmpty
        ? profile.motherTongue
        : null;
    _manglik = profile.manglik.value;

    final feet = profile.heightInInches ~/ 12;
    final inches = profile.heightInInches % 12;
    _heightFeet = feet > 0 ? feet : null;
    _heightInches = inches;

    // Listen for changes
    for (final ctrl in [
      _nameCtrl, _cityCtrl, _aboutCtrl,
      _collegeCtrl, _companyCtrl, _designationCtrl,
      _subCasteCtrl, _gotraCtrl, _nativeCityCtrl,
      _familyCityCtrl,
    ]) {
      ctrl.addListener(() =>
          setState(() => _hasChanges = true));
    }
  }

  void _markChanged() =>
      setState(() => _hasChanges = true);

  // ── SAVE ──────────────────────────────────────────────

  Future<void> _save() async {
    if (!_hasChanges) {
      context.pop();
      return;
    }

    final profileId = ref
        .read(myProfileProvider)
        .profile
        ?.id;
    if (profileId == null) return;

    final totalInches =
        ((_heightFeet ?? 5) * 12) +
            (_heightInches ?? 4);

    final data = {
      'fullName': _nameCtrl.text.trim(),
      'currentCity': _cityCtrl.text.trim(),
      'about': _aboutCtrl.text.trim(),
      'nativeCity': _nativeCityCtrl.text.trim(),
      'motherTongue': _motherTongue ?? '',
      'maritalStatus': _maritalStatus ?? 'never_married',
      'heightInInches': totalInches,
      if (_religion != null) 'religion': _religion,
      if (_caste != null) 'caste': _caste,
      'subCaste': _subCasteCtrl.text.trim(),
      'gotra': _gotraCtrl.text.trim(),
      'manglik': _manglik ?? 'no',
      if (_qualification != null)
        'qualification': _qualification,
      'collegeName': _collegeCtrl.text.trim(),
      'employmentType':
      _employmentType ?? 'private',
      'companyName': _companyCtrl.text.trim(),
      'designation': _designationCtrl.text.trim(),
      if (_annualIncome != null)
        'annualIncome': _annualIncome,
      'familyType': _familyType ?? 'joint',
      'familyValues':
      _familyValues ?? 'traditional',
      'familyCity': _familyCityCtrl.text.trim(),
    };

    final ok = await ref
        .read(myProfileProvider.notifier)
        .updateProfile(data);

    if (!mounted) return;

    if (ok) {
      setState(() => _hasChanges = false);
      _showSnack('Profile updated ✓',
          AppColors.success);
      context.pop();
    } else {
      final error =
          ref.read(myProfileProvider).error;
      _showSnack(
          error ?? 'Update failed. Try again.',
          AppColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── DISCARD DIALOG ────────────────────────────────────

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16)),
        title: const Text('Discard Changes?'),
        content: const Text(
            'You have unsaved changes. '
                'Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10)),
            ),
            onPressed: () =>
                Navigator.pop(ctx, true),
            child: const Text('Discard',
                style: TextStyle(
                    color: Colors.white)),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(myProfileProvider);
    final profile = profileState.profile;
    final isSaving = profileState.isSaving;

    if (profile != null) {
      _initControllers(profile);
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isSaving),
                _buildTabBar(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBasicTab(),
                        _buildReligionTab(),
                        _buildEducationTab(),
                        _buildFamilyTab(),
                        _buildAboutTab(),
                        _buildPhotosTab(profile),
                      ],
                    ),
                  ),
                ),
                _buildSaveBar(isSaving),
              ],
            ),
            if (isSaving) const LoadingOverlay(
              message: 'Saving changes...',
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader(bool isSaving) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding:
      EdgeInsets.fromLTRB(8, topPad + 8, 16, 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: isSaving
                ? null
                : () async {
              final shouldPop =
              await _onWillPop();
              if (shouldPop && mounted) {
                context.pop();
              }
            },
            icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white),
          ),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (_hasChanges)
                  Text(
                    'Unsaved changes',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white
                          .withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),

          // Preview button
          GestureDetector(
            onTap: isSaving
                ? null
                : () => context
                .push('/profile-preview'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.15),
                borderRadius:
                BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.white
                        .withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 14,
                      color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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

  // ── TAB BAR ───────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: AppColors.crimson,
      padding:
      const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding:
        const EdgeInsets.symmetric(
            vertical: 4, horizontal: -4),
        dividerColor: Colors.transparent,
        labelColor: AppColors.crimson,
        unselectedLabelColor:
        Colors.white.withOpacity(0.8),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        padding:
        const EdgeInsets.symmetric(
            horizontal: 16),
        tabs: EditSection.values.map((s) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.icon, size: 14),
                const SizedBox(width: 5),
                Text(s.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── BASIC TAB ─────────────────────────────────────────

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.person_outline_rounded,
              label: 'Basic Information'),
          const SizedBox(height: 16),

          // Full Name
          AppTextField.name(
            label: 'Full Name',
            controller: _nameCtrl,
          ),
          const SizedBox(height: 16),

          // Current City
          AppTextField.city(
            controller: _cityCtrl,
          ),
          const SizedBox(height: 16),

          // Native City
          AppTextField(
            label: 'Native City',
            hint: 'e.g. Lucknow, Patna',
            controller: _nativeCityCtrl,
            prefixIcon: Icons.location_city_outlined,
            textCapitalization:
            TextCapitalization.words,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Height
          _buildHeightPicker(),
          const SizedBox(height: 16),

          // Mother Tongue
          AppDropdownField<String>(
            label: 'Mother Tongue',
            hint: 'Select mother tongue',
            value: _motherTongue,
            items: const [
              'Hindi', 'Bengali', 'Telugu',
              'Marathi', 'Tamil', 'Gujarati',
              'Kannada', 'Malayalam', 'Punjabi',
              'Odia', 'Urdu', 'English', 'Other',
            ],
            prefixIcon: Icons.language_outlined,
            onChanged: (v) {
              setState(() => _motherTongue = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // Marital Status
          AppDropdownField<String>(
            label: 'Marital Status',
            hint: 'Select marital status',
            value: _maritalStatus,
            items: const [
              'never_married', 'divorced',
              'widowed', 'separated',
            ],
            itemLabel: (v) {
              switch (v) {
                case 'never_married':
                  return 'Never Married';
                case 'divorced': return 'Divorced';
                case 'widowed': return 'Widowed';
                case 'separated': return 'Separated';
                default: return v;
              }
            },
            prefixIcon: Icons.favorite_outline,
            onChanged: (v) {
              setState(() => _maritalStatus = v);
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Height',
            style: AppTextStyles.inputLabel),
        const SizedBox(height: 7),
        Row(children: [
          // Feet
          Expanded(
            child: AppDropdownField<int>(
              hint: "Feet",
              value: _heightFeet,
              items:
              List.generate(4, (i) => i + 4),
              itemLabel: (v) => "$v'",
              onChanged: (v) {
                setState(() => _heightFeet = v);
                _markChanged();
              },
            ),
          ),
          const SizedBox(width: 12),
          // Inches
          Expanded(
            child: AppDropdownField<int>(
              hint: 'Inches',
              value: _heightInches,
              items: List.generate(12, (i) => i),
              itemLabel: (v) => '$v"',
              onChanged: (v) {
                setState(() => _heightInches = v);
                _markChanged();
              },
            ),
          ),
        ]),
        if (_heightFeet != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              "Selected: $_heightFeet'${_heightInches ?? 0}\" "
                  "(${((_heightFeet! * 12 + (_heightInches ?? 0)) * 2.54).round()} cm)",
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.crimson),
            ),
          ),
      ],
    );
  }

  // ── RELIGION TAB ──────────────────────────────────────

  Widget _buildReligionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.temple_hindu_outlined,
              label: 'Religion & Community'),
          const SizedBox(height: 16),

          // Religion
          AppDropdownField<String>(
            label: 'Religion',
            hint: 'Select religion',
            value: _religion,
            required: true,
            items: const [
              'Hindu', 'Muslim', 'Christian',
              'Sikh', 'Jain', 'Buddhist',
              'Parsi', 'Other',
            ],
            prefixIcon:
            Icons.temple_hindu_outlined,
            onChanged: (v) {
              setState(() => _religion = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // Caste
          AppDropdownField<String>(
            label: 'Caste',
            hint: 'Select caste',
            value: _caste,
            required: true,
            items: const [
              'Brahmin', 'Kayastha', 'Rajput',
              'Patel', 'Yadav', 'Jat', 'Reddy',
              'Nair', 'Iyer', 'Naidu', 'Jain',
              'Khatri', 'Other',
            ],
            prefixIcon: Icons.groups_outlined,
            onChanged: (v) {
              setState(() => _caste = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // Sub Caste
          AppTextField(
            label: 'Sub Caste',
            hint: 'e.g. Kanyakubja, Mathur',
            controller: _subCasteCtrl,
            prefixIcon: Icons.account_tree_outlined,
            textCapitalization:
            TextCapitalization.words,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Gotra
          AppTextField(
            label: 'Gotra',
            hint: 'e.g. Kashyap, Bharadwaj',
            controller: _gotraCtrl,
            prefixIcon: Icons.family_restroom,
            textCapitalization:
            TextCapitalization.words,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Manglik
          AppDropdownField<String>(
            label: 'Manglik Status',
            hint: 'Select status',
            value: _manglik,
            items: const [
              'no', 'yes', 'partial', 'dont_know',
            ],
            itemLabel: (v) {
              switch (v) {
                case 'no':         return 'Non-Manglik';
                case 'yes':        return 'Manglik';
                case 'partial':    return 'Partial Manglik';
                case 'dont_know':  return "Don't Know";
                default: return v;
              }
            },
            prefixIcon: Icons.stars_rounded,
            onChanged: (v) {
              setState(() => _manglik = v);
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  // ── EDUCATION TAB ─────────────────────────────────────

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.school_outlined,
              label: 'Education & Career'),
          const SizedBox(height: 16),

          // Qualification
          AppDropdownField<String>(
            label: 'Highest Qualification',
            hint: 'Select qualification',
            value: _qualification,
            required: true,
            items: const [
              'High School', 'Diploma', 'Graduate',
              'Post Graduate', 'Doctorate',
              'CA / CS / CFA', 'Other',
            ],
            prefixIcon: Icons.school_outlined,
            onChanged: (v) {
              setState(() => _qualification = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // College
          AppTextField(
            label: 'College / University',
            hint: 'e.g. Delhi Technological Univ.',
            controller: _collegeCtrl,
            prefixIcon:
            Icons.account_balance_outlined,
            textCapitalization:
            TextCapitalization.words,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Employment Type
          AppDropdownField<String>(
            label: 'Employment Type',
            hint: 'Select employment type',
            value: _employmentType,
            required: true,
            items: const [
              'private', 'govt', 'business',
              'self_employed', 'not_working',
            ],
            itemLabel: (v) {
              switch (v) {
                case 'private':       return 'Private Sector';
                case 'govt':          return 'Government Job';
                case 'business':      return 'Business';
                case 'self_employed': return 'Self Employed';
                case 'not_working':   return 'Not Working';
                default: return v;
              }
            },
            prefixIcon: Icons.work_outline_rounded,
            onChanged: (v) {
              setState(() => _employmentType = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // Company
          AppTextField(
            label: 'Company / Organization',
            hint: 'e.g. TCS, Infosys, UPSC',
            controller: _companyCtrl,
            prefixIcon: Icons.business_outlined,
            textCapitalization:
            TextCapitalization.words,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Designation
          AppTextField(
            label: 'Designation / Role',
            hint: 'e.g. Software Engineer, IAS',
            controller: _designationCtrl,
            prefixIcon:
            Icons.badge_outlined,
            textCapitalization:
            TextCapitalization.words,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Annual Income
          AppDropdownField<String>(
            label: 'Annual Income',
            hint: 'Select income range',
            value: _annualIncome,
            items: const [
              'Below 3 LPA', '3-5 LPA',
              '5-8 LPA', '8-12 LPA',
              '12-20 LPA', '20-30 LPA',
              '30-50 LPA', '50+ LPA',
            ],
            prefixIcon:
            Icons.currency_rupee_rounded,
            onChanged: (v) {
              setState(() => _annualIncome = v);
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  // ── FAMILY TAB ────────────────────────────────────────

  Widget _buildFamilyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.home_outlined,
              label: 'Family Details'),
          const SizedBox(height: 16),

          // Family Type
          AppDropdownField<String>(
            label: 'Family Type',
            hint: 'Select family type',
            value: _familyType,
            items: const [
              'joint', 'nuclear', 'other',
            ],
            itemLabel: (v) {
              switch (v) {
                case 'joint':   return 'Joint Family';
                case 'nuclear': return 'Nuclear Family';
                default:        return 'Other';
              }
            },
            prefixIcon: Icons.home_outlined,
            onChanged: (v) {
              setState(() => _familyType = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // Family Values
          AppDropdownField<String>(
            label: 'Family Values',
            hint: 'Select family values',
            value: _familyValues,
            items: const [
              'traditional', 'moderate', 'liberal',
            ],
            itemLabel: (v) {
              switch (v) {
                case 'traditional': return 'Traditional';
                case 'moderate':    return 'Moderate';
                default:            return 'Liberal';
              }
            },
            prefixIcon:
            Icons.people_outline_rounded,
            onChanged: (v) {
              setState(() => _familyValues = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // Family City
          AppTextField(
            label: 'Family City / Hometown',
            hint: 'e.g. Lucknow, Patna',
            controller: _familyCityCtrl,
            prefixIcon: Icons.location_on_outlined,
            textCapitalization:
            TextCapitalization.words,
            onChanged: (_) => _markChanged(),
          ),

          const SizedBox(height: 16),
          _buildInfoNote(
            'To update father/mother occupation, '
                'brother/sister details — please use '
                'the full profile setup.',
            route: '/setup/step4',
            actionLabel: 'Go to Family Setup',
          ),
        ],
      ),
    );
  }

  // ── ABOUT TAB ─────────────────────────────────────────

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.edit_note_rounded,
              label: 'About Me'),
          const SizedBox(height: 8),

          // Character count info
          Row(children: [
            const Icon(Icons.info_outline_rounded,
                size: 13, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              'A good bio gets 3x more responses',
              style: AppTextStyles.bodySmall,
            ),
          ]),
          const SizedBox(height: 16),

          // About text area
          AppTextField.multiline(
            label: 'About Me',
            hint:
            'Tell potential matches about yourself — '
                'your personality, interests, what you '
                'are looking for...',
            controller: _aboutCtrl,
            maxLines: 8,
            maxLength: 300,
            showCounter: true,
          ),
          const SizedBox(height: 20),

          // Tips card
          _buildAboutTips(),
        ],
      ),
    );
  }

  Widget _buildAboutTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.tips_and_updates_rounded,
                size: 16, color: AppColors.gold),
            const SizedBox(width: 8),
            Text('Tips for a great bio',
                style: AppTextStyles.labelMedium
                    .copyWith(
                    color: AppColors.gold)),
          ]),
          const SizedBox(height: 12),
          ...[
            'Mention your hobbies and interests',
            'Share your values and what matters to you',
            'Describe your ideal partner briefly',
            'Keep it positive and genuine',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(
                bottom: 6),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text('• ',
                    style: TextStyle(
                        color: AppColors.gold,
                        fontWeight:
                        FontWeight.w700)),
                Expanded(
                    child: Text(tip,
                        style: AppTextStyles
                            .bodySmall
                            .copyWith(
                            color: AppColors
                                .inkSoft))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── PHOTOS TAB ────────────────────────────────────────

  Widget _buildPhotosTab(ProfileModel? profile) {
    final photos = profile?.photoUrls ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.photo_library_outlined,
              label: 'Profile Photos'),
          const SizedBox(height: 8),

          // Photo info
          Row(children: [
            const Icon(Icons.info_outline_rounded,
                size: 13, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Add at least 3 photos to get '
                    '5x more matches',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Photo grid
          GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (_, i) {
              final hasPhoto = i < photos.length;
              return _PhotoSlot(
                photoUrl:
                hasPhoto ? photos[i] : null,
                isMain: i == 0,
                onTap: () => _showPhotoOptions(
                    i, hasPhoto, photos),
              );
            },
          ),

          const SizedBox(height: 20),
          _buildInfoNote(
            'Photos are reviewed by our team for safety. '
                'Profile photos must show your face clearly.',
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions(
      int index,
      bool hasPhoto,
      List<String> photos,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasPhoto
                  ? 'Photo Options'
                  : 'Add Photo',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 16),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _showSnack(
                    'Photo upload coming in Phase 3',
                    AppColors.ink);
              },
            ),
            _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () {
                Navigator.pop(context);
                _showSnack(
                    'Camera coming in Phase 3',
                    AppColors.ink);
              },
            ),
            if (hasPhoto && index > 0) ...[
              _SheetOption(
                icon: Icons.star_outline_rounded,
                label: 'Set as Main Photo',
                onTap: () {
                  Navigator.pop(context);
                  _showSnack(
                      'Set as main photo — Phase 3',
                      AppColors.gold);
                },
              ),
              _SheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showSnack(
                      'Photo remove — Phase 3',
                      AppColors.error);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── SAVE BAR ──────────────────────────────────────────

  Widget _buildSaveBar(bool isSaving) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            top: BorderSide(color: AppColors.border)),
        boxShadow: AppColors.modalShadow,
      ),
      child: Row(children: [
        // Discard button
        if (_hasChanges) ...[
          SecondaryButton(
            label: 'Discard',
            isFullWidth: false,
            size: ButtonSize.medium,
            borderColor: AppColors.border,
            textColor: AppColors.muted,
            onPressed: isSaving
                ? null
                : () async {
              final discard =
              await _onWillPop();
              if (discard && mounted) {
                context.pop();
              }
            },
          ),
          const SizedBox(width: 10),
        ],

        // Save button
        Expanded(
          child: PrimaryButton(
            label: isSaving
                ? 'Saving...'
                : _hasChanges
                ? 'Save Changes'
                : 'No Changes',
            isLoading: isSaving,
            onPressed: isSaving
                ? null
                : _hasChanges
                ? _save
                : () => context.pop(),
          ),
        ),
      ]),
    );
  }

  // ── HELPERS ───────────────────────────────────────────

  Widget _buildInfoNote(
      String message, {
        String? route,
        String? actionLabel,
      }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 15, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(message,
                    style: AppTextStyles.bodySmall
                        .copyWith(
                        color:
                        AppColors.inkSoft)),
                if (route != null &&
                    actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        context.push(route),
                    child: Text(actionLabel,
                        style: AppTextStyles
                            .bodySmall
                            .copyWith(
                          color: AppColors.info,
                          fontWeight:
                          FontWeight.w600,
                          decoration: TextDecoration
                              .underline,
                          decorationColor:
                          AppColors.info,
                        )),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(icon,
              size: 16, color: AppColors.crimson),
        ),
      ),
      const SizedBox(width: 10),
      Text(label,
          style: AppTextStyles.h5),
    ]);
  }
}

class _PhotoSlot extends StatelessWidget {
  final String? photoUrl;
  final bool isMain;
  final VoidCallback onTap;

  const _PhotoSlot({
    required this.photoUrl,
    required this.isMain,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: hasPhoto
              ? AppColors.ivoryDark
              : AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMain
                ? AppColors.gold
                : AppColors.border,
            width: isMain ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or placeholder
              hasPhoto
                  ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _placeholder(),
              )
                  : _placeholder(),

              // Main badge
              if (isMain && hasPhoto)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius:
                      BorderRadius.circular(
                          100),
                    ),
                    child: const Text(
                      'Main',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Add icon overlay
              if (!hasPhoto)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 28,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMain
                            ? 'Main Photo'
                            : 'Add Photo',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                          fontWeight:
                          FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.ivoryDark,
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : AppColors.inkSoft;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.border,
                width: 0.5),
          ),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.errorSurface
                  : AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Center(
                child: Icon(icon,
                    size: 18, color: color)),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              )),
        ]),
      ),
    );
  }
}