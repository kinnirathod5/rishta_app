// lib/data/models/interest_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// INTEREST STATUS ENUM
// ─────────────────────────────────────────────────────────

enum InterestStatus {
  pending,   // Sent, waiting for response
  accepted,  // Receiver accepted
  declined,  // Receiver declined
  withdrawn, // Sender withdrew before response
  expired,   // No response within time limit
}

extension InterestStatusX on InterestStatus {
  String get value {
    switch (this) {
      case InterestStatus.pending:
        return 'pending';
      case InterestStatus.accepted:
        return 'accepted';
      case InterestStatus.declined:
        return 'declined';
      case InterestStatus.withdrawn:
        return 'withdrawn';
      case InterestStatus.expired:
        return 'expired';
    }
  }

  static InterestStatus fromString(String? value) {
    switch (value) {
      case 'accepted':
        return InterestStatus.accepted;
      case 'declined':
        return InterestStatus.declined;
      case 'withdrawn':
        return InterestStatus.withdrawn;
      case 'expired':
        return InterestStatus.expired;
      default:
        return InterestStatus.pending;
    }
  }

  /// Is this a terminal state (no more actions)
  bool get isTerminal =>
      this == InterestStatus.accepted ||
          this == InterestStatus.declined ||
          this == InterestStatus.withdrawn ||
          this == InterestStatus.expired;

  /// Display label for UI
  String get label {
    switch (this) {
      case InterestStatus.pending:
        return 'Pending';
      case InterestStatus.accepted:
        return 'Accepted';
      case InterestStatus.declined:
        return 'Declined';
      case InterestStatus.withdrawn:
        return 'Withdrawn';
      case InterestStatus.expired:
        return 'Expired';
    }
  }

  /// Emoji for status display
  String get emoji {
    switch (this) {
      case InterestStatus.pending:
        return '⏳';
      case InterestStatus.accepted:
        return '✅';
      case InterestStatus.declined:
        return '❌';
      case InterestStatus.withdrawn:
        return '↩️';
      case InterestStatus.expired:
        return '⌛';
    }
  }
}

// ─────────────────────────────────────────────────────────
// INTEREST MODEL
// ─────────────────────────────────────────────────────────

