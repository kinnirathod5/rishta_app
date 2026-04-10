// lib/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/profile_model.dart';
import '../data/models/subscription_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/subscription_repository.dart';
import 'auth_provider.dart';

// ── REPOSITORY PROVIDERS ──────────────────────────────────
final subscriptionRepositoryProvider =
Provider<SubscriptionRepository>(
      (ref) => SubscriptionRepository(),
);

// ── MY PROFILE STATE ──────────────────────────────────────
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
      error: error,
      successMessage: successMessage,
    );
  }

  // ── COMPUTED ──────────────────────────────────────
  bool get hasProfile => profile != null;
  bool get isPremium => subscription?.isActive ?? false;

  int get profileScore {
    if (profile == null) return 0;
    int score = 0;

    // Basic info (20%)
    if (profile!.fullName.isNotEmpty) score += 5;
    if (profile!.currentCity.isNotEmpty) score += 5;
    if (profile!.about.isNotEmpty) score += 5;
    if (profile!.heightInInches > 0) score += 5;

    // Religion (15%)
    if (profile!.religion.isNotEmpty) score += 8;
    if (profile!.caste.isNotEmpty) score += 7;

    // Education (15%)
    if (profile!.qualification.isNotEmpty) score += 8;
    if (profile!.annualIncome.isNotEmpty) score += 7;

    // Family (15%)
    if (profile!.fatherOccupation != null) score += 8;
    if (profile!.motherOccupation != null) score += 7;

    // Photos (20%)
    final photoCount = profile!.photoUrls.length;
    if (photoCount >= 1) score += 10;
    if (photoCount >= 3) score += 5;
    if (photoCount >= 5) score += 5;

    // Horoscope (15%)
    if (profile!.rashi != null) score += 5;
    if (profile!.nakshatra != null) score += 5;
    if (profile!.kundaliUrl != null) score += 5;

    return score.clamp(0, 100);
  }

  List<Map<String, String>> get incompleteSections {
    final sections = <Map<String, String>>[];
    if (profile == null) return sections;

    if (profile!.kundaliUrl == null) {
      sections.add({
        'label': '🏠 Horoscope add karo',
        'score': '+15%',
        'route': '/horoscope',
      });
    }
    if (profile!.photoUrls.length < 3) {
      sections.add({
        'label': '📸 Aur photos add karo',
        'score': '+7%',
        'route': '/setup/step5',
      });
    }
    if (!profile!.isVerified) {
      sections.add({
        'label': '🔐 ID Verify karo',
        'score': '+10%',
        'route': '/id-verification',
      });
    }
    return sections;
  }

  bool isShortlisted(String profileId) =>
      shortlistedIds.contains(profileId);

  bool isBlocked(String userId) =>
      blockedUserIds.contains(userId);
}

// ── MY PROFILE NOTIFIER ───────────────────────────────────
class MyProfileNotifier extends StateNotifier<MyProfileState> {
  final ProfileRepository _profileRepo;
  final SubscriptionRepository _subRepo;
  final String? _userId;

  MyProfileNotifier(
      this._profileRepo,
      this._subRepo,
      this._userId,
      ) : super(const MyProfileState()) {
    if (_userId != null) loadProfile();
  }

  // ── LOAD PROFILE ──────────────────────────────────
  Future<void> loadProfile() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile =
      await _profileRepo.getProfileByUserId(_userId!);
      final subscription =
      await _subRepo.getActiveSubscription(_userId!);
      final shortlistedIds =
      await _profileRepo.getShortlistedIds(
          profile?.id ?? '');
      final blockedIds =
      await _profileRepo.getBlockedUserIds(_userId!);

