// lib/data/models/notification_model.dart

enum NotificationType {
  interest,   // naya interest aaya
  accepted,   // interest accept hua
  declined,   // interest decline hua
  message,    // naya message
  view,       // profile view
  match,      // naya match mila
  photo,      // photo approved
  complete,   // profile score update
  premium,    // premium expiry warning
  system,     // system notification
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? actionRoute; // navigation route on tap
  final String? referenceId; // interestId / chatId / profileId
  final String? imageUrl;
  final String? senderName;
  final String? senderEmoji;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
    this.actionRoute,
    this.referenceId,
    this.imageUrl,
    this.senderName,
    this.senderEmoji,
  });

  // ── FROM FIRESTORE ──────────────────────────────────
  factory NotificationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
            (e) => e.name == (data['type'] ?? 'system'),
        orElse: () => NotificationType.system,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      actionRoute: data['actionRoute'],
      referenceId: data['referenceId'],
      imageUrl: data['imageUrl'],
      senderName: data['senderName'],
      senderEmoji: data['senderEmoji'],
    );
  }

  // ── TO FIRESTORE ────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'actionRoute': actionRoute,
      'referenceId': referenceId,
      'imageUrl': imageUrl,
      'senderName': senderName,
      'senderEmoji': senderEmoji,
    };
  }

  // ── COPY WITH ───────────────────────────────────────
  NotificationModel copyWith({
    bool? isRead,
    String? actionRoute,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      actionRoute: actionRoute ?? this.actionRoute,
      referenceId: referenceId,
      imageUrl: imageUrl,
      senderName: senderName,
      senderEmoji: senderEmoji,
    );
  }

  // ── HELPERS ─────────────────────────────────────────

  // Notification ka emoji type ke hisaab se
  String get typeEmoji {
    switch (type) {
      case NotificationType.interest:
        return '💌';
      case NotificationType.accepted:
        return '✅';
      case NotificationType.declined:
        return '❌';
      case NotificationType.message:
        return '💬';
      case NotificationType.view:
        return '👁️';
      case NotificationType.match:
        return '💑';
      case NotificationType.photo:
        return '📸';
      case NotificationType.complete:
        return '🎯';
      case NotificationType.premium:
        return '👑';
      case NotificationType.system:
        return '🔔';
    }
  }

  // Time ago text
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Abhi';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute pehle';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ghante pehle';
    } else if (diff.inDays == 1) {
      return 'Kal';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} din pehle';
    } else if (diff.inDays < 30) {
      return '${diff.inDays ~/ 7} hafte pehle';
    } else {
      return '${diff.inDays ~/ 30} mahine pehle';
    }
  }

  // Date group ke liye (Aaj / Kal / Is Hafte)
  String get dateGroup {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) return 'Aaj';
    if (diff.inDays == 1) return 'Kal';
    if (diff.inDays < 7) return 'Is Hafte';
    return 'Pehle';
  }

  @override
  String toString() =>
      'NotificationModel(id: $id, type: ${type.name}, title: $title)';
}