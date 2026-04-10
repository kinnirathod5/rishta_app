import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class Step3Education extends StatefulWidget {
  const Step3Education({super.key});

  @override
  State<Step3Education> createState() => _Step3EducationState();
}

class _Step3EducationState extends State<Step3Education> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _workingCityController = TextEditingController();
  final TextEditingController _nriCountryController = TextEditingController();

  String? _qualification;
  String _employmentType = 'private';
  String? _income;
  bool _isNri = false;

  // ── DATA ──────────────────────────────────────────────
  static const List<String> _qualifications = [
    '10th Pass',
    '12th Pass',
    'Diploma',
    'Graduate (B.A/B.Sc/B.Com)',
    'Graduate (B.Tech/B.E)',
    'Graduate (MBBS/BDS)',
    'Graduate (Other)',
    'Post Graduate (M.A/M.Sc)',
    'Post Graduate (M.Tech/M.E)',
    'Post Graduate (MBA)',
    'Post Graduate (MD/MS)',
    'Post Graduate (Other)',
    'Doctorate (Ph.D)',
    'Other',
  ];

  static const List<String> _incomeOptions = [
    '2 Lakh se kam',
    '2 - 4 Lakh',
    '4 - 6 Lakh',
    '6 - 8 Lakh',
    '8 - 10 Lakh',
    '10 - 15 Lakh',
    '15 - 20 Lakh',
    '20 - 30 Lakh',
    '30 - 50 Lakh',
    '50 Lakh - 1 Crore',
    '1 Crore se zyada',
    'Batana Nahi Chahta',
  ];

  static const List<Map<String, String>> _employmentOptions = [
    {'label': 'Sarkari Naukri', 'value': 'govt', 'emoji': '🏛️'},
    {'label': 'Private Naukri', 'value': 'private', 'emoji': '🏢'},
    {'label': 'Khud ka Kaam', 'value': 'business', 'emoji': '💰'},
    {'label': 'Naukri Nahi', 'value': 'not_working', 'emoji': '🏠'},
  ];

  @override
  void dispose() {
    _collegeController.dispose();
    _companyController.dispose();
    _designationController.dispose();
    _workingCityController.dispose();
    _nriCountryController.dispose();
    super.dispose();
  }

  // ── PICKERS ───────────────────────────────────────────
  void _showQualificationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 480,
          child: Column(
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
                      'Qualification Chunein',
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
                  itemCount: _qualifications.length,
                  itemBuilder: (context, index) {
                    final q = _qualifications[index];
                    final isSelected = _qualification == q;
                    return ListTile(
                      title: Text(
                        q,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color:
                              isSelected ? AppColors.crimson : AppColors.ink,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              size: 20, color: AppColors.crimson)
                          : null,
                      tileColor:
                          isSelected ? AppColors.crimsonSurface : null,
                      onTap: () {
                        setState(() => _qualification = q);
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

  void _showIncomePicker() {
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
                        'Income Range Chunein',
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
                    itemCount: _incomeOptions.length,
                    itemBuilder: (context, index) {
                      final opt = _incomeOptions[index];
                      final isSelected = _income == opt;
                      return ListTile(
                        title: Text(
                          opt,
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
                          setState(() => _income = opt);
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
    if (_qualification == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qualification zaroori hai')),
      );
      return;
    }
    if (_income == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income range chunein')),
      );
      return;
    }
    if (_isNri && _nriCountryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NRI country daalni zaroori hai')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    context.go('/setup/step4');
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

  Widget _buildEmploymentGrid() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _employmentOptions.map((opt) {
        final isSelected = _employmentType == opt['value'];
        return GestureDetector(
          onTap: () => setState(() => _employmentType = opt['value']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.crimsonSurface : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.crimson : AppColors.border,
                width: 2,
              ),
              boxShadow: isSelected ? AppColors.cardShadow : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(opt['emoji']!, style: const TextStyle(fontSize: 22)),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.crimson),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  opt['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.crimson : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
                onTap: () => context.go('/setup/step2'),
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
                'Step 3 of 5',
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
          // Progress bar — 3 crimson, 2 ivoryDark
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
                          color: index <= 2
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
            'Education & Career',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Aapki padhai aur kaam ki jankari',
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
        borderSide: const BorderSide(color: AppColors.crimson, width: 1.5),
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
    final bool isWorking = _employmentType != 'not_working';

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

                      // ── EDUCATION SECTION HEADER ──────
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.crimsonSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('🎓',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Shiksha (Education)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── FIELD 1: Qualification ────────
                      _buildFieldLabel(
                        'Highest Qualification',
                        Icons.school_outlined,
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showQualificationPicker,
                        child: _buildPickerField(
                          value: _qualification,
                          hint: 'Sabse badi degree chunein',
                          icon: Icons.school_outlined,
                        ),
                      ),

                      // ── FIELD 2: College ──────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                        'College / University',
                        Icons.account_balance_outlined,
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
                        controller: _collegeController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hintText:
                              'Jaise: Delhi University, IIT Bombay...',
                          prefixIcon: Icons.account_balance_outlined,
                        ),
                      ),

                      // ── DIVIDER ───────────────────────
                      const SizedBox(height: 28),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('💼',
                                style: TextStyle(fontSize: 16)),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── CAREER SECTION HEADER ─────────
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.goldSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('💼',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Naukri (Career)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── FIELD 3: Employment Type ──────
                      _buildFieldLabel(
                        'Naukri ka Prakar',
                        Icons.work_outline_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 12),
                      _buildEmploymentGrid(),

                      // ── FIELD 4: Company / Designation ─
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isWorking ? 1.0 : 0.0,
                        child: isWorking
                            ? Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  _buildFieldLabel(
                                    'Company / Kahan Kaam Karte Ho',
                                    Icons.business_outlined,
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
                                    controller: _companyController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    decoration: _inputDecoration(
                                      hintText:
                                          'Jaise: TCS, Infosys, Government Hospital...',
                                      prefixIcon: Icons.business_outlined,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFieldLabel(
                                    'Designation / Post',
                                    Icons.badge_outlined,
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
                                    controller: _designationController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    decoration: _inputDecoration(
                                      hintText:
                                          'Jaise: Software Engineer, Manager, Doctor...',
                                      prefixIcon: Icons.badge_outlined,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      // ── FIELD 5: Income ───────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                        'Saalana Aay (Income)',
                        Icons.currency_rupee_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showIncomePicker,
                        child: _buildPickerField(
                          value: _income,
                          hint: 'Income range chunein',
                          icon: Icons.currency_rupee_rounded,
                        ),
                      ),

                      // ── FIELD 6: Working City ─────────
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isWorking ? 1.0 : 0.0,
                        child: isWorking
                            ? Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  _buildFieldLabel(
                                    'Kaam Karne Ki City',
                                    Icons.location_city_outlined,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '(Optional — agar current city alag hai)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _workingCityController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    decoration: _inputDecoration(
                                      hintText:
                                          'Jaise: Bangalore, Pune, Dubai...',
                                      prefixIcon:
                                          Icons.location_city_outlined,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      // ── FIELD 7: NRI Toggle ───────────
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kya aap NRI hain?',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Non-Resident Indian',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isNri,
                                  onChanged: (val) => setState(() {
                                    _isNri = val;
                                    if (!val) {
                                      _nriCountryController.clear();
                                    }
                                  }),
                                  activeThumbColor: AppColors.crimson,
                                ),
                              ],
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _isNri ? 1.0 : 0.0,
                              child: _isNri
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 14),
                                        _buildFieldLabel(
                                          'Kaunse Desh Mein',
                                          Icons.flight_outlined,
                                          required: true,
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _nriCountryController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          decoration: _inputDecoration(
                                            hintText:
                                                'Jaise: USA, UK, Canada, Australia...',
                                            prefixIcon:
                                                Icons.flight_outlined,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),

                      // ── CONTINUE BUTTON ───────────────
                      const SizedBox(height: 36),
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
