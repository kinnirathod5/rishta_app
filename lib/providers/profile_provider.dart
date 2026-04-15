// lib/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/profile_model.dart';
import '../data/models/subscription_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/subscription_repository.dart';
import 'auth_provider.dart';

// ─────────────────────────────────────────────────────────
// REPOSITORY PROVIDERS
// ─────────────────────────────────────────────────────────

final profileRepositoryProvider =
Provider<ProfileRepository>(
      (ref) => ProfileRepository(),
);

final subscriptionRepositoryProvider =
Provider<SubscriptionRepository>(
      (ref) => SubscriptionRepository(),
);

// ─────────────────────────────────────────────────────────
// MY PROFILE STATE
// ─────────────────────────────────────────────────────────

class MyProfileState {
  final ProfileModel? profile;
  final SubscriptionModel? subscription;
  final bool isLoading;
  final bool isSaving;
  final Set<String> shortlistedIds;
  final Set<String> blockedUserIds;
  final String? error;
  final String? successMessage;

  const MyProfileState({
    this.profile,
    this.subscription,
    this.isLoading = false,
    this.isSaving = false,
    this.shortlistedIds = const {},
    this.blockedUserIds = const {},
    this.error,
    this.successMessage,
  });

  MyProfileState copyWith({
    ProfileModel? profile,
    SubscriptionModel? subscription,
    bool? isLoading,
    bool? isSaving,
    Set<String>? shortlistedIds,
    Set<String>? blockedUserIds,
    String? error,
    String? successMessage,
  }) {
    return MyProfileState(
      profile: profile ?? this.profile,
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      shortlistedIds:
      shortlistedIds ?? this.shortlistedIds,
      blockedUserIds:
      blockedUserIds ?? this.blockedUserIds,
      // Explicitly pass null to clear messages
      error: error,
      successMessage: successMessage,
    );
  }

  // ── COMPUTED PROPERTIES ───────────────────────────

  bool get hasProfile => profile != null;

  bool get isPremium => subscription?.isActive ?? false;

  String get displayName =>
      profile?.fullName ?? 'Your Name';

  String get profileCity =>
      profile?.currentCity ?? '';

  // Profile completeness score (0–100)
  int get profileScore {
    if (profile == null) return 0;
    int score = 0;

    // Basic Info — 20 pts
    if (profile!.fullName.isNotEmpty) score += 5;
    if (profile!.currentCity.isNotEmpty) score += 5;
    if (profile!.about.isNotEmpty) score += 5;
    if (profile!.heightInInches > 0) score += 5;

    // Religion — 15 pts
    if (profile!.religion.isNotEmpty) score += 8;
    if (profile!.caste.isNotEmpty) score += 7;

    // Education — 15 pts
    if (profile!.qualification.isNotEmpty) score += 8;
    if (profile!.annualIncome.isNotEmpty) score += 7;

    // Family — 15 pts
    if (profile!.fatherOccupation != null) score += 8;
    if (profile!.motherOccupation != null) score += 7;

    // Photos — 20 pts
    final photoCount = profile!.photoUrls.length;
    if (photoCount >= 1) score += 10;
    if (photoCount >= 3) score += 5;
    if (photoCount >= 5) score += 5;

    // Horoscope — 15 pts
    if (profile!.rashi != null) score += 5;
    if (profile!.nakshatra != null) score += 5;
    if (profile!.kundaliUrl != null) score += 5;

    return score.clamp(0, 100);
  }

  // Sections that still need to be completed
  List<_IncompleteSection> get incompleteSections {
    final sections = <_IncompleteSection>[];
    if (profile == null) return sections;

    if (profile!.kundaliUrl == null) {
      sections.add(const _IncompleteSection(
        emoji: '⭐',
        label: 'Add Horoscope',
        scoreGain: '+15%',
        route: '/horoscope',
      ));
    }
    if (profile!.photoUrls.length < 3) {
      sections.add(const _IncompleteSection(
        emoji: '📸',
        label: 'Add more photos',
        scoreGain: '+7%',
        route: '/setup/step5',
      ));
    }
    if (!profile!.isVerified) {
      sections.add(const _IncompleteSection(
        emoji: '🔐',
        label: 'Verify ID',
        scoreGain: '+10%',
        route: '/id-verification',
      ));
    }
    if (profile!.about.isEmpty) {
      sections.add(const _IncompleteSection(
        emoji: '✍️',
        label: 'Write about yourself',
        scoreGain: '+5%',
        route: '/setup/step1',
      ));
    }
    return sections;
  }

