// lib/data/repositories/notification_repository.dart

import '../models/notification_model.dart';

class NotificationRepository {
  // Singleton
  static final NotificationRepository _instance =
  NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  // ── CREATE NOTIFICATION ─────────────────────────────

  /// Naya notification banao
  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? referenceId,
    String? actionRoute,
    String? imageUrl,
    String? senderName,
    String? senderEmoji,
  }) async {
    // TODO: Firebase Phase mein uncomment karo
    // final notification = NotificationModel(
    //   id: '',
    //   userId: userId,
    //   type: type,
    //   title: title,
    //   body: body,
    //   referenceId: referenceId,
    //   actionRoute: actionRoute,
    //   imageUrl: imageUrl,
    //   senderName: senderName,
    //   senderEmoji: senderEmoji,
    //   createdAt: DateTime.now(),
    // );
    // final doc = await FirebaseFirestore.instance
    //   .collection('notifications')
    //   .add(notification.toFirestore());
    // return doc.id;

    await Future.delayed(const Duration(milliseconds: 200));
    return 'mock_notif_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ── GET NOTIFICATIONS ───────────────────────────────

  /// User ke saare notifications fetch karo
  Future<List<NotificationModel>> getUserNotifications(
      String userId, {
        int limit = 50,
        bool unreadOnly = false,
      }) async {
    // TODO: Firebase
    // var query = FirebaseFirestore.instance
    //   .collection('notifications')
    //   .where('userId', isEqualTo: userId)
    //   .orderBy('createdAt', descending: true)
    //   .limit(limit);
    //
    // if (unreadOnly) {
    //   query = query.where('isRead', isEqualTo: false);
    // }
    //
    // final snap = await query.get();
    // return snap.docs.map((doc) =>
    //   NotificationModel.fromFirestore(doc.data(), doc.id)).toList();

    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  // ── MARK AS READ ────────────────────────────────────

  /// Ek notification read karo
  Future<void> markAsRead(String notificationId) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('notifications')
    //   .doc(notificationId)
    //   .update({'isRead': true});

    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── MARK ALL AS READ ────────────────────────────────

  /// Saare notifications read karo
  Future<void> markAllAsRead(String userId) async {
    // TODO: Firebase — Batch update use karo
    // final unreadSnap = await FirebaseFirestore.instance
    //   .collection('notifications')
    //   .where('userId', isEqualTo: userId)
    //   .where('isRead', isEqualTo: false)
    //   .get();
    //
    // if (unreadSnap.docs.isEmpty) return;
    //
    // final batch = FirebaseFirestore.instance.batch();
    // for (final doc in unreadSnap.docs) {
    //   batch.update(doc.reference, {'isRead': true});
    // }
    // await batch.commit();

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── DELETE NOTIFICATION ─────────────────────────────

  /// Ek notification delete karo
  Future<void> deleteNotification(
      String notificationId) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('notifications')
    //   .doc(notificationId)
    //   .delete();

    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── CLEAR ALL ───────────────────────────────────────

  /// User ke saare notifications clear karo
  Future<void> clearAll(String userId) async {
    // TODO: Firebase
    // final snap = await FirebaseFirestore.instance
    //   .collection('notifications')
    //   .where('userId', isEqualTo: userId)
    //   .get();
    //
    // final batch = FirebaseFirestore.instance.batch();
    // for (final doc in snap.docs) {
    //   batch.delete(doc.reference);
    // }
    // await batch.commit();

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── UNREAD COUNT ────────────────────────────────────

  /// Unread notifications ki count
  Future<int> getUnreadCount(String userId) async {
    // TODO: Firebase
    // final snap = await FirebaseFirestore.instance
    //   .collection('notifications')
    //   .where('userId', isEqualTo: userId)
    //   .where('isRead', isEqualTo: false)
    //   .count()
    //   .get();
    // return snap.count;

    await Future.delayed(const Duration(milliseconds: 200));
    return 0;
  }

  // ── REALTIME STREAM ─────────────────────────────────

  /// Notifications ka realtime stream
  Stream<List<NotificationModel>> getNotificationsStream(
      String userId) {
    // TODO: Firebase
    // return FirebaseFirestore.instance
    //   .collection('notifications')
    //   .where('userId', isEqualTo: userId)
    //   .orderBy('createdAt', descending: true)
    //   .limit(50)
    //   .snapshots()
    //   .map((snap) => snap.docs.map((doc) =>
    //     NotificationModel.fromFirestore(doc.data(), doc.id)).toList());

    return Stream.value([]);
  }

  // ── UNREAD COUNT STREAM ─────────────────────────────

  /// Unread count ka realtime stream (badge ke liye)
  Stream<int> getUnreadCountStream(String userId) {
    // TODO: Firebase
    // return FirebaseFirestore.instance
    //   .collection('notifications')
    //   .where('userId', isEqualTo: userId)
    //   .where('isRead', isEqualTo: false)
    //   .snapshots()
    //   .map((snap) => snap.docs.length);

    return Stream.value(0);
  }

  // ── FCM TOKEN ───────────────────────────────────────

  /// Device ka FCM token save karo
  Future<void> saveFcmToken(
      String userId, String token) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('users')
    //   .doc(userId)
    //   .update({
    //     'fcmTokens': FieldValue.arrayUnion([token]),
    //     'lastTokenUpdated': DateTime.now().toIso8601String(),
    //   });

    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// FCM token remove karo (logout pe)
  Future<void> removeFcmToken(
      String userId, String token) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('users')
    //   .doc(userId)
    //   .update({
    //     'fcmTokens': FieldValue.arrayRemove([token]),
    //   });

    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── SEND PUSH NOTIFICATION ──────────────────────────
  // Note: Push notifications Cloud Functions se bhejte hain
  // Yeh sirf Firestore mein save karta hai
  // Cloud Functions automatically FCM push bhejta hai

  // ── PREDEFINED NOTIFICATIONS ────────────────────────

  /// Interest notification bhejo
  Future<void> sendInterestNotification({
    required String toUserId,
    required String senderName,
    required String senderEmoji,
    required String interestId,
  }) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.interest,
      title: 'Naya Interest! 💌',
      body: '$senderName ne aapko interest bheja',
      referenceId: interestId,
      actionRoute: '/interests',
      senderName: senderName,
      senderEmoji: senderEmoji,
    );
  }

  /// Accept notification bhejo
  Future<void> sendAcceptNotification({
    required String toUserId,
    required String accepterName,
    required String accepterEmoji,
    required String connectionId,
  }) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.accepted,
      title: 'Interest Accept Ho Gaya! 🎉',
      body: '$accepterName ne aapka interest accept kiya',
      referenceId: connectionId,
      actionRoute: '/interests',
      senderName: accepterName,
      senderEmoji: accepterEmoji,
    );
  }

  /// Message notification bhejo
  Future<void> sendMessageNotification({
    required String toUserId,
    required String senderName,
    required String messagePreview,
    required String chatId,
  }) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.message,
      title: 'Naya Message 💬',
      body: '$senderName: $messagePreview',
      referenceId: chatId,
      actionRoute: '/chat/$chatId',
      senderName: senderName,
    );
  }

  /// Profile view notification bhejo
  Future<void> sendProfileViewNotification({
    required String toUserId,
    required String viewerName,
  }) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.view,
      title: '${viewerName} ne profile dekhi 👁️',
      body: 'Aapki profile dekhi gayi',
      actionRoute: '/who-viewed',
      senderName: viewerName,
    );
  }
}