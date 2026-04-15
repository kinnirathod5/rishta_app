// lib/presentation/home/search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/home_provider.dart';
import '../home/home_screen.dart';

// ── FILTER MODEL ──────────────────────────────────────────
class _FilterState {
  final RangeValues ageRange;
  final RangeValues heightRange;
  final List<String> religions;
  final List<String> castes;
  final List<String> cities;
  final String? education;
  final String? income;
  final bool verifiedOnly;
  final String sortBy;

  const _FilterState({
    this.ageRange = const RangeValues(22, 35),
    this.heightRange = const RangeValues(60, 78),
    this.religions = const [],
    this.castes = const [],
    this.cities = const [],
    this.education,
    this.income,
    this.verifiedOnly = false,
    this.sortBy = 'Newest First',
  });

  bool get hasActiveFilters =>
      religions.isNotEmpty ||
          castes.isNotEmpty ||
          cities.isNotEmpty ||
          verifiedOnly ||
          education != null ||
          income != null ||
          ageRange.start != 22 ||
          ageRange.end != 35;

  int get activeFilterCount {
    int count = 0;
    if (religions.isNotEmpty) count++;
    if (castes.isNotEmpty) count++;
    if (cities.isNotEmpty) count++;
    if (verifiedOnly) count++;
    if (education != null) count++;
    if (income != null) count++;
    if (ageRange.start != 22 || ageRange.end != 35)
      count++;
    return count;
  }