  bool isShortlisted(String profileId) =>
      shortlistedIds.contains(profileId);

  bool isBlocked(String userId) =>
      blockedUserIds.contains(userId);

  bool get hasError => error != null;
  bool get hasSuccess => successMessage != null;
}

// ── INCOMPLETE SECTION MODEL ──────────────────────────────

class _IncompleteSection {
  final String emoji;
  final String label;
  final String scoreGain;
  final String route;

  const _IncompleteSection({
    required this.emoji,
    required this.label,
    required this.scoreGain,
    required this.route,
  });
}

// ─────────────────────────────────────────────────────────
// MY PROFILE NOTIFIER
// ─────────────────────────────────────────────────────────

class MyProfileNotifier
    extends StateNotifier<MyProfileState> {
  final ProfileRepository _profileRepo;
  final SubscriptionRepository _subRepo;
  final String? _userId;

  MyProfileNotifier(
      this._profileRepo,
      this._subRepo,
      this._userId,
      ) : super(const MyProfileState()) {
    if (_userId != null) _init();
  }

  // ── INIT ──────────────────────────────────────────
  Future<void> _init() async {
    await loadProfile();
  }

  // ── LOAD PROFILE ──────────────────────────────────
  Future<void> loadProfile() async {
    if (_userId == null) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      successMessage: null,
    );

    try {
      final results = await Future.wait([
        _profileRepo.getProfileByUserId(_userId!),
        _subRepo.getActiveSubscription(_userId!),
      ]);

      final profile = results[0] as ProfileModel?;
      final subscription =
      results[1] as SubscriptionModel?;

      // Load shortlisted + blocked in parallel
      final extras = await Future.wait([
        _profileRepo
            .getShortlistedIds(profile?.id ?? ''),
        _profileRepo.getBlockedUserIds(_userId!),
      ]);

      final shortlisted = extras[0] as List<String>;
      final blocked = extras[1] as List<String>;

      state = state.copyWith(
        profile: profile,
        subscription: subscription,
        shortlistedIds: shortlisted.toSet(),
        blockedUserIds: blocked.toSet(),
        isLoading: false,
        error: null,
        successMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _friendlyError(e),
        successMessage: null,
      );
    }
  }

  // ── UPDATE PROFILE ────────────────────────────────
  Future<bool> updateProfile(
      Map<String, dynamic> data) async {
    if (state.profile == null) return false;

    state = state.copyWith(
      isSaving: true,
      error: null,
      successMessage: null,
    );

    try {
      await _profileRepo.updateProfile(
          state.profile!.id, data);

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Profile updated successfully ✓',
        error: null,
      );

      // Reload in background
      await loadProfile();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _friendlyError(e),
        successMessage: null,
      );
      return false;
    }
  }

  // ── UPLOAD PHOTO ──────────────────────────────────
  Future<bool> uploadPhoto(String localPath) async {
    if (_userId == null || state.profile == null) {
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      error: null,
      successMessage: null,
    );

    try {
      final url = await _profileRepo.uploadPhoto(
          _userId!, localPath);

      final newPhotos = [
        ...state.profile!.photoUrls,
        url,
      ];

      await _profileRepo.updateProfile(
          state.profile!.id, {
        'photoUrls': newPhotos,
        if (state.profile!.mainPhotoUrl == null)
          'mainPhotoUrl': url,
      });

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Photo uploaded successfully ✓',
        error: null,
      );

      await loadProfile();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _friendlyError(e),
        successMessage: null,
      );
      return false;
    }
  }

  // ── DELETE PHOTO ──────────────────────────────────
  Future<bool> deletePhoto(String photoUrl) async {
    if (state.profile == null) return false;

    state = state.copyWith(isSaving: true);

    try {
      final updated = state.profile!.photoUrls
          .where((url) => url != photoUrl)
          .toList();

      await _profileRepo.updateProfile(
          state.profile!.id, {
        'photoUrls': updated,
        if (state.profile!.mainPhotoUrl == photoUrl)
          'mainPhotoUrl':
          updated.isNotEmpty ? updated.first : null,
      });

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Photo deleted ✓',
        error: null,
      );

      await loadProfile();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _friendlyError(e),
        successMessage: null,
      );
      return false;
    }
  }

  // ── SHORTLIST TOGGLE ──────────────────────────────
  Future<void> toggleShortlist(
      String targetProfileId) async {
    final myProfileId = state.profile?.id ?? '';
    final newSet =
    Set<String>.from(state.shortlistedIds);

    // Optimistic update
    if (newSet.contains(targetProfileId)) {
      newSet.remove(targetProfileId);
    } else {
      newSet.add(targetProfileId);
    }
    state = state.copyWith(shortlistedIds: newSet);

    // Sync with repo
    try {
      if (!newSet.contains(targetProfileId)) {
        await _profileRepo.removeFromShortlist(
            myProfileId, targetProfileId);
      } else {
        await _profileRepo.addToShortlist(
            myProfileId, targetProfileId);
      }
    } catch (e) {
      // Revert on failure
      final reverted =
      Set<String>.from(state.shortlistedIds);
      if (reverted.contains(targetProfileId)) {
        reverted.remove(targetProfileId);
      } else {
        reverted.add(targetProfileId);
      }
      state = state.copyWith(
        shortlistedIds: reverted,
        error: _friendlyError(e),
        successMessage: null,
      );
    }
  }

  // ── BLOCK USER ────────────────────────────────────
  Future<bool> blockUser(String targetUserId) async {
    if (_userId == null) return false;

    try {
      await _profileRepo.blockUser(
          _userId!, targetUserId);
      final newSet =
      Set<String>.from(state.blockedUserIds)
        ..add(targetUserId);
      state = state.copyWith(
        blockedUserIds: newSet,
        successMessage: 'User blocked',
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: _friendlyError(e),
        successMessage: null,
      );
      return false;
    }
  }

  // ── UNBLOCK USER ──────────────────────────────────
  Future<bool> unblockUser(
      String targetUserId) async {
    if (_userId == null) return false;

    try {
      await _profileRepo.unblockUser(
          _userId!, targetUserId);
      final newSet =
      Set<String>.from(state.blockedUserIds)
        ..remove(targetUserId);
      state = state.copyWith(
        blockedUserIds: newSet,
        successMessage: 'User unblocked ✓',
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: _friendlyError(e),
        successMessage: null,
      );
      return false;
    }
  }

  // ── REPORT USER ───────────────────────────────────
  Future<bool> reportUser({
    required String targetUserId,
    required String reason,
  }) async {
    if (_userId == null) return false;

    try {
      await _profileRepo.reportUser(
        reporterUserId: _userId!,
        targetUserId: targetUserId,
        reason: reason,
      );
      state = state.copyWith(
        successMessage:
        'Report submitted successfully ✓',
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: _friendlyError(e),
        successMessage: null,
      );
      return false;
    }
  }

  // ── SET MAIN PHOTO ────────────────────────────────
  Future<void> setMainPhoto(String photoUrl) async {
    if (state.profile == null) return;

    try {
      await _profileRepo.updateProfile(
          state.profile!.id,
          {'mainPhotoUrl': photoUrl});
      await loadProfile();
    } catch (e) {
      state = state.copyWith(
        error: _friendlyError(e),
        successMessage: null,
      );
    }
  }

  // ── CLEAR MESSAGES ────────────────────────────────
  void clearError() {
    state = state.copyWith(
        error: null, successMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(
        successMessage: null, error: null);
  }

  // ── REFRESH ───────────────────────────────────────
  Future<void> refresh() => loadProfile();

  // ── HELPER ────────────────────────────────────────
  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('network') ||
        msg.contains('socket')) {
      return 'No internet connection. Please try again.';
    }
    if (msg.contains('permission')) {
      return 'You do not have permission for this action.';
    }
    return 'Something went wrong. Please try again.';
  }
}

