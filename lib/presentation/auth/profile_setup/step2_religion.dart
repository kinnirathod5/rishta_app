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
import 'package:rishta_app/data/models/profile_model.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// STEP 2 — RELIGION & COMMUNITY
//
// Fields (updated):
//   1. Religion            ← required
//   2. Caste               ← required (with "Don't specify" option) ✅ NEW
//   3. Sub Caste           ← optional
//   4. Gotra               ← optional (Hindu only)
//   5. Manglik Status      ← optional
//   6. Nakshatra / Rashi   ← optional ✅ NEW
//   7. Mother Tongue       ← optional ✅ MOVED HERE from Step 1
// ─────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────
// BANJARA COMMUNITY — 5 MAIN GOTRAS (GOTH)
// Same gotra mein shaadi nahi hoti (Bhaipana rule)
// ─────────────────────────────────────────────────────────

// 5 Main Gotras of Banjara community
const List<String> _banjaraGotras = [
  'Rathod / Bhukya',
  'Pawar / Pamhar / Parmar',
  'Chauhan / Chavan',
  'Vaditya / Jadhav',
  'Banoth',
  'Other',
];

// Sub-Gotras (Pada) for each main Gotra
const Map<String, List<String>> _subGotrasFor = {
  'Rathod / Bhukya': [
    'Aaloth', 'Bhaanaavath', 'Bhilavath', 'Degaavath',
    'Depaavath', 'Devsoth', 'Dungaavath', 'Jhandavath',
    'Kaanaavath', 'Karamtoth', 'Khaatroth', 'Khethaavath',
    'Khilaavath', 'Kodaavath', 'Kumaavath', 'Meghaavath',
    'Meraajoth', 'Meraavath', 'Nenaavath', 'Paathloth',
    'Pithaavath', 'Raajavath', 'Raamavath', 'Ranasoth',
    'Sangaavath', 'Balanot', 'Munavath', 'Other',
  ],
  'Pawar / Pamhar / Parmar': [
    'Aamgoth', 'Aivath', 'Baanni', 'Chaivoth',
    'Injraavath', 'Inloth', 'Jharapla', 'Lunsavath',
    'Nunsavath', 'Pamaadiyaa', 'Tarabaanni', 'Vankdoth',
    'Vislaavath', 'Other',
  ],
  'Chauhan / Chavan': [
    'Mood', 'Kelooth', 'Sabavat', 'Korra',
    'Laavadiya', 'Paalthiya', 'Dumaavath', 'Kayloth',
    'Other',
  ],
  'Vaditya / Jadhav': [
    'Ajmera', 'Baadaavath', 'Barmaavath', 'Bharoth',
    'Bodaa', 'Dhaaraavath', 'Dungaroth', 'Gangaavath',
    'Goraam', 'Gugloth', 'Halaavath', 'Jaloth',
    'Lokaavath', 'Lonaavath', 'Maaloth', 'Pipaavath',
    'Salaavath', 'Sejaavath', 'Tejaavath', 'Tepaavath',
    'Teraavath', 'Vadithya', 'Other',
  ],
  'Banoth': [
    'Banoth', 'Other',
  ],
  'Other': ['Other'],
};

// Religion — Banjara mostly Hindu hain
// lekin community-specific options included
const List<String> _religions = [
  'Hindu (Banjara)',
  'Hindu',
  'Sikh (Banjara Sikh)',
  'Sikh',
  'Other',
];

// Mother Tongue — Banjara/Lambadi first
const List<String> _motherTongues = [
  'Banjara / Gor Boli',
  'Lambadi / Lambani',
  'Telugu',
  'Kannada',
  'Marathi',
  'Hindi',
  'Rajasthani',
  'Gujarati',
  'Tamil',
  'Other',
];

