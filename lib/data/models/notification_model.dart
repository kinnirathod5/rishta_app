// lib/data/models/notification_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// NOTIFICATION TYPE ENUM
// ─────────────────────────────────────────────────────────

enum NotificationType {
  interestReceived,   // Someone sent you an interest
  interestAccepted,   // Your interest was accepted
  interestDeclined,   // Your interest was declined
  newMessage,         // New chat message
  profileViewed,      // Someone viewed your profile
  connectionRequest,  // New connection request
  connected,          // You are now connected
  premiumExpiring,    // Subscription expiring soon
  premiumExpired,     // Subscription expired
  profileIncomplete,  // Profile completion reminder
  verificationDone,   // ID verification approved
  verificationFailed, // ID verification rejected
  newMatch,           // New profile match suggestion
  system,             // Generic system notification
}

extension NotificationTypeX on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.interestReceived:
        return 'interest_received';
      case NotificationType.interestAccepted:
        return 'interest_accepted';
      case NotificationType.interestDeclined:
        return 'interest_declined';
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.profileViewed:
        return 'profile_viewed';
      case NotificationType.connectionRequest:
        return 'connection_request';
      case NotificationType.connected:
        return 'connected';
      case NotificationType.premiumExpiring:
        return 'premium_expiring';
      case NotificationType.premiumExpired:
        return 'premium_expired';
      case NotificationType.profileIncomplete:
        return 'profile_incomplete';
      case NotificationType.verificationDone:
        return 'verification_done';
      case NotificationType.verificationFailed:
        return 'verification_failed';
      case NotificationType.newMatch:
        return 'new_match';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(
      String? value) {
    switch (value) {
      case 'interest_received':
        return NotificationType.interestReceived;
      case 'interest_accepted':
        return NotificationType.interestAccepted;
      case 'interest_declined':
        return NotificationType.interestDeclined;
      case 'new_message':
        return NotificationType.newMessage;
      case 'profile_viewed':
        return NotificationType.profileViewed;
      case 'connection_request':
        return NotificationType.connectionRequest;
      case 'connected':
        return NotificationType.connected;
      case 'premium_expiring':
        return NotificationType.premiumExpiring;
      case 'premium_expired':
        return NotificationType.premiumExpired;
      case 'profile_incomplete':
        return NotificationType.profileIncomplete;
      case 'verification_done':
        return NotificationType.verificationDone;
      case 'verification_failed':
        return NotificationType.verificationFailed;
      case 'new_match':
        return NotificationType.newMatch;
      default:
        return NotificationType.system;
    }
  }

  // ── DISPLAY ─────────────────────────────────────────

  /// Emoji icon for notification
  String get emoji {
    switch (this) {
      case NotificationType.interestReceived:
        return '💌';
      case NotificationType.interestAccepted:
        return '✅';
      case NotificationType.interestDeclined:
        return '❌';
      case NotificationType.newMessage:
        return '💬';
      case NotificationType.profileViewed:
        return '👁️';
      case NotificationType.connectionRequest:
        return '🤝';
      case NotificationType.connected:
        return '🎉';
      case NotificationType.premiumExpiring:
        return '⚠️';
      case NotificationType.premiumExpired:
        return '👑';
      case NotificationType.profileIncomplete:
        return '📝';
      case NotificationType.verificationDone:
        return '✅';
      case NotificationType.verificationFailed:
        return '❌';
      case NotificationType.newMatch:
        return '💫';
      case NotificationType.system:
        return '🔔';
    }
  }

  /// Category label for grouping
  String get category {
    switch (this) {
      case NotificationType.interestReceived:
      case NotificationType.interestAccepted:
      case NotificationType.interestDeclined:
      case NotificationType.connectionRequest:
      case NotificationType.connected:
        return 'Interests';
      case NotificationType.newMessage:
        return 'Messages';
      case NotificationType.profileViewed:
      case NotificationType.newMatch:
        return 'Profile';
      case NotificationType.premiumExpiring:
      case NotificationType.premiumExpired:
        return 'Subscription';
      case NotificationType.profileIncomplete:
      case NotificationType.verificationDone:
      case NotificationType.verificationFailed:
      case NotificationType.system:
        return 'Account';
    }
  }

  /// Is this notification actionable
  bool get isActionable {
    switch (this) {
      case NotificationType.interestReceived:
      case NotificationType.connectionRequest:
      case NotificationType.newMessage:
      case NotificationType.premiumExpiring:
      case NotificationType.premiumExpired:
      case NotificationType.profileIncomplete:
        return true;
      default:
        return false;
    }
  }
}