// ─────────────────────────────────────────────────────────
// MY PROFILE PROVIDER
// ─────────────────────────────────────────────────────────

final myProfileProvider = StateNotifierProvider<
    MyProfileNotifier, MyProfileState>(
      (ref) {
    final userId = ref.watch(currentUidProvider);
    return MyProfileNotifier(
      ref.read(profileRepositoryProvider),
      ref.read(subscriptionRepositoryProvider),
      userId,
    );
  },
);

// ─────────────────────────────────────────────────────────
// OTHER PROFILE STATE
// ─────────────────────────────────────────────────────────

class OtherProfileState {
  final Map<String, ProfileModel> cache;
  final Set<String> loadingIds;
  final Map<String, String> errors;

  const OtherProfileState({
    this.cache = const {},
    this.loadingIds = const {},
    this.errors = const {},
  });

  OtherProfileState copyWith({
    Map<String, ProfileModel>? cache,
    Set<String>? loadingIds,
    Map<String, String>? errors,
  }) {
    return OtherProfileState(
      cache: cache ?? this.cache,
      loadingIds: loadingIds ?? this.loadingIds,
      errors: errors ?? this.errors,
    );
  }

  ProfileModel? getProfile(String profileId) =>
      cache[profileId];

  bool isLoading(String profileId) =>
      loadingIds.contains(profileId);

