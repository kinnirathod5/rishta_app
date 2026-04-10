// lib/data/repositories/interest_repository.dart

import '../models/interest_model.dart';
import '../models/connection_model.dart';

class InterestRepository {
  // Singleton
  static final InterestRepository _instance =
  InterestRepository._internal();
  factory InterestRepository() => _instance;
  InterestRepository._internal();

  // ── SEND INTEREST ───────────────────────────────────

  /// Kisi ko interest bhejo
  Future<String> sendInterest({
    required String fromUserId,
    required String fromProfileId,
    required String toUserId,
    required String toProfileId,
    String? message,
  }) async {
    // TODO: Firebase Phase mein uncomment karo
    // final interestModel = InterestModel(
    //   id: '',
    //   fromUserId: fromUserId,
    //   fromProfileId: fromProfileId,
    //   toUserId: toUserId,
    //   toProfileId: toProfileId,
    //   sentAt: DateTime.now(),
    //   message: message,
    // );
    // final doc = await FirebaseFirestore.instance
    //   .collection('interests')
    //   .add(interestModel.toFirestore());
    //
    // Notification bhi bhejo:
    // await NotificationRepository().createNotification(
    //   userId: toUserId,
    //   type: NotificationType.interest,
    //   title: 'Naya Interest! 💌',
    //   body: 'Kisine aapko interest bheja',
    //   referenceId: doc.id,
    //   actionRoute: '/interests',
    // );
    //
    // return doc.id;

    await Future.delayed(const Duration(milliseconds: 500));
    return 'mock_interest_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ── RESPOND TO INTEREST ─────────────────────────────

  /// Interest accept ya decline karo
  Future<void> respondToInterest(
      String interestId,
      InterestStatus status, {
        required String currentUserId,
        required InterestModel interest,
      }) async {
    // TODO: Firebase Phase mein uncomment karo
    // await FirebaseFirestore.instance
    //   .collection('interests')
    //   .doc(interestId)
    //   .update({
    //     'status': status.name,
    //     'respondedAt': DateTime.now().toIso8601String(),
    //   });
    //
    // Agar accept hua → Connection banao
    // if (status == InterestStatus.accepted) {
    //   final connection = ConnectionModel(
    //     id: '',
    //     user1Id: interest.fromUserId,
    //     profile1Id: interest.fromProfileId,
    //     user2Id: interest.toUserId,
    //     profile2Id: interest.toProfileId,
    //     interestId: interestId,
    //     connectedAt: DateTime.now(),
    //   );
    //   final connDoc = await FirebaseFirestore.instance
    //     .collection('connections')
    //     .add(connection.toFirestore());
    //
    //   // Chat bhi banao
    //   final chat = ChatModel(
    //     id: '',
    //     connectionId: connDoc.id,
    //     participantIds: [interest.fromUserId, interest.toUserId],
    //     createdAt: DateTime.now(),
    //   );
    //   final chatDoc = await FirebaseFirestore.instance
    //     .collection('chats')
    //     .add(chat.toFirestore());
    //
    //   // Connection update karo chatId ke saath
    //   await connDoc.update({'chatId': chatDoc.id});
    //
    //   // Notification bhejo
    //   await NotificationRepository().createNotification(
    //     userId: interest.fromUserId,
    //     type: NotificationType.accepted,
    //     title: 'Interest Accept Ho Gaya! 🎉',
    //     body: 'Aapka interest accept ho gaya',
    //     referenceId: connDoc.id,
    //     actionRoute: '/interests',
    //   );
    // }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── WITHDRAW INTEREST ───────────────────────────────

  /// Bheja hua interest wapas lo
  Future<void> withdrawInterest(String interestId) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('interests')
    //   .doc(interestId)
    //   .update({
    //     'status': InterestStatus.withdrawn.name,
    //     'respondedAt': DateTime.now().toIso8601String(),
    //   });

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── GET RECEIVED INTERESTS ──────────────────────────

  /// Aaye hue interests fetch karo
  Future<List<InterestModel>> getReceivedInterests(
      String userId, {
        InterestStatus? filterStatus,
      }) async {
    // TODO: Firebase
    // var query = FirebaseFirestore.instance
    //   .collection('interests')
    //   .where('toUserId', isEqualTo: userId)
    //   .orderBy('sentAt', descending: true);
    //
    // if (filterStatus != null) {
    //   query = query.where('status', isEqualTo: filterStatus.name);
    // }
    //
    // final snap = await query.get();
    // return snap.docs.map((doc) =>
    //   InterestModel.fromFirestore(doc.data(), doc.id)).toList();

    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }

  // ── GET SENT INTERESTS ──────────────────────────────

  /// Bheje hue interests fetch karo
  Future<List<InterestModel>> getSentInterests(
      String userId, {
        InterestStatus? filterStatus,
      }) async {
    // TODO: Firebase
    // var query = FirebaseFirestore.instance
    //   .collection('interests')
    //   .where('fromUserId', isEqualTo: userId)
    //   .orderBy('sentAt', descending: true);
    //
    // if (filterStatus != null) {
    //   query = query.where('status', isEqualTo: filterStatus.name);
    // }
    //
    // final snap = await query.get();
    // return snap.docs.map((doc) =>
    //   InterestModel.fromFirestore(doc.data(), doc.id)).toList();

    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }

  // ── GET CONNECTIONS ─────────────────────────────────

  /// Connected profiles fetch karo
  Future<List<ConnectionModel>> getConnections(
      String userId) async {
    // TODO: Firebase
    // final q1 = await FirebaseFirestore.instance
    //   .collection('connections')
    //   .where('user1Id', isEqualTo: userId)
    //   .where('isActive', isEqualTo: true)
    //   .get();
    //
    // final q2 = await FirebaseFirestore.instance
    //   .collection('connections')
    //   .where('user2Id', isEqualTo: userId)
    //   .where('isActive', isEqualTo: true)
    //   .get();
    //
    // final allDocs = [...q1.docs, ...q2.docs];
    // return allDocs.map((doc) =>
    //   ConnectionModel.fromFirestore(doc.data(), doc.id)).toList();

    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }

  // ── CHECK IF ALREADY SENT ───────────────────────────

  /// Check karo ki already interest bheja hai ya nahi
  Future<bool> hasAlreadySentInterest({
    required String fromUserId,
    required String toUserId,
  }) async {
    // TODO: Firebase
    // final snap = await FirebaseFirestore.instance
    //   .collection('interests')
    //   .where('fromUserId', isEqualTo: fromUserId)
    //   .where('toUserId', isEqualTo: toUserId)
    //   .where('status', whereIn: ['pending', 'accepted'])
    //   .limit(1)
    //   .get();
    // return snap.docs.isNotEmpty;

    await Future.delayed(const Duration(milliseconds: 200));
    return false;
  }

  // ── PENDING COUNT ───────────────────────────────────

  /// Pending received interests ki count
  Future<int> getPendingReceivedCount(String userId) async {
    // TODO: Firebase
    // final snap = await FirebaseFirestore.instance
    //   .collection('interests')
    //   .where('toUserId', isEqualTo: userId)
    //   .where('status', isEqualTo: 'pending')
    //   .count()
    //   .get();
    // return snap.count;

    await Future.delayed(const Duration(milliseconds: 200));
    return 0;
  }

  // ── REALTIME STREAM ─────────────────────────────────

  /// Received interests ka realtime stream
  Stream<List<InterestModel>> receivedInterestsStream(
      String userId) {
    // TODO: Firebase
    // return FirebaseFirestore.instance
    //   .collection('interests')
    //   .where('toUserId', isEqualTo: userId)
    //   .where('status', isEqualTo: 'pending')
    //   .orderBy('sentAt', descending: true)
    //   .snapshots()
    //   .map((snap) => snap.docs.map((doc) =>
    //     InterestModel.fromFirestore(doc.data(), doc.id)).toList());

    return Stream.value([]);
  }
}