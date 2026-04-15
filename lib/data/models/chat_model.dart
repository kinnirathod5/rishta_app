// lib/data/models/chat_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// CHAT STATUS ENUM
// ─────────────────────────────────────────────────────────

enum ChatStatus {
  active,    // Normal active chat
  archived,  // Archived by user
  blocked,   // One user blocked the other
  deleted,   // Soft deleted
}

extension ChatStatusX on ChatStatus {
  String get value {
    switch (this) {
      case ChatStatus.active:   return 'active';
      case ChatStatus.archived: return 'archived';
      case ChatStatus.blocked:  return 'blocked';
      case ChatStatus.deleted:  return 'deleted';
    }
  }

  static ChatStatus fromString(String? value) {
    switch (value) {
      case 'archived': return ChatStatus.archived;
      case 'blocked':  return ChatStatus.blocked;
      case 'deleted':  return ChatStatus.deleted;
      default:         return ChatStatus.active;
    }
  }
}

// ─────────────────────────────────────────────────────────
// CHAT MODEL
// ─────────────────────────────────────────────────────────

/// Represents a chat conversation between two users.
///
/// Firestore path: /chats/{chatId}
class ChatModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageBy;
  final Map<String, int> unreadCount;
  final ChatStatus status;
  final List<String> mutedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageBy,
    this.unreadCount = const {},
    this.status = ChatStatus.active,
    this.mutedBy = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // ── COMPUTED ──────────────────────────────────────────

  /// Get the other participant's UID
  String otherUserId(String myUid) {
    return participantIds.firstWhere(
          (uid) => uid != myUid,
      orElse: () => '',
    );
  }

  /// Get unread count for a specific user
  int unreadCountFor(String uid) =>
      unreadCount[uid] ?? 0;

  /// Is chat muted by a specific user
  bool isMutedBy(String uid) =>
      mutedBy.contains(uid);

  bool get isActive =>
      status == ChatStatus.active;

  bool get hasUnread =>
      unreadCount.values.any((c) => c > 0);

  int get totalUnread =>
      unreadCount.values.fold(0, (a, b) => a + b);

  // ── FROM MAP ──────────────────────────────────────────

  /// From Firestore document data map.
  /// Phase 3: Pass doc.data() here.
  factory ChatModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return ChatModel(
      id: id,
      participantIds: List<String>.from(
          data['participantIds'] ?? []),
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime:
      _parseDateTime(data['lastMessageTime']),
      lastMessageBy:
      data['lastMessageBy'] as String?,
      unreadCount: Map<String, int>.from(
          data['unreadCount'] ?? {}),
      status: ChatStatusX.fromString(
          data['status'] as String?),
      mutedBy: List<String>.from(
          data['mutedBy'] ?? []),
      createdAt: _parseDateTime(
          data['createdAt']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(
          data['updatedAt']) ??
          DateTime.now(),
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  /// To Firestore-compatible map.
  /// Phase 3: Pass to doc.set() / doc.update()
  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime':
      lastMessageTime?.toIso8601String(),
      'lastMessageBy': lastMessageBy,
      'unreadCount': unreadCount,
      'status': status.value,
      'mutedBy': mutedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  ChatModel copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageBy,
    Map<String, int>? unreadCount,
    ChatStatus? status,
    List<String>? mutedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantIds:
      participantIds ?? this.participantIds,
      lastMessage:
      lastMessage ?? this.lastMessage,
      lastMessageTime:
      lastMessageTime ?? this.lastMessageTime,
      lastMessageBy:
      lastMessageBy ?? this.lastMessageBy,
      unreadCount:
      unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      mutedBy: mutedBy ?? this.mutedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── STATIC HELPERS ────────────────────────────────────

  /// Deterministic chat ID — order does not matter
  /// generateId('uid1','uid2') == generateId('uid2','uid1')
  static String generateId(
      String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Create a brand new chat between two users
  factory ChatModel.create({
    required String uid1,
    required String uid2,
  }) {
    final now = DateTime.now();
    return ChatModel(
      id: ChatModel.generateId(uid1, uid2),
      participantIds: [uid1, uid2],
      unreadCount: {uid1: 0, uid2: 0},
      status: ChatStatus.active,
      mutedBy: const [],
      createdAt: now,
      updatedAt: now,
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

  // ── EQUALITY ──────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is ChatModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ChatModel(id: $id, '
          'participants: $participantIds, '
          'lastMessage: $lastMessage, '
          'status: ${status.value})';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension ChatModelFirestore on ChatModel {
  static ChatModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChatModel.fromMap(doc.id, {
      ...data,
      'lastMessageTime':
          (data['lastMessageTime'] as Timestamp?)
              ?.toDate(),
      'createdAt':
          (data['createdAt'] as Timestamp?)
              ?.toDate(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)
              ?.toDate(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    return {
      ...map,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
*/