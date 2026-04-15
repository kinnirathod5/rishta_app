// lib/core/widgets/filter_sheet.dart
// Reusable filter bottom sheet — used in Search + Home

import 'package:flutter/material.dart';
import 'package:rishta_app/core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────
// FILTER STATE MODEL
// ─────────────────────────────────────────────────────────

class FilterState {
  final RangeValues ageRange;
  final RangeValues heightRange;
  final List<String> religions;
  final List<String> castes;
  final List<String> cities;
  final String? education;
  final String? income;
  final String? maritalStatus;
  final bool verifiedOnly;
  final bool premiumOnly;
  final bool withPhotoOnly;
  final String sortBy;

  const FilterState({
    this.ageRange = const RangeValues(22, 35),
    this.heightRange = const RangeValues(60, 78),
    this.religions = const [],
    this.castes = const [],
    this.cities = const [],
    this.education,
    this.income,
    this.maritalStatus,
    this.verifiedOnly = false,
    this.premiumOnly = false,
    this.withPhotoOnly = false,
    this.sortBy = 'Newest First',
  });

  FilterState copyWith({
    RangeValues? ageRange,
    RangeValues? heightRange,
    List<String>? religions,
    List<String>? castes,
    List<String>? cities,
    String? education,
    String? income,
    String? maritalStatus,
    bool? verifiedOnly,
    bool? premiumOnly,
    bool? withPhotoOnly,
    String? sortBy,
    bool clearEducation = false,
    bool clearIncome = false,
    bool clearMaritalStatus = false,
  }) {
    return FilterState(
      ageRange: ageRange ?? this.ageRange,
      heightRange: heightRange ?? this.heightRange,
      religions: religions ?? this.religions,
      castes: castes ?? this.castes,
      cities: cities ?? this.cities,
      education: clearEducation
          ? null
          : education ?? this.education,
      income: clearIncome
          ? null
          : income ?? this.income,
      maritalStatus: clearMaritalStatus
          ? null
          : maritalStatus ?? this.maritalStatus,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      premiumOnly: premiumOnly ?? this.premiumOnly,
      withPhotoOnly:
      withPhotoOnly ?? this.withPhotoOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  FilterState reset() => const FilterState();

  bool get hasActiveFilters =>
      religions.isNotEmpty ||
          castes.isNotEmpty ||
          cities.isNotEmpty ||
          verifiedOnly ||
          premiumOnly ||
          withPhotoOnly ||
          education != null ||
          income != null ||
          maritalStatus != null ||
          ageRange.start != 22 ||
          ageRange.end != 35 ||
          heightRange.start != 60 ||
          heightRange.end != 78;

  int get activeFilterCount {
    int count = 0;
    if (religions.isNotEmpty) count++;
    if (castes.isNotEmpty) count++;
    if (cities.isNotEmpty) count++;
    if (verifiedOnly) count++;
    if (premiumOnly) count++;
    if (withPhotoOnly) count++;
    if (education != null) count++;
    if (income != null) count++;
    if (maritalStatus != null) count++;
    if (ageRange.start != 22 || ageRange.end != 35) {
      count++;
    }
    if (heightRange.start != 60 ||
        heightRange.end != 78) {
      count++;
    }
    return count;
  }

  static String heightLabel(double inches) {
    final feet = inches ~/ 12;
    final inch = inches.toInt() % 12;
    return "$feet'$inch\"";
  }
}

// ─────────────────────────────────────────────────────────
// FILTER OPTIONS
// ─────────────────────────────────────────────────────────

abstract class FilterOptions {
  static const List<String> religions = [
    'Hindu', 'Muslim', 'Christian', 'Sikh',
    'Jain', 'Buddhist', 'Parsi', 'Other',
  ];

  static const List<String> castes = [
    'Brahmin', 'Kayastha', 'Rajput', 'Patel',
    'Yadav', 'Jat', 'Reddy', 'Nair',
    'Iyer', 'Naidu', 'Jain', 'Khatri',
  ];

  static const List<String> cities = [
    'Delhi', 'Mumbai', 'Bangalore', 'Hyderabad',
    'Chennai', 'Pune', 'Kolkata', 'Jaipur',
    'Lucknow', 'Chandigarh', 'Ahmedabad', 'Kochi',
  ];

  static const List<String> educations = [
    'High School', 'Diploma', 'Graduate',
    'Post Graduate', 'Doctorate',
  ];

  static const List<String> incomes = [
    'Below 3 LPA', '3-5 LPA', '5-8 LPA',
    '8-12 LPA', '12-20 LPA', '20+ LPA',
  ];

  static const List<String> maritalStatuses = [
    'Never Married', 'Divorced',
    'Widowed', 'Separated',
  ];

  static const List<String> sortOptions = [
    'Newest First',
    'Age: Low to High',
    'Age: High to Low',
    'Verified Only',
    'Premium First',
  ];
}

// ─────────────────────────────────────────────────────────
// FILTER SHEET
// ─────────────────────────────────────────────────────────

class FilterSheet extends StatefulWidget {
  final FilterState initialFilters;
  final ValueChanged<FilterState> onApply;

  const FilterSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static Future<void> show(
      BuildContext context, {
        required FilterState initialFilters,
        required ValueChanged<FilterState> onApply,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => FilterSheet(
        initialFilters: initialFilters,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterSheet> createState() =>
      _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterState _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _apply() {
    widget.onApply(_filters);
    Navigator.pop(context);
  }

  void _reset() =>
      setState(() => _filters = const FilterState());

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Column(children: [
        _buildHandle(),
        _buildHeader(),
        const Divider(
            height: 1, color: AppColors.border),
        Expanded(
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(
                20, 16, 20, 20),
            children: [
              _buildAgeSection(),
              _divider(),
              _buildHeightSection(),
              _divider(),
              _buildReligionSection(),
              _divider(),
              _buildCasteSection(),
              _divider(),
              _buildCitySection(),
              _divider(),
              _buildEducationSection(),
              _divider(),
              _buildIncomeSection(),
              _divider(),
              _buildMaritalSection(),
              _divider(),
              _buildToggleSection(),
            ],
          ),
        ),
        _buildApplyBar(),
      ]),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding:
      const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.ivoryDark,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(20, 8, 12, 14),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              if (_filters.activeFilterCount > 0)
                Text(
                  '${_filters.activeFilterCount} active',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.crimson,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          Row(children: [
            if (_filters.hasActiveFilters)
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.error),
                label: const Text('Reset All',
                    style: TextStyle(
                        color: AppColors.error,
                        fontSize: 13)),
              ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.ink),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildAgeSection() {
    final s = _filters.ageRange.start.toInt();
    final e = _filters.ageRange.end.toInt();
    return _Section(
      title: 'Age Range',
      trailing: '$s – $e yrs',
      child: Column(children: [
        RangeSlider(
          values: _filters.ageRange,
          min: 18,
          max: 60,
          divisions: 42,
          activeColor: AppColors.crimson,
          inactiveColor: AppColors.ivoryDark,
          labels: RangeLabels('$s yrs', '$e yrs'),
          onChanged: (v) => setState(() =>
          _filters =
              _filters.copyWith(ageRange: v)),
        ),
        _RangeRow(
            minLabel: '$s yrs',
            maxLabel: '$e yrs'),
      ]),
    );
  }

  Widget _buildHeightSection() {
    final s = FilterState.heightLabel(
        _filters.heightRange.start);
    final e = FilterState.heightLabel(
        _filters.heightRange.end);
    return _Section(
      title: 'Height Range',
      trailing: '$s – $e',
      child: Column(children: [
        RangeSlider(
          values: _filters.heightRange,
          min: 54,
          max: 84,
          divisions: 30,
          activeColor: AppColors.crimson,
          inactiveColor: AppColors.ivoryDark,
          labels: RangeLabels(s, e),
          onChanged: (v) => setState(() =>
          _filters =
              _filters.copyWith(heightRange: v)),
        ),
        _RangeRow(minLabel: s, maxLabel: e),
      ]),
    );
  }

  Widget _buildReligionSection() => _Section(
    title: 'Religion',
    trailing: _filters.religions.isEmpty
        ? 'Any'
        : '${_filters.religions.length} selected',
    child: _MultiChips(
      options: FilterOptions.religions,
      selected: _filters.religions,
      onChanged: (v) => setState(() =>
      _filters =
          _filters.copyWith(religions: v)),
    ),
  );

  Widget _buildCasteSection() => _Section(
    title: 'Caste',
    trailing: _filters.castes.isEmpty
        ? 'Any'
        : '${_filters.castes.length} selected',
    child: _MultiChips(
      options: FilterOptions.castes,
      selected: _filters.castes,
      onChanged: (v) => setState(() =>
      _filters = _filters.copyWith(castes: v)),
    ),
  );

  Widget _buildCitySection() => _Section(
    title: 'City',
    trailing: _filters.cities.isEmpty
        ? 'Any'
        : '${_filters.cities.length} selected',
    child: _MultiChips(
      options: FilterOptions.cities,
      selected: _filters.cities,
      onChanged: (v) => setState(() =>
      _filters = _filters.copyWith(cities: v)),
    ),
  );

  Widget _buildEducationSection() => _Section(
    title: 'Minimum Education',
    trailing: _filters.education ?? 'Any',
    child: _SingleChips(
      options: FilterOptions.educations,
      selected: _filters.education,
      onChanged: (v) => setState(
            () => _filters =
        v == _filters.education
            ? _filters.copyWith(
            clearEducation: true)
            : _filters.copyWith(education: v),
      ),
    ),
  );

  Widget _buildIncomeSection() => _Section(
    title: 'Minimum Income',
    trailing: _filters.income ?? 'Any',
    child: _SingleChips(
      options: FilterOptions.incomes,
      selected: _filters.income,
      onChanged: (v) => setState(
            () => _filters =
        v == _filters.income
            ? _filters.copyWith(
            clearIncome: true)
            : _filters.copyWith(income: v),
      ),
    ),
  );

  Widget _buildMaritalSection() => _Section(
    title: 'Marital Status',
    trailing: _filters.maritalStatus ?? 'Any',
    child: _SingleChips(
      options: FilterOptions.maritalStatuses,
      selected: _filters.maritalStatus,
      onChanged: (v) => setState(
            () => _filters =
        v == _filters.maritalStatus
            ? _filters.copyWith(
            clearMaritalStatus: true)
            : _filters.copyWith(
            maritalStatus: v),
      ),
    ),
  );

  Widget _buildToggleSection() => _Section(
    title: 'Other Preferences',
    child: Column(children: [
      _ToggleTile(
        icon: Icons.verified_rounded,
        iconColor: AppColors.success,
        label: 'Verified Profiles Only',
        subtitle: 'Show only ID verified profiles',
        value: _filters.verifiedOnly,
        onChanged: (v) => setState(() =>
        _filters =
            _filters.copyWith(verifiedOnly: v)),
      ),
      const SizedBox(height: 10),
      _ToggleTile(
        icon: Icons.workspace_premium_rounded,
        iconColor: AppColors.gold,
        label: 'Premium Members Only',
        subtitle: 'Show only premium subscribers',
        value: _filters.premiumOnly,
        onChanged: (v) => setState(() =>
        _filters =
            _filters.copyWith(premiumOnly: v)),
      ),
      const SizedBox(height: 10),
      _ToggleTile(
        icon: Icons.photo_library_outlined,
        iconColor: AppColors.info,
        label: 'With Photos Only',
        subtitle:
        'Show profiles with at least 1 photo',
        value: _filters.withPhotoOnly,
        onChanged: (v) => setState(() =>
        _filters = _filters.copyWith(
            withPhotoOnly: v)),
      ),
    ]),
  );

  Widget _buildApplyBar() {
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
        if (_filters.activeFilterCount > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.crimson
                      .withOpacity(0.2)),
            ),
            child: Text(
              '${_filters.activeFilterCount}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.crimson,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _apply,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded,
                      size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _filters.activeFilterCount > 0
                        ? 'Apply ${_filters.activeFilterCount} Filter${_filters.activeFilterCount > 1 ? 's' : ''}'
                        : 'Apply Filters',
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(
        height: 1, color: AppColors.border),
  );
}

// ─────────────────────────────────────────────────────────
// SORT SHEET
// ─────────────────────────────────────────────────────────

class SortSheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const SortSheet({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static Future<void> show(
      BuildContext context, {
        required String selected,
        required ValueChanged<String> onSelect,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => SortSheet(
          selected: selected, onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 20),
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          ...FilterOptions.sortOptions.map((opt) {
            final isSel = selected == opt;
            return GestureDetector(
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.crimsonSurface
                          : AppColors.ivoryDark,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        _icon(opt),
                        size: 16,
                        color: isSel
                            ? AppColors.crimson
                            : AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSel
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSel
                            ? AppColors.crimson
                            : AppColors.ink,
                      ),
                    ),
                  ),
                  if (isSel)
                    const Icon(Icons.check_rounded,
                        size: 18,
                        color: AppColors.crimson),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _icon(String opt) {
    switch (opt) {
      case 'Newest First':
        return Icons.schedule_rounded;
      case 'Age: Low to High':
        return Icons.arrow_upward_rounded;
      case 'Age: High to Low':
        return Icons.arrow_downward_rounded;
      case 'Verified Only':
        return Icons.verified_rounded;
      case 'Premium First':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.sort_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────
// ACTIVE FILTERS ROW (reusable)
// ─────────────────────────────────────────────────────────

class ActiveFiltersRow extends StatelessWidget {
  final FilterState filters;
  final int resultCount;
  final VoidCallback? onClearAll;
  final Function(String type)? onRemoveFilter;

  const ActiveFiltersRow({
    super.key,
    required this.filters,
    required this.resultCount,
    this.onClearAll,
    this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _CountChip(count: resultCount),
    ];

    if (filters.verifiedOnly) {
      chips.add(_FilterChip(
        label: 'Verified',
        onRemove: () =>
            onRemoveFilter?.call('verified'),
      ));
    }
    if (filters.premiumOnly) {
      chips.add(_FilterChip(
        label: 'Premium',
        onRemove: () =>
            onRemoveFilter?.call('premium'),
      ));
    }
    if (filters.withPhotoOnly) {
      chips.add(_FilterChip(
        label: 'With Photo',
        onRemove: () =>
            onRemoveFilter?.call('withPhoto'),
      ));
    }
    if (filters.ageRange.start != 22 ||
        filters.ageRange.end != 35) {
      chips.add(_FilterChip(
        label:
        '${filters.ageRange.start.toInt()}-${filters.ageRange.end.toInt()} yrs',
        onRemove: () => onRemoveFilter?.call('age'),
      ));
    }
    for (final c in filters.cities) {
      chips.add(_FilterChip(
        label: c,
        onRemove: () =>
            onRemoveFilter?.call('city:$c'),
      ));
    }
    for (final r in filters.religions) {
      chips.add(_FilterChip(
        label: r,
        onRemove: () =>
            onRemoveFilter?.call('religion:$r'),
      ));
    }
    if (filters.education != null) {
      chips.add(_FilterChip(
        label: filters.education!,
        onRemove: () =>
            onRemoveFilter?.call('education'),
      ));
    }
    if (filters.income != null) {
      chips.add(_FilterChip(
        label: filters.income!,
        onRemove: () =>
            onRemoveFilter?.call('income'),
      ));
    }
    if (filters.hasActiveFilters &&
        onClearAll != null) {
      chips.add(_ClearAllChip(onTap: onClearAll!));
    }

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;

  const _Section({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  )),
              if (trailing != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius:
                    BorderRadius.circular(100),
                  ),
                  child: Text(trailing!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSoft,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RangeRow extends StatelessWidget {
  final String minLabel;
  final String maxLabel;
  const _RangeRow(
      {required this.minLabel,
        required this.maxLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        _RangeLabel(label: minLabel),
        _RangeLabel(label: maxLabel),
      ],
    );
  }
}

class _RangeLabel extends StatelessWidget {
  final String label;
  const _RangeLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.crimson.withOpacity(0.2)),
      ),
      child: Text(label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.crimson,
          )),
    );
  }
}

class _MultiChips extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _MultiChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSel = selected.contains(opt);
        return GestureDetector(
          onTap: () {
            final updated =
            List<String>.from(selected);
            isSel
                ? updated.remove(opt)
                : updated.add(opt);
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration:
            const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel
                  ? AppColors.crimson
                  : AppColors.white,
              borderRadius:
              BorderRadius.circular(100),
              border: Border.all(
                color: isSel
                    ? AppColors.crimson
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(opt,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSel
                      ? Colors.white
                      : AppColors.inkSoft,
                )),
          ),
        );
      }).toList(),
    );
  }
}

class _SingleChips extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;

  const _SingleChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSel = selected == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration:
            const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel
                  ? AppColors.crimson
                  : AppColors.white,
              borderRadius:
              BorderRadius.circular(100),
              border: Border.all(
                color: isSel
                    ? AppColors.crimson
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSel) ...[
                  const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white),
                  const SizedBox(width: 5),
                ],
                Text(opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSel
                          ? Colors.white
                          : AppColors.inkSoft,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value
              ? iconColor.withOpacity(0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? iconColor.withOpacity(0.3)
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value
                  ? iconColor.withOpacity(0.12)
                  : AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon,
                  size: 18,
                  color: value
                      ? iconColor
                      : AppColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: value
                          ? AppColors.ink
                          : AppColors.inkSoft,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
            trackColor:
            WidgetStateProperty.resolveWith(
                  (states) => states.contains(
                  WidgetState.selected)
                  ? iconColor.withOpacity(0.3)
                  : AppColors.border,
            ),
          ),
        ]),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            color: AppColors.crimson.withOpacity(0.2)),
      ),
      child: Text('$count Results',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.crimson,
          )),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const _FilterChip(
      {required this.label, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gold,
                )),
            if (onRemove != null) ...[
              const SizedBox(width: 5),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded,
                    size: 13, color: AppColors.gold),
              ),
            ],
          ]),
    );
  }
}

class _ClearAllChip extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearAllChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: AppColors.error.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close_rounded,
                size: 12, color: AppColors.error),
            SizedBox(width: 4),
            Text('Clear All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                )),
          ],
        ),
      ),
    );
  }
}