// lib/data/repositories/interest_repository.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab actual Firestore calls uncomment karna hai.
// Abhi mock implementation se kaam chalega.

import 'package:rishta_app/data/models/interest_model.dart';
import 'package:rishta_app/data/models/connection_model.dart';

// ─────────────────────────────────────────────────────────
// INTEREST EXCEPTIONS
// ─────────────────────────────────────────────────────────

class InterestException implements Exception {
  final String code;
  final String message;

  const InterestException({
    required this.code,
    required this.message,
  });

  factory InterestException.fromCode(String code) {
    switch (code) {
      case 'already-sent':
        return const InterestException(
          code: 'already-sent',
          message: 'You have already sent an interest to this person.',
        );
      case 'interest-not-found':
        return const InterestException(
          code: 'interest-not-found',
          message: 'Interest not found.',
        );
      case 'cannot-self-interest':
        return const InterestException(
          code: 'cannot-self-interest',
          message: 'You cannot send interest to yourself.',
        );
      case 'user-blocked':
        return const InterestException(
          code: 'user-blocked',
          message: 'You cannot interact with this user.',
        );
      case 'limit-reached':
        return const InterestException(
          code: 'limit-reached',
          message: 'You have reached your daily interest limit. Upgrade to Premium for unlimited interests.',
        );
      case 'already-connected':
        return const InterestException(
          code: 'already-connected',
          message: 'You are already connected with this person.',
        );
      case 'network-error':
        return const InterestException(
          code: 'network-error',
          message: 'No internet connection. Please try again.',
        );
      default:
        return const InterestException(
          code: 'unknown',
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  @override
  String toString() =>
      'InterestException(code: $code, message: $message)';
}

// ─────────────────────────────────────────────────────────
// MOCK DATA STORE
// ─────────────────────────────────────────────────────────

final Map<String, InterestModel> _mockInterests = {};
final Map<String, ConnectionModel> _mockConnections = {};

// ─────────────────────────────────────────────────────────
// INTEREST REPOSITORY
// ─────────────────────────────────────────────────────────

class InterestRepository {

  // ── SEND INTEREST ─────────────────────────────────────

  /// Send an interest from one user to another.
  ///
  /// Returns [InterestModel] on success.
  /// Throws [InterestException] on failure.
  Future<InterestModel> sendInterest({
    required String senderId,
    required String receiverId,
    required String senderProfileId,
    required String receiverProfileId,
    String? message,
  }) async {
    try {
      // Validate
      if (senderId == receiverId) {
        throw InterestException.fromCode(
            'cannot-self-interest');
      }

      await _delay();

      // Check if already sent
      final existing = await getInterestBetween(
        uid1: senderId,
        uid2: receiverId,
      );

      if (existing != null &&
          existing.isPending) {
        throw InterestException.fromCode(
            'already-sent');
      }

      // Check if already connected
      final connId =
      ConnectionModel.generateId(
          senderId, receiverId);
      if (_mockConnections.containsKey(connId)) {
        throw InterestException.fromCode(
            'already-connected');
      }

      // Create interest
      final interest = InterestModel.create(
        senderId: senderId,
        receiverId: receiverId,
        senderProfileId: senderProfileId,
        receiverProfileId: receiverProfileId,
        message: message,
        expiryDuration:
        const Duration(days: 30),
      );

      _mockInterests[interest.id] = interest;
      return interest;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final ref = FirebaseFirestore.instance
      //     .collection('interests')
      //     .doc(interest.id);
      // await ref.set(interest.toMap());
      // return interest;
    } on InterestException {
      rethrow;
    } catch (e) {
      throw InterestException.fromCode('unknown');
    }
  }

  // ── RESPOND TO INTEREST ───────────────────────────────

  /// Accept or decline a received interest.
  ///
  /// [accept] = true → Accept and create connection
  /// [accept] = false → Decline
  ///
  /// Returns updated [InterestModel].
  /// If accepted, also returns [ConnectionModel].
  Future<({
  InterestModel interest,
  ConnectionModel? connection,
  })> respondToInterest({
    required String interestId,
    required bool accept,
    required String responderUid,
  }) async {
    try {
      await _delay();

      final interest = _mockInterests[interestId];
      if (interest == null) {
        throw InterestException.fromCode(
            'interest-not-found');
      }

      if (!interest.isPending) {
        throw const InterestException(
          code: 'already-responded',
          message: 'This interest has already been responded to.',
        );
      }

      // Validate responder
      if (interest.receiverId != responderUid) {
        throw const InterestException(
          code: 'unauthorized',
          message: 'You are not authorized to respond to this interest.',
        );
      }

      ConnectionModel? connection;

      if (accept) {
        // Accept → update interest + create connection
        final accepted = interest.accept();
        _mockInterests[interestId] = accepted;

        connection = ConnectionModel.create(
          uid1: interest.senderId,
          uid2: interest.receiverId,
          initiatedBy: interest.senderId,
        );
        _mockConnections[connection.id] =
            connection;

        return (
        interest: accepted,
        connection: connection,
        );
      } else {
        // Decline → update interest only
        final declined = interest.decline();
        _mockInterests[interestId] = declined;

        return (
        interest: declined,
        connection: null,
        );
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final batch =
      //     FirebaseFirestore.instance.batch();
      // final interestRef = FirebaseFirestore
      //     .instance
      //     .collection('interests')
      //     .doc(interestId);
      // if (accept) {
      //   batch.update(interestRef, {
      //     'status': 'accepted',
      //     'respondedAt':
      //         FieldValue.serverTimestamp(),
      //   });
      //   final conn = ConnectionModel.create(
      //     uid1: interest.senderId,
      //     uid2: interest.receiverId,
      //     initiatedBy: interest.senderId,
      //   );
      //   batch.set(
      //     FirebaseFirestore.instance
      //         .collection('connections')
      //         .doc(conn.id),
      //     conn.toMap(),
      //   );
      //   await batch.commit();
      //   return (interest: interest.accept(),
      //           connection: conn);
      // } else {
      //   batch.update(interestRef, {
      //     'status': 'declined',
      //     'respondedAt':
      //         FieldValue.serverTimestamp(),
      //   });
      //   await batch.commit();
      //   return (interest: interest.decline(),
      //           connection: null);
      // }
    } on InterestException {
      rethrow;
    } catch (e) {
      throw InterestException.fromCode('unknown');
    }
  }

  // ── WITHDRAW INTEREST ─────────────────────────────────

  /// Withdraw a sent interest (sender action).
  Future<InterestModel> withdrawInterest({
    required String interestId,
    required String senderUid,
  }) async {
    try {
      await _delay();

      final interest =
      _mockInterests[interestId];
      if (interest == null) {
        throw InterestException.fromCode(
            'interest-not-found');
      }

      if (interest.senderId != senderUid) {
        throw const InterestException(
          code: 'unauthorized',
          message: 'You can only withdraw your own interests.',
        );
      }

      if (!interest.isPending) {
        throw const InterestException(
          code: 'cannot-withdraw',
          message: 'Cannot withdraw — interest already responded.',
        );
      }

      final withdrawn = interest.withdraw();
      _mockInterests[interestId] = withdrawn;
      return withdrawn;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('interests')
      //     .doc(interestId)
      //     .update({
      //   'status': 'withdrawn',
      //   'respondedAt':
      //       FieldValue.serverTimestamp(),
      // });
      // return interest.withdraw();
    } on InterestException {
      rethrow;
    } catch (e) {
      throw InterestException.fromCode('unknown');
    }
  }

  // ── GET RECEIVED INTERESTS ────────────────────────────

  /// Get interests received by a user.
  ///
  /// [statusFilter] — null = all, else filter by status
  Future<List<InterestModel>> getReceivedInterests({
    required String uid,
    InterestStatus? statusFilter,
  }) async {
    try {
      await _delay(ms: 600);

      var interests = _mockInterests.values
          .where((i) => i.receiverId == uid)
          .toList();

      if (statusFilter != null) {
        interests = interests
            .where((i) => i.status == statusFilter)
            .toList();
      }

      // Sort newest first
      interests.sort((a, b) =>
          b.sentAt.compareTo(a.sentAt));

      return interests;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // Query q = FirebaseFirestore.instance
      //     .collection('interests')
      //     .where('receiverId', isEqualTo: uid)
      //     .orderBy('sentAt', descending: true);
      // if (statusFilter != null) {
      //   q = q.where('status',
      //       isEqualTo: statusFilter.value);
      // }
      // final snap = await q.get();
      // return snap.docs
      //     .map((d) => InterestModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      throw InterestException.fromCode('unknown');
    }
  }

  // ── GET SENT INTERESTS ────────────────────────────────

  /// Get interests sent by a user.
  Future<List<InterestModel>> getSentInterests({
    required String uid,
    InterestStatus? statusFilter,
  }) async {
    try {
      await _delay(ms: 600);

      var interests = _mockInterests.values
          .where((i) => i.senderId == uid)
          .toList();

      if (statusFilter != null) {
        interests = interests
            .where((i) => i.status == statusFilter)
            .toList();
      }

      interests.sort((a, b) =>
          b.sentAt.compareTo(a.sentAt));

      return interests;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // Query q = FirebaseFirestore.instance
      //     .collection('interests')
      //     .where('senderId', isEqualTo: uid)
      //     .orderBy('sentAt', descending: true);
      // if (statusFilter != null) {
      //   q = q.where('status',
      //       isEqualTo: statusFilter.value);
      // }
      // final snap = await q.get();
      // return snap.docs
      //     .map((d) => InterestModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      throw InterestException.fromCode('unknown');
    }
  }

  // ── GET CONNECTIONS ───────────────────────────────────

  /// Get all connections for a user.
  Future<List<ConnectionModel>> getConnections(
      String uid) async {
    try {
      await _delay(ms: 500);

      return _mockConnections.values
          .where((c) =>
      c.userIds.contains(uid) &&
          c.isConnected)
          .toList();

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('connections')
      //     .where('userIds',
      //         arrayContains: uid)
      //     .where('status',
      //         isEqualTo: 'connected')
      //     .get();
      // return snap.docs
      //     .map((d) => ConnectionModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      throw InterestException.fromCode('unknown');
    }
  }

  // ── GET INTEREST BY ID ────────────────────────────────

  /// Get a single interest by ID.
  Future<InterestModel?> getInterestById(
      String interestId) async {
    try {
      await _delay(ms: 300);
      return _mockInterests[interestId];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('interests')
      //     .doc(interestId)
      //     .get();
      // if (!snap.exists) return null;
      // return InterestModel.fromMap(
      //     snap.id, snap.data()!);
    } catch (e) {
      return null;
    }
  }

  // ── GET INTEREST BETWEEN ──────────────────────────────

  /// Get interest between two users (if any).
  Future<InterestModel?> getInterestBetween({
    required String uid1,
    required String uid2,
  }) async {
    try {
      await _delay(ms: 300);

      // Check both directions
      final id1 =
      InterestModel.generateId(uid1, uid2);
      final id2 =
      InterestModel.generateId(uid2, uid1);

      return _mockInterests[id1] ??
          _mockInterests[id2];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('interests')
      //     .where('senderId', isEqualTo: uid1)
      //     .where('receiverId', isEqualTo: uid2)
      //     .limit(1)
      //     .get();
      // if (snap.docs.isNotEmpty) {
      //   return InterestModel.fromMap(
      //       snap.docs.first.id,
      //       snap.docs.first.data());
      // }
      // // Check reverse
      // final snap2 = await FirebaseFirestore
      //     .instance
      //     .collection('interests')
      //     .where('senderId', isEqualTo: uid2)
      //     .where('receiverId', isEqualTo: uid1)
      //     .limit(1)
      //     .get();
      // if (snap2.docs.isNotEmpty) {
      //   return InterestModel.fromMap(
      //       snap2.docs.first.id,
      //       snap2.docs.first.data());
      // }
      // return null;
    } catch (e) {
      return null;
    }
  }

  // ── HAS ALREADY SENT ──────────────────────────────────

  /// Check if user has already sent interest to another.
  Future<bool> hasAlreadySent({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final interest = await getInterestBetween(
        uid1: senderId,
        uid2: receiverId,
      );
      return interest != null &&
          interest.senderId == senderId &&
          interest.isPending;
    } catch (e) {
      return false;
    }
  }

  // ── IS CONNECTED ──────────────────────────────────────

  /// Check if two users are connected.
  Future<bool> isConnected({
    required String uid1,
    required String uid2,
  }) async {
    try {
      final connId =
      ConnectionModel.generateId(uid1, uid2);
      final conn = _mockConnections[connId];
      return conn?.isConnected ?? false;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('connections')
      //     .doc(ConnectionModel.generateId(
      //         uid1, uid2))
      //     .get();
      // if (!snap.exists) return false;
      // final conn = ConnectionModel.fromMap(
      //     snap.id, snap.data()!);
      // return conn.isConnected;
    } catch (e) {
      return false;
    }
  }

  // ── GET SENT INTEREST IDS ─────────────────────────────

  /// Get all profile IDs user has sent interest to.
  /// Used to show "Interest Sent" state on cards.
  Future<Set<String>> getSentInterestIds(
      String uid) async {
    try {
      await _delay(ms: 300);

      return _mockInterests.values
          .where((i) =>
      i.senderId == uid &&
          i.isPending)
          .map((i) => i.receiverProfileId)
          .toSet();

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('interests')
      //     .where('senderId', isEqualTo: uid)
      //     .where('status', isEqualTo: 'pending')
      //     .get();
      // return snap.docs
      //     .map((d) => d.data()[
      //         'receiverProfileId'] as String)
      //     .toSet();
    } catch (e) {
      return {};
    }
  }

  // ── PENDING COUNT ─────────────────────────────────────

  /// Get count of pending interests received.
  Future<int> getPendingReceivedCount(
      String uid) async {
    try {
      await _delay(ms: 200);

      return _mockInterests.values
          .where((i) =>
      i.receiverId == uid &&
          i.isPending)
          .length;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('interests')
      //     .where('receiverId', isEqualTo: uid)
      //     .where('status', isEqualTo: 'pending')
      //     .count()
      //     .get();
      // return snap.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ── INTERESTS STREAM ──────────────────────────────────

  /// Real-time stream of received interests.
  Stream<List<InterestModel>> receivedInterestsStream(
      String uid) async* {
    yield await getReceivedInterests(uid: uid);

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('interests')
    //     .where('receiverId', isEqualTo: uid)
    //     .orderBy('sentAt', descending: true)
    //     .snapshots()
    //     .map((snap) => snap.docs
    //         .map((d) => InterestModel.fromMap(
    //             d.id, d.data()))
    //         .toList());
  }

  // ── CONNECTIONS STREAM ────────────────────────────────

  /// Real-time stream of connections.
  Stream<List<ConnectionModel>> connectionsStream(
      String uid) async* {
    yield await getConnections(uid);

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('connections')
    //     .where('userIds', arrayContains: uid)
    //     .where('status', isEqualTo: 'connected')
    //     .snapshots()
    //     .map((snap) => snap.docs
    //         .map((d) => ConnectionModel.fromMap(
    //             d.id, d.data()))
    //         .toList());
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  Future<void> _delay({int ms = 400}) async {
    await Future.delayed(
        Duration(milliseconds: ms));
  }
}