// ─────────────────────────────────────────────────────────
// NOTIFICATION MODEL
// ─────────────────────────────────────────────────────────

/// Represents an in-app notification for a user.
///
/// Firestore path: /notifications/{notificationId}
///
/// Fields:
/// - [id]          Firestore document ID
/// - [userId]      Recipient user UID
/// - [type]        NotificationType enum
/// - [title]       Short notification title
/// - [body]        Notification message body
/// - [imageUrl]    Optional sender photo/avatar URL
/// - [senderId]    UID of user who triggered it
/// - [senderName]  Name of sender (denormalized)
/// - [senderEmoji] Emoji of sender (denormalized)
/// - [referenceId] Related document ID (chatId, interestId etc.)
/// - [route]       Deep link route to navigate on tap
/// - [isRead]      Has user read this notification
/// - [createdAt]   When notification was created
/// - [readAt]      When user read it
class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? senderId;
  final String? senderName;
  final String? senderEmoji;
  final String? referenceId;
  final String? route;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.senderId,
    this.senderName,
    this.senderEmoji,
    this.referenceId,
    this.route,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  // ── COMPUTED ──────────────────────────────────────────

  bool get isUnread => !isRead;

  bool get hasImage =>
      imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasSender =>
      senderId != null && senderId!.isNotEmpty;

  bool get hasRoute =>
      route != null && route!.isNotEmpty;

  bool get isActionable => type.isActionable;

  /// Display emoji — sender emoji or type emoji
  String get displayEmoji =>
      senderEmoji ?? type.emoji;

  /// Time ago text
  String get timeAgo {
    final diff =
    DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${createdAt.day} ${_monthName(createdAt.month)}';
  }

  /// Date group for section headers
  String get dateGroup {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day) {
      return 'Today';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return 'This Week';
    if (diff.inDays < 30) return 'This Month';
    return 'Earlier';
  }

  // ── FROM MAP ──────────────────────────────────────────

  /// From Firestore document data map.
  /// Phase 3: Pass doc.data() here.
  factory NotificationModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return NotificationModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      type: NotificationTypeX.fromString(
          data['type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      senderEmoji:
      data['senderEmoji'] as String?,
      referenceId:
      data['referenceId'] as String?,
      route: data['route'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt:
      _parseDateTime(data['createdAt']) ??
          DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  /// To Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.value,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'senderId': senderId,
      'senderName': senderName,
      'senderEmoji': senderEmoji,
      'referenceId': referenceId,
      'route': route,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    String? senderId,
    String? senderName,
    String? senderEmoji,
    String? referenceId,
    String? route,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderEmoji:
      senderEmoji ?? this.senderEmoji,
      referenceId:
      referenceId ?? this.referenceId,
      route: route ?? this.route,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // ── STATUS TRANSITIONS ────────────────────────────────

  /// Mark as read
  NotificationModel markRead() => copyWith(
    isRead: true,
    readAt: DateTime.now(),
  );

  // ── FACTORY CONSTRUCTORS ──────────────────────────────

  /// Interest received notification
  factory NotificationModel.interestReceived({
    required String userId,
    required String senderId,
    required String senderName,
    required String senderEmoji,
    required String interestId,
  }) {
    return NotificationModel(
      id: _generateId(),
      userId: userId,
      type: NotificationType.interestReceived,
      title: 'New Interest! 💌',
      body:
      '$senderName sent you an interest',
      senderId: senderId,
      senderName: senderName,
      senderEmoji: senderEmoji,
      referenceId: interestId,
      route: '/interests',
      createdAt: DateTime.now(),
    );
  }

  /// Interest accepted notification
  factory NotificationModel.interestAccepted({
    required String userId,
    required String senderId,
    required String senderName,
    required String senderEmoji,
    required String chatId,
  }) {
    return NotificationModel(
      id: _generateId(),
      userId: userId,
      type: NotificationType.interestAccepted,
      title: 'Interest Accepted! 🎉',
      body: '$senderName accepted your interest',
      senderId: senderId,
      senderName: senderName,
      senderEmoji: senderEmoji,
      referenceId: chatId,
      route: '/chat/$chatId',
      createdAt: DateTime.now(),
    );
  }

  /// New message notification
  factory NotificationModel.newMessage({
    required String userId,
    required String senderId,
    required String senderName,
    required String senderEmoji,
    required String chatId,
    required String messagePreview,
  }) {
    return NotificationModel(
      id: _generateId(),
      userId: userId,
      type: NotificationType.newMessage,
      title: senderName,
      body: messagePreview,
      senderId: senderId,
      senderName: senderName,
      senderEmoji: senderEmoji,
      referenceId: chatId,
      route: '/chat/$chatId',
      createdAt: DateTime.now(),
    );
  }

  /// Profile viewed notification
  factory NotificationModel.profileViewed({
    required String userId,
    required String viewerId,
    required String viewerName,
    required String viewerEmoji,
    required String viewerProfileId,
  }) {
    return NotificationModel(
      id: _generateId(),
      userId: userId,
      type: NotificationType.profileViewed,
      title: 'Profile Viewed 👁️',
      body: '$viewerName viewed your profile',
      senderId: viewerId,
      senderName: viewerName,
      senderEmoji: viewerEmoji,
      referenceId: viewerProfileId,
      route: '/who-viewed',
      createdAt: DateTime.now(),
    );
  }

  /// Premium expiring notification
  factory NotificationModel.premiumExpiring({
    required String userId,
    required int daysLeft,
  }) {
    return NotificationModel(
      id: _generateId(),
      userId: userId,
      type: NotificationType.premiumExpiring,
      title: 'Premium Expiring Soon ⚠️',
      body:
      'Your premium plan expires in $daysLeft day${daysLeft == 1 ? '' : 's'}. Renew now!',
      route: '/premium',
      createdAt: DateTime.now(),
    );
  }

  /// Verification approved notification
  factory NotificationModel.verificationDone({
    required String userId,
  }) {
    return NotificationModel(
      id: _generateId(),
      userId: userId,
      type: NotificationType.verificationDone,
      title: 'ID Verified ✅',
      body:
      'Your profile is now verified. You will get more matches!',
      route: '/my-profile',
      createdAt: DateTime.now(),
    );
  }

  /// Profile incomplete reminder
  factory NotificationModel.profileIncomplete({
    required String userId,
    required String missingSections,
  }) {
    return NotificationModel(
      id: _generateId(),
      userId: userId,
      type: NotificationType.profileIncomplete,
      title: 'Complete Your Profile 📝',
      body:
      'Add $missingSections to get more matches',
      route: '/my-profile',
      createdAt: DateTime.now(),
    );
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  static String _generateId() =>
      'notif_${DateTime.now().millisecondsSinceEpoch}';

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    // Phase 3: Timestamp.toDate() handled here
    // if (value is Timestamp) return value.toDate();
    return null;
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  // ── EQUALITY ──────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is NotificationModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'NotificationModel(id: $id, '
          'type: ${type.value}, '
          'title: $title, '
          'isRead: $isRead)';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension NotificationModelFirestore
    on NotificationModel {
  static NotificationModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return NotificationModel.fromMap(doc.id, {
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp?)
              ?.toDate(),
      'readAt':
          (data['readAt'] as Timestamp?)
              ?.toDate(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    return {
      ...map,
      'createdAt':
          Timestamp.fromDate(createdAt),
      'readAt': readAt != null
          ? Timestamp.fromDate(readAt!)
          : null,
    };
  }
}
*/