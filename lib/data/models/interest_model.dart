// lib/data/models/interest_model.dart

enum InterestStatus { pending, accepted, declined, withdrawn }

class InterestModel {
  final String id;
  final String fromUserId;
  final String fromProfileId;
  final String toUserId;
  final String toProfileId;
  final InterestStatus status;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final String? message; // optional intro message

  const InterestModel({
    required this.id,
    required this.fromUserId,
    required this.fromProfileId,
    required this.toUserId,
    required this.toProfileId,
    this.status = InterestStatus.pending,
    required this.sentAt,
    this.respondedAt,
    this.message,
  });

  factory InterestModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return InterestModel(
      id: id,
      fromUserId: data['fromUserId'] ?? '',
      fromProfileId: data['fromProfileId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toProfileId: data['toProfileId'] ?? '',
      status: InterestStatus.values.firstWhere(
            (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => InterestStatus.pending,
      ),
      sentAt: data['sentAt'] != null
          ? DateTime.parse(data['sentAt'])
          : DateTime.now(),
      respondedAt: data['respondedAt'] != null
          ? DateTime.parse(data['respondedAt'])
          : null,
      message: data['message'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromProfileId': fromProfileId,
      'toUserId': toUserId,
      'toProfileId': toProfileId,
      'status': status.name,
      'sentAt': sentAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'message': message,
    };
  }

  InterestModel copyWith({
    InterestStatus? status,
    DateTime? respondedAt,
  }) {
    return InterestModel(
      id: id,
      fromUserId: fromUserId,
      fromProfileId: fromProfileId,
      toUserId: toUserId,
      toProfileId: toProfileId,
      status: status ?? this.status,
      sentAt: sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message,
    );
  }
}