// ✅ NEW: Nakshatra list (27 nakshatras)
const List<String> _nakshatras = [
  'Ashwini', 'Bharani', 'Krittika', 'Rohini',
  'Mrigashira', 'Ardra', 'Punarvasu', 'Pushya',
  'Ashlesha', 'Magha', 'Purva Phalguni',
  'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati',
  'Vishakha', 'Anuradha', 'Jyeshtha', 'Moola',
  'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
  'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada',
  'Uttara Bhadrapada', 'Revati',
];

// ✅ NEW: Rashi (Moon Sign) list
const List<String> _rashis = [
  'Mesh (Aries)', 'Vrishabh (Taurus)',
  'Mithun (Gemini)', 'Karka (Cancer)',
  'Singh (Leo)', 'Kanya (Virgo)',
  'Tula (Libra)', 'Vrishchik (Scorpio)',
  'Dhanu (Sagittarius)', 'Makar (Capricorn)',
  'Kumbh (Aquarius)', 'Meen (Pisces)',
];

// ─────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────

class Step2Religion extends ConsumerStatefulWidget {
  const Step2Religion({super.key});

  @override
  ConsumerState<Step2Religion> createState() => _Step2ReligionState();
}

class _Step2ReligionState extends ConsumerState<Step2Religion>
    with SingleTickerProviderStateMixin {

  final _formKey     = GlobalKey<FormState>();
  final _subCasteCtrl = TextEditingController();
  final _gotraCtrl    = TextEditingController();

  // Values
  String? _religion;
  String? _caste;
  String? _manglik;
  String? _motherTongue;
  String? _nakshatra;    // ✅ NEW
  String? _rashi;        // ✅ NEW

  // ✅ NEW: "Don't want to specify" caste toggle
  bool _dontSpecifyCaste = false;

  // Animation
  late AnimationController _ctrl;
  late Animation<double>  _fade;
  late Animation<Offset>  _slide;

  // Sub-gotras (Pada) based on selected main Goth
  List<String> get _availableSubGotras =>
      _caste != null ? (_subGotrasFor[_caste] ?? ['Other']) : [];

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _ctrl.forward();
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

  void _loadExisting() {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _religion     = profile.religion.isNotEmpty ? profile.religion : null;
        _caste        = profile.caste.isNotEmpty ? profile.caste : null;
        _subCasteCtrl.text = profile.subCaste ?? '';
        _gotraCtrl.text    = profile.gotra ?? '';
        _manglik           = profile.manglik.value; // ManglikStatus → String
        _motherTongue      = profile.motherTongue;
        _nakshatra         = profile.nakshatra;
        _rashi             = profile.rashi;
        // If caste was saved as 'dont_specify'
        if (_caste == 'dont_specify') {
          _dontSpecifyCaste = true;
          _caste = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _subCasteCtrl.dispose();
    _gotraCtrl.dispose();
    super.dispose();
  }

  // ── SAVE ──────────────────────────────────────────────

  Future<void> _saveAndNext() async {
    FocusScope.of(context).unfocus();

    if (_religion == null) {
      _showError('Please select your religion.');
      return;
    }
    if (!_dontSpecifyCaste && _caste == null) {
      _showError('Please select your caste or choose "Don\'t want to specify".');
      return;
    }

    final data = {
      'religion'    : _religion!,
      'caste'       : _dontSpecifyCaste ? 'dont_specify' : (_caste ?? ''),
      'subCaste'    : _subCasteCtrl.text.trim(),
      'gotra'       : _gotraCtrl.text.trim(),
      'manglik'     : _manglik ?? 'dont_know',
      'motherTongue': _motherTongue ?? '',
      'nakshatra'   : _nakshatra ?? '',
      'rashi'       : _rashi ?? '',
      'setupStep'   : 2,
    };

    final ok = await ref.read(myProfileProvider.notifier).updateProfile(data);
    if (!mounted) return;
    if (ok) {
      context.go('/setup/step3');
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

                              // ── Section: Community ──────────────
                              _buildSectionLabel(
                                icon: Icons.temple_hindu_outlined,
                                label: 'Religion & Community',
                              ),
                              const SizedBox(height: 14),

                              // 1. Religion
                              _buildReligionField(),
                              const SizedBox(height: 16),

                              // 2. Caste (with "Don't specify" option)
                              _buildCasteField(),
                              const SizedBox(height: 16),

                              // 3. Sub Caste (optional)
                              _buildSubCasteField(),
                              const SizedBox(height: 16),

                              // 4. Gotra (optional, Hindu only)
                              // Dhadi/Bhat lineage — relevant for all Banjara
                              if (true) ...[
                                _buildGotraField(),
                                const SizedBox(height: 16),
                              ],

                              // 5. Manglik Status
                              _buildManglikField(),
                              const SizedBox(height: 28),

                              // ── Section: Astrology ──────────────
                              _buildSectionLabel(
                                icon: Icons.stars_rounded,
                                label: 'Astrology',
                                isOptional: true,
                              ),
                              const SizedBox(height: 14),

                              // 6. Nakshatra & Rashi ✅ NEW
                              _buildAstrologyFields(),
                              const SizedBox(height: 28),

                              // ── Section: Language ───────────────
                              _buildSectionLabel(
                                icon: Icons.language_outlined,
                                label: 'Language',
                              ),
                              const SizedBox(height: 14),

                              // 7. Mother Tongue ✅ MOVED from Step 1
                              _buildMotherTongueField(),
                              const SizedBox(height: 24),

                              // Info note
                              _buildInfoNote(),
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
              onTap: () => context.go('/setup/step1'),
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
                  Text('Step 2 of 5',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      )),
                  const Text('Religion & Community',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/setup/step3'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Skip for now',
                    style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
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
        final isDone    = i < 1;
        final isCurrent = i == 1;
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
        const Text('🛕', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text('Religion & Community', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Banjara Samaj mein sahi rishta\ndhundhne ke liye Goth zaruri hai',
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

  Widget _buildReligionField() {
    return AppDropdownField<String>(
      label: 'Religion',
      hint: 'Select religion',
      value: _religion,
      required: true,
      items: _religions,
      prefixIcon: Icons.temple_hindu_outlined,
      validator: Validators.religion,
      onChanged: (v) => setState(() {
        _religion = v;
      }),
    );
  }

  Widget _buildCasteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ NEW: Don't specify toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text('Goth / Gotra', style: AppTextStyles.inputLabel),
              Text(' *',
                  style: AppTextStyles.inputLabel.copyWith(color: AppColors.crimson)),
            ]),
            // Toggle chip
            GestureDetector(
              onTap: () => setState(() {
                _dontSpecifyCaste = !_dontSpecifyCaste;
                if (_dontSpecifyCaste) _caste = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _dontSpecifyCaste
                      ? AppColors.crimson
                      : AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _dontSpecifyCaste
                        ? AppColors.crimson
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _dontSpecifyCaste
                          ? Icons.check_rounded
                          : Icons.do_not_disturb_alt_outlined,
                      size: 12,
                      color: _dontSpecifyCaste ? Colors.white : AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Don\'t want to specify',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _dontSpecifyCaste ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),

        // Caste dropdown — disabled when "don't specify"
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _dontSpecifyCaste ? 0.4 : 1.0,
          child: AppDropdownField<String>(
            hint: _dontSpecifyCaste
                ? 'Not specified'
                : 'Select your Goth',
            value: _dontSpecifyCaste ? null : _caste,
            required: !_dontSpecifyCaste,
            enabled: !_dontSpecifyCaste,
            items: _banjaraGotras,
            prefixIcon: Icons.groups_outlined,
            onChanged: (v) => setState(() {
              _caste = v;
              _subCasteCtrl.clear();
            }),
          ),
        ),

        // Info when "don't specify" is selected
        if (_dontSpecifyCaste) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.crimson.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.crimson),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aapka Goth profile pe nahi dikhega. Aapko sabhi Banjara Goth ke profiles se match kiya jayega.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Religion hint
        if (_religion == null && !_dontSpecifyCaste) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.muted),
            const SizedBox(width: 6),
            Text('Please select religion first', style: AppTextStyles.bodySmall),
          ]),
        ],
      ],
    );
  }

  Widget _buildSubCasteField() {
    // If known Goth selected — show Pada dropdown
    // Otherwise — free text
    if (_caste != null && _availableSubGotras.length > 1) {
      return AppDropdownField<String>(
        label: 'Pada (Sub Gotra)',
        hint: 'Select your Pada',
        value: _subCasteCtrl.text.isNotEmpty ? _subCasteCtrl.text : null,
        items: _availableSubGotras,
        prefixIcon: Icons.account_tree_outlined,
        helperText: 'Optional',
        onChanged: (v) {
          if (v != null) _subCasteCtrl.text = v;
        },
      );
    }
    return AppTextField(
      label: 'Pada (Sub Gotra)',
      hint: 'e.g. Ramavath, Ajmera, Aaloth',
      controller: _subCasteCtrl,
      prefixIcon: Icons.account_tree_outlined,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional',
    );
  }

  Widget _buildGotraField() {
    return AppTextField(
      label: 'Dhadi / Bhat (Lineage)',
      hint: 'e.g. Tajnath, Pochala, Dungroth',
      controller: _gotraCtrl,
      prefixIcon: Icons.family_restroom_rounded,
      textCapitalization: TextCapitalization.words,
      helperText: 'Optional — your lineage/Dhadi Bhat lineage',
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
          items: const ['no', 'yes', 'partial', 'dont_know'],
          itemLabel: (v) {
            switch (v) {
              case 'no':         return 'Non-Manglik';
              case 'yes':        return 'Manglik';
              case 'partial':    return 'Partial Manglik';
              case 'dont_know':  return "Don't Know";
              default:           return v;
            }
          },
          prefixIcon: Icons.stars_outlined,
          helperText: 'Optional',
          onChanged: (v) => setState(() => _manglik = v),
        ),
        if (_manglik == 'yes' || _manglik == 'partial') ...[
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
                    'In Banjara community, Manglik status is checked before finalising a match. You will be matched accordingly.',
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

  // ✅ NEW: Nakshatra + Rashi side by side
  Widget _buildAstrologyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rashi
        AppDropdownField<String>(
          label: 'Rashi (Moon Sign)',
          hint: 'Select your rashi',
          value: _rashi,
          items: _rashis,
          prefixIcon: Icons.brightness_3_outlined,
          helperText: 'Optional — helps in kundali matching',
          onChanged: (v) => setState(() => _rashi = v),
        ),
        const SizedBox(height: 16),
        // Nakshatra
        AppDropdownField<String>(
          label: 'Nakshatra (Birth Star)',
          hint: 'Select your nakshatra',
          value: _nakshatra,
          items: _nakshatras,
          prefixIcon: Icons.auto_awesome_outlined,
          helperText: 'Optional',
          onChanged: (v) => setState(() => _nakshatra = v),
        ),
      ],
    );
  }

  // ✅ MOVED from Step 1: Mother Tongue
  Widget _buildMotherTongueField() {
    return AppDropdownField<String>(
      label: 'Mother Tongue',
      hint: 'Select your mother tongue',
      value: _motherTongue,
      items: _motherTongues,
      prefixIcon: Icons.language_outlined,
      helperText: 'Optional',
      onChanged: (v) => setState(() => _motherTongue = v),
    );
  }

  Widget _buildInfoNote() {
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
          const Icon(Icons.tips_and_updates_rounded,
              size: 15, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Banjara community marriages follow Goth rules — same Goth mein shaadi nahi hoti. Apna sahi Goth bharein taaki best matches milein.',
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