  _FilterState copyWith({
    RangeValues? ageRange,
    RangeValues? heightRange,
    List<String>? religions,
    List<String>? castes,
    List<String>? cities,
    String? education,
    String? income,
    bool? verifiedOnly,
    String? sortBy,
  }) {
    return _FilterState(
      ageRange: ageRange ?? this.ageRange,
      heightRange: heightRange ?? this.heightRange,
      religions: religions ?? this.religions,
      castes: castes ?? this.castes,
      cities: cities ?? this.cities,
      education: education ?? this.education,
      income: income ?? this.income,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  _FilterState reset() => const _FilterState();
}

// ── SCREEN ────────────────────────────────────────────────
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  _FilterState _filters = const _FilterState();
  final Set<String> _sentInterests = {};
  final Set<String> _shortlisted = {};

  // Sort options
  static const List<String> _sortOptions = [
    'Newest First',
    'Age: Low to High',
    'Age: High to Low',
    'Verified Only',
  ];

  List<MockProfile> get _filteredProfiles {
    List<MockProfile> results = List.from(mockProfiles);

    // Text search
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      results = results.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q) ||
            p.caste.toLowerCase().contains(q) ||
            p.profession.toLowerCase().contains(q);
      }).toList();
    }

    // Age filter
    results = results.where((p) {
      return p.age >= _filters.ageRange.start &&
          p.age <= _filters.ageRange.end;
    }).toList();

    // Religion filter
    if (_filters.religions.isNotEmpty) {
      results = results
          .where((p) => _filters.religions
          .contains(p.caste))
          .toList();
    }

    // Verified only
    if (_filters.verifiedOnly) {
      results =
          results.where((p) => p.isVerified).toList();
    }

    // Sort
    switch (_filters.sortBy) {
      case 'Age: Low to High':
        results.sort((a, b) => a.age.compareTo(b.age));
        break;
      case 'Age: High to Low':
        results.sort((a, b) => b.age.compareTo(a.age));
        break;
      case 'Verified Only':
        results = results
            .where((p) => p.isVerified)
            .toList();
        break;
    }

    return results;
  }

  void _toggleInterest(String id) {
    setState(() {
      if (_sentInterests.contains(id)) {
        _sentInterests.remove(id);
      } else {
        _sentInterests.add(id);
      }
    });
  }

  void _toggleShortlist(String id) {
    setState(() {
      if (_shortlisted.contains(id)) {
        _shortlisted.remove(id);
      } else {
        _shortlisted.add(id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredProfiles;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: results.isEmpty
                ? _buildEmptyState()
                : _buildResultsGrid(results),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding:
      EdgeInsets.fromLTRB(20, topPad + 10, 20, 14),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Search',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Row(children: [
            // Sort button
            GestureDetector(
              onTap: _showSortSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius:
                  BorderRadius.circular(100),
                  border: Border.all(
                      color: Colors.white
                          .withOpacity(0.25)),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        _filters.sortBy,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ]),
              ),
            ),
            const SizedBox(width: 8),
            // Filter button
            GestureDetector(
              onTap: _showFilterSheet,
              child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(0.15),
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white
                                .withOpacity(0.25)),
                      ),
                      child: const Center(
                        child: Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: Colors.white),
                      ),
                    ),
                    if (_filters.activeFilterCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.crimson,
                                width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '${_filters.activeFilterCount}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
            ),
          ]),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.crimson,
      padding:
      const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (v) =>
              setState(() => _query = v),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.ink,
          ),
          decoration: InputDecoration(
            hintText:
            'Search by name, city, caste...',
            hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.disabled),
            prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.muted),
            suffixIcon: _query.isNotEmpty
                ? GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.muted),
            )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(
                vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── FILTER CHIPS ──────────────────────────────────────
  Widget _buildFilterChips() {
    final chips = <Widget>[];

    // Results count
    chips.add(_ResultCountChip(
        count: _filteredProfiles.length));

    if (_filters.verifiedOnly) {
      chips.add(_ActiveFilterChip(
        label: 'Verified Only',
        onRemove: () => setState(() {
          _filters = _filters.copyWith(
              verifiedOnly: false);
        }),
      ));
    }

    if (_filters.ageRange.start != 22 ||
        _filters.ageRange.end != 35) {
      chips.add(_ActiveFilterChip(
        label:
        '${_filters.ageRange.start.toInt()}-${_filters.ageRange.end.toInt()} yrs',
        onRemove: () => setState(() {
          _filters = _filters.copyWith(
              ageRange: const RangeValues(22, 35));
        }),
      ));
    }

    for (final city in _filters.cities) {
      chips.add(_ActiveFilterChip(
        label: city,
        onRemove: () {
          final updated = List<String>.from(
              _filters.cities)
            ..remove(city);
          setState(() => _filters =
              _filters.copyWith(cities: updated));
        },
      ));
    }

    if (_filters.hasActiveFilters) {
      chips.add(
        GestureDetector(
          onTap: () =>
              setState(() => _filters = _FilterState()),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.errorSurface,
              borderRadius:
              BorderRadius.circular(100),
              border: Border.all(
                  color: AppColors.error
                      .withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close_rounded,
                    size: 12,
                    color: AppColors.error),
                SizedBox(width: 4),
                Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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

  // ── RESULTS GRID ──────────────────────────────────────
  Widget _buildResultsGrid(List<MockProfile> results) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) =>
          _buildProfileCard(results[i]),
    );
  }

  Widget _buildProfileCard(MockProfile p) {
    final interested = _sentInterests.contains(p.id);
    final bookmarked = _shortlisted.contains(p.id);

    return GestureDetector(
      onTap: () =>
          context.push('/profile/${p.id}', extra: p),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(
                          top: Radius.circular(13)),
                      child: Container(
                        color: p.isVerified
                            ? AppColors.crimsonSurface
                            : const Color(0xFFF3F4F6),
                        child: Center(
                          child: Text(p.emoji,
                              style: const TextStyle(
                                  fontSize: 60)),
                        ),
                      ),
                    ),
                    // Verified badge
                    if (p.isVerified)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _VerifiedBadge(),
                      ),
                    // Premium badge
                    if (p.isPremium)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            gradient: AppColors.goldGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('👑',
                                style:
                                TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                    // Shortlist button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () =>
                            _toggleShortlist(p.id),
                        child: AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 200),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: bookmarked
                                ? AppColors.gold
                                : Colors.white
                                .withOpacity(0.85),
                            shape: BoxShape.circle,
                            boxShadow:
                            AppColors.softShadow,
                          ),
                          child: Center(
                            child: Icon(
                              bookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons
                                  .bookmark_border_rounded,
                              size: 14,
                              color: bookmarked
                                  ? Colors.white
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  12, 10, 12, 12),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.name}, ${p.age}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.profession,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkSoft,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: AppColors.muted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${p.city} • ${p.caste}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted),
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  // Interest button
                  GestureDetector(
                    onTap: () =>
                        _toggleInterest(p.id),
                    child: AnimatedContainer(
                      duration: const Duration(
                          milliseconds: 200),
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 7),
                      decoration: BoxDecoration(
                        color: interested
                            ? AppColors.crimson
                            : AppColors.crimsonSurface,
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(
                            interested
                                ? Icons.favorite_rounded
                                : Icons
                                .favorite_border_rounded,
                            size: 12,
                            color: interested
                                ? Colors.white
                                : AppColors.crimson,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            interested
                                ? AppStrings
                                .interestSent
                                : AppStrings
                                .sendInterest,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                              color: interested
                                  ? Colors.white
                                  : AppColors.crimson,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍',
                style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text(
              _query.isNotEmpty
                  ? 'No results for "$_query"'
                  : AppStrings.noProfiles,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _query.isNotEmpty
                  ? 'Try a different name, city or profession'
                  : AppStrings.noProfilesSub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5),
            ),
            if (_filters.hasActiveFilters) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => setState(
                          () => _filters = _FilterState()),
                  child: const Text(
                      AppStrings.resetFilters),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── SORT SHEET ────────────────────────────────────────
  void _showSortSheet() {
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
          crossAxisAlignment:
          CrossAxisAlignment.start,
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
            ..._sortOptions.map((opt) {
              final isSelected =
                  _filters.sortBy == opt;
              return GestureDetector(
                onTap: () {
                  setState(() => _filters =
                      _filters.copyWith(sortBy: opt));
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
                    Expanded(
                      child: Text(
                        opt,
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
                    ),
                    if (isSelected)
                      const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppColors.crimson),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── FILTER SHEET ──────────────────────────────────────
  void _showFilterSheet() {
    // Local temp state
    _FilterState tempFilters = _filters;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.92,
          minChildSize: 0.5,
          builder: (_, scrollController) =>
              Column(children: [
                // Handle + Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      20, 8, 20, 0),
                  child: Column(children: [
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
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() =>
                            tempFilters =
                                _FilterState());
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(
                                color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                const Divider(color: AppColors.border),
                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                        20, 16, 20, 20),
                    children: [
                      // Age range
                      _FilterSection(
                        title:
                        'Age Range: ${tempFilters.ageRange.start.toInt()} – ${tempFilters.ageRange.end.toInt()} yrs',
                        child: RangeSlider(
                          values: tempFilters.ageRange,
                          min: 18,
                          max: 60,
                          divisions: 42,
                          activeColor: AppColors.crimson,
                          inactiveColor:
                          AppColors.ivoryDark,
                          labels: RangeLabels(
                            '${tempFilters.ageRange.start.toInt()} yrs',
                            '${tempFilters.ageRange.end.toInt()} yrs',
                          ),
                          onChanged: (v) =>
                              setSheetState(() =>
                              tempFilters =
                                  tempFilters.copyWith(
                                      ageRange: v)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Verified only toggle
                      _FilterSection(
                        title: 'Other Filters',
                        child: GestureDetector(
                          onTap: () => setSheetState(() =>
                          tempFilters =
                              tempFilters.copyWith(
                                verifiedOnly: !tempFilters
                                    .verifiedOnly,
                              )),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12),
                            decoration: BoxDecoration(
                              color: tempFilters.verifiedOnly
                                  ? AppColors.successSurface
                                  : AppColors.white,
                              borderRadius:
                              BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                tempFilters.verifiedOnly
                                    ? AppColors.success
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color:
                                tempFilters.verifiedOnly
                                    ? AppColors.success
                                    : AppColors.muted,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Verified Profiles Only',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w500,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Switch(
                                value:
                                tempFilters.verifiedOnly,
                                onChanged: (v) =>
                                    setSheetState(() =>
                                    tempFilters =
                                        tempFilters
                                            .copyWith(
                                            verifiedOnly:
                                            v)),
                                activeColor:
                                AppColors.success,
                              ),
                            ]),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Cities
                      _FilterSection(
                        title: 'City',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Delhi',
                            'Mumbai',
                            'Bangalore',
                            'Hyderabad',
                            'Chennai',
                            'Pune',
                            'Kolkata',
                            'Jaipur',
                          ].map((city) {
                            final selected = tempFilters
                                .cities
                                .contains(city);
                            return GestureDetector(
                              onTap: () {
                                final updated =
                                List<String>.from(
                                    tempFilters.cities);
                                if (selected) {
                                  updated.remove(city);
                                } else {
                                  updated.add(city);
                                }
                                setSheetState(() =>
                                tempFilters =
                                    tempFilters.copyWith(
                                        cities: updated));
                              },
                              child: AnimatedContainer(
                                duration: const Duration(
                                    milliseconds: 150),
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.crimson
                                      : AppColors.white,
                                  borderRadius:
                                  BorderRadius.circular(
                                      100),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.crimson
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w500,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.inkSoft,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Apply button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(context).padding.bottom +
                        12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(
                                () => _filters = tempFilters);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

// ── PRIVATE WIDGETS ───────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded,
              size: 10, color: Colors.white),
          SizedBox(width: 3),
          Text(
            AppStrings.verified,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCountChip extends StatelessWidget {
  final int count;
  const _ResultCountChip({required this.count});

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
            color:
            AppColors.crimson.withOpacity(0.2)),
      ),
      child: Text(
        '$count Results',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.crimson,
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

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
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 13, color: AppColors.gold),
            ),
          ]),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}