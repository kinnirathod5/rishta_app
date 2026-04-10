 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';

class Step1BasicInfo extends StatefulWidget {
  const Step1BasicInfo({super.key});

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();

  DateTime? _dob;
  String? _dobError;
  int? _height; // in inches
  String? _heightText;
  String? _motherTongue;
  String _maritalStatus = 'never_married';

  static const List<String> _motherTongueOptions = [
    'Hindi', 'Bengali', 'Telugu', 'Marathi',
    'Tamil', 'Gujarati', 'Kannada', 'Malayalam',
    'Punjabi', 'Odia', 'Urdu', 'Sindhi', 'Other',
  ];

  static const List<Map<String, String>> _maritalOptions = [
    {'label': 'Kabhi Shaadi Nahi Hui', 'value': 'never_married'},
    {'label': 'Divorced', 'value': 'divorced'},
    {'label': 'Widowed', 'value': 'widowed'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _aboutController.dispose();
    _nameFocusNode.dispose();
    _cityFocusNode.dispose();
    super.dispose();
  }

  // ── DATE PICKER ───────────────────────────────────────
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 70),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.crimson,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobError = null;
      });
    }
  }

  // ── HEIGHT PICKER ─────────────────────────────────────
  void _showHeightPicker() {
    // Range: 4'5" to 6'5" = 53 to 77 inches
    const int minInches = 53;
    const int maxInches = 77;
    int selectedInches = _height ?? 66; // default 5'6"

    String formatHeight(int inches) {
      final feet = inches ~/ 12;
      final inch = inches % 12;
      return '$feet feet $inch inch';
    }

    final items = List.generate(
      maxInches - minInches + 1,
      (i) => minInches + i,
    );

    int initialIndex = selectedInches - minInches;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Height Chunein',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded,
                          size: 22, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // Picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: 44,
                  onSelectedItemChanged: (index) {
                    selectedInches = items[index];
                  },
                  children: items
                      .map((inch) => Center(
                            child: Text(
                              formatHeight(inch),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.ink,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Done button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _height = selectedInches;
                        _heightText = formatHeight(selectedInches);
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crimson,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── MOTHER TONGUE PICKER ──────────────────────────────
  void _showMotherTonguePicker() {
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
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Matrubhasha Chunein',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded,
                            size: 22, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                // List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _motherTongueOptions.length,
                    itemBuilder: (context, index) {
                      final option = _motherTongueOptions[index];
                      final isSelected = _motherTongue == option;
                      return ListTile(
                        onTap: () {
                          setState(() => _motherTongue = option);
                          Navigator.pop(context);
                        },
                        title: Text(
                          option,
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
                                color: AppColors.crimson, size: 20)
                            : null,
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
    // Validate DOB
    if (_dob == null) {
      setState(() => _dobError = 'Janam tithi zaroori hai');
      return;
    }
    // Validate height
    if (_height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Height select karo')),
      );
      return;
    }
    // Validate mother tongue
    if (_motherTongue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Matrubhasha select karo')),
      );
      return;
    }
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    context.go('/setup/step2');
  }

  // ── INPUT DECORATION ─────────────────────────────────
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  // ── FIELD LABEL ───────────────────────────────────────
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

  // ── PICKER CONTAINER ─────────────────────────────────
  Widget _buildPickerContainer({
    required VoidCallback onTap,
    required IconData icon,
    required String? value,
    required String placeholder,
    bool showCheckOnValue = false,
    bool showDropdownArrow = true,
  }) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? AppColors.crimson : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: hasValue ? AppColors.crimson : AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: hasValue
                  ? Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Text(
                      placeholder,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.disabled,
                      ),
                    ),
            ),
            if (showCheckOnValue && hasValue)
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: AppColors.success)
            else if (showDropdownArrow)
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  // ── PROGRESS BAR ─────────────────────────────────────
  Widget _buildProgressBar() {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 5,
                  decoration: BoxDecoration(
                    color: index <= 0
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
            // ── FIXED HEADER ────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
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
                  // Row 1: Back + Step label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/profile-type'),
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
                        'Step 1 of 5',
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
                  // Row 2: Progress bar
                  _buildProgressBar(),
                  const SizedBox(height: 12),
                  // Row 3: Step title
                  const Text(
                    'Basic Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Apni basic jankari bharein',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE FORM ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24)
                        .copyWith(bottom: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // ── FIELD 1: Full Name ────────────
                      _buildFieldLabel(
                          'Poora Naam', Icons.person_outline,
                          required: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hintText: 'Jaise: Priya Sharma',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        validator: Validators.name,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_cityFocusNode),
                      ),

                      // ── FIELD 2: Date of Birth ────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                          'Janam Tithi', Icons.cake_outlined,
                          required: true),
                      const SizedBox(height: 8),
                      _buildPickerContainer(
                        onTap: _selectDate,
                        icon: Icons.cake_outlined,
                        value: _dob != null
                            ? DateFormat('d MMMM yyyy').format(_dob!)
                            : null,
                        placeholder: 'DD / MM / YYYY',
                        showCheckOnValue: true,
                        showDropdownArrow: false,
                      ),
                      if (_dobError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 6),
                          child: Text(
                            _dobError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),

                      // ── FIELD 3: Height ───────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                          'Lambai (Height)', Icons.height_rounded,
                          required: true),
                      const SizedBox(height: 8),
                      _buildPickerContainer(
                        onTap: _showHeightPicker,
                        icon: Icons.height_rounded,
                        value: _heightText,
                        placeholder: 'Apni height chunein',
                        showDropdownArrow: true,
                      ),

                      // ── FIELD 4: City ─────────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                          'Abhi Kahan Rehte Ho',
                          Icons.location_on_outlined,
                          required: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityController,
                        focusNode: _cityFocusNode,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hintText: 'Jaise: Delhi, Mumbai, Bangalore',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        validator: Validators.city,
                      ),

                      // ── FIELD 5: Mother Tongue ────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                          'Matrubhasha', Icons.language_rounded,
                          required: true),
                      const SizedBox(height: 8),
                      _buildPickerContainer(
                        onTap: _showMotherTonguePicker,
                        icon: Icons.language_rounded,
                        value: _motherTongue,
                        placeholder: 'Apni bhasha chunein',
                        showDropdownArrow: true,
                      ),

                      // ── FIELD 6: About Me ─────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                          'Apne Baare Mein', Icons.info_outline_rounded,
                          required: false),
                      const SizedBox(height: 4),
                      const Text(
                        '(Optional — max 300 akshar)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _aboutController,
                        maxLines: 4,
                        maxLength: 300,
                        textInputAction: TextInputAction.done,
                        decoration: _inputDecoration(
                          hintText:
                              'Thoda apne baare mein likho — hobbies, kaam, family...',
                          prefixIcon: Icons.info_outline_rounded,
                        ).copyWith(
                          alignLabelWithHint: true,
                          counterStyle: const TextStyle(
                              fontSize: 11, color: AppColors.muted),
                        ),
                        validator: Validators.about,
                        onChanged: (_) => setState(() {}),
                      ),
                      // Character count
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_aboutController.text.length}/300',
                          style: TextStyle(
                            fontSize: 11,
                            color: _aboutController.text.length > 280
                                ? AppColors.warning
                                : AppColors.muted,
                          ),
                        ),
                      ),

                      // ── MARITAL STATUS ────────────────
                      const SizedBox(height: 20),
                      _buildFieldLabel(
                          'Vivah Status', Icons.favorite_border_rounded,
                          required: true),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _maritalOptions.map((opt) {
                          final isSelected =
                              _maritalStatus == opt['value'];
                          return GestureDetector(
                            onTap: () => setState(
                                () => _maritalStatus = opt['value']!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.crimson
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.crimson
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                opt['label']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.inkSoft,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
