// lib/data/repositories/notification_repository.dart
//
// NOTE: Firebase (cloud_firestore + fcm) Phase 3 mein add hoga.
// Tab actual Firestore + FCM calls uncomment karna hai.
// Abhi mock implementation se kaam chalega.

import 'package:rishta_app/data/models/notification_model.dart';

// ─────────────────────────────────────────────────────────
// NOTIFICATION EXCEPTIONS
// ─────────────────────────────────────────────────────────

class NotificationException implements Exception {
  final String code;
  final String message;

  const NotificationException({
    required this.code,
    required this.message,
  });

  factory NotificationException.fromCode(
      String code) {
    switch (code) {
      case 'not-found':
        return const NotificationException(
          code: 'not-found',
          message: 'Notification not found.',
        );
      case 'permission-denied':
        return const NotificationException(
          code: 'permission-denied',
          message: 'Push notification permission denied.',
        );
      case 'network-error':
        return const NotificationException(
          code: 'network-error',
          message: 'No internet connection. Please try again.',
        );
      default:
        return const NotificationException(
          code: 'unknown',
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  @override
  String toString() =>
      'NotificationException(code: $code, '
          'message: $message)';
}

// ─────────────────────────────────────────────────────────
// MOCK DATA STORE
// ─────────────────────────────────────────────────────────

final Map<String, List<NotificationModel>>
_mockNotifications = {};
final Map<String, String> _mockFcmTokens = {};

// ─────────────────────────────────────────────────────────
// NOTIFICATION REPOSITORY
// ─────────────────────────────────────────────────────────

class NotificationRepository {

  // ── CREATE NOTIFICATION ───────────────────────────────

  /// Create and store a new notification.
  Future<NotificationModel> createNotification(
      NotificationModel notification) async {
    try {
      await _delay(ms: 200);

      _mockNotifications[notification.userId] ??=
      [];
      _mockNotifications[notification.userId]!
          .insert(0, notification);

      return notification;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final ref = FirebaseFirestore.instance
      //     .collection('notifications')
      //     .doc(notification.id);
      // await ref.set(notification.toMap());
      // return notification;
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  // ── GET NOTIFICATIONS ─────────────────────────────────

  /// Get all notifications for a user.
  ///
  /// [limit] — max notifications to fetch
  /// [unreadOnly] — fetch only unread
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    try {
      await _delay(ms: 500);

      var notifications =
          _mockNotifications[userId] ?? [];

      if (unreadOnly) {
        notifications = notifications
            .where((n) => n.isUnread)
            .toList();
      }

      // Sort newest first
      notifications.sort((a, b) =>
          b.createdAt.compareTo(a.createdAt));

      return notifications.take(limit).toList();

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // Query q = FirebaseFirestore.instance
      //     .collection('notifications')
      //     .where('userId', isEqualTo: userId)
      //     .orderBy('createdAt', descending: true)
      //     .limit(limit);
      // if (unreadOnly) {
      //   q = q.where('isRead', isEqualTo: false);
      // }
      // final snap = await q.get();
      // return snap.docs
      //     .map((d) => NotificationModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  // ── GET UNREAD COUNT ──────────────────────────────────

  /// Get unread notification count for badge.
  Future<int> getUnreadCount(
      String userId) async {
    try {
      await _delay(ms: 200);

      return (_mockNotifications[userId] ?? [])
          .where((n) => n.isUnread)
          .length;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('notifications')
      //     .where('userId', isEqualTo: userId)
      //     .where('isRead', isEqualTo: false)
      //     .count()
      //     .get();
      // return snap.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ── MARK AS READ ──────────────────────────────────────

  /// Mark a single notification as read.
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _delay(ms: 200);

      final notifications =
      _mockNotifications[userId];
      if (notifications == null) return;

      final idx = notifications.indexWhere(
              (n) => n.id == notificationId);
      if (idx != -1) {
        notifications[idx] =
            notifications[idx].markRead();
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('notifications')
      //     .doc(notificationId)
      //     .update({
      //   'isRead': true,
      //   'readAt': FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  // ── MARK ALL AS READ ──────────────────────────────────

  /// Mark all notifications as read for a user.
  Future<void> markAllAsRead(
      String userId) async {
    try {
      await _delay(ms: 400);

      final notifications =
      _mockNotifications[userId];
      if (notifications == null) return;

      _mockNotifications[userId] = notifications
          .map((n) =>
      n.isUnread ? n.markRead() : n)
          .toList();

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('notifications')
      //     .where('userId', isEqualTo: userId)
      //     .where('isRead', isEqualTo: false)
      //     .get();
      // final batch =
      //     FirebaseFirestore.instance.batch();
      // for (final doc in snap.docs) {
      //   batch.update(doc.reference, {
      //     'isRead': true,
      //     'readAt': FieldValue.serverTimestamp(),
      //   });
      // }
      // await batch.commit();
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  // ── DELETE NOTIFICATION ───────────────────────────────

  /// Delete a single notification.
  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _delay(ms: 200);

      _mockNotifications[userId]?.removeWhere(
              (n) => n.id == notificationId);

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('notifications')
      //     .doc(notificationId)
      //     .delete();
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  // ── CLEAR ALL ─────────────────────────────────────────

  /// Delete all notifications for a user.
  Future<void> clearAll(String userId) async {
    try {
      await _delay(ms: 400);

      _mockNotifications[userId] = [];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('notifications')
      //     .where('userId', isEqualTo: userId)
      //     .get();
      // final batch =
      //     FirebaseFirestore.instance.batch();
      // for (final doc in snap.docs) {
      //   batch.delete(doc.reference);
      // }
      // await batch.commit();
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  // ── NOTIFICATIONS STREAM ──────────────────────────────

  /// Real-time stream of notifications for a user.
  Stream<List<NotificationModel>> notificationsStream(
      String userId) async* {
    yield await getNotifications(
        userId: userId);

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('notifications')
    //     .where('userId', isEqualTo: userId)
    //     .orderBy('createdAt', descending: true)
    //     .limit(50)
    //     .snapshots()
    //     .map((snap) => snap.docs
    //         .map((d) => NotificationModel.fromMap(
    //             d.id, d.data()))
    //         .toList());
  }

  // ── UNREAD COUNT STREAM ───────────────────────────────

  /// Real-time stream of unread count.
  Stream<int> unreadCountStream(
      String userId) async* {
    yield await getUnreadCount(userId);

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('notifications')
    //     .where('userId', isEqualTo: userId)
    //     .where('isRead', isEqualTo: false)
    //     .snapshots()
    //     .map((snap) => snap.docs.length);
  }

  // ── FCM TOKEN ─────────────────────────────────────────

  /// Save FCM token for push notifications.
  Future<void> saveFcmToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _delay(ms: 200);

      _mockFcmTokens[userId] = token;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .update({
      //   'fcmTokens':
      //       FieldValue.arrayUnion([token]),
      //   'updatedAt':
      //       FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  /// Remove FCM token (on logout/uninstall).
  Future<void> removeFcmToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _delay(ms: 200);

      _mockFcmTokens.remove(userId);

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .update({
      //   'fcmTokens':
      //       FieldValue.arrayRemove([token]),
      // });
    } catch (e) {
      throw NotificationException.fromCode(
          'unknown');
    }
  }

  // ── SEND PUSH NOTIFICATION ────────────────────────────

  /// Send FCM push notification to a user.
  ///
  /// Phase 3: Use Firebase Cloud Functions.
  Future<void> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      await _delay(ms: 300);

      // Mock: just log
      // ignore: avoid_print
      print(
          '[FCM Mock] To: $targetUserId | '
              'Title: $title | Body: $body');

      // ── PHASE 3 — CLOUD FUNCTIONS ───────────────
      // final callable = FirebaseFunctions
      //     .instance
      //     .httpsCallable('sendPushNotification');
      // await callable.call({
      //   'targetUserId': targetUserId,
      //   'title': title,
      //   'body': body,
      //   'data': data ?? {},
      // });
    } catch (e) {
      // Push notification failure should not
      // block the main flow — fail silently
    }
  }

  // ── PREDEFINED NOTIFICATION HELPERS ──────────────────

  /// Notify user about received interest.
  Future<void> notifyInterestReceived({
    required String targetUserId,
    required String senderId,
    required String senderName,
    required String senderEmoji,
    required String interestId,
  }) async {
    final notif =
    NotificationModel.interestReceived(
      userId: targetUserId,
      senderId: senderId,
      senderName: senderName,
      senderEmoji: senderEmoji,
      interestId: interestId,
    );
    await createNotification(notif);
    await sendPushNotification(
      targetUserId: targetUserId,
      title: notif.title,
      body: notif.body,
      data: {
        'type': notif.type.value,
        'route': notif.route ?? '/interests',
        'referenceId': interestId,
      },
    );
  }

  /// Notify user about accepted interest.
  Future<void> notifyInterestAccepted({
    required String targetUserId,
    required String acceptorId,
    required String acceptorName,
    required String acceptorEmoji,
    required String chatId,
  }) async {
    final notif =
    NotificationModel.interestAccepted(
      userId: targetUserId,
      senderId: acceptorId,
      senderName: acceptorName,
      senderEmoji: acceptorEmoji,
      chatId: chatId,
    );
    await createNotification(notif);
    await sendPushNotification(
      targetUserId: targetUserId,
      title: notif.title,
      body: notif.body,
      data: {
        'type': notif.type.value,
        'route': '/chat/$chatId',
        'referenceId': chatId,
      },
    );
  }

  /// Notify user about new message.
  Future<void> notifyNewMessage({
    required String targetUserId,
    required String senderId,
    required String senderName,
    required String senderEmoji,
    required String chatId,
    required String messagePreview,
  }) async {
    final notif = NotificationModel.newMessage(
      userId: targetUserId,
      senderId: senderId,
      senderName: senderName,
      senderEmoji: senderEmoji,
      chatId: chatId,
      messagePreview: messagePreview,
    );
    await createNotification(notif);
    await sendPushNotification(
      targetUserId: targetUserId,
      title: senderName,
      body: messagePreview,
      data: {
        'type': notif.type.value,
        'route': '/chat/$chatId',
        'referenceId': chatId,
      },
    );
  }

  /// Notify user about profile view.
  Future<void> notifyProfileViewed({
    required String targetUserId,
    required String viewerId,
    required String viewerName,
    required String viewerEmoji,
    required String viewerProfileId,
  }) async {
    final notif = NotificationModel.profileViewed(
      userId: targetUserId,
      viewerId: viewerId,
      viewerName: viewerName,
      viewerEmoji: viewerEmoji,
      viewerProfileId: viewerProfileId,
    );
    await createNotification(notif);
    await sendPushNotification(
      targetUserId: targetUserId,
      title: notif.title,
      body: notif.body,
      data: {
        'type': notif.type.value,
        'route': '/who-viewed',
      },
    );
  }

  /// Notify about premium expiring soon.
  Future<void> notifyPremiumExpiring({
    required String userId,
    required int daysLeft,
  }) async {
    final notif =
    NotificationModel.premiumExpiring(
      userId: userId,
      daysLeft: daysLeft,
    );
    await createNotification(notif);
    await sendPushNotification(
      targetUserId: userId,
      title: notif.title,
      body: notif.body,
      data: {
        'type': notif.type.value,
        'route': '/premium',
      },
    );
  }

  /// Notify about ID verification result.
  Future<void> notifyVerificationResult({
    required String userId,
    required bool isApproved,
  }) async {
    final notif = isApproved
        ? NotificationModel.verificationDone(
        userId: userId)
        : NotificationModel.verificationDone(
        userId: userId);
    await createNotification(notif);
    await sendPushNotification(
      targetUserId: userId,
      title: notif.title,
      body: notif.body,
      data: {
        'type': notif.type.value,
        'route': '/my-profile',
      },
    );
  }

  /// Notify about profile completion.
  Future<void> notifyProfileIncomplete({
    required String userId,
    required String missingSections,
  }) async {
    final notif =
    NotificationModel.profileIncomplete(
      userId: userId,
      missingSections: missingSections,
    );
    await createNotification(notif);
    await sendPushNotification(
      targetUserId: userId,
      title: notif.title,
      body: notif.body,
      data: {
        'type': notif.type.value,
        'route': '/my-profile',
      },
    );
  }

  // ── GET BY TYPE ───────────────────────────────────────

  /// Get notifications filtered by type.
  Future<List<NotificationModel>> getByType({
    required String userId,
    required NotificationType type,
  }) async {
    try {
      await _delay(ms: 300);

      return (_mockNotifications[userId] ?? [])
          .where((n) => n.type == type)
          .toList();

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('notifications')
      //     .where('userId', isEqualTo: userId)
      //     .where('type', isEqualTo: type.value)
      //     .orderBy('createdAt', descending: true)
      //     .get();
      // return snap.docs
      //     .map((d) => NotificationModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      return [];
    }
  }

  // ── GROUPED NOTIFICATIONS ─────────────────────────────

  /// Get notifications grouped by date.
  ///
  /// Returns Map<dateGroup, List<NotificationModel>>
  /// e.g. {'Today': [...], 'Yesterday': [...]}
  Future<Map<String, List<NotificationModel>>>
  getGrouped(String userId) async {
    try {
      final notifications =
      await getNotifications(userId: userId);

      final grouped =
      <String, List<NotificationModel>>{};

      for (final notif in notifications) {
        final group = notif.dateGroup;
        grouped[group] ??= [];
        grouped[group]!.add(notif);
      }

      return grouped;
    } catch (e) {
      return {};
    }
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  Future<void> _delay({int ms = 400}) async {
    await Future.delayed(
        Duration(milliseconds: ms));
  }
}