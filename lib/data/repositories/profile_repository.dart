// lib/data/repositories/profile_repository.dart
//
// NOTE: Firebase (cloud_firestore + storage) Phase 3 mein add hoga.
// Tab actual Firestore + Storage calls uncomment karna hai.
// Abhi mock implementation se kaam chalega.

import 'package:rishta_app/data/models/profile_model.dart';
import 'package:rishta_app/data/models/user_model.dart';

// ─────────────────────────────────────────────────────────
// PROFILE EXCEPTIONS
// ─────────────────────────────────────────────────────────

class ProfileException implements Exception {
  final String code;
  final String message;

  const ProfileException({
    required this.code,
    required this.message,
  });

  factory ProfileException.fromCode(String code) {
    switch (code) {
      case 'profile-not-found':
        return const ProfileException(
          code: 'profile-not-found',
          message: 'Profile not found.',
        );
      case 'upload-failed':
        return const ProfileException(
          code: 'upload-failed',
          message: 'Photo upload failed. Please try again.',
        );
      case 'invalid-photo':
        return const ProfileException(
          code: 'invalid-photo',
          message: 'Invalid photo. Please select a valid image.',
        );
      case 'max-photos-reached':
        return const ProfileException(
          code: 'max-photos-reached',
          message: 'Maximum photo limit reached.',
        );
      case 'permission-denied':
        return const ProfileException(
          code: 'permission-denied',
          message: 'You do not have permission to perform this action.',
        );
      case 'network-error':
        return const ProfileException(
          code: 'network-error',
          message: 'No internet connection. Please try again.',
        );
      default:
        return const ProfileException(
          code: 'unknown',
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  @override
  String toString() =>
      'ProfileException(code: $code, message: $message)';
}

// ─────────────────────────────────────────────────────────
// MOCK DATA STORE
// ─────────────────────────────────────────────────────────

final Map<String, ProfileModel> _mockProfiles = {};
final Map<String, List<String>> _mockShortlists = {};
final Map<String, List<String>> _mockBlockedUsers = {};
final Map<String, List<String>> _mockProfileViews = {};
final List<Map<String, dynamic>> _mockReports = [];

// ─────────────────────────────────────────────────────────
// PROFILE REPOSITORY
// ─────────────────────────────────────────────────────────

class ProfileRepository {

  // ── CREATE PROFILE ────────────────────────────────────

  /// Create a new profile for a user.
  Future<ProfileModel> createProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _delay();

      final profileId = 'profile_$userId';
      final now = DateTime.now();

      final profile = ProfileModel.fromMap(
        profileId,
        {
          ...data,
          'userId': userId,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      );

      _mockProfiles[profileId] = profile;
      return profile;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final ref = FirebaseFirestore.instance
      //     .collection('profiles')
      //     .doc();
      // final profile = ProfileModel.fromMap(
      //     ref.id, {
      //   ...data,
      //   'userId': userId,
      //   'createdAt': FieldValue.serverTimestamp(),
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      // await ref.set(profile.toMap());
      // // Link profile to user
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .update({
      //   'profileId': ref.id,
      //   'hasCompletedSetup': true,
      // });
      // return profile.copyWith(id: ref.id);
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  // ── GET PROFILE ───────────────────────────────────────

  /// Get a profile by its profile ID.
  Future<ProfileModel?> getProfile(
      String profileId) async {
    try {
      await _delay(ms: 400);
      return _mockProfiles[profileId];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('profiles')
      //     .doc(profileId)
      //     .get();
      // if (!snap.exists) return null;
      // return ProfileModel.fromMap(
      //     snap.id, snap.data()!);
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  // ── GET PROFILE BY USER ID ────────────────────────────

  /// Get a profile using userId (not profileId).
  Future<ProfileModel?> getProfileByUserId(
      String userId) async {
    try {
      await _delay(ms: 400);

      try {
        return _mockProfiles.values.firstWhere(
                (p) => p.userId == userId);
      } catch (_) {
        return null;
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('profiles')
      //     .where('userId', isEqualTo: userId)
      //     .limit(1)
      //     .get();
      // if (snap.docs.isEmpty) return null;
      // return ProfileModel.fromMap(
      //     snap.docs.first.id,
      //     snap.docs.first.data());
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  // ── UPDATE PROFILE ────────────────────────────────────

  /// Update specific fields of a profile.
  Future<ProfileModel> updateProfile(
      String profileId,
      Map<String, dynamic> data,
      ) async {
    try {
      await _delay(ms: 600);

      final existing = _mockProfiles[profileId];
      if (existing == null) {
        throw ProfileException.fromCode(
            'profile-not-found');
      }

      final updated = ProfileModel.fromMap(
        profileId,
        {
          ...existing.toMap(),
          ...data,
          'updatedAt':
          DateTime.now().toIso8601String(),
        },
      );

      _mockProfiles[profileId] = updated;
      return updated;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('profiles')
      //     .doc(profileId)
      //     .update({
      //   ...data,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      // return await getProfile(profileId) ??
      //     (throw ProfileException.fromCode(
      //         'profile-not-found'));
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  // ── GET MATCHES ───────────────────────────────────────

  /// Get matching profiles for a user.
  ///
  /// Filters based on partner preference.
  /// Returns paginated list.
  Future<List<ProfileModel>> getMatches({
    required String userId,
    required String myProfileId,
    int limit = 20,
    int page = 0,
    Map<String, dynamic>? filters,
  }) async {
    try {
      await _delay(ms: 800);

      // Get all profiles except self + blocked
      final blocked =
          _mockBlockedUsers[userId] ?? [];

      var profiles = _mockProfiles.values
          .where((p) =>
      p.userId != userId &&
          !blocked.contains(p.userId) &&
          p.isActive)
          .toList();

      // Apply filters
      if (filters != null) {
        profiles = _applyFilters(
            profiles, filters);
      }

      // Sort by profile score desc
      profiles.sort((a, b) =>
          b.profileScore
              .compareTo(a.profileScore));

      // Paginate
      final start = page * limit;
      if (start >= profiles.length) return [];
      final end =
      (start + limit).clamp(0, profiles.length);

      return profiles.sublist(start, end);

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // Get my profile for partner preference
      // final myProfile =
      //     await getProfile(myProfileId);
      // final pref =
      //     myProfile?.partnerPreference;
      // Query q = FirebaseFirestore.instance
      //     .collection('profiles')
      //     .where('isActive', isEqualTo: true)
      //     .where('userId',
      //         isNotEqualTo: userId);
      // if (pref != null) {
      //   q = q.where('age',
      //       isGreaterThanOrEqualTo: pref.minAge)
      //       .where('age',
      //       isLessThanOrEqualTo: pref.maxAge);
      // }
      // if (filters?['verifiedOnly'] == true) {
      //   q = q.where('isVerified',
      //       isEqualTo: true);
      // }
      // final snap = await q
      //     .limit(limit)
      //     .get();
      // return snap.docs
      //     .map((d) => ProfileModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  // ── SEARCH PROFILES ───────────────────────────────────

  /// Search profiles by query string.
  Future<List<ProfileModel>> searchProfiles({
    required String query,
    required String userId,
    int limit = 20,
  }) async {
    try {
      await _delay(ms: 600);

      if (query.trim().isEmpty) return [];

      final q = query.toLowerCase().trim();
      final blocked =
          _mockBlockedUsers[userId] ?? [];

      return _mockProfiles.values
          .where((p) =>
      p.userId != userId &&
          !blocked.contains(p.userId) &&
          p.isActive &&
          (p.fullName
              .toLowerCase()
              .contains(q) ||
              p.currentCity
                  .toLowerCase()
                  .contains(q) ||
              p.caste
                  .toLowerCase()
                  .contains(q) ||
              p.professionDisplay
                  .toLowerCase()
                  .contains(q) ||
              p.religion
                  .toLowerCase()
                  .contains(q)))
          .take(limit)
          .toList();

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // Firestore does not support full-text search.
      // Use Algolia / Typesense for production.
      // Basic prefix search:
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('profiles')
      //     .where('searchKeywords',
      //         arrayContains: q.toLowerCase())
      //     .where('isActive', isEqualTo: true)
      //     .limit(limit)
      //     .get();
      // return snap.docs
      //     .map((d) => ProfileModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  // ── UPLOAD PHOTO ──────────────────────────────────────

  /// Upload a profile photo and return its URL.
  Future<String> uploadPhoto(
      String userId,
      String localPath,
      ) async {
    try {
      await _delay(ms: 1200);

      // Mock: return a placeholder URL
      final timestamp =
          DateTime.now().millisecondsSinceEpoch;
      return 'https://mock.storage.com/'
          'profiles/$userId/photo_$timestamp.jpg';

      // ── PHASE 3 — FIREBASE STORAGE ──────────────
      // final file = File(localPath);
      // final ref = FirebaseStorage.instance
      //     .ref()
      //     .child('profiles/$userId/'
      //     'photo_$timestamp.jpg');
      // final task = await ref.putFile(file);
      // return await task.ref.getDownloadURL();
    } catch (e) {
      throw ProfileException.fromCode(
          'upload-failed');
    }
  }

  /// Delete a photo from storage.
  Future<void> deletePhoto(
      String photoUrl) async {
    try {
      await _delay(ms: 400);
      // Mock: no-op

      // ── PHASE 3 — FIREBASE STORAGE ──────────────
      // await FirebaseStorage.instance
      //     .refFromURL(photoUrl)
      //     .delete();
    } catch (e) {
      // Fail silently — photo already deleted
    }
  }

  // ── SHORTLIST ─────────────────────────────────────────

  /// Add a profile to shortlist.
  Future<void> addToShortlist(
      String myProfileId,
      String targetProfileId,
      ) async {
    try {
      await _delay(ms: 300);

      _mockShortlists[myProfileId] ??= [];
      if (!_mockShortlists[myProfileId]!
          .contains(targetProfileId)) {
        _mockShortlists[myProfileId]!
            .add(targetProfileId);
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('profiles')
      //     .doc(myProfileId)
      //     .update({
      //   'shortlistedIds':
      //       FieldValue.arrayUnion([targetProfileId]),
      // });
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  /// Remove a profile from shortlist.
  Future<void> removeFromShortlist(
      String myProfileId,
      String targetProfileId,
      ) async {
    try {
      await _delay(ms: 300);

      _mockShortlists[myProfileId]
          ?.remove(targetProfileId);

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('profiles')
      //     .doc(myProfileId)
      //     .update({
      //   'shortlistedIds':
      //       FieldValue.arrayRemove([targetProfileId]),
      // });
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  /// Get all shortlisted profile IDs.
  Future<List<String>> getShortlistedIds(
      String profileId) async {
    try {
      await _delay(ms: 300);
      return _mockShortlists[profileId] ?? [];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('profiles')
      //     .doc(profileId)
      //     .get();
      // return List<String>.from(
      //     snap.data()?['shortlistedIds'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// Get full shortlisted profiles.
  Future<List<ProfileModel>> getShortlisted(
      String profileId) async {
    try {
      final ids =
      await getShortlistedIds(profileId);
      if (ids.isEmpty) return [];

      final profiles = <ProfileModel>[];
      for (final id in ids) {
        final p = await getProfile(id);
        if (p != null) profiles.add(p);
      }
      return profiles;
    } catch (e) {
      return [];
    }
  }

  // ── BLOCK / UNBLOCK ───────────────────────────────────

  /// Block a user.
  Future<void> blockUser(
      String myUserId,
      String targetUserId,
      ) async {
    try {
      await _delay(ms: 300);

      _mockBlockedUsers[myUserId] ??= [];
      if (!_mockBlockedUsers[myUserId]!
          .contains(targetUserId)) {
        _mockBlockedUsers[myUserId]!
            .add(targetUserId);
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final batch =
      //     FirebaseFirestore.instance.batch();
      // batch.update(
      //   FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(myUserId),
      //   {
      //     'blockedUsers':
      //         FieldValue.arrayUnion([targetUserId]),
      //   },
      // );
      // await batch.commit();
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  /// Unblock a user.
  Future<void> unblockUser(
      String myUserId,
      String targetUserId,
      ) async {
    try {
      await _delay(ms: 300);

      _mockBlockedUsers[myUserId]
          ?.remove(targetUserId);

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(myUserId)
      //     .update({
      //   'blockedUsers':
      //       FieldValue.arrayRemove([targetUserId]),
      // });
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  /// Get all blocked user IDs.
  Future<List<String>> getBlockedUserIds(
      String userId) async {
    try {
      await _delay(ms: 300);
      return _mockBlockedUsers[userId] ?? [];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('users')
      //     .doc(userId)
      //     .get();
      // return List<String>.from(
      //     snap.data()?['blockedUsers'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// Get full blocked user profiles.
  Future<List<ProfileModel>> getBlockedProfiles(
      String userId) async {
    try {
      final ids =
      await getBlockedUserIds(userId);
      if (ids.isEmpty) return [];

      final profiles = <ProfileModel>[];
      for (final uid in ids) {
        final p =
        await getProfileByUserId(uid);
        if (p != null) profiles.add(p);
      }
      return profiles;
    } catch (e) {
      return [];
    }
  }

  // ── REPORT USER ───────────────────────────────────────

  /// Report a user for inappropriate behavior.
  Future<void> reportUser({
    required String reporterUserId,
    required String targetUserId,
    required String reason,
    String? additionalInfo,
  }) async {
    try {
      await _delay(ms: 400);

      _mockReports.add({
        'reporterUserId': reporterUserId,
        'targetUserId': targetUserId,
        'reason': reason,
        'additionalInfo': additionalInfo,
        'createdAt':
        DateTime.now().toIso8601String(),
      });

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('reports')
      //     .add({
      //   'reporterUserId': reporterUserId,
      //   'targetUserId': targetUserId,
      //   'reason': reason,
      //   'additionalInfo': additionalInfo,
      //   'status': 'pending',
      //   'createdAt':
      //       FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      throw ProfileException.fromCode('unknown');
    }
  }

  // ── RECORD PROFILE VIEW ───────────────────────────────

  /// Record that a user viewed a profile.
  Future<void> recordProfileView({
    required String viewerId,
    required String profileId,
  }) async {
    try {
      await _delay(ms: 200);

      _mockProfileViews[profileId] ??= [];
      if (!_mockProfileViews[profileId]!
          .contains(viewerId)) {
        _mockProfileViews[profileId]!
            .add(viewerId);
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('profileViews')
      //     .add({
      //   'viewerId': viewerId,
      //   'profileId': profileId,
      //   'viewedAt':
      //       FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      // Fail silently — non-critical
    }
  }

  /// Get IDs of users who viewed a profile.
  Future<List<String>> getProfileViewerIds(
      String profileId) async {
    try {
      await _delay(ms: 400);
      return _mockProfileViews[profileId] ?? [];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('profileViews')
      //     .where('profileId',
      //         isEqualTo: profileId)
      //     .orderBy('viewedAt', descending: true)
      //     .limit(100)
      //     .get();
      // return snap.docs
      //     .map((d) =>
      //         d.data()['viewerId'] as String)
      //     .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get full profiles of who viewed.
  Future<List<ProfileModel>> getWhoViewedProfiles(
      String profileId) async {
    try {
      final viewerIds =
      await getProfileViewerIds(profileId);
      if (viewerIds.isEmpty) return [];

      final profiles = <ProfileModel>[];
      for (final uid in viewerIds) {
        final p =
        await getProfileByUserId(uid);
        if (p != null) profiles.add(p);
      }
      return profiles;
    } catch (e) {
      return [];
    }
  }

  // ── PROFILE STREAM ────────────────────────────────────

  /// Real-time stream for a single profile.
  Stream<ProfileModel?> profileStream(
      String profileId) async* {
    yield await getProfile(profileId);

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('profiles')
    //     .doc(profileId)
    //     .snapshots()
    //     .map((snap) => snap.exists
    //         ? ProfileModel.fromMap(
    //             snap.id, snap.data()!)
    //         : null);
  }

  // ── UPDATE LAST ACTIVE ────────────────────────────────

  /// Update profile's last active timestamp.
  Future<void> updateLastActive(
      String profileId) async {
    try {
      if (!_mockProfiles.containsKey(profileId)) {
        return;
      }
      _mockProfiles[profileId] =
          _mockProfiles[profileId]!.copyWith(
            lastActiveAt: DateTime.now(),
          );

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('profiles')
      //     .doc(profileId)
      //     .update({
      //   'lastActiveAt':
      //       FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      // Fail silently
    }
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  Future<void> _delay({int ms = 500}) async {
    await Future.delayed(
        Duration(milliseconds: ms));
  }

  List<ProfileModel> _applyFilters(
      List<ProfileModel> profiles,
      Map<String, dynamic> filters,
      ) {
    var result = profiles;

    // Age filter
    final minAge = filters['minAge'] as int?;
    final maxAge = filters['maxAge'] as int?;
    if (minAge != null || maxAge != null) {
      result = result.where((p) {
        final age = p.age;
        if (minAge != null && age < minAge) {
          return false;
        }
        if (maxAge != null && age > maxAge) {
          return false;
        }
        return true;
      }).toList();
    }

    // Religion filter
    final religions =
    filters['religions'] as List<String>?;
    if (religions != null &&
        religions.isNotEmpty) {
      result = result
          .where((p) =>
          religions.contains(p.religion))
          .toList();
    }

    // Caste filter
    final castes =
    filters['castes'] as List<String>?;
    if (castes != null && castes.isNotEmpty) {
      result = result
          .where((p) => castes.contains(p.caste))
          .toList();
    }

    // City filter
    final cities =
    filters['cities'] as List<String>?;
    if (cities != null && cities.isNotEmpty) {
      result = result
          .where((p) =>
          cities.contains(p.currentCity))
          .toList();
    }

    // Verified only
    if (filters['verifiedOnly'] == true) {
      result = result
          .where((p) => p.isVerified)
          .toList();
    }

    // With photo only
    if (filters['withPhotoOnly'] == true) {
      result = result
          .where((p) => p.hasPhoto)
          .toList();
    }

    // Height filter
    final minHeight =
    filters['minHeightInches'] as int?;
    final maxHeight =
    filters['maxHeightInches'] as int?;
    if (minHeight != null || maxHeight != null) {
      result = result.where((p) {
        if (minHeight != null &&
            p.heightInInches < minHeight) {
          return false;
        }
        if (maxHeight != null &&
            p.heightInInches > maxHeight) {
          return false;
        }
        return true;
      }).toList();
    }

    return result;
  }
}