// lib/data/models/connection_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// CONNECTION STATUS ENUM
// ─────────────────────────────────────────────────────────

enum ConnectionStatus {
  connected,    // Both accepted interests
  disconnected, // One removed connection
  blocked,      // One blocked the other
}

extension ConnectionStatusX on ConnectionStatus {
  String get value {
    switch (this) {
      case ConnectionStatus.connected:
        return 'connected';
      case ConnectionStatus.disconnected:
        return 'disconnected';
      case ConnectionStatus.blocked:
        return 'blocked';
    }
  }

  static ConnectionStatus fromString(String? value) {
    switch (value) {
      case 'disconnected':
        return ConnectionStatus.disconnected;
      case 'blocked':
        return ConnectionStatus.blocked;
      default:
        return ConnectionStatus.connected;
    }
  }
}

// ─────────────────────────────────────────────────────────
// CONNECTION MODEL
// ─────────────────────────────────────────────────────────

/// Represents a mutual connection between two users.
/// Created when both users accept each other's interest.
///
/// Firestore path: /connections/{connectionId}
class ConnectionModel {
  final String id;
  final List<String> userIds;
  final String? chatId;
  final ConnectionStatus status;
  final DateTime connectedAt;
  final DateTime updatedAt;
  final String initiatedBy;

  const ConnectionModel({
    required this.id,
    required this.userIds,
    this.chatId,
    this.status = ConnectionStatus.connected,
    required this.connectedAt,
    required this.updatedAt,
    required this.initiatedBy,
  });

  // ── COMPUTED ──────────────────────────────────────────

  /// Get the other user's UID
  String otherUserId(String myUid) {
    return userIds.firstWhere(
          (uid) => uid != myUid,
      orElse: () => '',
    );
  }

  bool get isConnected =>
      status == ConnectionStatus.connected;

  bool get isBlocked =>
      status == ConnectionStatus.blocked;

  bool get isDisconnected =>
      status == ConnectionStatus.disconnected;

  bool get hasChatId =>
      chatId != null && chatId!.isNotEmpty;

  // ── FROM MAP ──────────────────────────────────────────

  /// From Firestore document data map.
  /// Phase 3: Pass doc.data() here.
  factory ConnectionModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return ConnectionModel(
      id: id,
      userIds: List<String>.from(
          data['userIds'] ?? []),
      chatId: data['chatId'] as String?,
      status: ConnectionStatusX.fromString(
          data['status'] as String?),
      connectedAt: _parseDateTime(
          data['connectedAt']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(
          data['updatedAt']) ??
          DateTime.now(),
      initiatedBy:
      data['initiatedBy'] as String? ?? '',
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  /// To Firestore-compatible map.
  /// Phase 3: Pass to doc.set() / doc.update()
  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'chatId': chatId,
      'status': status.value,
      'connectedAt':
      connectedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'initiatedBy': initiatedBy,
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  ConnectionModel copyWith({
    String? id,
    List<String>? userIds,
    String? chatId,
    ConnectionStatus? status,
    DateTime? connectedAt,
    DateTime? updatedAt,
    String? initiatedBy,
  }) {
    return ConnectionModel(
      id: id ?? this.id,
      userIds: userIds ?? this.userIds,
      chatId: chatId ?? this.chatId,
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      initiatedBy: initiatedBy ?? this.initiatedBy,
    );
  }

  // ── STATIC HELPERS ────────────────────────────────────

  /// Deterministic connection ID — order does not matter
  /// generateId('uid1','uid2') == generateId('uid2','uid1')
  static String generateId(
      String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Create a brand new connection between two users
  factory ConnectionModel.create({
    required String uid1,
    required String uid2,
    required String initiatedBy,
    String? chatId,
  }) {
    final now = DateTime.now();
    return ConnectionModel(
      id: ConnectionModel.generateId(uid1, uid2),
      userIds: [uid1, uid2],
      chatId: chatId,
      status: ConnectionStatus.connected,
      connectedAt: now,
      updatedAt: now,
      initiatedBy: initiatedBy,
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
      other is ConnectionModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ConnectionModel(id: $id, '
          'users: $userIds, '
          'status: ${status.value})';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension ConnectionModelFirestore on ConnectionModel {
  static ConnectionModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ConnectionModel.fromMap(doc.id, {
      ...data,
      'connectedAt':
          (data['connectedAt'] as Timestamp?)
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
      'connectedAt':
          Timestamp.fromDate(connectedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
*/