  bool hasError(String profileId) =>
      errors.containsKey(profileId);
}

// ─────────────────────────────────────────────────────────
// OTHER PROFILE NOTIFIER
// ─────────────────────────────────────────────────────────

class OtherProfileNotifier
    extends StateNotifier<OtherProfileState> {
  final ProfileRepository _repo;

  OtherProfileNotifier(this._repo)
      : super(const OtherProfileState());

  Future<ProfileModel?> getProfile(
      String profileId) async {
    // Return from cache if available
    if (state.cache.containsKey(profileId)) {
      return state.cache[profileId];
    }

    // Mark as loading
    state = state.copyWith(
      loadingIds: {
        ...state.loadingIds,
        profileId
      },
    );

    try {
      final profile =
      await _repo.getProfile(profileId);

      if (profile != null) {
        final newCache =
        Map<String, ProfileModel>.from(state.cache)
          ..[profileId] = profile;
        final newLoading =
        Set<String>.from(state.loadingIds)
          ..remove(profileId);
        final newErrors =
        Map<String, String>.from(state.errors)
          ..remove(profileId);

        state = state.copyWith(
          cache: newCache,
          loadingIds: newLoading,
          errors: newErrors,
        );
      }

      return profile;
    } catch (e) {
      final newLoading =
      Set<String>.from(state.loadingIds)
        ..remove(profileId);
      final newErrors =
      Map<String, String>.from(state.errors)
        ..[profileId] = e.toString();

      state = state.copyWith(
        loadingIds: newLoading,
        errors: newErrors,
      );
      return null;
    }
  }

  void removeFromCache(String profileId) {
    final newCache =
    Map<String, ProfileModel>.from(state.cache)
      ..remove(profileId);
    state = state.copyWith(cache: newCache);
  }

  void clearCache() {
    state = const OtherProfileState();
  }
}

// ─────────────────────────────────────────────────────────
// OTHER PROFILE PROVIDER
// ─────────────────────────────────────────────────────────

final otherProfileProvider = StateNotifierProvider<
    OtherProfileNotifier, OtherProfileState>(
      (ref) => OtherProfileNotifier(
    ref.read(profileRepositoryProvider),
  ),
);

// ─────────────────────────────────────────────────────────
// CONVENIENCE PROVIDERS
// ─────────────────────────────────────────────────────────

/// Current logged-in user's profile
final currentProfileProvider =
Provider<ProfileModel?>((ref) {
  return ref.watch(myProfileProvider).profile;
});

/// Profile completeness score (0–100)
final profileScoreProvider = Provider<int>((ref) {
  return ref.watch(myProfileProvider).profileScore;
});

/// Is user on an active premium plan
final isPremiumActiveProvider = Provider<bool>((ref) {
  return ref.watch(myProfileProvider).isPremium;
});

/// IDs of profiles shortlisted by current user
final shortlistedIdsProvider =
Provider<Set<String>>((ref) {
  return ref.watch(myProfileProvider).shortlistedIds;
});

/// IDs of users blocked by current user
final blockedUserIdsProvider =
Provider<Set<String>>((ref) {
  return ref.watch(myProfileProvider).blockedUserIds;
});

/// Whether current user's profile is fully loaded
final hasProfileProvider = Provider<bool>((ref) {
  return ref.watch(myProfileProvider).hasProfile;
});

/// Incomplete sections list for profile score hints
final incompleteSectionsProvider =
Provider<List<_IncompleteSection>>((ref) {
  return ref
      .watch(myProfileProvider)
      .incompleteSections;
});

/// Active subscription model
final activeSubscriptionProvider =
Provider<SubscriptionModel?>((ref) {
  return ref.watch(myProfileProvider).subscription;
});