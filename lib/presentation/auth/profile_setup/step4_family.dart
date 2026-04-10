import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class Step4Family extends StatefulWidget {
  const Step4Family({super.key});

  @override
  State<Step4Family> createState() => _Step4FamilyState();
}

class _Step4FamilyState extends State<Step4Family> {
  // ── STATE VARIABLES ───────────────────────────────────
  String _familyType = 'joint';
  String _familyValues = 'moderate';
  String _familyStatus = 'middle';
  String? _fatherOccupation;
  String? _motherOccupation;
  int _brothers = 0;
  int _sisters = 0;
  final TextEditingController _familyCityController = TextEditingController();

  // ── DATA ──────────────────────────────────────────────
  static const List<Map<String, String>> _familyTypeOptions = [
    {'label': 'Sanyukt\nParivar', 'value': 'joint', 'emoji': '👨‍👩‍👧‍👦'},
    {'label': 'Ekl\nParivar', 'value': 'nuclear', 'emoji': '👨‍👩‍👦'},
    {'label': 'Koi Bhi', 'value': 'other', 'emoji': '🤷'},
  ];

  static const List<Map<String, String>> _familyValuesOptions = [
    {'label': 'Paramparik', 'value': 'traditional', 'emoji': '🛕'},
    {'label': 'Madhyam', 'value': 'moderate', 'emoji': '⚖️'},
    {'label': 'Aadhunik', 'value': 'liberal', 'emoji': '🌟'},
  ];

  static const List<Map<String, String>> _familyStatusOptions = [
    {'label': 'Madhyam\nVarg', 'value': 'middle', 'emoji': '🏘️'},
    {'label': 'Ucch Madhyam', 'value': 'upper_middle', 'emoji': '🏡'},
    {'label': 'Sampann', 'value': 'rich', 'emoji': '🏰'},
  ];

  static const List<String> _occupationOptions = [
    'Sarkari Naukri',
    'Private Naukri',
    'Khud ka Vyapar (Business)',
    'Doctor',
    'Engineer',
    'Teacher/Professor',
    'Lawyer/Advocate',
    'Chartered Accountant',
    'Police/Army/Navy',
    'Farmer (Kisan)',
    'Retired',
    'Ghar pe Rehte Hain (Homemaker)',
    'Nahi Rahe (Expired)',
    'Other',
  ];

  @override
  void dispose() {
    _familyCityController.dispose();
    super.dispose();
  }

  // ── PICKERS ───────────────────────────────────────────
  void _showOccupationPicker(String parent) {
    final title =
        parent == 'father' ? 'Pita ka Kaam' : 'Mata ka Kaam';
    final current =
        parent == 'father' ? _fatherOccupation : _motherOccupation;

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
                    itemCount: _occupationOptions.length,
                    itemBuilder: (context, index) {
                      final opt = _occupationOptions[index];
                      final isSelected = current == opt;
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
                          setState(() {
                            if (parent == 'father') {
                              _fatherOccupation = opt;
                            } else {
                              _motherOccupation = opt;
                            }
                          });
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
    if (_fatherOccupation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pita ka kaam chunein')),
      );
      return;
    }
    if (_motherOccupation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mata ka kaam chunein')),
      );
      return;
    }
    context.go('/setup/step5');
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildFamilyTypeSection(),
                    const SizedBox(height: 24),
                    _buildFamilyValuesSection(),
                    const SizedBox(height: 24),
                    _buildFamilyStatusSection(),
                    const SizedBox(height: 24),
                    _buildParentsSection(),
                    const SizedBox(height: 24),
                    _buildSiblingsSection(),
                    const SizedBox(height: 24),
                    _buildFamilyLocationSection(),
                    _buildContinueButton(),
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

