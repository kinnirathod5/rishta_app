// lib/data/models/message_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// MESSAGE TYPE ENUM
// ─────────────────────────────────────────────────────────

enum MessageType {
  text,     // Plain text message
  image,    // Image attachment
  audio,    // Voice message
  system,   // System generated (e.g. "You are now connected")
}

extension MessageTypeX on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:   return 'text';
      case MessageType.image:  return 'image';
      case MessageType.audio:  return 'audio';
      case MessageType.system: return 'system';
    }
  }

  static MessageType fromString(String? value) {
    switch (value) {
      case 'image':  return MessageType.image;
      case 'audio':  return MessageType.audio;
      case 'system': return MessageType.system;
      default:       return MessageType.text;
    }
  }

  bool get isText   => this == MessageType.text;
  bool get isImage  => this == MessageType.image;
  bool get isAudio  => this == MessageType.audio;
  bool get isSystem => this == MessageType.system;
}

// ─────────────────────────────────────────────────────────
// MESSAGE STATUS ENUM
// ─────────────────────────────────────────────────────────

enum MessageStatus {
  sending,   // Being sent (optimistic UI)
  sent,      // Delivered to Firestore
  delivered, // Delivered to receiver device
  read,      // Receiver has read it
  failed,    // Send failed
}

extension MessageStatusX on MessageStatus {
  String get value {
    switch (this) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }

  static MessageStatus fromString(String? value) {
    switch (value) {
      case 'sent':      return MessageStatus.sent;
      case 'delivered': return MessageStatus.delivered;
      case 'read':      return MessageStatus.read;
      case 'failed':    return MessageStatus.failed;
      default:          return MessageStatus.sending;
    }
  }

  /// Is message visible to receiver
  bool get isVisible =>
      this == MessageStatus.sent ||
          this == MessageStatus.delivered ||
          this == MessageStatus.read;

  /// Has message been read
  bool get isRead => this == MessageStatus.read;

  /// Is message in a failed state
  bool get isFailed => this == MessageStatus.failed;

  /// Tick icon count for UI
  /// 0 = sending, 1 = sent, 2 = delivered/read
  int get tickCount {
    switch (this) {
      case MessageStatus.sending:
        return 0;
      case MessageStatus.sent:
        return 1;
      case MessageStatus.delivered:
      case MessageStatus.read:
        return 2;
      case MessageStatus.failed:
        return 0;
    }
  }
}

// ─────────────────────────────────────────────────────────
// MESSAGE MODEL
// ─────────────────────────────────────────────────────────

