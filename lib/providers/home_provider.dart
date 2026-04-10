// lib/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

// ── REPOSITORY PROVIDER ───────────────────────────────────
final profileRepositoryProvider =
Provider<ProfileRepository>(
      (ref) => ProfileRepository(),
);

// ── FILTER MODEL ──────────────────────────────────────────
class ProfileFilter {
  final int minAge;
  final int maxAge;
  final List<String> religions;
  final List<String> castes;
  final List<String> cities;
  final bool verifiedOnly;
  final String sortBy; // 'newest' | 'age_asc' | 'age_desc' | 'verified'

  const ProfileFilter({
    this.minAge = 18,
    this.maxAge = 60,
    this.religions = const [],
    this.castes = const [],
    this.cities = const [],
    this.verifiedOnly = false,
    this.sortBy = 'newest',
  });

  ProfileFilter copyWith({
    int? minAge,
    int? maxAge,
    List<String>? religions,
    List<String>? castes,
    List<String>? cities,
    bool? verifiedOnly,
    String? sortBy,
  }) {
    return ProfileFilter(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      religions: religions ?? this.religions,
      castes: castes ?? this.castes,
      cities: cities ?? this.cities,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      religions.isNotEmpty ||
          castes.isNotEmpty ||
          cities.isNotEmpty ||
          verifiedOnly ||
          minAge != 18 ||
          maxAge != 60;

  ProfileFilter get reset => const ProfileFilter();
}

// ── HOME STATE ────────────────────────────────────────────
class HomeState {
  final List<ProfileModel> todayMatches;
  final List<ProfileModel> recentlyJoined;
  final List<ProfileModel> featuredProfiles;
  final Set<String> sentInterestIds;
  final Set<String> shortlistedIds;
  final bool isLoading;
  final String? error;
  final ProfileFilter filter;

  const HomeState({
    this.todayMatches = const [],
    this.recentlyJoined = const [],
    this.featuredProfiles = const [],
    this.sentInterestIds = const {},
    this.shortlistedIds = const {},
    this.isLoading = false,
    this.error,
    this.filter = const ProfileFilter(),
  });

  HomeState copyWith({
    List<ProfileModel>? todayMatches,
    List<ProfileModel>? recentlyJoined,
    List<ProfileModel>? featuredProfiles,
    Set<String>? sentInterestIds,
    Set<String>? shortlistedIds,
    bool? isLoading,
    String? error,
    ProfileFilter? filter,
  }) {
    return HomeState(
      todayMatches: todayMatches ?? this.todayMatches,
      recentlyJoined:
      recentlyJoined ?? this.recentlyJoined,
      featuredProfiles:
      featuredProfiles ?? this.featuredProfiles,
      sentInterestIds:
      sentInterestIds ?? this.sentInterestIds,
      shortlistedIds:
      shortlistedIds ?? this.shortlistedIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }

  bool isSentInterest(String profileId) =>
      sentInterestIds.contains(profileId);

  bool isShortlisted(String profileId) =>
      shortlistedIds.contains(profileId);
}

// ── HOME NOTIFIER ─────────────────────────────────────────
class HomeNotifier extends StateNotifier<HomeState> {
  final ProfileRepository _profileRepo;
  final String? _userId;

  HomeNotifier(this._profileRepo, this._userId)
      : super(const HomeState()) {
    if (_userId != null) loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Firebase se real data aayega
      // final matches = await _profileRepo.getMatches(
      //   currentProfileId: _currentProfileId,
      //   myProfile: _myProfile,
      // );

      // Abhi mock data use ho raha hai screens mein
      state = state.copyWith(
        isLoading: false,
        todayMatches: [],
        recentlyJoined: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshMatches() async {
    await loadHomeData();
  }

  // ── INTEREST TOGGLE ───────────────────────────────
  void toggleInterest(String profileId) {
    final newSet = Set<String>.from(state.sentInterestIds);
    if (newSet.contains(profileId)) {
      newSet.remove(profileId);
    } else {
      newSet.add(profileId);
      // TODO: InterestRepository.sendInterest() call karo
    }
    state = state.copyWith(sentInterestIds: newSet);
  }

  // ── SHORTLIST TOGGLE ──────────────────────────────
  void toggleShortlist(String profileId) {
    final newSet = Set<String>.from(state.shortlistedIds);
    if (newSet.contains(profileId)) {
      newSet.remove(profileId);
      // TODO: ProfileRepository.removeFromShortlist()
    } else {
      newSet.add(profileId);
      // TODO: ProfileRepository.addToShortlist()
    }
    state = state.copyWith(shortlistedIds: newSet);
  }

  // ── FILTER UPDATE ─────────────────────────────────
  void updateFilter(ProfileFilter filter) {
    state = state.copyWith(filter: filter);
    // TODO: Filter ke hisaab se profiles reload karo
  }

  void clearFilter() {
    state = state.copyWith(filter: const ProfileFilter());
  }
}

// ── HOME PROVIDER ─────────────────────────────────────────
final homeProvider =
StateNotifierProvider<HomeNotifier, HomeState>(
      (ref) {
    final userId = ref.watch(currentUidProvider);
    return HomeNotifier(
      ref.read(profileRepositoryProvider),
      userId,
    );
  },
);

// ── SEARCH STATE ──────────────────────────────────────────
class SearchState {
  final String query;
  final List<ProfileModel> results;
  final bool isSearching;
  final ProfileFilter filter;
  final String sortLabel;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.filter = const ProfileFilter(),
    this.sortLabel = 'Naaye Pehle',
  });

  SearchState copyWith({
    String? query,
    List<ProfileModel>? results,
    bool? isSearching,
    ProfileFilter? filter,
    String? sortLabel,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      filter: filter ?? this.filter,
      sortLabel: sortLabel ?? this.sortLabel,
    );
  }

  bool get hasResults => results.isNotEmpty;
  bool get hasQuery => query.isNotEmpty;
}

// ── SEARCH NOTIFIER ───────────────────────────────────────
class SearchNotifier extends StateNotifier<SearchState> {
  final ProfileRepository _repo;

  SearchNotifier(this._repo) : super(const SearchState());

  Future<void> search(String query) async {
    state = state.copyWith(
      query: query,
      isSearching: query.isNotEmpty,
    );

    if (query.isEmpty) {
      state = state.copyWith(
          results: [], isSearching: false);
      return;
    }

    try {
      // TODO: Firebase se search karo
      // final results = await _repo.searchProfiles(query);
      state = state.copyWith(
        results: [],
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(isSearching: false);
    }
  }

  void updateFilter(ProfileFilter filter) {
    state = state.copyWith(filter: filter);
    // TODO: Filter ke saath re-search karo
    if (state.query.isNotEmpty) search(state.query);
  }

  void updateSort(String sortLabel) {
    state = state.copyWith(sortLabel: sortLabel);
  }

  void clearSearch() {
    state = const SearchState();
  }
}

// ── SEARCH PROVIDER ───────────────────────────────────────
final searchProvider =
StateNotifierProvider<SearchNotifier, SearchState>(
      (ref) => SearchNotifier(
    ref.read(profileRepositoryProvider),
  ),
);

// ── SHORTLISTED PROFILES PROVIDER ────────────────────────
final shortlistedProfilesProvider =
StateProvider<List<ProfileModel>>((ref) => []);

// ── WHO VIEWED PROVIDER ───────────────────────────────────
final whoViewedCountProvider = Provider<int>((ref) => 0);