  // ── TOP HEADER ────────────────────────────────────────
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
                onTap: () => context.go('/setup/step3'),
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
                'Step 4 of 5',
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
          // Progress bar — 4 crimson, 1 ivoryDark
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
                          color: index <= 3
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
            'Family Info',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Apne parivar ki jankari bharein',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER HELPER ─────────────────────────────
  Widget _buildSectionHeader({
    required Color bgColor,
    required String emoji,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
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

  // ── OPTION CARD ROW HELPER ────────────────────────────
  Widget _buildOptionCardRow({
    required List<Map<String, String>> options,
    required String selectedValue,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(options[i]['value']!),
              child: _buildOptionCard(
                label: options[i]['label']!,
                emoji: options[i]['emoji']!,
                isSelected: selectedValue == options[i]['value'],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionCard({
    required String label,
    required String emoji,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.crimson : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.crimson : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION 1: FAMILY TYPE ────────────────────────────
  Widget _buildFamilyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          bgColor: AppColors.crimsonSurface,
          emoji: '🏠',
          title: 'Parivar ka Prakar',
        ),
        const SizedBox(height: 14),
        _buildOptionCardRow(
          options: _familyTypeOptions,
          selectedValue: _familyType,
          onSelect: (val) => setState(() => _familyType = val),
        ),
      ],
    );
  }

  // ── SECTION 2: FAMILY VALUES ──────────────────────────
  Widget _buildFamilyValuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          bgColor: AppColors.goldSurface,
          emoji: '🙏',
          title: 'Parivar ki Soch',
        ),
        const SizedBox(height: 14),
        _buildOptionCardRow(
          options: _familyValuesOptions,
          selectedValue: _familyValues,
          onSelect: (val) => setState(() => _familyValues = val),
        ),
      ],
    );
  }

  // ── SECTION 3: FAMILY STATUS ──────────────────────────
  Widget _buildFamilyStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          bgColor: AppColors.successSurface,
          emoji: '💰',
          title: 'Parivar ki Sthiti',
        ),
        const SizedBox(height: 14),
        _buildOptionCardRow(
          options: _familyStatusOptions,
          selectedValue: _familyStatus,
          onSelect: (val) => setState(() => _familyStatus = val),
        ),
      ],
    );
  }

  // ── SECTION 4: PARENTS INFO ───────────────────────────
  Widget _buildParentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          bgColor: AppColors.infoSurface,
          emoji: '👨‍👩‍👧',
          title: 'Mata-Pita ki Jankari',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: [
              _buildParentRow(
                label: 'Pita ka Kaam',
                emoji: '👨',
                value: _fatherOccupation,
                onTap: () => _showOccupationPicker('father'),
              ),
              const Divider(
                height: 1,
                color: AppColors.border,
                indent: 0,
                endIndent: 0,
              ),
              const SizedBox(height: 12),
              _buildParentRow(
                label: 'Mata ka Kaam',
                emoji: '👩',
                value: _motherOccupation,
                onTap: () => _showOccupationPicker('mother'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParentRow({
    required String label,
    required String emoji,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ?? 'Chunein...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: value != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: value != null
                            ? AppColors.ink
                            : AppColors.disabled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION 5: SIBLINGS ───────────────────────────────
  Widget _buildSiblingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          bgColor: const Color(0xFFF3E8FF),
          emoji: '👫',
          title: 'Bhai-Behen',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: [
              _buildSiblingRow(
                label: 'Bhai (Brothers)',
                emoji: '👦',
                count: _brothers,
                onDecrement: () {
                  if (_brothers > 0) setState(() => _brothers--);
                },
                onIncrement: () {
                  if (_brothers < 10) setState(() => _brothers++);
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSiblingRow(
                label: 'Behen (Sisters)',
                emoji: '👧',
                count: _sisters,
                onDecrement: () {
                  if (_sisters > 0) setState(() => _sisters--);
                },
                onIncrement: () {
                  if (_sisters < 10) setState(() => _sisters++);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSiblingRow({
    required String label,
    required String emoji,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: emoji + label
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
          // Right: counter controls
          Row(
            children: [
              // Decrement
              GestureDetector(
                onTap: onDecrement,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: count > 0
                        ? AppColors.crimsonSurface
                        : AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: count > 0
                          ? AppColors.crimson.withValues(alpha: 0.3)
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.remove_rounded,
                      size: 16,
                      color: count > 0 ? AppColors.crimson : AppColors.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Count
              SizedBox(
                width: 20,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: count > 0 ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Increment
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.crimsonSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.crimson.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.crimson,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── SECTION 6: FAMILY LOCATION ────────────────────────
  Widget _buildFamilyLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          bgColor: const Color(0xFFE8F5E9),
          emoji: '📍',
          title: 'Parivar Kahan Rehta Hai',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: TextFormField(
            controller: _familyCityController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Parivar ki city/gaon ka naam...',
              hintStyle: const TextStyle(
                color: AppColors.disabled,
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.muted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.crimson, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── CONTINUE BUTTON ───────────────────────────────────
  Widget _buildContinueButton() {
    return Column(
      children: [
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
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
