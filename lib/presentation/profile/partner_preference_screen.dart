import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class PartnerPreferenceScreen extends StatefulWidget {
  const PartnerPreferenceScreen({super.key});

  @override
  State<PartnerPreferenceScreen> createState() =>
      _PartnerPreferenceScreenState();
}

class _PartnerPreferenceScreenState
    extends State<PartnerPreferenceScreen> {
  // ── STATE VARIABLES ────────────────────────────────
  RangeValues _ageRange = const RangeValues(24, 34);
  int _minHeight = 65; // 5'5"
  int _maxHeight = 76; // 6'4"

  Set<String> _selectedReligions = {'Hindu'};
  bool _anyReligion = false;

  bool _sameCasteOnly = false;
  Set<String> _selectedCastes = {'Brahmin', 'Kayastha'};

  String _minEducation = 'Graduate';
  String _minIncome = '4 LPA+';

  bool _anyCity = true;
  Set<String> _selectedCities = {};

  String _manglikPref = 'Koi Bhi';
  Set<String> _selectedMaritalStatus = {'Never Married'};

  final TextEditingController _aboutPartnerController =
  TextEditingController(
    text:
    'Honest, caring aur family-oriented partner chahiye.',
  );

  // ── HEIGHT CONVERTER ───────────────────────────────
  String _heightToString(int inches) {
    final feet = inches ~/ 12;
    final inch = inches % 12;
    return "$feet'$inch\"";
  }

  // ── TOGGLE SELECTION ───────────────────────────────
  void _toggleSelection(Set<String> set, String val) {
    setState(() {
      if (set.contains(val)) {
        set.remove(val);
      } else {
        set.add(val);
      }
    });
  }

  // ── SAVE PREFERENCES ───────────────────────────────
  void _savePreferences() async {
    if (_selectedReligions.isEmpty && !_anyReligion) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              "Dharm preference chunein ya 'Koi bhi' select karein"),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text("Save ho raha hai..."),
          ],
        ),
        backgroundColor: AppColors.ink,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Preferences save ho gayi! ✓"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    context.pop();
  }

  @override
  void dispose() {
    _aboutPartnerController.dispose();
    super.dispose();
  }

  // ── BUILD ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildAgeSection(),
                    const SizedBox(height: 20),
                    _buildHeightSection(),
                    const SizedBox(height: 20),
                    _buildReligionSection(),
                    const SizedBox(height: 20),
                    _buildCasteSection(),
                    const SizedBox(height: 20),
                    _buildEducationSection(),
                    const SizedBox(height: 20),
                    _buildIncomeSection(),
                    const SizedBox(height: 20),
                    _buildLocationSection(),
                    const SizedBox(height: 20),
                    _buildManglikSection(),
                    const SizedBox(height: 20),
                    _buildMaritalStatusSection(),
                    const SizedBox(height: 20),
                    _buildAboutPartnerSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Partner Preference",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    "Aap kaisa partner chahte ho",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: _savePreferences,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.crimson,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Save Karo",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ─────────────────────────────────
  Widget _buildSectionHeader(String emoji, String title) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.crimsonSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  // ── CARD WRAPPER ───────────────────────────────────
  Widget _buildCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  // ── SELECT CHIP (multi) ────────────────────────────
  Widget _buildSelectChip(
      String label,
      Set<String> selectedSet,
      VoidCallback onTap,
      ) {
    final isSelected = selectedSet.contains(label);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.crimson : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.crimson
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }

  // ── SINGLE SELECT CHIP ─────────────────────────────
  Widget _buildSingleSelectChip(
      String label,
      String selectedValue,
      VoidCallback onTap,
      ) {
    final isSelected = selectedValue == label;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.crimson : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.crimson
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded,
                  size: 14, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                isSelected ? Colors.white : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AGE SECTION ────────────────────────────────────
  Widget _buildAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🎂', 'Umar (Age)'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Umar ki Range",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonSurface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "${_ageRange.start.round()} - ${_ageRange.end.round()} saal",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.crimson,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _ageRange,
                min: 18,
                max: 60,
                divisions: 42,
                activeColor: AppColors.crimson,
                inactiveColor: AppColors.ivoryDark,
                labels: RangeLabels(
                  "${_ageRange.start.round()} saal",
                  "${_ageRange.end.round()} saal",
                ),
                onChanged: (val) =>
                    setState(() => _ageRange = val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("18 saal",
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  Text("60 saal",
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── HEIGHT SECTION ─────────────────────────────────
  Widget _buildHeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('📏', 'Lambai (Height)'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Height ki Range",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonSurface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "${_heightToString(_minHeight)} - ${_heightToString(_maxHeight)}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.crimson,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: RangeValues(
                  _minHeight.toDouble(),
                  _maxHeight.toDouble(),
                ),
                min: 53,
                max: 84,
                divisions: 31,
                activeColor: AppColors.crimson,
                inactiveColor: AppColors.ivoryDark,
                labels: RangeLabels(
                  _heightToString(_minHeight),
                  _heightToString(_maxHeight),
                ),
                onChanged: (val) => setState(() {
                  _minHeight = val.start.round();
                  _maxHeight = val.end.round();
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("4'5\"",
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  Text("7'0\"",
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── RELIGION SECTION ───────────────────────────────
  Widget _buildReligionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🛕', 'Dharm (Religion)'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kaunse dharm ke partner chahiye?",
                style: TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Hindu',
                  'Muslim',
                  'Sikh',
                  'Christian',
                  'Jain',
                  'Buddhist',
                  'Any',
                ]
                    .map((label) => _buildSelectChip(
                  label,
                  _selectedReligions,
                      () => _toggleSelection(
                      _selectedReligions, label),
                ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Koi bhi dharm chalega",
                    style: TextStyle(
                        fontSize: 13, color: AppColors.inkSoft),
                  ),
                  Switch(
                    value: _anyReligion,
                    activeColor: AppColors.crimson,
                    onChanged: (val) => setState(() {
                      _anyReligion = val;
                      if (val) _selectedReligions.clear();
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── CASTE SECTION ──────────────────────────────────
  Widget _buildCasteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('👥', 'Jaati (Caste)'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Same caste preferred?",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                  Switch(
                    value: _sameCasteOnly,
                    activeColor: AppColors.crimson,
                    onChanged: (val) =>
                        setState(() => _sameCasteOnly = val),
                  ),
                ],
              ),
              Text(
                "Off karne par sab castes dikhenge",
                style:
                TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              if (!_sameCasteOnly) ...[
                const SizedBox(height: 14),
                const Divider(color: AppColors.border),
                const SizedBox(height: 14),
                Text(
                  "Specific castes chunein (optional):",
                  style: TextStyle(
                      fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Brahmin',
                    'Kshatriya',
                    'Kayastha',
                    'Rajput',
                    'Patel',
                    'Jat',
                    'Maratha',
                    'Nair',
                    'Iyer',
                    'Reddy',
                    'Any',
                  ]
                      .map((label) => _buildSelectChip(
                    label,
                    _selectedCastes,
                        () => _toggleSelection(
                        _selectedCastes, label),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── EDUCATION SECTION ──────────────────────────────
  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🎓', 'Shiksha (Education)'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Minimum qualification:",
                style: TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '12th Pass',
                  'Graduate',
                  'Post Graduate',
                  'Doctorate',
                  'Koi bhi',
                ]
                    .map((label) => _buildSingleSelectChip(
                  label,
                  _minEducation,
                      () => setState(
                          () => _minEducation = label),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── INCOME SECTION ─────────────────────────────────
  Widget _buildIncomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('💰', 'Aay (Income)'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Minimum income preferred:",
                style: TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Koi bhi',
                  '2 LPA+',
                  '4 LPA+',
                  '6 LPA+',
                  '8 LPA+',
                  '10 LPA+',
                  '15 LPA+',
                  '20 LPA+',
                ]
                    .map((label) => _buildSingleSelectChip(
                  label,
                  _minIncome,
                      () =>
                      setState(() => _minIncome = label),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── LOCATION SECTION ───────────────────────────────
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('📍', 'Sheher (Location)'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Koi bhi sheher chalega",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                  Switch(
                    value: _anyCity,
                    activeColor: AppColors.crimson,
                    onChanged: (val) =>
                        setState(() => _anyCity = val),
                  ),
                ],
              ),
              if (!_anyCity) ...[
                const SizedBox(height: 14),
                const Divider(color: AppColors.border),
                const SizedBox(height: 14),
                Text(
                  "Preferred cities chunein:",
                  style: TextStyle(
                      fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Delhi',
                    'Mumbai',
                    'Bangalore',
                    'Hyderabad',
                    'Chennai',
                    'Pune',
                    'Jaipur',
                    'Chandigarh',
                    'Lucknow',
                    'Ahmedabad',
                    'Noida',
                    'Gurgaon',
                  ]
                      .map((label) => _buildSelectChip(
                    label,
                    _selectedCities,
                        () => _toggleSelection(
                        _selectedCities, label),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── MANGLIK SECTION ────────────────────────────────
  Widget _buildManglikSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('⭐', 'Manglik Preference'),
        const SizedBox(height: 14),
        _buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Partner ka manglik status:",
                style: TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Manglik', 'Non-Manglik', 'Koi Bhi']
                    .map((option) {
                  final isSelected = _manglikPref == option;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: option != 'Koi Bhi' ? 8 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(
                                () => _manglikPref = option),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 200),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.crimson
                                : AppColors.white,
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.crimson
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.inkSoft,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── MARITAL STATUS SECTION ─────────────────────────
  Widget _buildMaritalStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('💒', 'Vivah Status'),
        const SizedBox(height: 14),
        _buildCard(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Never Married',
              'Divorced',
              'Widowed',
              'Koi Bhi',
            ]
                .map((label) => _buildSelectChip(
              label,
              _selectedMaritalStatus,
                  () => _toggleSelection(
                  _selectedMaritalStatus, label),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── ABOUT PARTNER SECTION ──────────────────────────
  Widget _buildAboutPartnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('💝', 'Partner Ke Baare Mein'),
        const SizedBox(height: 14),
        _buildCard(
          TextFormField(
            controller: _aboutPartnerController,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              hintText:
              "Apne ideal partner ke baare mein likho...",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.crimson, width: 2),
              ),
              counterStyle: TextStyle(
                  fontSize: 11, color: AppColors.muted),
              hintStyle: TextStyle(
                  color: AppColors.disabled, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── SAVE BUTTON ────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _savePreferences,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded, size: 20, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Preferences Save Karo",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}