/// Represents an interest sent from one user to another.
///
/// Firestore path: /interests/{interestId}
///
/// Fields:
/// - [id]            Firestore document ID
/// - [senderId]      UID of user who sent interest
/// - [receiverId]    UID of user who received interest
/// - [senderProfileId]   Profile ID of sender
/// - [receiverProfileId] Profile ID of receiver
/// - [status]        pending/accepted/declined/withdrawn/expired
/// - [message]       Optional intro message
/// - [sentAt]        When interest was sent
/// - [respondedAt]   When receiver responded
/// - [expiresAt]     Auto-expiry timestamp (optional)
class InterestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderProfileId;
  final String receiverProfileId;
  final InterestStatus status;
  final String? message;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;

  const InterestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderProfileId,
    required this.receiverProfileId,
    this.status = InterestStatus.pending,
    this.message,
    required this.sentAt,
    this.respondedAt,
    this.expiresAt,
  });

  // ── COMPUTED ──────────────────────────────────────────

  bool get isPending =>
      status == InterestStatus.pending;

  bool get isAccepted =>
      status == InterestStatus.accepted;

  bool get isDeclined =>
      status == InterestStatus.declined;

  bool get isWithdrawn =>
      status == InterestStatus.withdrawn;

  bool get isExpired =>
      status == InterestStatus.expired;

  bool get isTerminal => status.isTerminal;

  bool get hasMessage =>
      message != null && message!.isNotEmpty;

  /// Is this interest expired based on current time
  bool get isExpiredNow =>
      expiresAt != null &&
          DateTime.now().isAfter(expiresAt!);

  /// Days remaining before expiry
  int? get daysUntilExpiry {
    if (expiresAt == null) return null;
    final diff =
    expiresAt!.difference(DateTime.now());
    return diff.inDays.clamp(0, 999);
  }

  /// Time ago text for sent time
  String get sentTimeAgo {
    final diff =
    DateTime.now().difference(sentAt);
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
    return '${sentAt.day}/${sentAt.month}/${sentAt.year}';
  }

  // ── FROM MAP ──────────────────────────────────────────

  /// From Firestore document data map.
  /// Phase 3: Pass doc.data() here.
  factory InterestModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return InterestModel(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      receiverId:
      data['receiverId'] as String? ?? '',
      senderProfileId:
      data['senderProfileId'] as String? ??
          '',
      receiverProfileId:
      data['receiverProfileId'] as String? ??
          '',
      status: InterestStatusX.fromString(
          data['status'] as String?),
      message: data['message'] as String?,
      sentAt:
      _parseDateTime(data['sentAt']) ??
          DateTime.now(),
      respondedAt:
      _parseDateTime(data['respondedAt']),
      expiresAt:
      _parseDateTime(data['expiresAt']),
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  /// To Firestore-compatible map.
  /// Phase 3: Pass to doc.set() / doc.update()
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderProfileId': senderProfileId,
      'receiverProfileId': receiverProfileId,
      'status': status.value,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'respondedAt':
      respondedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  InterestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? senderProfileId,
    String? receiverProfileId,
    InterestStatus? status,
    String? message,
    DateTime? sentAt,
    DateTime? respondedAt,
    DateTime? expiresAt,
  }) {
    return InterestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderProfileId:
      senderProfileId ?? this.senderProfileId,
      receiverProfileId: receiverProfileId ??
          this.receiverProfileId,
      status: status ?? this.status,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // ── STATUS TRANSITIONS ────────────────────────────────

  /// Accept this interest
  InterestModel accept() {
    return copyWith(
      status: InterestStatus.accepted,
      respondedAt: DateTime.now(),
    );
  }

  /// Decline this interest
  InterestModel decline() {
    return copyWith(
      status: InterestStatus.declined,
      respondedAt: DateTime.now(),
    );
  }

  /// Withdraw this interest (sender action)
  InterestModel withdraw() {
    return copyWith(
      status: InterestStatus.withdrawn,
      respondedAt: DateTime.now(),
    );
  }

  /// Mark as expired
  InterestModel expire() {
    return copyWith(
      status: InterestStatus.expired,
    );
  }

  // ── STATIC HELPERS ────────────────────────────────────

  /// Generate deterministic interest ID
  static String generateId(
      String senderId, String receiverId) {
    return '${senderId}_${receiverId}_interest';
  }

  /// Create a new interest
  factory InterestModel.create({
    required String senderId,
    required String receiverId,
    required String senderProfileId,
    required String receiverProfileId,
    String? message,
    Duration? expiryDuration,
  }) {
    final now = DateTime.now();
    return InterestModel(
      id: InterestModel.generateId(
          senderId, receiverId),
      senderId: senderId,
      receiverId: receiverId,
      senderProfileId: senderProfileId,
      receiverProfileId: receiverProfileId,
      status: InterestStatus.pending,
      message: message,
      sentAt: now,
      expiresAt: expiryDuration != null
          ? now.add(expiryDuration)
          : null,
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
      other is InterestModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InterestModel(id: $id, '
          'from: $senderId → to: $receiverId, '
          'status: ${status.value})';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension InterestModelFirestore on InterestModel {
  static InterestModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return InterestModel.fromMap(doc.id, {
      ...data,
      'sentAt':
          (data['sentAt'] as Timestamp?)
              ?.toDate(),
      'respondedAt':
          (data['respondedAt'] as Timestamp?)
              ?.toDate(),
      'expiresAt':
          (data['expiresAt'] as Timestamp?)
              ?.toDate(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    return {
      ...map,
      'sentAt': Timestamp.fromDate(sentAt),
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
      'expiresAt': expiresAt != null
          ? Timestamp.fromDate(expiresAt!)
          : null,
    };
  }
}
*/