      state = state.copyWith(
        profile: profile,
        subscription: subscription,
        shortlistedIds: shortlistedIds.toSet(),
        blockedUserIds: blockedIds.toSet(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ── UPDATE PROFILE ────────────────────────────────
  Future<bool> updateProfile(
      Map<String, dynamic> data) async {
    if (state.profile == null) return false;
    state = state.copyWith(isSaving: true, error: null);

    try {
      await _profileRepo.updateProfile(
          state.profile!.id, data);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Profile update ho gayi ✓',
      );
      await loadProfile();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // ── UPLOAD PHOTO ──────────────────────────────────
  Future<bool> uploadPhoto(String localPath) async {
    if (_userId == null || state.profile == null) {
      return false;
    }

    state = state.copyWith(isSaving: true);

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
        successMessage: 'Photo upload ho gayi ✓',
      );
      await loadProfile();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // ── SHORTLIST TOGGLE ──────────────────────────────
  Future<void> toggleShortlist(
      String targetProfileId) async {
    final myProfileId = state.profile?.id ?? '';
    final newSet = Set<String>.from(state.shortlistedIds);

    if (newSet.contains(targetProfileId)) {
      newSet.remove(targetProfileId);
      await _profileRepo.removeFromShortlist(
          myProfileId, targetProfileId);
    } else {
      newSet.add(targetProfileId);
      await _profileRepo.addToShortlist(
          myProfileId, targetProfileId);
    }

    state = state.copyWith(shortlistedIds: newSet);
  }

  // ── BLOCK USER ────────────────────────────────────
  Future<void> blockUser(String targetUserId) async {
    if (_userId == null) return;
    await _profileRepo.blockUser(_userId!, targetUserId);
    final newSet = Set<String>.from(state.blockedUserIds);
    newSet.add(targetUserId);
    state = state.copyWith(blockedUserIds: newSet);
  }

  // ── UNBLOCK USER ──────────────────────────────────
  Future<void> unblockUser(String targetUserId) async {
    if (_userId == null) return;
    await _profileRepo.unblockUser(
        _userId!, targetUserId);
    final newSet = Set<String>.from(state.blockedUserIds);
    newSet.remove(targetUserId);
    state = state.copyWith(blockedUserIds: newSet);
  }

  // ── REPORT USER ───────────────────────────────────
  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  }) async {
    if (_userId == null) return;
    await _profileRepo.reportUser(
      reporterUserId: _userId!,
      targetUserId: targetUserId,
      reason: reason,
    );
    state = state.copyWith(
        successMessage: 'Report submit ho gayi ✓');
  }

  // ── CLEAR MESSAGES ────────────────────────────────
  void clearMessages() {
    state = state.copyWith(
      error: null,
      successMessage: null,
    );
  }

  // ── REFRESH ───────────────────────────────────────
  Future<void> refresh() async {
    await loadProfile();
  }
}

// ── MY PROFILE PROVIDER ───────────────────────────────────
final myProfileProvider =
StateNotifierProvider<MyProfileNotifier, MyProfileState>(
      (ref) {
    final userId = ref.watch(currentUidProvider);
    return MyProfileNotifier(
      ref.read(profileRepositoryProvider),
      ref.read(subscriptionRepositoryProvider),
      userId,
    );
  },
);

// ── OTHER PROFILE STATE ───────────────────────────────────
class OtherProfileState {
  final Map<String, ProfileModel> cache;
  final Set<String> loadingIds;

  const OtherProfileState({
    this.cache = const {},
    this.loadingIds = const {},
  });

  OtherProfileState copyWith({
    Map<String, ProfileModel>? cache,
    Set<String>? loadingIds,
  }) {
    return OtherProfileState(
      cache: cache ?? this.cache,
      loadingIds: loadingIds ?? this.loadingIds,
    );
  }

  ProfileModel? getProfile(String profileId) =>
      cache[profileId];

  bool isLoading(String profileId) =>
      loadingIds.contains(profileId);
}

// ── OTHER PROFILE NOTIFIER ────────────────────────────────
class OtherProfileNotifier
    extends StateNotifier<OtherProfileState> {
  final ProfileRepository _repo;

  OtherProfileNotifier(this._repo)
      : super(const OtherProfileState());

  Future<ProfileModel?> getProfile(
      String profileId) async {
    // Cache check
    if (state.cache.containsKey(profileId)) {
      return state.cache[profileId];
    }

    // Loading set mein daalo
    final newLoading =
    Set<String>.from(state.loadingIds);
    newLoading.add(profileId);
    state = state.copyWith(loadingIds: newLoading);

    try {
      final profile =
      await _repo.getProfile(profileId);

      if (profile != null) {
        final newCache =
        Map<String, ProfileModel>.from(state.cache);
        newCache[profileId] = profile;

        final updatedLoading =
        Set<String>.from(state.loadingIds);
        updatedLoading.remove(profileId);

        state = state.copyWith(
          cache: newCache,
          loadingIds: updatedLoading,
        );
      }

      return profile;
    } catch (e) {
      final updatedLoading =
      Set<String>.from(state.loadingIds);
      updatedLoading.remove(profileId);
      state = state.copyWith(loadingIds: updatedLoading);
      return null;
    }
  }

  void clearCache() {
    state = const OtherProfileState();
  }
}

// ── OTHER PROFILE PROVIDER ────────────────────────────────
final otherProfileProvider = StateNotifierProvider<
    OtherProfileNotifier, OtherProfileState>(
      (ref) => OtherProfileNotifier(
    ref.read(profileRepositoryProvider),
  ),
);

// ── CONVENIENCE PROVIDERS ─────────────────────────────────

/// Current user ka profile
final currentProfileProvider =
Provider<ProfileModel?>((ref) {
  return ref.watch(myProfileProvider).profile;
});

/// Profile score
final profileScoreProvider = Provider<int>((ref) {
  return ref.watch(myProfileProvider).profileScore;
});

/// Premium status
final isPremiumActiveProvider = Provider<bool>((ref) {
  return ref.watch(myProfileProvider).isPremium;
});

/// Shortlisted profile ids
final shortlistedIdsProvider =
Provider<Set<String>>((ref) {
  return ref.watch(myProfileProvider).shortlistedIds;
});