// lib/data/repositories/profile_repository.dart

import '../models/profile_model.dart';

class ProfileRepository {
  static final ProfileRepository _instance =
  ProfileRepository._internal();
  factory ProfileRepository() => _instance;
  ProfileRepository._internal();

  // ── GET PROFILE ────────────────────────────────────

  Future<ProfileModel?> getProfile(String profileId) async {
    // TODO: Firebase
    // final doc = await FirebaseFirestore.instance
    //   .collection('profiles')
    //   .doc(profileId)
    //   .get();
    // if (!doc.exists) return null;
    // return ProfileModel.fromFirestore(doc.data()!, doc.id);

    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  Future<ProfileModel?> getProfileByUserId(String userId) async {
    // TODO: Firebase
    // final query = await FirebaseFirestore.instance
    //   .collection('profiles')
    //   .where('userId', isEqualTo: userId)
    //   .limit(1)
    //   .get();
    // if (query.docs.isEmpty) return null;
    // return ProfileModel.fromFirestore(
    //   query.docs.first.data(), query.docs.first.id);

    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  // ── CREATE / UPDATE ────────────────────────────────

  Future<String> createProfile(ProfileModel profile) async {
    // TODO: Firebase
    // final doc = await FirebaseFirestore.instance
    //   .collection('profiles')
    //   .add(profile.toFirestore());
    // return doc.id;

    await Future.delayed(const Duration(milliseconds: 500));
    return 'mock_profile_id';
  }

  Future<void> updateProfile(
      String profileId, Map<String, dynamic> data) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('profiles')
    //   .doc(profileId)
    //   .update({...data, 'updatedAt': DateTime.now().toIso8601String()});

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── FETCH MATCHES ──────────────────────────────────

  Future<List<ProfileModel>> getMatches({
    required String currentProfileId,
    required ProfileModel myProfile,
    int limit = 20,
  }) async {
    // TODO: Firebase — preference ke hisaab se query
    // final query = FirebaseFirestore.instance
    //   .collection('profiles')
    //   .where('isActive', isEqualTo: true)
    //   .where('isHidden', isEqualTo: false)
    //   .where('gender', isNotEqualTo: myProfile.gender)
    //   .orderBy('profileScore', descending: true)
    //   .limit(limit);

    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // ── SHORTLIST ──────────────────────────────────────

  Future<void> addToShortlist(
      String myProfileId, String targetProfileId) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('shortlists')
    //   .doc(myProfileId)
    //   .set({
    //     'profileIds': FieldValue.arrayUnion([targetProfileId]),
    //     'updatedAt': DateTime.now().toIso8601String(),
    //   }, SetOptions(merge: true));

    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> removeFromShortlist(
      String myProfileId, String targetProfileId) async {
    // TODO: Firebase
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<List<String>> getShortlistedIds(
      String myProfileId) async {
    // TODO: Firebase
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  // ── PHOTO UPLOAD ───────────────────────────────────

  Future<String> uploadPhoto(
      String userId, String localPath) async {
    // TODO: Firebase Storage
    // final ref = FirebaseStorage.instance
    //   .ref('profiles/$userId/photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
    // await ref.putFile(File(localPath));
    // return await ref.getDownloadURL();

    await Future.delayed(const Duration(seconds: 1));
    return 'https://placeholder.com/photo.jpg';
  }

  // ── BLOCK / REPORT ─────────────────────────────────

  Future<void> blockUser(
      String myUserId, String targetUserId) async {
    // TODO: Firebase
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> unblockUser(
      String myUserId, String targetUserId) async {
    // TODO: Firebase
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<List<String>> getBlockedUserIds(String myUserId) async {
    // TODO: Firebase
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<void> reportUser({
    required String reporterUserId,
    required String targetUserId,
    required String reason,
  }) async {
    // TODO: Firebase
    await Future.delayed(const Duration(milliseconds: 300));
  }
}