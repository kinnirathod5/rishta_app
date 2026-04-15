// lib/data/repositories/chat_repository.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab actual Firestore calls uncomment karna hai.
// Abhi mock implementation se kaam chalega.

import 'package:rishta_app/data/models/chat_model.dart';
import 'package:rishta_app/data/models/message_model.dart';

// ─────────────────────────────────────────────────────────
// CHAT EXCEPTIONS
// ─────────────────────────────────────────────────────────

class ChatException implements Exception {
  final String code;
  final String message;

  const ChatException({
    required this.code,
    required this.message,
  });

  factory ChatException.fromCode(String code) {
    switch (code) {
      case 'chat-not-found':
        return const ChatException(
          code: 'chat-not-found',
          message: 'Chat not found.',
        );
      case 'not-connected':
        return const ChatException(
          code: 'not-connected',
          message: 'You are not connected with this user.',
        );
      case 'user-blocked':
        return const ChatException(
          code: 'user-blocked',
          message: 'You cannot message this user.',
        );
      case 'message-too-long':
        return const ChatException(
          code: 'message-too-long',
          message: 'Message is too long. Max 1000 characters.',
        );
      case 'network-error':
        return const ChatException(
          code: 'network-error',
          message: 'No internet connection. Please try again.',
        );
      default:
        return const ChatException(
          code: 'unknown',
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  @override
  String toString() =>
      'ChatException(code: $code, message: $message)';
}

// ─────────────────────────────────────────────────────────
// MOCK DATA STORE
// ─────────────────────────────────────────────────────────

// In-memory mock store — Phase 3 mein Firestore se replace
final Map<String, ChatModel> _mockChats = {};
final Map<String, List<MessageModel>> _mockMessages = {};

// ─────────────────────────────────────────────────────────
// CHAT REPOSITORY
// ─────────────────────────────────────────────────────────

class ChatRepository {

  // ── CREATE CHAT ───────────────────────────────────────

  /// Create or get existing chat between two users.
  ///
  /// Returns existing chat if already exists.
  Future<ChatModel> createChat({
    required String uid1,
    required String uid2,
  }) async {
    try {
      await _delay();

      final chatId =
      ChatModel.generateId(uid1, uid2);

      // Return existing if found
      if (_mockChats.containsKey(chatId)) {
        return _mockChats[chatId]!;
      }

      // Create new chat
      final chat = ChatModel.create(
        uid1: uid1,
        uid2: uid2,
      );
      _mockChats[chatId] = chat;
      _mockMessages[chatId] = [];

      return chat;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final chatId =
      //     ChatModel.generateId(uid1, uid2);
      // final ref = FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatId);
      // final snap = await ref.get();
      // if (snap.exists) {
      //   return ChatModel.fromMap(
      //       snap.id, snap.data()!);
      // }
      // final chat = ChatModel.create(
      //     uid1: uid1, uid2: uid2);
      // await ref.set(chat.toMap());
      // return chat;
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── GET CHAT ──────────────────────────────────────────

  /// Get a chat by its ID.
  Future<ChatModel?> getChat(
      String chatId) async {
    try {
      await _delay(ms: 300);
      return _mockChats[chatId];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .get();
      // if (!snap.exists) return null;
      // return ChatModel.fromMap(
      //     snap.id, snap.data()!);
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── GET USER CHATS ────────────────────────────────────

  /// Get all chats for a user, sorted by latest.
  Future<List<ChatModel>> getUserChats(
      String uid) async {
    try {
      await _delay(ms: 600);

      final chats = _mockChats.values
          .where((c) =>
      c.participantIds.contains(uid) &&
          c.isActive)
          .toList();

      // Sort by latest message
      chats.sort((a, b) {
        final aTime = a.lastMessageTime ??
            a.createdAt;
        final bTime = b.lastMessageTime ??
            b.createdAt;
        return bTime.compareTo(aTime);
      });

      return chats;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('chats')
      //     .where('participantIds',
      //         arrayContains: uid)
      //     .where('status', isEqualTo: 'active')
      //     .orderBy('updatedAt', descending: true)
      //     .get();
      // return snap.docs
      //     .map((d) => ChatModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── SEND MESSAGE ──────────────────────────────────────

  /// Send a text message in a chat.
  ///
  /// Returns sent message with updated status.
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? replyTo,
    String? replyText,
  }) async {
    try {
      // Validate
      if (text.trim().isEmpty) {
        throw const ChatException(
          code: 'empty-message',
          message: 'Message cannot be empty.',
        );
      }
      if (text.length > 1000) {
        throw ChatException.fromCode(
            'message-too-long');
      }

      // Optimistic message
      final msg = MessageModel.text(
        chatId: chatId,
        senderId: senderId,
        text: text.trim(),
        replyTo: replyTo,
        replyText: replyText,
      );

      // Add to mock store
      _mockMessages[chatId] ??= [];
      _mockMessages[chatId]!.add(msg);

      await _delay(ms: 400);

      // Mark as sent
      final sentMsg = msg.markSent();
      _updateMessage(chatId, sentMsg);

      // Update chat's last message
      _updateChatLastMessage(
        chatId: chatId,
        senderId: senderId,
        lastMessage: text.trim(),
      );

      return sentMsg;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final chatRef = FirebaseFirestore
      //     .instance.collection('chats').doc(chatId);
      // final msgRef =
      //     chatRef.collection('messages').doc();
      // final msg = MessageModel.text(
      //     chatId: chatId,
      //     senderId: senderId,
      //     text: text,
      //     replyTo: replyTo,
      //     replyText: replyText);
      // final batch =
      //     FirebaseFirestore.instance.batch();
      // batch.set(msgRef, msg.toMap());
      // batch.update(chatRef, {
      //   'lastMessage': text,
      //   'lastMessageTime':
      //       FieldValue.serverTimestamp(),
      //   'lastMessageBy': senderId,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      // await batch.commit();
      // return msg.copyWith(id: msgRef.id);
    } on ChatException {
      rethrow;
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── SEND IMAGE MESSAGE ────────────────────────────────

  /// Send an image message.
  Future<MessageModel> sendImageMessage({
    required String chatId,
    required String senderId,
    required String imageUrl,
    int? imageSize,
    String? caption,
  }) async {
    try {
      await _delay(ms: 600);

      final msg = MessageModel.image(
        chatId: chatId,
        senderId: senderId,
        mediaUrl: imageUrl,
        mediaSize: imageSize,
        text: caption,
      );

      _mockMessages[chatId] ??= [];
      _mockMessages[chatId]!.add(msg);

      final sentMsg = msg.markSent();
      _updateMessage(chatId, sentMsg);

      _updateChatLastMessage(
        chatId: chatId,
        senderId: senderId,
        lastMessage: caption ?? '📷 Photo',
      );

      return sentMsg;
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── GET MESSAGES ──────────────────────────────────────

  /// Get messages for a chat, paginated.
  Future<List<MessageModel>> getMessages({
    required String chatId,
    int limit = 30,
    String? lastMessageId,
  }) async {
    try {
      await _delay(ms: 500);

      final all = _mockMessages[chatId] ?? [];

      // Filter deleted messages
      final visible = all
          .where((m) => !m.isDeleted)
          .toList();

      // Sort oldest first
      visible.sort((a, b) =>
          a.sentAt.compareTo(b.sentAt));

      // Pagination
      if (lastMessageId != null) {
        final idx = visible.indexWhere(
                (m) => m.id == lastMessageId);
        if (idx > 0) {
          final start =
          (idx - limit).clamp(0, idx);
          return visible.sublist(start, idx);
        }
      }

      // Return last [limit] messages
      if (visible.length > limit) {
        return visible.sublist(
            visible.length - limit);
      }
      return visible;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // Query q = FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .collection('messages')
      //     .orderBy('sentAt', descending: true)
      //     .limit(limit);
      // if (lastMessageId != null) {
      //   final lastDoc = await FirebaseFirestore
      //       .instance
      //       .collection('chats')
      //       .doc(chatId)
      //       .collection('messages')
      //       .doc(lastMessageId)
      //       .get();
      //   q = q.startAfterDocument(lastDoc);
      // }
      // final snap = await q.get();
      // return snap.docs
      //     .map((d) => MessageModel.fromMap(
      //         d.id, d.data()))
      //     .toList()
      //     .reversed
      //     .toList();
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── MESSAGES STREAM ───────────────────────────────────

  /// Real-time stream of messages for a chat.
  Stream<List<MessageModel>> messagesStream(
      String chatId) async* {
    // Mock: yield once then listen for changes
    yield _mockMessages[chatId] ?? [];

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('chats')
    //     .doc(chatId)
    //     .collection('messages')
    //     .orderBy('sentAt')
    //     .snapshots()
    //     .map((snap) => snap.docs
    //         .map((d) => MessageModel.fromMap(
    //             d.id, d.data()))
    //         .toList());
  }

  // ── CHATS STREAM ──────────────────────────────────────

  /// Real-time stream of user's chats.
  Stream<List<ChatModel>> chatsStream(
      String uid) async* {
    yield await getUserChats(uid);

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('chats')
    //     .where('participantIds',
    //         arrayContains: uid)
    //     .where('status', isEqualTo: 'active')
    //     .orderBy('updatedAt', descending: true)
    //     .snapshots()
    //     .map((snap) => snap.docs
    //         .map((d) => ChatModel.fromMap(
    //             d.id, d.data()))
    //         .toList());
  }

  // ── MARK MESSAGES READ ────────────────────────────────

  /// Mark all unread messages in a chat as read.
  Future<void> markMessagesRead({
    required String chatId,
    required String readerUid,
  }) async {
    try {
      await _delay(ms: 300);

      final messages = _mockMessages[chatId];
      if (messages == null) return;

      // Mark unread messages as read
      for (int i = 0; i < messages.length; i++) {
        final msg = messages[i];
        if (msg.senderId != readerUid &&
            !msg.isRead) {
          messages[i] = msg.markRead();
        }
      }

      // Reset unread count
      if (_mockChats.containsKey(chatId)) {
        final chat = _mockChats[chatId]!;
        final updated =
        Map<String, int>.from(
            chat.unreadCount);
        updated[readerUid] = 0;
        _mockChats[chatId] =
            chat.copyWith(unreadCount: updated);
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final batch =
      //     FirebaseFirestore.instance.batch();
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .collection('messages')
      //     .where('senderId',
      //         isNotEqualTo: readerUid)
      //     .where('status',
      //         isNotEqualTo: 'read')
      //     .get();
      // for (final doc in snap.docs) {
      //   batch.update(doc.reference,
      //       {'status': 'read',
      //        'readAt': FieldValue.serverTimestamp()});
      // }
      // batch.update(
      //     FirebaseFirestore.instance
      //         .collection('chats')
      //         .doc(chatId),
      //     {'unreadCount.$readerUid': 0});
      // await batch.commit();
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── DELETE MESSAGE ────────────────────────────────────

  /// Delete a message (soft delete).
  ///
  /// [deleteForEveryone] — true: both see deleted
  /// [deleteForEveryone] — false: only sender sees
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String deleterUid,
    bool deleteForEveryone = false,
  }) async {
    try {
      await _delay(ms: 300);

      final messages = _mockMessages[chatId];
      if (messages == null) return;

      final idx = messages.indexWhere(
              (m) => m.id == messageId);
      if (idx == -1) return;

      if (deleteForEveryone) {
        messages[idx] =
            messages[idx].deleteForEveryone();
      } else {
        messages[idx] =
            messages[idx].deleteForUser(deleterUid);
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final ref = FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .collection('messages')
      //     .doc(messageId);
      // if (deleteForEveryone) {
      //   await ref.update({
      //     'isDeleted': true,
      //     'text': null,
      //     'mediaUrl': null,
      //   });
      // } else {
      //   await ref.update({
      //     'deletedFor':
      //         FieldValue.arrayUnion([deleterUid]),
      //   });
      // }
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── MUTE / UNMUTE CHAT ────────────────────────────────

  /// Toggle mute status for a chat.
  Future<void> toggleMuteChat({
    required String chatId,
    required String uid,
    required bool mute,
  }) async {
    try {
      await _delay(ms: 200);

      if (_mockChats.containsKey(chatId)) {
        final chat = _mockChats[chatId]!;
        final mutedBy =
        List<String>.from(chat.mutedBy);
        if (mute) {
          if (!mutedBy.contains(uid)) {
            mutedBy.add(uid);
          }
        } else {
          mutedBy.remove(uid);
        }
        _mockChats[chatId] =
            chat.copyWith(mutedBy: mutedBy);
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .update({
      //   'mutedBy': mute
      //       ? FieldValue.arrayUnion([uid])
      //       : FieldValue.arrayRemove([uid]),
      // });
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── ARCHIVE / DELETE CHAT ─────────────────────────────

  /// Archive a chat (hide from inbox).
  Future<void> archiveChat({
    required String chatId,
  }) async {
    try {
      await _delay(ms: 300);

      if (_mockChats.containsKey(chatId)) {
        _mockChats[chatId] = _mockChats[chatId]!
            .copyWith(status: ChatStatus.archived);
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .update({'status': 'archived'});
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  /// Soft delete a chat.
  Future<void> deleteChat({
    required String chatId,
  }) async {
    try {
      await _delay(ms: 300);
      _mockChats.remove(chatId);

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .update({'status': 'deleted',
      //              'updatedAt':
      //     FieldValue.serverTimestamp()});
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── TOTAL UNREAD COUNT ────────────────────────────────

  /// Get total unread message count for a user.
  Future<int> getTotalUnreadCount(
      String uid) async {
    try {
      await _delay(ms: 200);

      return _mockChats.values
          .where((c) =>
      c.participantIds.contains(uid) &&
          c.isActive &&
          !c.isMutedBy(uid))
          .fold<int>(0, (int sum, c) =>
      sum + c.unreadCountFor(uid));

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('chats')
      //     .where('participantIds',
      //         arrayContains: uid)
      //     .where('status', isEqualTo: 'active')
      //     .get();
      // return snap.docs.fold(0, (sum, doc) {
      //   final chat = ChatModel.fromMap(
      //       doc.id, doc.data());
      //   if (chat.isMutedBy(uid)) return sum;
      //   return sum + chat.unreadCountFor(uid);
      // });
    } catch (e) {
      return 0;
    }
  }

  // ── SYSTEM MESSAGE ────────────────────────────────────

  /// Send a system message (e.g. "You are connected!").
  Future<void> sendSystemMessage({
    required String chatId,
    required String text,
  }) async {
    try {
      await _delay(ms: 200);

      final msg = MessageModel.system(
        chatId: chatId,
        text: text,
      );

      _mockMessages[chatId] ??= [];
      _mockMessages[chatId]!.add(msg);

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatId)
      //     .collection('messages')
      //     .add(msg.toMap());
    } catch (e) {
      throw ChatException.fromCode('unknown');
    }
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  Future<void> _delay({int ms = 400}) async {
    await Future.delayed(
        Duration(milliseconds: ms));
  }

  void _updateMessage(
      String chatId, MessageModel msg) {
    final messages = _mockMessages[chatId];
    if (messages == null) return;
    final idx = messages.indexWhere(
            (m) => m.id == msg.id);
    if (idx != -1) messages[idx] = msg;
  }

  void _updateChatLastMessage({
    required String chatId,
    required String senderId,
    required String lastMessage,
  }) {
    if (!_mockChats.containsKey(chatId)) return;
    final chat = _mockChats[chatId]!;

    // Increment unread for other participants
    final updated =
    Map<String, int>.from(chat.unreadCount);
    for (final uid in chat.participantIds) {
      if (uid != senderId) {
        updated[uid] = (updated[uid] ?? 0) + 1;
      }
    }

    _mockChats[chatId] = chat.copyWith(
      lastMessage: lastMessage,
      lastMessageTime: DateTime.now(),
      lastMessageBy: senderId,
      unreadCount: updated,
      updatedAt: DateTime.now(),
    );
  }
}