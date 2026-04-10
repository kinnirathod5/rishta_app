// lib/data/models/message_model.dart

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum MessageType {
  text,
  image,
  audio,
  system,
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? mediaUrl; // image/audio ke liye
  final bool isDeleted;
  final String? replyToMessageId;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.mediaUrl,
    this.isDeleted = false,
    this.replyToMessageId,
  });

  // ── FROM FIRESTORE ──────────────────────────────────
  factory MessageModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.name == (data['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
            (e) => e.name == (data['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      sentAt: data['sentAt'] != null
          ? DateTime.parse(data['sentAt'])
          : DateTime.now(),
      deliveredAt: data['deliveredAt'] != null
          ? DateTime.parse(data['deliveredAt'])
          : null,
      readAt: data['readAt'] != null
          ? DateTime.parse(data['readAt'])
          : null,
      mediaUrl: data['mediaUrl'],
      isDeleted: data['isDeleted'] ?? false,
      replyToMessageId: data['replyToMessageId'],
    );
  }

  // ── TO FIRESTORE ────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'status': status.name,
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'mediaUrl': mediaUrl,
      'isDeleted': isDeleted,
      'replyToMessageId': replyToMessageId,
    };
  }

  // ── COPY WITH ───────────────────────────────────────
  MessageModel copyWith({
    MessageStatus? status,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isDeleted,
    String? content,
  }) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content ?? this.content,
      type: type,
      status: status ?? this.status,
      sentAt: sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      mediaUrl: mediaUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToMessageId: replyToMessageId,
    );
  }

  // ── HELPERS ─────────────────────────────────────────
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isRead => status == MessageStatus.read;
  bool get isFailed => status == MessageStatus.failed;
  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isSystem => type == MessageType.system;

  // Display content (deleted messages ke liye)
  String get displayContent {
    if (isDeleted) return 'Yeh message delete ho gaya';
    return content;
  }

  // Time format for chat bubble
  String get timeText {
    final hour = sentAt.hour > 12
        ? sentAt.hour - 12
        : sentAt.hour == 0 ? 12 : sentAt.hour;
    final min = sentAt.minute.toString().padLeft(2, '0');
    final period = sentAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }

  @override
  String toString() =>
      'MessageModel(id: $id, sender: $senderId, content: $content)';
}