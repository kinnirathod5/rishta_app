// lib/data/repositories/chat_repository.dart

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/connection_model.dart';

class ChatRepository {
  // Singleton
  static final ChatRepository _instance =
  ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal();

  // ── CREATE CHAT ─────────────────────────────────────

  /// Connection accept hone ke baad chat banao
  Future<String> createChat(ConnectionModel connection) async {
    // TODO: Firebase Phase mein uncomment karo
    // final chat = ChatModel(
    //   id: '',
    //   connectionId: connection.id,
    //   participantIds: [connection.user1Id, connection.user2Id],
    //   createdAt: DateTime.now(),
    // );
    // final doc = await FirebaseFirestore.instance
    //   .collection('chats')
    //   .add(chat.toFirestore());
    // return doc.id;

    await Future.delayed(const Duration(milliseconds: 300));
    return 'mock_chat_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ── GET USER CHATS ──────────────────────────────────

  /// User ke saare chats fetch karo
  Future<List<ChatModel>> getUserChats(String userId) async {
    // TODO: Firebase
    // final snap = await FirebaseFirestore.instance
    //   .collection('chats')
    //   .where('participantIds', arrayContains: userId)
    //   .where('isActive', isEqualTo: true)
    //   .orderBy('lastMessageAt', descending: true)
    //   .get();
    // return snap.docs.map((doc) =>
    //   ChatModel.fromFirestore(doc.data(), doc.id)).toList();

    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }

  // ── GET SINGLE CHAT ─────────────────────────────────

  Future<ChatModel?> getChat(String chatId) async {
    // TODO: Firebase
    // final doc = await FirebaseFirestore.instance
    //   .collection('chats')
    //   .doc(chatId)
    //   .get();
    // if (!doc.exists) return null;
    // return ChatModel.fromFirestore(doc.data()!, doc.id);

    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }

  // ── CHATS REALTIME STREAM ───────────────────────────

  /// User ke chats ka realtime stream
  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    // TODO: Firebase
    // return FirebaseFirestore.instance
    //   .collection('chats')
    //   .where('participantIds', arrayContains: userId)
    //   .where('isActive', isEqualTo: true)
    //   .orderBy('lastMessageAt', descending: true)
    //   .snapshots()
    //   .map((snap) => snap.docs.map((doc) =>
    //     ChatModel.fromFirestore(doc.data(), doc.id)).toList());

    return Stream.value([]);
  }

  // ── SEND MESSAGE ────────────────────────────────────

