// lib/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rishta_app/data/models/chat_model.dart';
import 'package:rishta_app/data/models/message_model.dart';
import 'package:rishta_app/data/repositories/chat_repository.dart';
import 'package:rishta_app/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────

final chatRepositoryProvider =
Provider<ChatRepository>(
      (ref) => ChatRepository(),
);

// ─────────────────────────────────────────────────────────
// CHATS STATE
// ─────────────────────────────────────────────────────────

class ChatsState {
  final List<ChatModel> chats;
  final bool isLoading;
  final String? error;

  const ChatsState({
    this.chats = const [],
    this.isLoading = false,
    this.error,
  });

  ChatsState copyWith({
    List<ChatModel>? chats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  // ── COMPUTED ──────────────────────────────────────────

  bool get isEmpty => chats.isEmpty;

  bool get hasError =>
      error != null && error!.isNotEmpty;

  int get totalCount => chats.length;

  /// Muted chats filtered out
  List<ChatModel> unmutedChats(String uid) =>
      chats
          .where((c) => !c.isMutedBy(uid))
          .toList();

  /// Get chat by ID
  ChatModel? getChat(String chatId) {
    try {
      return chats.firstWhere(
              (c) => c.id == chatId);
    } catch (_) {
      return null;
    }
  }

  /// Get chat with a specific user
  ChatModel? getChatWithUser(
      String myUid, String otherUid) {
    final chatId =
    ChatModel.generateId(myUid, otherUid);
    return getChat(chatId);
  }

  /// Total unread across all chats
  int totalUnread(String uid) => chats
      .where((c) => !c.isMutedBy(uid))
      .fold<int>(
      0, (sum, c) => sum + c.unreadCountFor(uid));
}

// ─────────────────────────────────────────────────────────
// CHATS NOTIFIER
// ─────────────────────────────────────────────────────────

class ChatsNotifier
    extends StateNotifier<ChatsState> {
  final ChatRepository _repo;
  final String? _uid;

  ChatsNotifier(this._repo, this._uid)
      : super(const ChatsState()) {
    if (_uid != null) _load();
  }

  // ── LOAD ──────────────────────────────────────────────

  Future<void> _load() async {
    if (_uid == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final chats =
      await _repo.getUserChats(_uid!);
      state = state.copyWith(
        chats: chats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load chats.',
      );
    }
  }

  // ── CREATE CHAT ───────────────────────────────────────

  Future<ChatModel?> createChat(
      String otherUid) async {
    if (_uid == null) return null;

    try {
      final chat = await _repo.createChat(
        uid1: _uid!,
        uid2: otherUid,
      );

      // Add to list if not present
      final exists =
      state.chats.any((c) => c.id == chat.id);
      if (!exists) {
        state = state.copyWith(
          chats: [chat, ...state.chats],
        );
      }
      return chat;
    } catch (e) {
      return null;
    }
  }

  // ── UPDATE CHAT ───────────────────────────────────────

  /// Update a single chat in state.
  void updateChat(ChatModel updatedChat) {
    final updated = state.chats.map((c) =>
    c.id == updatedChat.id ? updatedChat : c)
        .toList();
    state = state.copyWith(chats: updated);
  }

  // ── REMOVE CHAT ───────────────────────────────────────

  /// Remove a chat from state (after delete).
  void removeChat(String chatId) {
    final updated = state.chats
        .where((c) => c.id != chatId)
        .toList();
    state = state.copyWith(chats: updated);
  }

  // ── MARK READ ─────────────────────────────────────────

  /// Mark all messages in a chat as read.
  Future<void> markRead(String chatId) async {
    if (_uid == null) return;

    try {
      await _repo.markMessagesRead(
        chatId: chatId,
        readerUid: _uid!,
      );

      // Update unread count in state
      final chat = state.getChat(chatId);
      if (chat != null) {
        final updatedCount =
        Map<String, int>.from(
            chat.unreadCount);
        updatedCount[_uid!] = 0;
        updateChat(chat.copyWith(
            unreadCount: updatedCount));
      }
    } catch (_) {}
  }

  // ── MUTE TOGGLE ───────────────────────────────────────

  Future<void> toggleMute(
      String chatId, bool mute) async {
    if (_uid == null) return;

    try {
      await _repo.toggleMuteChat(
        chatId: chatId,
        uid: _uid!,
        mute: mute,
      );

      final chat = state.getChat(chatId);
      if (chat == null) return;

      final mutedBy =
      List<String>.from(chat.mutedBy);
      if (mute) {
        if (!mutedBy.contains(_uid)) {
          mutedBy.add(_uid!);
        }
      } else {
        mutedBy.remove(_uid);
      }
      updateChat(
          chat.copyWith(mutedBy: mutedBy));
    } catch (_) {}
  }

  // ── ARCHIVE ───────────────────────────────────────────

  Future<void> archiveChat(
      String chatId) async {
    try {
      await _repo.archiveChat(chatId: chatId);
      removeChat(chatId);
    } catch (_) {}
  }

  // ── DELETE CHAT ───────────────────────────────────────

  Future<void> deleteChat(
      String chatId) async {
    try {
      await _repo.deleteChat(chatId: chatId);
      removeChat(chatId);
    } catch (_) {}
  }

  Future<void> refresh() => _load();
}

// ─────────────────────────────────────────────────────────
// CHATS PROVIDER
// ─────────────────────────────────────────────────────────

final chatsProvider = StateNotifierProvider<
    ChatsNotifier, ChatsState>((ref) {
  final uid = ref.watch(currentUidProvider);
  return ChatsNotifier(
    ref.read(chatRepositoryProvider),
    uid,
  );
});

// ─────────────────────────────────────────────────────────
// MESSAGES STATE
// ─────────────────────────────────────────────────────────

class MessagesState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final bool hasMore;
  final String? error;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.hasMore = true,
    this.error,
  });

  MessagesState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      hasMore: hasMore ?? this.hasMore,
      error: clearError
          ? null
          : error ?? this.error,
    );
  }

  // ── COMPUTED ──────────────────────────────────────────

  bool get isEmpty => messages.isEmpty;

  bool get hasError =>
      error != null && error!.isNotEmpty;

  /// Latest message
  MessageModel? get lastMessage =>
      messages.isEmpty ? null : messages.last;

  /// Messages visible to a specific user
  List<MessageModel> visibleFor(String uid) =>
      messages
          .where((m) => !m.isDeletedFor(uid))
          .toList();

  /// Get message by ID
  MessageModel? getById(String id) {
    try {
      return messages.firstWhere(
              (m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────
// MESSAGES NOTIFIER
// ─────────────────────────────────────────────────────────

class MessagesNotifier
    extends StateNotifier<MessagesState> {
  final ChatRepository _repo;
  final String _chatId;
  final String? _myUid;

  static const int _pageSize = 30;

  MessagesNotifier(
      this._repo,
      this._chatId,
      this._myUid,
      ) : super(const MessagesState()) {
    _load();
  }

  // ── LOAD MESSAGES ─────────────────────────────────────

  Future<void> _load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final messages = await _repo.getMessages(
        chatId: _chatId,
        limit: _pageSize,
      );

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        hasMore: messages.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages.',
      );
    }
  }

  // ── LOAD MORE (PAGINATION) ────────────────────────────

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoading ||
        state.messages.isEmpty) return;

    try {
      final older = await _repo.getMessages(
        chatId: _chatId,
        limit: _pageSize,
        lastMessageId: state.messages.first.id,
      );

      if (older.isEmpty) {
        state = state.copyWith(hasMore: false);
        return;
      }

      // Prepend older messages
      state = state.copyWith(
        messages: [...older, ...state.messages],
        hasMore: older.length >= _pageSize,
      );
    } catch (_) {}
  }

  // ── SEND MESSAGE ──────────────────────────────────────

  /// Send text message with optimistic update.
  Future<void> sendMessage(String text) async {
    if (_myUid == null ||
        text.trim().isEmpty) return;

    // Optimistic message
    final optimistic = MessageModel.text(
      chatId: _chatId,
      senderId: _myUid!,
      text: text.trim(),
    );

    // Add immediately to UI
    state = state.copyWith(
      messages: [...state.messages, optimistic],
      isSending: true,
    );

    try {
      final sent = await _repo.sendMessage(
        chatId: _chatId,
        senderId: _myUid!,
        text: text.trim(),
      );

      // Replace optimistic with real message
      _replaceMessage(optimistic.id, sent);
      state = state.copyWith(isSending: false);
    } catch (e) {
      // Mark as failed
      _replaceMessage(
        optimistic.id,
        optimistic.markFailed(),
      );
      state = state.copyWith(
        isSending: false,
        error: 'Failed to send message.',
      );
    }
  }

  // ── SEND IMAGE ────────────────────────────────────────

  Future<void> sendImage({
    required String imageUrl,
    int? imageSize,
    String? caption,
  }) async {
    if (_myUid == null) return;

    final optimistic = MessageModel.image(
      chatId: _chatId,
      senderId: _myUid!,
      mediaUrl: imageUrl,
      mediaSize: imageSize,
      text: caption,
    );

    state = state.copyWith(
      messages: [...state.messages, optimistic],
      isSending: true,
    );

    try {
      final sent = await _repo.sendImageMessage(
        chatId: _chatId,
        senderId: _myUid!,
        imageUrl: imageUrl,
        imageSize: imageSize,
        caption: caption,
      );

      _replaceMessage(optimistic.id, sent);
      state = state.copyWith(isSending: false);
    } catch (e) {
      _replaceMessage(
        optimistic.id,
        optimistic.markFailed(),
      );
      state = state.copyWith(
        isSending: false,
        error: 'Failed to send image.',
      );
    }
  }

  // ── DELETE MESSAGE ────────────────────────────────────

  Future<void> deleteMessage({
    required String messageId,
    bool deleteForEveryone = false,
  }) async {
    if (_myUid == null) return;

    try {
      await _repo.deleteMessage(
        chatId: _chatId,
        messageId: messageId,
        deleterUid: _myUid!,
        deleteForEveryone: deleteForEveryone,
      );

      final msg = state.getById(messageId);
      if (msg == null) return;

      final updated = deleteForEveryone
          ? msg.deleteForEveryone()
          : msg.deleteForUser(_myUid!);

      _replaceMessage(messageId, updated);
    } catch (_) {}
  }

  // ── RETRY FAILED ──────────────────────────────────────

  /// Retry sending a failed message.
  Future<void> retryMessage(
      String messageId) async {
    final msg = state.getById(messageId);
    if (msg == null || !msg.isFailed) return;
    if (msg.text == null) return;

    // Remove failed message
    final updated = state.messages
        .where((m) => m.id != messageId)
        .toList();
    state = state.copyWith(messages: updated);

    // Resend
    await sendMessage(msg.text!);
  }

  // ── MARK READ ─────────────────────────────────────────

  Future<void> markRead() async {
    if (_myUid == null) return;
    try {
      await _repo.markMessagesRead(
        chatId: _chatId,
        readerUid: _myUid!,
      );

      // Update status in state
      final updated = state.messages.map((m) {
        if (m.senderId != _myUid &&
            !m.isRead) {
          return m.markRead();
        }
        return m;
      }).toList();

      state = state.copyWith(messages: updated);
    } catch (_) {}
  }

  // ── ADD INCOMING MESSAGE ──────────────────────────────

  /// Add a message received via real-time stream.
  void addIncomingMessage(MessageModel msg) {
    final exists =
    state.messages.any((m) => m.id == msg.id);
    if (exists) return;

    state = state.copyWith(
      messages: [...state.messages, msg],
    );
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  void _replaceMessage(
      String oldId, MessageModel newMsg) {
    final updated = state.messages.map((m) =>
    m.id == oldId ? newMsg : m).toList();
    state = state.copyWith(messages: updated);
  }

  Future<void> refresh() => _load();

  void clearError() =>
      state = state.copyWith(clearError: true);
}

