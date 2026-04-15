// lib/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rishta_app/data/models/profile_model.dart';
import 'package:rishta_app/data/repositories/profile_repository.dart';
import 'package:rishta_app/providers/auth_provider.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// PROFILE FILTER MODEL
// ─────────────────────────────────────────────────────────

class ProfileFilter {
  final int minAge;
  final int maxAge;
  final int? minHeightInches;
  final int? maxHeightInches;
  final List<String> religions;
  final List<String> castes;
  final List<String> cities;
  final String? education;
  final String? income;
  final bool verifiedOnly;
  final bool withPhotoOnly;
  final String sortBy;

  const ProfileFilter({
    this.minAge = 22,
    this.maxAge = 35,
    this.minHeightInches,
    this.maxHeightInches,
    this.religions = const [],
    this.castes = const [],
    this.cities = const [],
    this.education,
    this.income,
    this.verifiedOnly = false,
    this.withPhotoOnly = false,
    this.sortBy = 'Newest First',
  });

  ProfileFilter copyWith({
    int? minAge,
    int? maxAge,
    int? minHeightInches,
    int? maxHeightInches,
    List<String>? religions,
    List<String>? castes,
    List<String>? cities,
    String? education,
    String? income,
    bool? verifiedOnly,
    bool? withPhotoOnly,
    String? sortBy,
    bool clearEducation = false,
    bool clearIncome = false,
  }) {
    return ProfileFilter(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      minHeightInches:
      minHeightInches ?? this.minHeightInches,
      maxHeightInches:
      maxHeightInches ?? this.maxHeightInches,
      religions: religions ?? this.religions,
      castes: castes ?? this.castes,
      cities: cities ?? this.cities,
      education: clearEducation
          ? null
          : education ?? this.education,
      income: clearIncome
          ? null
          : income ?? this.income,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      withPhotoOnly:
      withPhotoOnly ?? this.withPhotoOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  ProfileFilter reset() => const ProfileFilter();

  // ── COMPUTED ──────────────────────────────────────────

  bool get hasActiveFilters =>
      religions.isNotEmpty ||
          castes.isNotEmpty ||
          cities.isNotEmpty ||
          verifiedOnly ||
          withPhotoOnly ||
          education != null ||
          income != null ||
          minAge != 22 ||
          maxAge != 35;

  int get activeFilterCount {
    int count = 0;
    if (religions.isNotEmpty) count++;
    if (castes.isNotEmpty) count++;
    if (cities.isNotEmpty) count++;
    if (verifiedOnly) count++;
    if (withPhotoOnly) count++;
    if (education != null) count++;
    if (income != null) count++;
    if (minAge != 22 || maxAge != 35) count++;
    return count;
  }

  /// Convert to Map for repository
  Map<String, dynamic> toFilterMap() {
    return {
      'minAge': minAge,
      'maxAge': maxAge,
      if (minHeightInches != null)
        'minHeightInches': minHeightInches,
      if (maxHeightInches != null)
        'maxHeightInches': maxHeightInches,
      if (religions.isNotEmpty)
        'religions': religions,
      if (castes.isNotEmpty)
        'castes': castes,
      if (cities.isNotEmpty)
        'cities': cities,
      if (verifiedOnly) 'verifiedOnly': true,
      if (withPhotoOnly) 'withPhotoOnly': true,
    };
  }
}

// ─────────────────────────────────────────────────────────
// HOME STATE
// ─────────────────────────────────────────────────────────

class HomeState {
  final List<ProfileModel> todayMatches;
  final List<ProfileModel> newMembers;
  final List<ProfileModel> featuredProfiles;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastRefreshedAt;

  const HomeState({
    this.todayMatches = const [],
    this.newMembers = const [],
    this.featuredProfiles = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastRefreshedAt,
  });

  HomeState copyWith({
    List<ProfileModel>? todayMatches,
    List<ProfileModel>? newMembers,
    List<ProfileModel>? featuredProfiles,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? lastRefreshedAt,
    bool clearError = false,
  }) {
    return HomeState(
      todayMatches: todayMatches ?? this.todayMatches,
      newMembers: newMembers ?? this.newMembers,
      featuredProfiles:
      featuredProfiles ?? this.featuredProfiles,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing:
      isRefreshing ?? this.isRefreshing,
      error:
      clearError ? null : error ?? this.error,
      lastRefreshedAt:
      lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }

  // ── COMPUTED ──────────────────────────────────────────

  bool get isEmpty =>
      todayMatches.isEmpty && newMembers.isEmpty;

  bool get hasError =>
      error != null && error!.isNotEmpty;

  bool get hasData => todayMatches.isNotEmpty;

  int get totalMatchCount =>
      todayMatches.length + newMembers.length;

  /// Is data stale (older than 30 min)
  bool get isStale {
    if (lastRefreshedAt == null) return true;
    return DateTime.now()
        .difference(lastRefreshedAt!)
        .inMinutes >
        30;
  }
}

// ─────────────────────────────────────────────────────────
// HOME NOTIFIER
// ─────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  final ProfileRepository _repo;
  final String? _uid;
  final String? _profileId;

  HomeNotifier(
      this._repo,
      this._uid,
      this._profileId,
      ) : super(const HomeState()) {
    if (_uid != null) _load();
  }

  // ── LOAD ──────────────────────────────────────────────

  Future<void> _load() async {
    if (_uid == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      // Load today matches + new members in parallel
      final results = await Future.wait([
        _repo.getMatches(
          userId: _uid!,
          myProfileId: _profileId ?? '',
          limit: 10,
          page: 0,
        ),
        _repo.getMatches(
          userId: _uid!,
          myProfileId: _profileId ?? '',
          limit: 8,
          page: 1,
        ),
        _repo.getMatches(
          userId: _uid!,
          myProfileId: _profileId ?? '',
          limit: 5,
          page: 0,
          filters: {'verifiedOnly': true},
        ),
      ]);

      state = state.copyWith(
        todayMatches: results[0],
        newMembers: results[1],
        featuredProfiles: results[2],
        isLoading: false,
        lastRefreshedAt: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load matches.',
      );
    }
  }

  // ── REFRESH ───────────────────────────────────────────

  Future<void> refresh() async {
    if (_uid == null) return;

    state = state.copyWith(isRefreshing: true);

    try {
      final results = await Future.wait([
        _repo.getMatches(
          userId: _uid!,
          myProfileId: _profileId ?? '',
          limit: 10,
          page: 0,
        ),
        _repo.getMatches(
          userId: _uid!,
          myProfileId: _profileId ?? '',
          limit: 8,
          page: 1,
        ),
        _repo.getMatches(
          userId: _uid!,
          myProfileId: _profileId ?? '',
          limit: 5,
          page: 0,
          filters: {'verifiedOnly': true},
        ),
      ]);

      state = state.copyWith(
        todayMatches: results[0],
        newMembers: results[1],
        featuredProfiles: results[2],
        isRefreshing: false,
        lastRefreshedAt: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh.',
      );
    }
  }

  /// Refresh only if data is stale
  Future<void> refreshIfStale() async {
    if (state.isStale) await refresh();
  }

  void clearError() =>
      state = state.copyWith(clearError: true);
}

// ─────────────────────────────────────────────────────────
// HOME PROVIDER
// ─────────────────────────────────────────────────────────

final homeProvider =
StateNotifierProvider<HomeNotifier, HomeState>(
      (ref) {
    final uid = ref.watch(currentUidProvider);
    final profileId = ref
        .watch(currentProfileProvider)
        ?.id;
    return HomeNotifier(
      ref.read(profileRepositoryProvider),
      uid,
      profileId,
    );
  },
);

// ─────────────────────────────────────────────────────────
// SEARCH STATE
// ─────────────────────────────────────────────────────────

class SearchState {
  final List<ProfileModel> results;
  final String query;
  final ProfileFilter filter;
  final bool isLoading;
  final bool isSearching;
  final bool hasMore;
  final int page;
  final String? error;

  const SearchState({
    this.results = const [],
    this.query = '',
    this.filter = const ProfileFilter(),
    this.isLoading = false,
    this.isSearching = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  SearchState copyWith({
    List<ProfileModel>? results,
    String? query,
    ProfileFilter? filter,
    bool? isLoading,
    bool? isSearching,
    bool? hasMore,
    int? page,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      results: results ?? this.results,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error:
      clearError ? null : error ?? this.error,
    );
  }

  // ── COMPUTED ──────────────────────────────────────────

  bool get isEmpty => results.isEmpty;

  bool get hasResults => results.isNotEmpty;

  bool get hasQuery => query.trim().isNotEmpty;

  bool get hasError =>
      error != null && error!.isNotEmpty;

  bool get hasActiveFilters =>
      filter.hasActiveFilters;

  int get resultCount => results.length;
}

// ─────────────────────────────────────────────────────────
// SEARCH NOTIFIER
// ─────────────────────────────────────────────────────────

class SearchNotifier
    extends StateNotifier<SearchState> {
  final ProfileRepository _repo;
  final String? _uid;

  static const int _pageSize = 20;

  SearchNotifier(this._repo, this._uid)
      : super(const SearchState()) {
    // Load initial results
    if (_uid != null) _loadInitial();
  }

  // ── INITIAL LOAD ──────────────────────────────────────

  Future<void> _loadInitial() async {
    if (_uid == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final results = await _repo.getMatches(
        userId: _uid!,
        myProfileId: '',
        limit: _pageSize,
        page: 0,
        filters: state.filter.toFilterMap(),
      );

      state = state.copyWith(
        results: results,
        isLoading: false,
        page: 0,
        hasMore: results.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profiles.',
      );
    }
  }

  // ── SEARCH ────────────────────────────────────────────

  Future<void> search(String query) async {
    if (_uid == null) return;

    state = state.copyWith(
      query: query,
      isSearching: true,
      clearError: true,
    );

    if (query.trim().isEmpty) {
      // Clear search → load normal matches
      await _loadInitial();
      state = state.copyWith(isSearching: false);
      return;
    }

    try {
      final results = await _repo.searchProfiles(
        query: query.trim(),
        userId: _uid!,
        limit: _pageSize,
      );

      state = state.copyWith(
        results: results,
        isSearching: false,
        hasMore: false, // search no pagination
        page: 0,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: 'Search failed. Please try again.',
      );
    }
  }

  // ── CLEAR SEARCH ──────────────────────────────────────

  Future<void> clearSearch() async {
    state = state.copyWith(
      query: '',
      clearError: true,
    );
    await _loadInitial();
  }

  // ── APPLY FILTER ──────────────────────────────────────

  Future<void> applyFilter(
      ProfileFilter filter) async {
    if (_uid == null) return;

    state = state.copyWith(
      filter: filter,
      isLoading: true,
      page: 0,
      clearError: true,
    );

    try {
      final filterMap = filter.toFilterMap();

      final results = state.hasQuery
          ? await _repo.searchProfiles(
        query: state.query,
        userId: _uid!,
        limit: _pageSize,
      )
          : await _repo.getMatches(
        userId: _uid!,
        myProfileId: '',
        limit: _pageSize,
        page: 0,
        filters: filterMap,
      );

      state = state.copyWith(
        results: results,
        isLoading: false,
        hasMore: results.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to apply filters.',
      );
    }
  }

  // ── RESET FILTER ──────────────────────────────────────

  Future<void> resetFilter() async {
    await applyFilter(const ProfileFilter());
  }

  // ── LOAD MORE (PAGINATION) ────────────────────────────

  Future<void> loadMore() async {
    if (_uid == null ||
        !state.hasMore ||
        state.isLoading ||
        state.hasQuery) return;

    final nextPage = state.page + 1;

    try {
      final more = await _repo.getMatches(
        userId: _uid!,
        myProfileId: '',
        limit: _pageSize,
        page: nextPage,
        filters: state.filter.toFilterMap(),
      );

      if (more.isEmpty) {
        state = state.copyWith(hasMore: false);
        return;
      }

      state = state.copyWith(
        results: [...state.results, ...more],
        page: nextPage,
        hasMore: more.length >= _pageSize,
      );
    } catch (_) {}
  }

  // ── SORT ──────────────────────────────────────────────

  void sortBy(String sortOption) {
    final updated =
    state.filter.copyWith(sortBy: sortOption);

    // Sort existing results locally
    final sorted =
    List<ProfileModel>.from(state.results);

    switch (sortOption) {
      case 'Age: Low to High':
        sorted.sort(
                (a, b) => a.age.compareTo(b.age));
        break;
      case 'Age: High to Low':
        sorted.sort(
                (a, b) => b.age.compareTo(a.age));
        break;
      case 'Verified Only':
        sorted.retainWhere((p) => p.isVerified);
        break;
      default:
      // Newest First — sort by createdAt
        sorted.sort((a, b) =>
            b.createdAt.compareTo(a.createdAt));
    }

    state = state.copyWith(
      results: sorted,
      filter: updated,
    );
  }

  void clearError() =>
      state = state.copyWith(clearError: true);

  Future<void> refresh() => _loadInitial();
}

// ─────────────────────────────────────────────────────────
// SEARCH PROVIDER
// ─────────────────────────────────────────────────────────

final searchProvider =
StateNotifierProvider<SearchNotifier,
    SearchState>((ref) {
  final uid = ref.watch(currentUidProvider);
  return SearchNotifier(
    ref.read(profileRepositoryProvider),
    uid,
  );
});

// ─────────────────────────────────────────────────────────
// CONVENIENCE PROVIDERS
// ─────────────────────────────────────────────────────────

/// Home screen loading state
final homeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider).isLoading;
});

/// Home screen refreshing state
final homeRefreshingProvider =
Provider<bool>((ref) {
  return ref.watch(homeProvider).isRefreshing;
});

/// Today's matches for home screen
final todayMatchesProvider =
Provider<List<ProfileModel>>((ref) {
  return ref.watch(homeProvider).todayMatches;
});

/// New member profiles
final newMembersProvider =
Provider<List<ProfileModel>>((ref) {
  return ref.watch(homeProvider).newMembers;
});

/// Featured/premium profiles
final featuredProfilesProvider =
Provider<List<ProfileModel>>((ref) {
  return ref.watch(homeProvider).featuredProfiles;
});

/// Search results
final searchResultsProvider =
Provider<List<ProfileModel>>((ref) {
  return ref.watch(searchProvider).results;
});

/// Search loading state
final searchLoadingProvider =
Provider<bool>((ref) {
  final state = ref.watch(searchProvider);
  return state.isLoading || state.isSearching;
});

/// Active filter count for badge
final activeFilterCountProvider =
Provider<int>((ref) {
  return ref
      .watch(searchProvider)
      .filter
      .activeFilterCount;
});

/// Current search query
final currentSearchQueryProvider =
Provider<String>((ref) {
  return ref.watch(searchProvider).query;
});

/// Has active search filters
final hasActiveFiltersProvider =
Provider<bool>((ref) {
  return ref
      .watch(searchProvider)
      .hasActiveFilters;
});