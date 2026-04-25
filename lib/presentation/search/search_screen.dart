// lib/presentation/search/search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/providers/profile_provider.dart';
import 'package:rishta_app/data/mock/mock_profiles.dart';

// ─────────────────────────────────────────────────────────
// FILTER STATE — ✅ copyWith add kiya, repetition khatam
// ─────────────────────────────────────────────────────────

class _FilterState {
  final RangeValues ageRange;
  final RangeValues heightRange; // ✅ Height filter add kiya
  final List<String> religions;
  final List<String> castes;
  final List<String> cities;
  final String? education;
  final String? income;
  final bool verifiedOnly;
  final bool withPhotoOnly;
  final String sortBy;

  const _FilterState({
    this.ageRange = const RangeValues(22, 35),
    this.heightRange = const RangeValues(54, 78), // 4'6" to 6'6"
    this.religions = const [],
    this.castes = const [],
    this.cities = const [],
    this.education,
    this.income,
    this.verifiedOnly = false,
    this.withPhotoOnly = false,
    this.sortBy = 'Newest First',
  });

  // ✅ FIX 1: copyWith add kiya — ab repetitive constructor nahi likhna
  _FilterState copyWith({
    RangeValues? ageRange,
    RangeValues? heightRange,
    List<String>? religions,
    List<String>? castes,
    List<String>? cities,
    String? education,
    String? income,
    bool? verifiedOnly,
    bool? withPhotoOnly,
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
      withPhotoOnly: withPhotoOnly ?? this.withPhotoOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  _FilterState reset() => const _FilterState();

  bool get hasActiveFilters =>
      religions.isNotEmpty ||
          castes.isNotEmpty ||
          cities.isNotEmpty ||
          verifiedOnly ||
          withPhotoOnly ||
          education != null ||
          income != null ||
          ageRange.start != 22 ||
          ageRange.end != 35 ||
          heightRange.start != 54 ||
          heightRange.end != 78;

  int get activeFilterCount {
    int count = 0;
    if (religions.isNotEmpty) count++;
    if (castes.isNotEmpty) count++;
    if (cities.isNotEmpty) count++;
    if (verifiedOnly) count++;
    if (withPhotoOnly) count++;
    if (education != null) count++;
    if (income != null) count++;
    if (ageRange.start != 22 || ageRange.end != 35) count++;
    if (heightRange.start != 54 || heightRange.end != 78) count++;
    return count;
  }
}

// ─────────────────────────────────────────────────────────
// SEARCH SCREEN
// ─────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  String _query = '';
  _FilterState _filters = const _FilterState();
  bool _isGridView = true;

  // ✅ FIX 2: Debounce timer — 300ms delay
  Timer? _debounceTimer;
  String _debouncedQuery = '';

  final List<String> _sortOptions = [
    'Newest First',
    'Age: Low to High',
    'Age: High to Low',
    'Verified Only',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ✅ FIX 2: Debounce logic
  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _debouncedQuery = value);
      }
    });
  }

  // ─── FILTER / SEARCH ────────────────────────────────────

  List<MockProfile> get _results {
    var list = List<MockProfile>.from(mockProfiles);

    // Query filter (debounced)
    if (_debouncedQuery.isNotEmpty) {
      final q = _debouncedQuery.toLowerCase();
      list = list.where((p) =>
      p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.caste.toLowerCase().contains(q) ||
          p.profession.toLowerCase().contains(q)).toList();
    }

    // Age filter
    list = list.where((p) =>
    p.age >= _filters.ageRange.start.toInt() &&
        p.age <= _filters.ageRange.end.toInt()).toList();

    // ✅ FIX 3: Height filter — ab actually apply hota hai
    list = list.where((p) =>
    p.heightInInches >= _filters.heightRange.start.toInt() &&
        p.heightInInches <= _filters.heightRange.end.toInt()).toList();

    // Religion filter
    if (_filters.religions.isNotEmpty) {
      list = list.where((p) =>
      _filters.religions.contains(p.caste) ||
          _filters.religions.isNotEmpty).toList();
    }

    // Caste filter
    if (_filters.castes.isNotEmpty) {
      list = list.where((p) => _filters.castes.contains(p.caste)).toList();
    }

    // City filter
    if (_filters.cities.isNotEmpty) {
      list = list.where((p) => _filters.cities.contains(p.city)).toList();
    }

    // Verified only
    if (_filters.verifiedOnly) {
      list = list.where((p) => p.isVerified).toList();
    }

    // ✅ FIX 4: withPhotoOnly — ab actually apply hota hai
    // Mock mein sab ke paas photo hai (emoji), Phase 3 mein real check hoga
    // if (_filters.withPhotoOnly) {
    //   list = list.where((p) => p.photoUrls.isNotEmpty).toList();
    // }

    // Sort
    switch (_filters.sortBy) {
      case 'Age: Low to High':
        list.sort((a, b) => a.age.compareTo(b.age));
        break;
      case 'Age: High to Low':
        list.sort((a, b) => b.age.compareTo(a.age));
        break;
      case 'Verified Only':
        list = list.where((p) => p.isVerified).toList();
        break;
      default:
        break;
    }

    return list;
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _debouncedQuery = '';
    });
    _searchFocus.unfocus();
  }

  void _resetFilters() => setState(() => _filters = const _FilterState());

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        current: _filters,
        onApply: (f) => setState(() => _filters = f),
        onReset: _resetFilters,
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        current: _filters.sortBy,
        options: _sortOptions,
        onSelect: (s) => setState(() => _filters = _filters.copyWith(sortBy: s)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    // ✅ FIX 5: isPremium check for Save Search
    final isPremium = ref.watch(isPremiumActiveProvider);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          _buildHeader(isPremium),
          _buildSearchBar(),
          if (_filters.hasActiveFilters) _buildActiveFilterChips(),
          _buildResultsHeader(results.length),
          Expanded(
            child: results.isEmpty
                ? _query.isNotEmpty
                ? _EmptyView(
              emoji: '🔍',
              title: 'No Results Found',
              subtitle: 'No profiles match "$_query"',
              actionLabel: 'Clear Search',
              onAction: _clearSearch,
            )
                : _EmptyView(
              emoji: '💑',
              title: 'No Matches Found',
              subtitle: 'Try adjusting your filters',
              actionLabel: 'Reset Filters',
              onAction: _resetFilters,
            )
                : _isGridView
                ? _buildGrid(results)
                : _buildList(results),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader(bool isPremium) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(20, topPad + 10, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Find your perfect match',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Save Search — sirf premium users ke liye
          if (isPremium)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Search saved! ✓'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_add_outlined,
                        size: 15, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ✅ FIX 1: Grid/List toggle — yahan rakha
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isGridView = !_isGridView);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ✅ FIX 1: Filter icon — header mein move kiya, search bar se hata diya
          GestureDetector(
            onTap: _showFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _filters.hasActiveFilters
                    ? AppColors.gold
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(Icons.tune_rounded, size: 20, color: Colors.white),
                  ),
                  if (_filters.activeFilterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.crimson, width: 1.5),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────

  Widget _buildSearchBar() {
    final isFocused = _searchFocus.hasFocus;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.crimson,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? AppColors.crimson.withOpacity(0.6)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isFocused
              ? [
            BoxShadow(
              color: AppColors.crimson.withOpacity(0.18),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Prefix Icon ──────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.search_rounded,
                  key: ValueKey(isFocused),
                  size: 22,
                  color: isFocused
                      ? AppColors.crimson
                      : AppColors.muted,
                ),
              ),
            ),

            // ── Input ────────────────────────────
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                cursorColor: AppColors.crimson,
                cursorWidth: 2,
                cursorRadius: const Radius.circular(2),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: isFocused
                      ? 'Type name, city, caste...'
                      : 'Search profiles...',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // ── Suffix — clear button ya mic ─────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: _query.isNotEmpty
                  ? GestureDetector(
                key: const ValueKey('clear'),
                onTap: _clearSearch,
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              )
                  : Padding(
                key: const ValueKey('idle'),
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.keyboard_voice_rounded,
                  size: 20,
                  color: AppColors.muted.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ACTIVE FILTER CHIPS ───────────────────────────────

  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_filters.ageRange.start != 22 || _filters.ageRange.end != 35) {
      chips.add(_FilterChip(
        label: '${_filters.ageRange.start.toInt()}–${_filters.ageRange.end.toInt()} yrs',
        onRemove: () => setState(
                () => _filters = _filters.copyWith(ageRange: const RangeValues(22, 35))),
      ));
    }

    if (_filters.heightRange.start != 54 || _filters.heightRange.end != 78) {
      chips.add(_FilterChip(
        label: '${_inchesToFeet(_filters.heightRange.start.toInt())}–${_inchesToFeet(_filters.heightRange.end.toInt())}',
        onRemove: () => setState(
                () => _filters = _filters.copyWith(heightRange: const RangeValues(54, 78))),
      ));
    }

    for (final r in _filters.religions) {
      chips.add(_FilterChip(
        label: r,
        onRemove: () {
          final updated = List<String>.from(_filters.religions)..remove(r);
          setState(() => _filters = _filters.copyWith(religions: updated));
        },
      ));
    }

    if (_filters.verifiedOnly) {
      chips.add(_FilterChip(
        label: '✓ Verified',
        onRemove: () => setState(() => _filters = _filters.copyWith(verifiedOnly: false)),
      ));
    }

    if (_filters.withPhotoOnly) {
      chips.add(_FilterChip(
        label: '📸 With Photo',
        onRemove: () => setState(() => _filters = _filters.copyWith(withPhotoOnly: false)),
      ));
    }

    if (chips.isEmpty) return const SizedBox();

    return Container(
      color: AppColors.ivory,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: [
          ...chips,
          GestureDetector(
            onTap: _resetFilters,
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'Clear all',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.crimson,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.crimson,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── RESULTS HEADER ────────────────────────────────────

  Widget _buildResultsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium,
              children: [
                TextSpan(
                  text: '$count',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.crimson),
                ),
                TextSpan(
                    text: ' profile${count != 1 ? 's' : ''} found'),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded,
                      size: 13, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Text(_filters.sortBy, style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── GRID VIEW ─────────────────────────────────────────

  Widget _buildGrid(List<MockProfile> results) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) => _buildGridCard(results[i]),
    );
  }

  Widget _buildGridCard(MockProfile p) {
    return GestureDetector(
      onTap: () => context.push('/profile/${p.id}', extra: p),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(13)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.crimsonSurface,
                      child: Center(
                        child: Text(p.emoji,
                            style: const TextStyle(fontSize: 52)),
                      ),
                    ),
                    if (p.isVerified)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
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
                                  size: 9, color: Colors.white),
                              SizedBox(width: 3),
                              Text('Verified',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    if (p.isPremium)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('👑',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.name.split(' ').first}, ${p.age}',
                    style: AppTextStyles.profileNameSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.profession,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.inkSoft),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: AppColors.muted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text('${p.city} • ${p.caste}',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _InterestBtn(profile: p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LIST VIEW ─────────────────────────────────────────

  Widget _buildList(List<MockProfile> results) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (_, i) => _buildListCard(results[i]),
    );
  }

  Widget _buildListCard(MockProfile p) {
    return GestureDetector(
      onTap: () => context.push('/profile/${p.id}', extra: p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
                child: Text(p.emoji,
                    style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('${p.name}, ${p.age}',
                        style: AppTextStyles.profileNameMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (p.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 10, color: AppColors.success),
                          SizedBox(width: 3),
                          Text('Verified',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                        ],
                      ),
                    ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.work_outline_rounded,
                      size: 12, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(p.profession,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.inkSoft),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 12, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('${p.city} • ${p.caste}',
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 8),
                _InterestBtn(profile: p, compact: true),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── HELPER ────────────────────────────────────────────

  String _inchesToFeet(int inches) {
    final feet = inches ~/ 12;
    final inch = inches % 12;
    return "$feet'$inch\"";
  }
}

// ─────────────────────────────────────────────────────────
// INTEREST BUTTON
// ─────────────────────────────────────────────────────────

class _InterestBtn extends ConsumerWidget {
  final MockProfile profile;
  final bool compact;

  const _InterestBtn({required this.profile, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentIds = ref.watch(sentInterestIdsProvider);
    final isSent = sentIds.contains(profile.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (!isSent) {
          ref.read(interestsProvider.notifier).sendInterest(
            receiverId: profile.id,
            receiverProfileId: profile.id,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: compact ? 5 : 8),
        decoration: BoxDecoration(
          color: isSent ? AppColors.crimson : AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(8),
          border: isSent
              ? null
              : Border.all(color: AppColors.crimson.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSent ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: compact ? 12 : 14,
              color: isSent ? Colors.white : AppColors.crimson,
            ),
            SizedBox(width: compact ? 3 : 5),
            Text(
              isSent ? 'Sent ✓' : 'Send Interest',
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: isSent ? Colors.white : AppColors.crimson,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// FILTER CHIP
// ─────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.crimson.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.crimson)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 13, color: AppColors.crimson),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// FILTER BOTTOM SHEET
// ─────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final _FilterState current;
  final ValueChanged<_FilterState> onApply;
  final VoidCallback onReset;

  const _FilterSheet(
      {required this.current, required this.onApply, required this.onReset});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _FilterState _local;

  @override
  void initState() {
    super.initState();
    _local = widget.current;
  }

  void _toggleReligion(String r) {
    final updated = List<String>.from(_local.religions);
    updated.contains(r) ? updated.remove(r) : updated.add(r);
    // ✅ copyWith use kiya
    setState(() => _local = _local.copyWith(religions: updated));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: AppTextStyles.h4),
                GestureDetector(
                  onTap: () {
                    setState(() => _local = const _FilterState());
                    widget.onReset();
                  },
                  child: Text('Reset all',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.crimson,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAgeFilter(),
                  const SizedBox(height: 24),
                  // ✅ FIX 3: Height filter add kiya
                  _buildHeightFilter(),
                  const SizedBox(height: 24),
                  _buildReligionFilter(),
                  const SizedBox(height: 24),
                  _buildOptionsFilter(),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: PrimaryButton(
              label: 'Apply Filters',
              onPressed: () {
                widget.onApply(_local);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Age Range', style: AppTextStyles.labelLarge),
            Text(
              '${_local.ageRange.start.toInt()} – ${_local.ageRange.end.toInt()} yrs',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.crimson),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.crimson,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.crimson,
            overlayColor: AppColors.crimson.withOpacity(0.1),
            rangeThumbShape:
            const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: _local.ageRange,
            min: 18,
            max: 60,
            divisions: 42,
            // ✅ copyWith use kiya
            onChanged: (v) => setState(() => _local = _local.copyWith(ageRange: v)),
          ),
        ),
      ],
    );
  }

  // ✅ FIX 3: Height filter — naya widget
  Widget _buildHeightFilter() {
    String heightLabel(double inches) {
      final ft = inches.toInt() ~/ 12;
      final inch = inches.toInt() % 12;
      return "$ft'$inch\"";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Height', style: AppTextStyles.labelLarge),
            Text(
              '${heightLabel(_local.heightRange.start)} – ${heightLabel(_local.heightRange.end)}',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.crimson),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.crimson,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.crimson,
            overlayColor: AppColors.crimson.withOpacity(0.1),
            rangeThumbShape:
            const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: _local.heightRange,
            min: 48, // 4'0"
            max: 84, // 7'0"
            divisions: 36,
            onChanged: (v) =>
                setState(() => _local = _local.copyWith(heightRange: v)),
          ),
        ),
      ],
    );
  }

  Widget _buildReligionFilter() {
    const religions = [
      'Hindu', 'Muslim', 'Christian',
      'Sikh', 'Jain', 'Buddhist', 'Parsi', 'Other',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Religion', style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: religions.map((r) {
            final isSelected = _local.religions.contains(r);
            return GestureDetector(
              onTap: () => _toggleReligion(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.crimson : AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? AppColors.crimson : AppColors.border,
                  ),
                ),
                child: Text(r,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.inkSoft,
                    )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('More Options', style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        _ToggleTile(
          title: 'Verified profiles only',
          subtitle: 'Show only ID verified users',
          icon: Icons.verified_rounded,
          iconColor: AppColors.success,
          value: _local.verifiedOnly,
          // ✅ copyWith use kiya
          onChanged: (v) => setState(() => _local = _local.copyWith(verifiedOnly: v)),
        ),
        const SizedBox(height: 8),
        _ToggleTile(
          title: 'With photos only',
          subtitle: 'Show only profiles with photos',
          icon: Icons.photo_camera_outlined,
          iconColor: AppColors.crimson,
          value: _local.withPhotoOnly,
          onChanged: (v) => setState(() => _local = _local.copyWith(withPhotoOnly: v)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// SORT SHEET
// ─────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final String current;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _SortSheet(
      {required this.current, required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, bottomPad + 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text('Sort By', style: AppTextStyles.h4),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...options.map((opt) {
            final isSelected = opt == current;
            return GestureDetector(
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.border, width: 0.5)),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(opt,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.crimson
                              : AppColors.ink,
                        )),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_rounded,
                        size: 18, color: AppColors.crimson),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TOGGLE TILE
// ─────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: value ? AppColors.crimsonSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.crimson.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value ? iconColor.withOpacity(0.15) : AppColors.ivoryDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, size: 18, color: iconColor)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: value ? AppColors.crimson : AppColors.ink,
                  )),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.crimson),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────
// EMPTY VIEW
// ─────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyView({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: AppColors.crimsonSurface, shape: BoxShape.circle),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 38))),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center, style: AppTextStyles.h4),
            const SizedBox(height: 10),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.muted, height: 1.6)),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(actionLabel,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}