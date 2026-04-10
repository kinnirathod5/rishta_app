import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class Step2Religion extends StatefulWidget {
  const Step2Religion({super.key});

  @override
  State<Step2Religion> createState() => _Step2ReligionState();
}

class _Step2ReligionState extends State<Step2Religion> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subCasteController = TextEditingController();
  final TextEditingController _gotraController = TextEditingController();

  String? _religion;
  String? _caste;
  String _manglik = 'no';
  String? _nakshatra;

  // ── DATA ──────────────────────────────────────────────
  static const List<String> _religions = [
    'Hindu', 'Muslim', 'Sikh', 'Christian',
    'Jain', 'Buddhist', 'Parsi', 'Jewish', 'Other',
  ];

  static const Map<String, String> _religionEmojis = {
    'Hindu': '🛕',
    'Muslim': '🕌',
    'Sikh': '⚔️',
    'Christian': '✝️',
    'Jain': '☸️',
    'Buddhist': '☸️',
    'Parsi': '🔥',
    'Jewish': '✡️',
    'Other': '🙏',
  };

  static const Map<String, List<String>> _casteOptions = {
    'Hindu': [
      'Brahmin', 'Kshatriya', 'Vaishya', 'Kayastha', 'Rajput', 'Jat',
      'Maratha', 'Nair', 'Reddy', 'Naidu', 'Lingayat', 'Vokkaliga',
      'Scheduled Caste', 'Scheduled Tribe', 'Other',
    ],
    'Muslim': [
      'Sunni', 'Shia', 'Syed', 'Sheikh', 'Pathan', 'Mughal', 'Ansari',
      'Other',
    ],
    'Sikh': [
      'Jat Sikh', 'Khatri', 'Arora', 'Ramgarhia', 'Saini', 'Other',
    ],
    'Christian': [
      'Catholic', 'Protestant', 'Orthodox', 'Born Again', 'Other',
    ],
    'Jain': ['Digambar', 'Shwetambar', 'Other'],
  };

  static const List<String> _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
    'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
    'Dhanishtha', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada',
    'Revati', 'Pata Nahi',
  ];

  static const List<Map<String, String>> _manglikOptions = [
    {'label': 'Haan', 'value': 'yes', 'emoji': '⚠️'},
    {'label': 'Nahi', 'value': 'no', 'emoji': '✅'},
    {'label': 'Anshik', 'value': 'partial', 'emoji': '🔶'},
  ];

  @override
  void dispose() {
    _subCasteController.dispose();
    _gotraController.dispose();
    super.dispose();
  }

  // ── PICKERS ───────────────────────────────────────────
  void _showReligionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 420,
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dharm Chunein',
                      style: TextStyle(
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
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.builder(
                  itemCount: _religions.length,
                  itemBuilder: (context, index) {
                    final religion = _religions[index];
                    final isSelected = _religion == religion;
                    return ListTile(
                      leading: Text(
                        _religionEmojis[religion] ?? '🙏',
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        religion,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              size: 20, color: AppColors.crimson)
                          : null,
                      tileColor:
                          isSelected ? AppColors.crimsonSurface : null,
                      onTap: () {
                        setState(() {
                          _religion = religion;
                          _caste = null;
                        });
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

  void _showCastePicker() {
    final castes = _casteOptions[_religion] ?? ['Other'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.ivoryDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jaati Chunein',
                        style: TextStyle(
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
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: castes.length,
                    itemBuilder: (context, index) {
                      final caste = castes[index];
                      final isSelected = _caste == caste;
                      return ListTile(
                        title: Text(
                          caste,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.crimson
                                : AppColors.ink,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                size: 20, color: AppColors.crimson)
                            : null,
                        tileColor:
                            isSelected ? AppColors.crimsonSurface : null,
                        onTap: () {
                          setState(() => _caste = caste);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNakshatraPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.ivoryDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nakshatra Chunein',
                        style: TextStyle(
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
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _nakshatras.length,
                    itemBuilder: (context, index) {
                      final nakshatra = _nakshatras[index];
                      final isSelected = _nakshatra == nakshatra;
                      return ListTile(
                        title: Text(
                          nakshatra,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.crimson
                                : AppColors.ink,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                size: 20, color: AppColors.crimson)
                            : null,
                        tileColor:
                            isSelected ? AppColors.crimsonSurface : null,
                        onTap: () {
                          setState(() => _nakshatra = nakshatra);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── CONTINUE ──────────────────────────────────────────
  void _onContinue() {
    if (_religion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dharm zaroori hai')),
      );
      return;
    }
    if (_caste == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jaati zaroori hai')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    context.go('/setup/step3');
  }

  // ── HELPER WIDGETS ────────────────────────────────────
  Widget _buildFieldLabel(String label, IconData icon,
      {bool required = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.crimson),
        const SizedBox(width: 8),
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
          const Text(
            '*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPickerField({
    required String? value,
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value != null
              ? AppColors.crimson
              : enabled
                  ? AppColors.border
                  : const Color(0xFFEEEEEE),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value != null
                ? AppColors.crimson
                : enabled
                    ? AppColors.muted
                    : AppColors.disabled,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: value != null
                ? Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Text(
                    hint,
                    style: TextStyle(
                      fontSize: 15,
                      color: enabled
                          ? AppColors.disabled
                          : const Color(0xFFBBBBBB),
                    ),
                  ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: enabled ? AppColors.muted : AppColors.disabled,
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.go('/setup/step1'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              const Text(
                'Step 2 of 5',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar — 2 crimson, 3 ivoryDark
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 5,
                        decoration: BoxDecoration(
                          color: index <= 1
                              ? AppColors.crimson
                              : AppColors.ivoryDark,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    if (index < 4) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text(
            'Religion & Caste',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Apni community ki jankari bharein',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.disabled, fontSize: 15),
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.muted),
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: AppColors.crimson, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24)
                    .copyWith(bottom: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // ── FIELD 1: Religion ─────────────
                      _buildFieldLabel(
                        'Dharm (Religion)',
                        Icons.temple_hindu_outlined,
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showReligionPicker,
                        child: _buildPickerField(
                          value: _religion,
                          hint: 'Apna dharm chunein',
                          icon: Icons.temple_hindu_outlined,
                        ),
                      ),

                      // ── FIELD 2: Caste ────────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                        'Jaati (Caste)',
                        Icons.people_outline_rounded,
                        required: true,
                      ),
                      if (_religion == null) ...[
                        const SizedBox(height: 4),
                        const Text(
                          '(Religion chunne ke baad options aayenge)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          if (_religion == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pehle religion chunein'),
                              ),
                            );
                          } else {
                            _showCastePicker();
                          }
                        },
                        child: _buildPickerField(
                          value: _caste,
                          hint: 'Apni jaati chunein',
                          icon: Icons.people_outline_rounded,
                          enabled: _religion != null,
                        ),
                      ),

                      // ── FIELD 3: Sub-caste ────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                        'Upjaati (Sub-caste)',
                        Icons.account_tree_outlined,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(Optional)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _subCasteController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hintText: 'Jaise: Saraswat, Iyer, Khatri...',
                          prefixIcon: Icons.account_tree_outlined,
                        ),
                      ),

                      // ── FIELD 4: Gotra ────────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                        'Gotra',
                        Icons.family_restroom_outlined,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(Optional — mainly Hindu/Sikh ke liye)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _gotraController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hintText: 'Jaise: Kashyap, Bharadwaj, Atri...',
                          prefixIcon: Icons.family_restroom_outlined,
                        ),
                      ),

                      // ── FIELD 5: Manglik ──────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                        'Manglik',
                        Icons.stars_outlined,
                        required: true,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kundali/horoscope se pata karo',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_manglikOptions.length,
                            (index) {
                          final opt = _manglikOptions[index];
                          final isSelected = _manglik == opt['value'];
                          final isLast =
                              index == _manglikOptions.length - 1;
                          return Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: isLast ? 0 : 10),
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _manglik = opt['value']!),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        opt['emoji']!,
                                        style: const TextStyle(
                                            fontSize: 18),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        opt['label']!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      // ── FIELD 6: Nakshatra ────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                        'Nakshatra / Star',
                        Icons.star_outline_rounded,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(Optional)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showNakshatraPicker,
                        child: _buildPickerField(
                          value: _nakshatra,
                          hint: 'Apna nakshatra chunein (optional)',
                          icon: Icons.star_outline_rounded,
                        ),
                      ),

                      // ── INFO BOX ──────────────────────
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.infoSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AppColors.info.withValues(alpha: 0.20),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.privacy_tip_outlined,
                              size: 18,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Yeh information private hai',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sirf connected members hi aapki caste details dekh sakte hain',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.info
                                          .withValues(alpha: 0.80),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── CONTINUE BUTTON ───────────────
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.crimson,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aage Badho',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 18, color: AppColors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
