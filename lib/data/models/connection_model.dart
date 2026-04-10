// lib/data/models/connection_model.dart

class ConnectionModel {
  final String id;
  final String user1Id;
  final String profile1Id;
  final String user2Id;
  final String profile2Id;
  final String interestId; // reference to InterestModel
  final DateTime connectedAt;
  final bool isActive;
  final String? chatId; // linked ChatModel id

  const ConnectionModel({
    required this.id,
    required this.user1Id,
    required this.profile1Id,
    required this.user2Id,
    required this.profile2Id,
    required this.interestId,
    required this.connectedAt,
    this.isActive = true,
    this.chatId,
  });

  factory ConnectionModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return ConnectionModel(
      id: id,
      user1Id: data['user1Id'] ?? '',
      profile1Id: data['profile1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      profile2Id: data['profile2Id'] ?? '',
      interestId: data['interestId'] ?? '',
      connectedAt: data['connectedAt'] != null
          ? DateTime.parse(data['connectedAt'])
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
      chatId: data['chatId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'profile1Id': profile1Id,
      'user2Id': user2Id,
      'profile2Id': profile2Id,
      'interestId': interestId,
      'connectedAt': connectedAt.toIso8601String(),
      'isActive': isActive,
      'chatId': chatId,
    };
  }

  // Get the other user's id from current user's perspective
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  String getOtherProfileId(String currentUserId) {
    return currentUserId == user1Id ? profile2Id : profile1Id;
  }
}