/// Represents a single message in a chat conversation.
///
/// Firestore path: /chats/{chatId}/messages/{messageId}
///
/// Fields:
/// - [id]          Firestore document ID
/// - [chatId]      Parent chat document ID
/// - [senderId]    UID of sender
/// - [text]        Message text content
/// - [type]        text/image/audio/system
/// - [status]      sending/sent/delivered/read/failed
/// - [mediaUrl]    URL for image/audio attachments
/// - [mediaSize]   File size in bytes (for media)
/// - [duration]    Audio duration in seconds
/// - [isDeleted]   Soft delete flag
/// - [deletedFor]  List of UIDs who deleted this
/// - [replyTo]     ID of message being replied to
/// - [replyText]   Preview of replied message
/// - [sentAt]      When message was sent
/// - [readAt]      When receiver read the message
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String? text;
  final MessageType type;
  final MessageStatus status;
  final String? mediaUrl;
  final int? mediaSize;
  final int? duration;
  final bool isDeleted;
  final List<String> deletedFor;
  final String? replyTo;
  final String? replyText;
  final DateTime sentAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.text,
    this.type = MessageType.text,
    this.status = MessageStatus.sending,
    this.mediaUrl,
    this.mediaSize,
    this.duration,
    this.isDeleted = false,
    this.deletedFor = const [],
    this.replyTo,
    this.replyText,
    required this.sentAt,
    this.readAt,
  });

  // ── COMPUTED ──────────────────────────────────────────

  bool get isText   => type == MessageType.text;
  bool get isImage  => type == MessageType.image;
  bool get isAudio  => type == MessageType.audio;
  bool get isSystem => type == MessageType.system;

  bool get isSending =>
      status == MessageStatus.sending;
  bool get isSent =>
      status == MessageStatus.sent;
  bool get isDelivered =>
      status == MessageStatus.delivered;
  bool get isRead =>
      status == MessageStatus.read;
  bool get isFailed =>
      status == MessageStatus.failed;

  bool get hasMedia =>
      mediaUrl != null && mediaUrl!.isNotEmpty;

  bool get hasReply =>
      replyTo != null && replyTo!.isNotEmpty;

  /// Is this message deleted for a specific user
  bool isDeletedFor(String uid) =>
      isDeleted || deletedFor.contains(uid);

  /// Display text — handles deleted state
  String displayText(String myUid) {
    if (isDeleted) return 'This message was deleted';
    if (deletedFor.contains(myUid)) {
      return 'You deleted this message';
    }
    return text ?? '';
  }

  /// Chat time display — '3:45 PM'
  String get timeLabel {
    final h = sentAt.hour > 12
        ? sentAt.hour - 12
        : (sentAt.hour == 0 ? 12 : sentAt.hour);
    final m =
    sentAt.minute.toString().padLeft(2, '0');
    final period =
    sentAt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  /// Is this message from the same day as [other]
  bool isSameDay(MessageModel other) {
    return sentAt.year == other.sentAt.year &&
        sentAt.month == other.sentAt.month &&
        sentAt.day == other.sentAt.day;
  }

  /// Date label for chat separator
  String get dateSeparatorLabel {
    final now = DateTime.now();
    final diff = now.difference(sentAt);

    if (sentAt.year == now.year &&
        sentAt.month == now.month &&
        sentAt.day == now.day) {
      return 'Today';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${sentAt.day} ${_monthName(sentAt.month)} ${sentAt.year}';
  }

  // ── FROM MAP ──────────────────────────────────────────

  /// From Firestore document data map.
  /// Phase 3: Pass doc.data() here.
  factory MessageModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return MessageModel(
      id: id,
      chatId: data['chatId'] as String? ?? '',
      senderId:
      data['senderId'] as String? ?? '',
      text: data['text'] as String?,
      type: MessageTypeX.fromString(
          data['type'] as String?),
      status: MessageStatusX.fromString(
          data['status'] as String?),
      mediaUrl: data['mediaUrl'] as String?,
      mediaSize: data['mediaSize'] as int?,
      duration: data['duration'] as int?,
      isDeleted:
      data['isDeleted'] as bool? ?? false,
      deletedFor: List<String>.from(
          data['deletedFor'] ?? []),
      replyTo: data['replyTo'] as String?,
      replyText: data['replyText'] as String?,
      sentAt: _parseDateTime(data['sentAt']) ??
          DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  /// To Firestore-compatible map.
  /// Phase 3: Pass to doc.set() / doc.update()
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'type': type.value,
      'status': status.value,
      'mediaUrl': mediaUrl,
      'mediaSize': mediaSize,
      'duration': duration,
      'isDeleted': isDeleted,
      'deletedFor': deletedFor,
      'replyTo': replyTo,
      'replyText': replyText,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    MessageType? type,
    MessageStatus? status,
    String? mediaUrl,
    int? mediaSize,
    int? duration,
    bool? isDeleted,
    List<String>? deletedFor,
    String? replyTo,
    String? replyText,
    DateTime? sentAt,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaSize: mediaSize ?? this.mediaSize,
      duration: duration ?? this.duration,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedFor: deletedFor ?? this.deletedFor,
      replyTo: replyTo ?? this.replyTo,
      replyText: replyText ?? this.replyText,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // ── STATUS TRANSITIONS ────────────────────────────────

  /// Mark as successfully sent
  MessageModel markSent() =>
      copyWith(status: MessageStatus.sent);

  /// Mark as delivered to receiver
  MessageModel markDelivered() =>
      copyWith(status: MessageStatus.delivered);

  /// Mark as read by receiver
  MessageModel markRead() => copyWith(
    status: MessageStatus.read,
    readAt: DateTime.now(),
  );

  /// Mark as failed
  MessageModel markFailed() =>
      copyWith(status: MessageStatus.failed);

  /// Soft delete for everyone
  MessageModel deleteForEveryone() =>
      copyWith(isDeleted: true);

  /// Soft delete for specific user
  MessageModel deleteForUser(String uid) {
    final updated = List<String>.from(deletedFor)
      ..add(uid);
    return copyWith(deletedFor: updated);
  }

  // ── STATIC HELPERS ────────────────────────────────────

  /// Generate a unique message ID
  static String generateId() {
    return DateTime.now()
        .millisecondsSinceEpoch
        .toString();
  }

  /// Create a new text message
  factory MessageModel.text({
    required String chatId,
    required String senderId,
    required String text,
    String? replyTo,
    String? replyText,
  }) {
    return MessageModel(
      id: MessageModel.generateId(),
      chatId: chatId,
      senderId: senderId,
      text: text,
      type: MessageType.text,
      status: MessageStatus.sending,
      replyTo: replyTo,
      replyText: replyText,
      sentAt: DateTime.now(),
    );
  }

  /// Create a new image message
  factory MessageModel.image({
    required String chatId,
    required String senderId,
    required String mediaUrl,
    int? mediaSize,
    String? text,
  }) {
    return MessageModel(
      id: MessageModel.generateId(),
      chatId: chatId,
      senderId: senderId,
      text: text,
      type: MessageType.image,
      status: MessageStatus.sending,
      mediaUrl: mediaUrl,
      mediaSize: mediaSize,
      sentAt: DateTime.now(),
    );
  }

  /// Create a system message
  factory MessageModel.system({
    required String chatId,
    required String text,
  }) {
    return MessageModel(
      id: MessageModel.generateId(),
      chatId: chatId,
      senderId: 'system',
      text: text,
      type: MessageType.system,
      status: MessageStatus.sent,
      sentAt: DateTime.now(),
    );
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

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
      other is MessageModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MessageModel(id: $id, '
          'from: $senderId, '
          'type: ${type.value}, '
          'status: ${status.value}, '
          'text: $text)';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension MessageModelFirestore on MessageModel {
  static MessageModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MessageModel.fromMap(doc.id, {
      ...data,
      'sentAt':
          (data['sentAt'] as Timestamp?)
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
      'sentAt': Timestamp.fromDate(sentAt),
      'readAt': readAt != null
          ? Timestamp.fromDate(readAt!)
          : null,
    };
  }
}
*/