  /// Naya message bhejo
  Future<String> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? replyToMessageId,
  }) async {
    // TODO: Firebase — Batch write use karo
    // final batch = FirebaseFirestore.instance.batch();
    //
    // 1. Message add karo
    // final msgRef = FirebaseFirestore.instance
    //   .collection('chats/$chatId/messages')
    //   .doc();
    //
    // final message = MessageModel(
    //   id: msgRef.id,
    //   chatId: chatId,
    //   senderId: senderId,
    //   content: content,
    //   type: type,
    //   status: MessageStatus.sent,
    //   sentAt: DateTime.now(),
    //   mediaUrl: mediaUrl,
    //   replyToMessageId: replyToMessageId,
    // );
    // batch.set(msgRef, message.toFirestore());
    //
    // 2. Chat lastMessage update karo
    // final chatRef = FirebaseFirestore.instance
    //   .collection('chats')
    //   .doc(chatId);
    // batch.update(chatRef, {
    //   'lastMessage': type == MessageType.text
    //     ? content : '📷 Photo',
    //   'lastMessageSenderId': senderId,
    //   'lastMessageAt': DateTime.now().toIso8601String(),
    //   'unreadCount.${otherUserId}': FieldValue.increment(1),
    // });
    //
    // await batch.commit();
    // return msgRef.id;

    await Future.delayed(const Duration(milliseconds: 200));
    return 'mock_msg_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ── GET MESSAGES ────────────────────────────────────

  /// Chat ke messages fetch karo (pagination)
  Future<List<MessageModel>> getMessages(
      String chatId, {
        int limit = 30,
        String? lastMessageId,
      }) async {
    // TODO: Firebase
    // var query = FirebaseFirestore.instance
    //   .collection('chats/$chatId/messages')
    //   .orderBy('sentAt', descending: true)
    //   .limit(limit);
    //
    // if (lastMessageId != null) {
    //   final lastDoc = await FirebaseFirestore.instance
    //     .collection('chats/$chatId/messages')
    //     .doc(lastMessageId)
    //     .get();
    //   query = query.startAfterDocument(lastDoc);
    // }
    //
    // final snap = await query.get();
    // return snap.docs.map((doc) =>
    //   MessageModel.fromFirestore(doc.data(), doc.id))
    //   .toList()
    //   .reversed
    //   .toList();

    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  // ── MESSAGES REALTIME STREAM ────────────────────────

  /// Messages ka realtime stream
  Stream<List<MessageModel>> getMessagesStream(
      String chatId) {
    // TODO: Firebase
    // return FirebaseFirestore.instance
    //   .collection('chats/$chatId/messages')
    //   .orderBy('sentAt', descending: false)
    //   .snapshots()
    //   .map((snap) => snap.docs.map((doc) =>
    //     MessageModel.fromFirestore(doc.data(), doc.id)).toList());

    return Stream.value([]);
  }

  // ── MARK AS READ ────────────────────────────────────

  /// Messages ko read mark karo
  Future<void> markMessagesAsRead(
      String chatId, String userId) async {
    // TODO: Firebase
    // Unread count reset karo
    // await FirebaseFirestore.instance
    //   .collection('chats')
    //   .doc(chatId)
    //   .update({'unreadCount.$userId': 0});
    //
    // Recent unread messages ko read mark karo
    // final unreadMessages = await FirebaseFirestore.instance
    //   .collection('chats/$chatId/messages')
    //   .where('senderId', isNotEqualTo: userId)
    //   .where('status', whereIn: ['sent', 'delivered'])
    //   .get();
    //
    // final batch = FirebaseFirestore.instance.batch();
    // for (final doc in unreadMessages.docs) {
    //   batch.update(doc.reference, {
    //     'status': MessageStatus.read.name,
    //     'readAt': DateTime.now().toIso8601String(),
    //   });
    // }
    // await batch.commit();

    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── DELETE MESSAGE ──────────────────────────────────

  /// Message delete karo
  Future<void> deleteMessage(
      String chatId, String messageId) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('chats/$chatId/messages')
    //   .doc(messageId)
    //   .update({'isDeleted': true});

    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── DELETE CHAT ─────────────────────────────────────

  /// Poora chat delete karo
  Future<void> deleteChat(
      String chatId, String userId) async {
    // TODO: Firebase
    // User ke liye chat hide karo
    // await FirebaseFirestore.instance
    //   .collection('chats')
    //   .doc(chatId)
    //   .update({'deletedBy.$userId': true});

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── MUTE CHAT ───────────────────────────────────────

  /// Chat mute/unmute karo
  Future<void> muteChat(
      String chatId, String userId, bool mute) async {
    // TODO: Firebase
    // await FirebaseFirestore.instance
    //   .collection('chats')
    //   .doc(chatId)
    //   .update({'isMuted.$userId': mute});

    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── UPLOAD MEDIA ────────────────────────────────────

  /// Chat mein photo bhejo
  Future<String> uploadChatMedia(
      String chatId, String localPath) async {
    // TODO: Firebase Storage
    // final ref = FirebaseStorage.instance
    //   .ref('chats/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    // await ref.putFile(File(localPath));
    // return await ref.getDownloadURL();

    await Future.delayed(const Duration(seconds: 1));
    return 'https://placeholder.com/chat_image.jpg';
  }

  // ── TOTAL UNREAD COUNT ──────────────────────────────

  /// User ke total unread messages ki count
  Future<int> getTotalUnreadCount(String userId) async {
    // TODO: Firebase
    // final chats = await getUserChats(userId);
    // return chats.fold(0, (sum, chat) =>
    //   sum + chat.getUnreadCount(userId));

    await Future.delayed(const Duration(milliseconds: 200));
    return 0;
  }
}