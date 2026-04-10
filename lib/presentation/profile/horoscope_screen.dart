import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  // ── STATE VARIABLES ────────────────────────────────
  TimeOfDay? _birthTime;
  String? _birthPlace;
  String? _rashi;
  String? _nakshatra;
  String? _gotra;
  bool _isManglik = false;
  bool _isAnshikManglik = false;
  File? _kundaliFile;
  bool _isSaving = false;

  final TextEditingController _birthPlaceController =
  TextEditingController();
  final TextEditingController _gotraController =
  TextEditingController();

  // ── DATA LISTS ─────────────────────────────────────
  final List<String> _rashiList = [
    'Mesh (Aries)',
    'Vrishabh (Taurus)',
    'Mithun (Gemini)',
    'Kark (Cancer)',
    'Singh (Leo)',
    'Kanya (Virgo)',
    'Tula (Libra)',
    'Vrishchik (Scorpio)',
    'Dhanu (Sagittarius)',
    'Makar (Capricorn)',
    'Kumbh (Aquarius)',
    'Meen (Pisces)',
  ];

  final List<String> _nakshatraList = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishtha',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
    'Pata Nahi',
  ];

  // ── TIME PICKER ────────────────────────────────────
  Future<void> _selectBirthTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.crimson,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthTime = picked);
    }
  }

  // ── PICKER BOTTOM SHEET ────────────────────────────
  void _showPickerSheet(
      String title,
      List<String> items,
      String? selected,
      ValueChanged<String> onSelected,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.ivoryDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border),
              // List
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selected == item;
                    return ListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.crimson
                              : AppColors.ink,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                          size: 20, color: AppColors.crimson)
                          : null,
                      tileColor: isSelected
                          ? AppColors.crimsonSurface
                          : null,
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── KUNDALI UPLOAD ─────────────────────────────────
  void _showKundaliOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Kundali Kaise Upload Karein?",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildUploadOption('📷', 'Camera',
                      AppColors.infoSurface, () async {
                        Navigator.pop(context);
                        final picker = ImagePicker();
                        final img = await picker.pickImage(
                            source: ImageSource.camera);
                        if (img != null) {
                          setState(
                                  () => _kundaliFile = File(img.path));
                        }
                      }),
                  _buildUploadOption('🖼️', 'Gallery',
                      AppColors.successSurface, () async {
                        Navigator.pop(context);
                        final picker = ImagePicker();
                        final img = await picker.pickImage(
                            source: ImageSource.gallery);
                        if (img != null) {
                          setState(
                                  () => _kundaliFile = File(img.path));
                        }
                      }),
                  _buildUploadOption(
                      '📄', 'PDF', AppColors.goldSurface, () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        const Text('PDF upload jald aayega! 🚀'),
                        backgroundColor: AppColors.ink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(
      String emoji,
      String label,
      Color bgColor,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  // ── SAVE ───────────────────────────────────────────
  Future<void> _saveHoroscope() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Horoscope save ho gaya! ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    context.pop();
  }

  // ── PICKER FIELD WIDGET ────────────────────────────
  Widget _buildPickerField({
    required String hint,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
            value != null ? AppColors.crimson : AppColors.border,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
              value != null ? AppColors.crimson : AppColors.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: value != null
                      ? FontWeight.w500
                      : FontWeight.w400,
                  color: value != null
                      ? AppColors.ink
                      : AppColors.disabled,
                ),
              ),
            ),
            if (value != null)
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: AppColors.success)
            else
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  // ── FIELD LABEL ────────────────────────────────────
  Widget _buildFieldLabel(String label, IconData icon,
      {bool required = false, String? optional}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.crimson),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.inkSoft,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.error,
                  fontWeight: FontWeight.w700)),
        ],
        if (optional != null) ...[
          const SizedBox(width: 6),
          Text(
            optional,
            style: const TextStyle(
                fontSize: 11, color: AppColors.muted),
          ),
        ],
      ],
    );
  }

  // ── SECTION CARD ───────────────────────────────────
  Widget _buildSectionCard(Widget child) {
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
            child:
            Text(emoji, style: const TextStyle(fontSize: 18)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBanner(),
                    const SizedBox(height: 20),
                    _buildBirthDetailsSection(),
                    const SizedBox(height: 20),
                    _buildRashiNakshatraSection(),
                    const SizedBox(height: 20),
                    _buildManglikSection(),
                    const SizedBox(height: 20),
                    _buildKundaliSection(),
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
                    "Horoscope Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    "Kundali aur janam ki jankari",
                    style: TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: AppColors.gold.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⭐', style: TextStyle(fontSize: 12)),
                SizedBox(width: 5),
                Text(
                  '+15% Score',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── INFO BANNER ────────────────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Horoscope se zyada matches milte hain",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Kundali match karne wale profiles alag dikhenge aur profile score +15% badhega",
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BIRTH DETAILS SECTION ──────────────────────────
  Widget _buildBirthDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🕐', 'Janam ki Jankari'),
        const SizedBox(height: 14),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Birth Time
              _buildFieldLabel(
                'Janam ka Samay',
                Icons.access_time_rounded,
                optional: '(Optional)',
              ),
              const SizedBox(height: 8),
              _buildPickerField(
                hint: "Janam ka samay chunein",
                value: _birthTime != null
                    ? _birthTime!.format(context)
                    : null,
                icon: Icons.access_time_rounded,
                onTap: _selectBirthTime,
              ),

              const SizedBox(height: 16),

              // Birth Place
              _buildFieldLabel(
                'Janam ka Sthan',
                Icons.location_on_outlined,
                optional: '(Optional)',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _birthPlaceController,
                textCapitalization: TextCapitalization.words,
                onChanged: (val) =>
                    setState(() => _birthPlace = val),
                decoration: InputDecoration(
                  hintText: "Jaise: Agra, Delhi, Varanasi...",
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: _birthPlace != null &&
                        _birthPlace!.isNotEmpty
                        ? AppColors.crimson
                        : AppColors.muted,
                  ),
                  suffixIcon: _birthPlace != null &&
                      _birthPlace!.isNotEmpty
                      ? const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.success)
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // Gotra
              _buildFieldLabel(
                'Gotra',
                Icons.family_restroom_outlined,
                optional: '(Optional)',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gotraController,
                textCapitalization: TextCapitalization.words,
                onChanged: (val) =>
                    setState(() => _gotra = val),
                decoration: InputDecoration(
                  hintText:
                  "Jaise: Kashyap, Bharadwaj, Atri...",
                  prefixIcon: Icon(
                    Icons.family_restroom_outlined,
                    size: 20,
                    color:
                    _gotra != null && _gotra!.isNotEmpty
                        ? AppColors.crimson
                        : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── RASHI & NAKSHATRA SECTION ──────────────────────
  Widget _buildRashiNakshatraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('♈', 'Rashi & Nakshatra'),
        const SizedBox(height: 14),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rashi
              _buildFieldLabel(
                'Rashi (Moon Sign)',
                Icons.circle_outlined,
                optional: '(Optional)',
              ),
              const SizedBox(height: 8),
              _buildPickerField(
                hint: "Apni rashi chunein",
                value: _rashi,
                icon: Icons.circle_outlined,
                onTap: () => _showPickerSheet(
                  'Rashi Chunein',
                  _rashiList,
                  _rashi,
                      (val) => setState(() => _rashi = val),
                ),
              ),

              const SizedBox(height: 16),

              // Nakshatra
              _buildFieldLabel(
                'Nakshatra (Birth Star)',
                Icons.star_outline_rounded,
                optional: '(Optional)',
              ),
              const SizedBox(height: 8),
              _buildPickerField(
                hint: "Apna nakshatra chunein",
                value: _nakshatra,
                icon: Icons.star_outline_rounded,
                onTap: () => _showPickerSheet(
                  'Nakshatra Chunein',
                  _nakshatraList,
                  _nakshatra,
                      (val) => setState(() => _nakshatra = val),
                ),
              ),

              // Rashi info chips
              const SizedBox(height: 14),
              if (_rashi != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.crimsonSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Text('♈',
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _rashi!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.crimson,
                              ),
                            ),
                            Text(
                              "Selected rashi",
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                AppColors.crimson.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _rashi = null),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.crimson
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 12,
                              color: AppColors.crimson),
                        ),
                      ),
                    ],
                  ),
                ),
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
        _buildSectionHeader('⚠️', 'Manglik Status'),
        const SizedBox(height: 14),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kundali mein Mangal dosh hai?",
                style: TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 12),

              // 3 options
              Row(
                children: [
                  _buildManglikOption(
                    'Haan',
                    '⚠️',
                    _isManglik && !_isAnshikManglik,
                    AppColors.error,
                        () => setState(() {
                      _isManglik = true;
                      _isAnshikManglik = false;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildManglikOption(
                    'Nahi',
                    '✅',
                    !_isManglik && !_isAnshikManglik,
                    AppColors.success,
                        () => setState(() {
                      _isManglik = false;
                      _isAnshikManglik = false;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildManglikOption(
                    'Anshik',
                    '🔶',
                    _isAnshikManglik,
                    AppColors.warning,
                        () => setState(() {
                      _isManglik = false;
                      _isAnshikManglik = true;
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.info.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Anshik Manglik = Partial Mangal dosh. Yeh kundali milaan mein consider hota hai.",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManglikOption(
      String label,
      String emoji,
      bool isSelected,
      Color color,
      VoidCallback onTap,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.1)
                : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── KUNDALI UPLOAD SECTION ─────────────────────────
  Widget _buildKundaliSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('📜', 'Kundali Upload Karein'),
        const SizedBox(height: 14),
        _buildSectionCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kundali document upload karein (Optional)",
                style: TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 14),

              if (_kundaliFile == null)
                GestureDetector(
                  onTap: _showKundaliOptions,
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.ivory,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.crimson.withOpacity(0.3),
                        width: 2,
                        strokeAlign:
                        BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.crimsonSurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            size: 20,
                            color: AppColors.crimson,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Tap karo upload karne ke liye",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.crimson,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "JPG, PNG ya PDF",
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          size: 24,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Kundali uploaded ✓",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              _kundaliFile!.path
                                  .split('/')
                                  .last,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _kundaliFile = null),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.errorSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Privacy note
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 14, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Kundali sirf aap aur connected members dekh sakte hain",
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        onPressed: _isSaving ? null : _saveHoroscope,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          disabledBackgroundColor: AppColors.disabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Save ho raha hai...",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded,
                size: 20, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Horoscope Save Karo",
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

  @override
  void dispose() {
    _birthPlaceController.dispose();
    _gotraController.dispose();
    super.dispose();
  }
}