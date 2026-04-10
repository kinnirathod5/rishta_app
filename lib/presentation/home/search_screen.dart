import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import 'home_screen.dart' show MockProfile, mockProfiles;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ── STATE ─────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isFocused = false;
  List<MockProfile> _filteredProfiles = [];
  final Set<String> _sentInterests = {};
  final Set<String> _shortlisted = {};
  String _sortLabel = 'Naaye Pehle';

  RangeValues _ageRange = const RangeValues(22, 35);
  final Set<String> _selectedReligions = {};
  final Set<String> _selectedCities = {};
  final Set<String> _selectedEducation = {};
  bool _verifiedOnly = false;
  bool _withPhotoOnly = false;

  bool get _hasActiveFilters =>
      _selectedReligions.isNotEmpty ||
      _selectedCities.isNotEmpty ||
      _selectedEducation.isNotEmpty ||
      _verifiedOnly ||
      _withPhotoOnly ||
      _ageRange.start != 22 ||
      _ageRange.end != 35;

  // ── INIT / DISPOSE ────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _filteredProfiles = List.from(mockProfiles);
    _searchFocusNode.addListener(() {
      setState(() => _isFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── FILTER LOGIC ──────────────────────────────────────
  List<MockProfile> _applyFiltersTemp() {
    List<MockProfile> results = List.from(mockProfiles);

    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      results = results
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.city.toLowerCase().contains(q) ||
              p.profession.toLowerCase().contains(q) ||
              p.caste.toLowerCase().contains(q))
          .toList();
    }

    results = results
        .where((p) =>
            p.age >= _ageRange.start.round() &&
            p.age <= _ageRange.end.round())
        .toList();

    if (_selectedReligions.isNotEmpty) {
      results = results
          .where((p) => _selectedReligions.contains(p.religion))
          .toList();
    }

    if (_selectedCities.isNotEmpty) {
      results =
          results.where((p) => _selectedCities.contains(p.city)).toList();
    }

    if (_selectedEducation.isNotEmpty) {
      results = results
          .where((p) => _selectedEducation.any(
              (edu) => p.education.toLowerCase().contains(edu.toLowerCase())))
          .toList();
    }

    if (_verifiedOnly) {
      results = results.where((p) => p.isVerified).toList();
    }

    if (_sortLabel == 'Umar: Kam se Zyada') {
      results.sort((a, b) => a.age.compareTo(b.age));
    } else if (_sortLabel == 'Umar: Zyada se Kam') {
      results.sort((a, b) => b.age.compareTo(a.age));
    } else if (_sortLabel == 'Verified Pehle') {
      results.sort(
          (a, b) => (b.isVerified ? 1 : 0) - (a.isVerified ? 1 : 0));
    }

    return results;
  }

  void _applyFilters() =>
      setState(() => _filteredProfiles = _applyFiltersTemp());

  int _getFilteredCount() => _applyFiltersTemp().length;

  void _onSearchChanged(String _) => _applyFilters();

  void _clearSearch() {
    _searchController.clear();
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedReligions.clear();
      _selectedCities.clear();
      _selectedEducation.clear();
      _verifiedOnly = false;
      _withPhotoOnly = false;
      _ageRange = const RangeValues(22, 35);
      _sortLabel = 'Naaye Pehle';
    });
    _applyFilters();
  }

  void _toggleFilter(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
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

  // ── BUILD ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildFilterChipsRow(),
            _buildResultsCountBar(),
            Expanded(
              child: _filteredProfiles.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: _filteredProfiles.length,
                      itemBuilder: (context, index) =>
                          _buildSearchResultCard(
                              _filteredProfiles[index], index),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SEARCH HEADER ─────────────────────────────────────
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new,
                    size: 16, color: AppColors.ink),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Search field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _isFocused ? AppColors.crimson : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded,
                      size: 20,
                      color: _isFocused
                          ? AppColors.crimson
                          : AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.ink),
                      decoration: const InputDecoration(
                        hintText: 'Naam, city, profession...',
                        hintStyle: TextStyle(
                            color: AppColors.disabled, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.muted),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Filter button
          GestureDetector(
            onTap: _showFilterSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _hasActiveFilters
                        ? AppColors.crimson
                        : AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(Icons.tune_rounded,
                        size: 20,
                        color: _hasActiveFilters
                            ? AppColors.white
                            : AppColors.ink),
                  ),
                ),
                if (_hasActiveFilters)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.goldLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER CHIPS ROW ──────────────────────────────────
  Widget _buildFilterChipsRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in _selectedReligions)
              _buildActiveFilterChip(r, () {
                _toggleFilter(_selectedReligions, r);
                _applyFilters();
              }),
            for (final c in _selectedCities)
              _buildActiveFilterChip(c, () {
                _toggleFilter(_selectedCities, c);
                _applyFilters();
              }),
            for (final e in _selectedEducation)
              _buildActiveFilterChip(e, () {
                _toggleFilter(_selectedEducation, e);
                _applyFilters();
              }),
            if (_verifiedOnly)
              _buildActiveFilterChip('Verified', () {
                setState(() => _verifiedOnly = false);
                _applyFilters();
              }),
            if (_ageRange.start != 22 || _ageRange.end != 35)
              _buildActiveFilterChip(
                '${_ageRange.start.round()}-${_ageRange.end.round()} saal',
                () {
                  setState(
                      () => _ageRange = const RangeValues(22, 35));
                  _applyFilters();
                },
              ),
            // Add filter chip
            GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(100),
                  border:
                      Border.all(color: AppColors.border, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 14, color: AppColors.muted),
                    SizedBox(width: 4),
                    Text('Filter Add Karo',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            if (_hasActiveFilters)
              GestureDetector(
                onTap: _clearAllFilters,
                child: const Text(
                  'Sab Hatao',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.crimson,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.crimson,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            color: AppColors.crimson.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.crimson)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.crimson.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close_rounded,
                    size: 10, color: AppColors.crimson),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── RESULTS COUNT BAR ─────────────────────────────────
  Widget _buildResultsCountBar() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_filteredProfiles.length}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.crimson),
                ),
                const TextSpan(
                  text: ' profiles mile',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(100),
                border:
                    Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Text(_sortLabel,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                          fontWeight: FontWeight.w500)),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH RESULT CARD ────────────────────────────────
  Widget _buildSearchResultCard(MockProfile profile, int index) {
    final bool interested = _sentInterests.contains(profile.id);
    final bool bookmarked = _shortlisted.contains(profile.id);

    return GestureDetector(
      onTap: () => context.push('/profile/${profile.id}', extra: profile),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Container(
                width: 80,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(profile.emoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                    if (profile.isVerified)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.verified_rounded,
                                size: 11, color: AppColors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Premium badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${profile.name}, ${profile.age}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius:
                                  BorderRadius.circular(100),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('👑',
                                    style: TextStyle(fontSize: 9)),
                                SizedBox(width: 3),
                                Text('PREMIUM',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Religion + Caste pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.crimsonSurface,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${profile.religion} \u2022 ${profile.caste}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.crimson,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Info chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                            Icons.location_on_outlined, profile.city),
                        _buildInfoChip(Icons.work_outline_rounded,
                            profile.profession),
                        _buildInfoChip(
                            Icons.height_rounded, profile.height),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Action buttons
                    Row(
                      children: [
                        // Interest
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleInterest(profile.id),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              decoration: BoxDecoration(
                                color: interested
                                    ? AppColors.crimson
                                    : AppColors.crimsonSurface,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      interested
                                          ? Icons.favorite_rounded
                                          : Icons
                                              .favorite_border_rounded,
                                      size: 14,
                                      color: interested
                                          ? AppColors.white
                                          : AppColors.crimson,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      interested
                                          ? 'Interest Bheja \u2713'
                                          : '\u2764\ufe0f Interest Bhejo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: interested
                                            ? AppColors.white
                                            : AppColors.crimson,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Shortlist
                        GestureDetector(
                          onTap: () => _toggleShortlist(profile.id),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: bookmarked
                                  ? AppColors.goldSurface
                                  : AppColors.ivoryDark,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                bookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 18,
                                color: bookmarked
                                    ? AppColors.gold
                                    : AppColors.muted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Chat
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.infoSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                                color: AppColors.info),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.muted),
        const SizedBox(width: 3),
        Text(text,
            style:
                const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍',
                style: TextStyle(fontSize: 56),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text('Koi profile nahi mila',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
            const SizedBox(height: 8),
            const Text('Filters hatao ya\nalag search try karo',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.muted, height: 1.5)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _clearAllFilters,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.crimson),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: const Text('Filters Reset Karo',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── FILTER SHEET ──────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            void sheetToggle(Set<String> set, String val) {
              setSheet(() {
                if (set.contains(val)) {
                  set.remove(val);
                } else {
                  set.add(val);
                }
              });
            }

            Widget chip(
                String label, Set<String> set, VoidCallback onTap) {
              final sel = set.contains(label);
              return GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        sel ? AppColors.crimson : AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: sel
                          ? AppColors.crimson
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: sel
                              ? AppColors.white
                              : AppColors.inkSoft)),
                ),
              );
            }

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
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filters',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink)),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setSheet(() {
                                  _selectedReligions.clear();
                                  _selectedCities.clear();
                                  _selectedEducation.clear();
                                  _verifiedOnly = false;
                                  _withPhotoOnly = false;
                                  _ageRange = const RangeValues(
                                      22, 35);
                                });
                              },
                              child: const Text('Reset',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.crimson)),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.ivoryDark,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Center(
                                    child: Icon(Icons.close,
                                        size: 16,
                                        color: AppColors.ink)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                      height: 1, color: AppColors.border),

                  // Scrollable filters
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Age
                          const Text('Umar (Age)',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                          const SizedBox(height: 8),
                          RangeSlider(
                            values: _ageRange,
                            min: 18,
                            max: 60,
                            divisions: 42,
                            activeColor: AppColors.crimson,
                            inactiveColor: AppColors.ivoryDark,
                            labels: RangeLabels(
                              '${_ageRange.start.round()} saal',
                              '${_ageRange.end.round()} saal',
                            ),
                            onChanged: (val) => setSheet(
                                () => _ageRange = val),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${_ageRange.start.round()} saal',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted)),
                              Text(
                                  '${_ageRange.end.round()} saal',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Religion
                          const Text('Dharm',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final r in [
                                'Hindu', 'Muslim', 'Sikh',
                                'Christian', 'Jain', 'Other'
                              ])
                                chip(
                                    r,
                                    _selectedReligions,
                                    () => sheetToggle(
                                        _selectedReligions, r)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // City
                          const Text('Sheher',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in [
                                'Delhi', 'Mumbai', 'Bangalore',
                                'Hyderabad', 'Chennai', 'Pune',
                                'Jaipur', 'Chandigarh', 'Lucknow',
                                'Ahmedabad', 'Kochi', 'Other'
                              ])
                                chip(
                                    c,
                                    _selectedCities,
                                    () => sheetToggle(
                                        _selectedCities, c)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Education
                          const Text('Shiksha',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final e in [
                                'Graduate', 'Post Graduate',
                                'Doctorate', '12th Pass'
                              ])
                                chip(
                                    e,
                                    _selectedEducation,
                                    () => sheetToggle(
                                        _selectedEducation, e)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Verified only
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Sirf Verified Profiles',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink)),
                                  Text('ID verified members only',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.muted)),
                                ],
                              ),
                              Switch(
                                value: _verifiedOnly,
                                activeThumbColor: AppColors.crimson,
                                onChanged: (val) => setSheet(
                                    () => _verifiedOnly = val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // With photo
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Photo Wale Hi Dikhao',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink)),
                              Switch(
                                value: _withPhotoOnly,
                                activeThumbColor: AppColors.crimson,
                                onChanged: (val) => setSheet(
                                    () => _withPhotoOnly = val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // Apply button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: AppColors.border, width: 1)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crimson,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        child: Text(
                          '${_getFilteredCount()} Profiles Dekhein',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── SORT SHEET ────────────────────────────────────────
  void _showSortSheet() {
    const options = [
      'Naaye Pehle',
      'Umar: Kam se Zyada',
      'Umar: Zyada se Kam',
      'Verified Pehle',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Sort Karein',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink)),
              const SizedBox(height: 16),
              for (final option in options)
                GestureDetector(
                  onTap: () {
                    setState(() => _sortLabel = option);
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: _sortLabel == option
                          ? AppColors.crimsonSurface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: _sortLabel == option
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _sortLabel == option
                                    ? AppColors.crimson
                                    : AppColors.ink)),
                        if (_sortLabel == option)
                          const Icon(Icons.check_rounded,
                              size: 18, color: AppColors.crimson),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
