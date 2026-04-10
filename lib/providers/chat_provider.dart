// lib/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';
import 'auth_provider.dart';

// ── REPOSITORY PROVIDER ───────────────────────────────────
final chatRepositoryProvider = Provider<ChatRepository>(
      (ref) => ChatRepository(),
);

// ── CHATS LIST STATE ──────────────────────────────────────
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
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalUnread {
    // TODO: userId se filter karo
    return 0;
  }

  bool get hasChats => chats.isNotEmpty;
}

// ── CHATS NOTIFIER ────────────────────────────────────────
class ChatsNotifier extends StateNotifier<ChatsState> {
  final ChatRepository _repo;
  final String? _userId;

  ChatsNotifier(this._repo, this._userId)
      : super(const ChatsState()) {
    if (_userId != null) loadChats();
  }

  Future<void> loadChats() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final chats = await _repo.getUserChats(_userId!);
      state = state.copyWith(
        chats: chats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> muteChat(String chatId, bool mute) async {
    if (_userId == null) return;
    await _repo.muteChat(chatId, _userId!, mute);

    state = state.copyWith(
      chats: state.chats.map((chat) {
        if (chat.id == chatId) {
          final newMuted =
          Map<String, bool>.from(chat.isMuted);
          newMuted[_userId!] = mute;
          return chat.copyWith(isMuted: newMuted);
        }
        return chat;
      }).toList(),
    );
  }

  Future<void> deleteChat(String chatId) async {
    if (_userId == null) return;
    await _repo.deleteChat(chatId, _userId!);
    state = state.copyWith(
      chats: state.chats
          .where((c) => c.id != chatId)
          .toList(),
    );
  }

  void updateLastMessage(
      String chatId,
      String message,
      String senderId,
      ) {
    state = state.copyWith(
      chats: state.chats.map((chat) {
        if (chat.id == chatId) {
          return chat.copyWith(
            lastMessage: message,
            lastMessageSenderId: senderId,
            lastMessageAt: DateTime.now(),
          );
        }
        return chat;
      }).toList(),
    );
  }
}

// ── CHATS PROVIDER ────────────────────────────────────────
final chatsProvider =
StateNotifierProvider<ChatsNotifier, ChatsState>(
      (ref) {
    final userId = ref.watch(currentUidProvider);
    return ChatsNotifier(
      ref.read(chatRepositoryProvider),
      userId,
    );
  },
);

// ── MESSAGES STATE ────────────────────────────────────────
class MessagesState {
  final String chatId;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const MessagesState({
    required this.chatId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  MessagesState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return MessagesState(
      chatId: chatId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

// ── MESSAGES NOTIFIER ─────────────────────────────────────
class MessagesNotifier extends StateNotifier<MessagesState> {
  final ChatRepository _repo;
  final String _userId;

  MessagesNotifier(
      this._repo,
      String chatId,
      this._userId,
      ) : super(MessagesState(chatId: chatId)) {
    loadMessages();
    markAsRead();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final messages =
      await _repo.getMessages(state.chatId);
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;

    state = state.copyWith(isSending: true);

    // Optimistic update — message turant dikhao
    final tempMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: state.chatId,
      senderId: _userId,
      content: content.trim(),
      status: MessageStatus.sending,
      sentAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, tempMessage],
      isSending: false,
    );

    try {
      final messageId = await _repo.sendMessage(
        chatId: state.chatId,
        senderId: _userId,
        content: content.trim(),
      );

      // Temp message ko real message se replace karo
      state = state.copyWith(
        messages: state.messages.map((msg) {
          if (msg.id == tempMessage.id) {
            return msg.copyWith(
              status: MessageStatus.sent,
            );
          }
          return msg;
        }).toList(),
      );

      return true;
    } catch (e) {
      // Failed — error mark karo
      state = state.copyWith(
        messages: state.messages.map((msg) {
          if (msg.id == tempMessage.id) {
            return msg.copyWith(
                status: MessageStatus.failed);
          }
          return msg;
        }).toList(),
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> markAsRead() async {
    await _repo.markMessagesAsRead(
        state.chatId, _userId);
  }

  Future<void> deleteMessage(String messageId) async {
    await _repo.deleteMessage(state.chatId, messageId);
    state = state.copyWith(
      messages: state.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(isDeleted: true);
        }
        return msg;
      }).toList(),
    );
  }

  // Simulate auto reply (testing ke liye)
  void addAutoReply(String replyText) {
    final replyMessage = MessageModel(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      chatId: state.chatId,
      senderId: 'other_user',
      content: replyText,
      status: MessageStatus.read,
      sentAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, replyMessage],
    );
  }
}

// ── MESSAGES PROVIDER (family — chatId ke liye) ───────────
final messagesProvider = StateNotifierProvider.family<
    MessagesNotifier, MessagesState, String>(
      (ref, chatId) {
    final userId =
        ref.watch(currentUidProvider) ?? 'unknown';
    return MessagesNotifier(
      ref.read(chatRepositoryProvider),
      chatId,
      userId,
    );
  },
);

// ── TOTAL UNREAD PROVIDER ─────────────────────────────────
final totalUnreadProvider = Provider<int>((ref) {
  final chatsState = ref.watch(chatsProvider);
  final userId = ref.watch(currentUidProvider);
  if (userId == null) return 0;
  return chatsState.chats.fold(
    0,
        (sum, chat) => sum + chat.getUnreadCount(userId),
  );
});