// ─────────────────────────────────────────────────────────
// MESSAGES PROVIDER FAMILY
// ─────────────────────────────────────────────────────────

final messagesProvider = StateNotifierProvider
    .family<MessagesNotifier, MessagesState,
    String>((ref, chatId) {
  final uid = ref.watch(currentUidProvider);
  return MessagesNotifier(
    ref.read(chatRepositoryProvider),
    chatId,
    uid,
  );
});

// ─────────────────────────────────────────────────────────
// CONVENIENCE PROVIDERS
// ─────────────────────────────────────────────────────────

/// Total unread count across all chats.
final totalUnreadProvider = Provider<int>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return 0;
  return ref.watch(chatsProvider).totalUnread(uid);
});

/// Is sending message in a specific chat.
final isSendingProvider =
Provider.family<bool, String>((ref, chatId) {
  return ref
      .watch(messagesProvider(chatId))
      .isSending;
});

/// Messages for a chat visible to current user.
final visibleMessagesProvider =
Provider.family<List<MessageModel>, String>(
        (ref, chatId) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return [];
      return ref
          .watch(messagesProvider(chatId))
          .visibleFor(uid);
    });

/// Single chat model by ID.
final chatByIdProvider =
Provider.family<ChatModel?, String>(
        (ref, chatId) {
      return ref.watch(chatsProvider).getChat(chatId);
    });

/// Has unread messages in a specific chat.
final hasUnreadProvider =
Provider.family<bool, String>((ref, chatId) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return false;
  final chat =
  ref.watch(chatsProvider).getChat(chatId);
  return (chat?.unreadCountFor(uid) ?? 0) > 0;
});

/// Is a specific chat muted by current user.
final isChatMutedProvider =
Provider.family<bool, String>((ref, chatId) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return false;
  final chat =
  ref.watch(chatsProvider).getChat(chatId);
  return chat?.isMutedBy(uid) ?? false;
});