// lib/presentation/home/search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/providers/home_provider.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/presentation/home/home_screen.dart';

// ─────────────────────────────────────────────────────────
// FILTER STATE
// ─────────────────────────────────────────────────────────

class _FilterState {
  final RangeValues ageRange;
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
    this.religions = const [],
    this.castes = const [],
    this.cities = const [],
    this.education,
    this.income,
    this.verifiedOnly = false,
    this.withPhotoOnly = false,
    this.sortBy = 'Newest First',
  });

  bool get hasActiveFilters =>
      religions.isNotEmpty ||
          castes.isNotEmpty ||
          cities.isNotEmpty ||
          verifiedOnly ||
          withPhotoOnly ||
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
    if (withPhotoOnly) count++;
    if (education != null) count++;
    if (income != null) count++;
    if (ageRange.start != 22 ||
        ageRange.end != 35) count++;
    return count;
  }

  _FilterState reset() => const _FilterState();
}

// ─────────────────────────────────────────────────────────
// SEARCH SCREEN
// ─────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  String _query = '';
  _FilterState _filters = const _FilterState();
  bool _isSearching = false;

  // View mode — grid or list
  bool _isGridView = true;

  // Sort options
  final List<String> _sortOptions = [
    'Newest First',
    'Age: Low to High',
    'Age: High to Low',
    'Verified Only',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(
              () => _isSearching =
              _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── FILTER / SEARCH ───────────────────────────────────

  List<MockProfile> get _results {
    var list = List<MockProfile>.from(
        mockProfiles);

    // Query filter
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) =>
      p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.caste.toLowerCase().contains(q) ||
          p.profession
              .toLowerCase()
              .contains(q)).toList();
    }

    // Caste filter
    if (_filters.castes.isNotEmpty) {
      list = list.where((p) =>
          _filters.castes
              .contains(p.caste)).toList();
    }

    // City filter
    if (_filters.cities.isNotEmpty) {
      list = list.where((p) =>
          _filters.cities
              .contains(p.city)).toList();
    }

    // Age filter
    list = list.where((p) =>
    p.age >= _filters.ageRange.start.toInt() &&
        p.age <= _filters.ageRange.end.toInt())
        .toList();

    // Verified only
    if (_filters.verifiedOnly) {
      list = list
          .where((p) => p.isVerified)
          .toList();
    }

    // Sort
    switch (_filters.sortBy) {
      case 'Age: Low to High':
        list.sort(
                (a, b) => a.age.compareTo(b.age));
        break;
      case 'Age: High to Low':
        list.sort(
                (a, b) => b.age.compareTo(a.age));
        break;
      default:
        break;
    }

    return list;
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
    _searchFocus.unfocus();
  }

  void _resetFilters() {
    setState(() => _filters =
    const _FilterState());
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        current: _filters,
        onApply: (f) =>
            setState(() => _filters = f),
        onReset: _resetFilters,
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        current: _filters.sortBy,
        options: _sortOptions,
        onSelect: (s) => setState(() =>
        _filters = _FilterState(
          ageRange: _filters.ageRange,
          religions: _filters.religions,
          castes: _filters.castes,
          cities: _filters.cities,
          education: _filters.education,
          income: _filters.income,
          verifiedOnly: _filters.verifiedOnly,
          withPhotoOnly:
          _filters.withPhotoOnly,
          sortBy: s,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          if (_filters.hasActiveFilters)
            _buildActiveFilterChips(),
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

  Widget _buildHeader() {
    final topPad =
        MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(
          20, topPad + 10, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search',  // lib/core/constants/app_strings.dart mein add karein
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
                    color: Colors.white
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // View toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() =>
              _isGridView = !_isGridView);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.15),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  _isGridView
                      ? Icons.view_list_rounded
                      : Icons
                      .grid_view_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.15),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.sort_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.crimson,
      padding:
      const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white
                      .withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText:
                'Search by name, city, caste...',
                hintStyle: TextStyle(
                    color: Colors.white
                        .withOpacity(0.6),
                    fontSize: 13),
                prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Colors.white
                        .withOpacity(0.7)),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                  onTap: _clearSearch,
                  child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white
                          .withOpacity(
                          0.7)),
                )
                    : null,
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(
                    vertical: 12),
              ),
              onChanged: (v) =>
                  setState(() => _query = v),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Filter button
        GestureDetector(
          onTap: _showFilterSheet,
          child: AnimatedContainer(
            duration: const Duration(
                milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _filters.hasActiveFilters
                  ? AppColors.gold
                  : Colors.white
                  .withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white
                      .withOpacity(0.3)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                if (_filters.activeFilterCount >
                    0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white,
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '${_filters.activeFilterCount}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w800,
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
      ]),
    );
  }

  // ── ACTIVE FILTER CHIPS ───────────────────────────────

  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_filters.ageRange.start != 22 ||
        _filters.ageRange.end != 35) {
      chips.add(_FilterChip(
        label:
        '${_filters.ageRange.start.toInt()}'
            '–${_filters.ageRange.end.toInt()} yrs',
        onRemove: () => setState(() =>
        _filters = _FilterState(
          religions: _filters.religions,
          castes: _filters.castes,
          cities: _filters.cities,
          education: _filters.education,
          income: _filters.income,
          verifiedOnly: _filters.verifiedOnly,
          withPhotoOnly: _filters.withPhotoOnly,
          sortBy: _filters.sortBy,
        )),
      ));
    }
    for (final r in _filters.religions) {
      chips.add(_FilterChip(
        label: r,
        onRemove: () {
          final updated =
          List<String>.from(_filters.religions)
            ..remove(r);
          setState(() => _filters = _FilterState(
            ageRange: _filters.ageRange,
            religions: updated,
            castes: _filters.castes,
            cities: _filters.cities,
            education: _filters.education,
            income: _filters.income,
            verifiedOnly: _filters.verifiedOnly,
            withPhotoOnly:
            _filters.withPhotoOnly,
            sortBy: _filters.sortBy,
          ));
        },
      ));
    }
    if (_filters.verifiedOnly) {
      chips.add(_FilterChip(
        label: '✓ Verified',
        onRemove: () => setState(() =>
        _filters = _FilterState(
          ageRange: _filters.ageRange,
          religions: _filters.religions,
          castes: _filters.castes,
          cities: _filters.cities,
          education: _filters.education,
          income: _filters.income,
          verifiedOnly: false,
          withPhotoOnly: _filters.withPhotoOnly,
          sortBy: _filters.sortBy,
        )),
      ));
    }

    if (chips.isEmpty) return const SizedBox();

    return Container(
      color: AppColors.ivory,
      padding: const EdgeInsets.fromLTRB(
          12, 10, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: [
          ...chips,
          // Clear all
          GestureDetector(
            onTap: _resetFilters,
            child: Container(
              margin:
              const EdgeInsets.only(left: 4),
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6),
              child: Text(
                'Clear all',
                style: AppTextStyles.bodySmall
                    .copyWith(
                  color: AppColors.crimson,
                  fontWeight: FontWeight.w600,
                  decoration:
                  TextDecoration.underline,
                  decorationColor:
                  AppColors.crimson,
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
      padding:
      const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium,
              children: [
                TextSpan(
                  text: '$count',
                  style: AppTextStyles
                      .labelLarge
                      .copyWith(
                      color:
                      AppColors.crimson),
                ),
                TextSpan(
                  text: ' profile${count != 1 ? 's' : ''} found',
                ),
              ],
            ),
          ),
          // Sort chip
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                BorderRadius.circular(100),
                border: Border.all(
                    color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                      Icons.sort_rounded,
                      size: 13,
                      color: AppColors.muted),
                  const SizedBox(width: 5),
                  Text(
                    _filters.sortBy,
                    style: AppTextStyles
                        .labelSmall,
                  ),
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
      padding: const EdgeInsets.fromLTRB(
          12, 8, 12, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) =>
          _buildGridCard(results[i]),
    );
  }

  Widget _buildGridCard(MockProfile p) {
    return GestureDetector(
      onTap: () =>
          context.push('/profile/${p.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                    top: Radius.circular(13)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color:
                      AppColors.crimsonSurface,
                      child: Center(
                        child: Text(p.emoji,
                            style: const TextStyle(
                                fontSize: 52)),
                      ),
                    ),
                    if (p.isVerified)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            AppColors.success,
                            borderRadius:
                            BorderRadius
                                .circular(
                                100),
                          ),
                          child: const Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              Icon(
                                  Icons
                                      .verified_rounded,
                                  size: 9,
                                  color: Colors
                                      .white),
                              SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                  color:
                                  Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                  10, 8, 10, 10),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.name.split(' ').first},'
                        ' ${p.age}',
                    style: AppTextStyles
                        .profileNameSmall,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.profession,
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                        color:
                        AppColors.inkSoft),
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
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
                        style:
                        AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
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
      padding: const EdgeInsets.fromLTRB(
          16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (_, i) =>
          _buildListCard(results[i]),
    );
  }

  Widget _buildListCard(MockProfile p) {
    return GestureDetector(
      onTap: () =>
          context.push('/profile/${p.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: AppColors.border),
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
              border: Border.all(
                  color: AppColors.border),
            ),
            child: Center(
              child: Text(p.emoji,
                  style: const TextStyle(
                      fontSize: 30)),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      '${p.name}, ${p.age}',
                      style: AppTextStyles
                          .profileNameMedium,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
                  if (p.isVerified)
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                          horizontal: 6,
                          vertical: 2),
                      decoration: BoxDecoration(
                        color:
                        AppColors.successSurface,
                        borderRadius:
                        BorderRadius.circular(
                            100),
                      ),
                      child: const Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Icon(
                              Icons
                                  .verified_rounded,
                              size: 10,
                              color: AppColors
                                  .success),
                          SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight:
                              FontWeight.w600,
                              color:
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(
                      Icons.work_outline_rounded,
                      size: 12,
                      color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.profession,
                      style: AppTextStyles
                          .bodySmall
                          .copyWith(
                          color:
                          AppColors.inkSoft),
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${p.city} • ${p.caste}',
                      style:
                      AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                _InterestBtn(
                    profile: p, compact: true),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// INTEREST BUTTON
// ─────────────────────────────────────────────────────────

class _InterestBtn extends ConsumerWidget {
  final MockProfile profile;
  final bool compact;

  const _InterestBtn({
    required this.profile,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentIds =
    ref.watch(sentInterestIdsProvider);
    final isSent = sentIds.contains(profile.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (!isSent) {
          ref
              .read(interestsProvider.notifier)
              .sendInterest(
            receiverId: profile.id,
            receiverProfileId: profile.id,
          );
        }
      },
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 5 : 8,
        ),
        decoration: BoxDecoration(
          color: isSent
              ? AppColors.crimson
              : AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(8),
          border: isSent
              ? null
              : Border.all(
              color: AppColors.crimson
                  .withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isSent
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: compact ? 12 : 14,
              color: isSent
                  ? Colors.white
                  : AppColors.crimson,
            ),
            SizedBox(width: compact ? 3 : 5),
            Text(
              isSent ? 'Sent ✓' : 'Send Interest',
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: isSent
                    ? Colors.white
                    : AppColors.crimson,
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

  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            color:
            AppColors.crimson.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.crimson),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: AppColors.crimson,
            ),
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

  const _FilterSheet({
    required this.current,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterSheet> createState() =>
      _FilterSheetState();
}

class _FilterSheetState
    extends State<_FilterSheet> {
  late _FilterState _local;

  @override
  void initState() {
    super.initState();
    _local = widget.current;
  }

  void _toggleReligion(String r) {
    final updated =
    List<String>.from(_local.religions);
    if (updated.contains(r)) {
      updated.remove(r);
    } else {
      updated.add(r);
    }
    setState(() => _local = _FilterState(
      ageRange: _local.ageRange,
      religions: updated,
      castes: _local.castes,
      cities: _local.cities,
      education: _local.education,
      income: _local.income,
      verifiedOnly: _local.verifiedOnly,
      withPhotoOnly: _local.withPhotoOnly,
      sortBy: _local.sortBy,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad =
        MediaQuery.of(context).padding.bottom;
    return Container(
      height:
      MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(
                  top: 10, bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                20, 8, 20, 12),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters',
                    style: AppTextStyles.h4),
                GestureDetector(
                  onTap: () {
                    setState(() =>
                    _local =
                    const _FilterState());
                    widget.onReset();
                  },
                  child: Text(
                    'Reset all',
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
              height: 1, color: AppColors.border),
          // Filters
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  20, 16, 20, 16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // Age range
                  _buildAgeFilter(),
                  const SizedBox(height: 24),
                  // Religion
                  _buildReligionFilter(),
                  const SizedBox(height: 24),
                  // Options
                  _buildOptionsFilter(),
                ],
              ),
            ),
          ),
          // Apply button
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, bottomPad + 16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(
                    color: AppColors.border),
              ),
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
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text('Age Range',
                style: AppTextStyles.labelLarge),
            Text(
              '${_local.ageRange.start.toInt()}'
                  ' – '
                  '${_local.ageRange.end.toInt()} yrs',
              style: AppTextStyles.labelMedium
                  .copyWith(
                  color: AppColors.crimson),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.crimson,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.crimson,
            overlayColor:
            AppColors.crimson.withOpacity(0.1),
            rangeThumbShape:
            const RoundRangeSliderThumbShape(
                enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: _local.ageRange,
            min: 18,
            max: 60,
            divisions: 42,
            onChanged: (v) => setState(
                  () => _local = _FilterState(
                ageRange: v,
                religions: _local.religions,
                castes: _local.castes,
                cities: _local.cities,
                education: _local.education,
                income: _local.income,
                verifiedOnly: _local.verifiedOnly,
                withPhotoOnly: _local.withPhotoOnly,
                sortBy: _local.sortBy,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReligionFilter() {
    const religions = [
      'Hindu', 'Muslim', 'Christian',
      'Sikh', 'Jain', 'Buddhist',
      'Parsi', 'Other',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Religion',
            style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: religions.map((r) {
            final isSelected =
            _local.religions.contains(r);
            return GestureDetector(
              onTap: () => _toggleReligion(r),
              child: AnimatedContainer(
                duration: const Duration(
                    milliseconds: 150),
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.crimson
                      : AppColors.white,
                  borderRadius:
                  BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.crimson
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppColors.inkSoft,
                  ),
                ),
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
        Text('More Options',
            style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        _ToggleTile(
          title: 'Verified profiles only',
          subtitle: 'Show only ID verified users',
          icon: Icons.verified_rounded,
          iconColor: AppColors.success,
          value: _local.verifiedOnly,
          onChanged: (v) =>
              setState(() => _local = _FilterState(
                ageRange: _local.ageRange,
                religions: _local.religions,
                castes: _local.castes,
                cities: _local.cities,
                education: _local.education,
                income: _local.income,
                verifiedOnly: v,
                withPhotoOnly:
                _local.withPhotoOnly,
                sortBy: _local.sortBy,
              )),
        ),
        const SizedBox(height: 8),
        _ToggleTile(
          title: 'With photos only',
          subtitle: 'Show only profiles with photos',
          icon: Icons.photo_camera_outlined,
          iconColor: AppColors.crimson,
          value: _local.withPhotoOnly,
          onChanged: (v) =>
              setState(() => _local = _FilterState(
                ageRange: _local.ageRange,
                religions: _local.religions,
                castes: _local.castes,
                cities: _local.cities,
                education: _local.education,
                income: _local.income,
                verifiedOnly: _local.verifiedOnly,
                withPhotoOnly: v,
                sortBy: _local.sortBy,
              )),
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

  const _SortSheet({
    required this.current,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad =
        MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0, 8, 0, bottomPad + 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin:
              const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                20, 0, 20, 12),
            child: Text('Sort By',
                style: AppTextStyles.h4),
          ),
          const Divider(
              height: 1, color: AppColors.border),
          ...options.map((opt) {
            final isSelected = opt == current;
            return GestureDetector(
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 20,
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
                      color: AppColors.crimson,
                    ),
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
        color: value
            ? AppColors.crimsonSurface
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.crimson.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value
                ? iconColor.withOpacity(0.15)
                : AppColors.ivoryDark,
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon,
                size: 18, color: iconColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.labelMedium
                      .copyWith(
                    color: value
                        ? AppColors.crimson
                        : AppColors.ink,
                  )),
              Text(subtitle,
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.crimson,
        ),
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
              decoration: BoxDecoration(
                color: AppColors.crimsonSurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(
                        fontSize: 38)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(
                  color: AppColors.muted,
                  height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.crimson,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          12)),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}