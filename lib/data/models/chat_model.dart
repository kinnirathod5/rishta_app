// lib/data/models/chat_model.dart

class ChatModel {
  final String id;
  final String connectionId;
  final List<String> participantIds; // [user1Id, user2Id]
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount; // {userId: count}
  final Map<String, bool> isMuted; // {userId: bool}
  final bool isActive;
  final DateTime createdAt;

  const ChatModel({
    required this.id,
    required this.connectionId,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCount = const {},
    this.isMuted = const {},
    this.isActive = true,
    required this.createdAt,
  });

  // ── FROM FIRESTORE ──────────────────────────────────
  factory ChatModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return ChatModel(
      id: id,
      connectionId: data['connectionId'] ?? '',
      participantIds:
      List<String>.from(data['participantIds'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageAt: data['lastMessageAt'] != null
          ? DateTime.parse(data['lastMessageAt'])
          : null,
      unreadCount: Map<String, int>.from(
          data['unreadCount'] ?? {}),
      isMuted: Map<String, bool>.from(
          data['isMuted'] ?? {}),
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  // ── TO FIRESTORE ────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'connectionId': connectionId,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'isMuted': isMuted,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ── COPY WITH ───────────────────────────────────────
  ChatModel copyWith({
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
    Map<String, bool>? isMuted,
    bool? isActive,
  }) {
    return ChatModel(
      id: id,
      connectionId: connectionId,
      participantIds: participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId:
      lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  // ── HELPERS ─────────────────────────────────────────
  int getUnreadCount(String userId) =>
      unreadCount[userId] ?? 0;

  bool getMuted(String userId) =>
      isMuted[userId] ?? false;

  String getOtherUserId(String currentUserId) {
    return participantIds.firstWhere(
          (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  bool hasUnread(String userId) =>
      getUnreadCount(userId) > 0;

  @override
  String toString() =>
      'ChatModel(id: $id, lastMessage: $lastMessage)';
}