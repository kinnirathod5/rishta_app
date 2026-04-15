// lib/presentation/chat/chat_inbox_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

// ── MOCK DATA ─────────────────────────────────────────────
class _MockChatItem {
  final String chatId;
  final String name;
  final String emoji;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isMuted;
  final bool isMe; // last message sent by me

  const _MockChatItem({
    required this.chatId,
    required this.name,
    required this.emoji,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    required this.isMuted,
    required this.isMe,
  });
}

final _mockChats = [
  _MockChatItem(
    chatId: 'chat1',
    name: 'Priya Sharma',
    emoji: '👩',
    lastMessage: 'That sounds wonderful! 😊',
    lastMessageTime: DateTime.now()
        .subtract(const Duration(minutes: 5)),
    unreadCount: 3,
    isOnline: true,
    isMuted: false,
    isMe: false,
  ),
  _MockChatItem(
    chatId: 'chat2',
    name: 'Anjali Gupta',
    emoji: '👩‍💼',
    lastMessage: 'Sure, let us talk tomorrow!',
    lastMessageTime: DateTime.now()
        .subtract(const Duration(hours: 2)),
    unreadCount: 0,
    isOnline: false,
    isMuted: false,
    isMe: true,
  ),
  _MockChatItem(
    chatId: 'chat3',
    name: 'Meera Singh',
    emoji: '👩‍⚕️',
    lastMessage: 'I am a doctor at Fortis Hospital.',
    lastMessageTime: DateTime.now()
        .subtract(const Duration(hours: 5)),
    unreadCount: 1,
    isOnline: true,
    isMuted: true,
    isMe: false,
  ),
  _MockChatItem(
    chatId: 'chat4',
    name: 'Sneha Patel',
    emoji: '👩‍🏫',
    lastMessage: 'Nice to meet you! 🙏',
    lastMessageTime: DateTime.now()
        .subtract(const Duration(days: 1)),
    unreadCount: 0,
    isOnline: false,
    isMuted: false,
    isMe: false,
  ),
  _MockChatItem(
    chatId: 'chat5',
    name: 'Kavya Reddy',
    emoji: '👩‍💻',
    lastMessage: 'I work as a data scientist at Amazon.',
    lastMessageTime: DateTime.now()
        .subtract(const Duration(days: 2)),
    unreadCount: 0,
    isOnline: false,
    isMuted: false,
    isMe: false,
  ),
];

// ── SCREEN ────────────────────────────────────────────────
class ChatInboxScreen extends ConsumerStatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  ConsumerState<ChatInboxScreen> createState() =>
      _ChatInboxScreenState();
}

class _ChatInboxScreenState
    extends ConsumerState<ChatInboxScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isSearching = false;
  final Set<String> _mutedChats = {};
  List<_MockChatItem> _chats =
  List.from(_mockChats);

  List<_MockChatItem> get _filtered {
    if (_query.isEmpty) return _chats;
    final q = _query.toLowerCase();
    return _chats
        .where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q))
        .toList();
  }

  int get _totalUnread =>
      _chats.fold(0, (sum, c) => sum + c.unreadCount);

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  void _deleteChat(String chatId) {
    setState(() => _chats.removeWhere(
            (c) => c.chatId == chatId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chat deleted'),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.goldLight,
          onPressed: () {
            setState(() => _chats =
                List.from(_mockChats));
          },
        ),
      ),
    );
  }

  void _toggleMute(String chatId) {
    setState(() {
      if (_mutedChats.contains(chatId)) {
        _mutedChats.remove(chatId);
      } else {
        _mutedChats.add(chatId);
      }
    });
    final isMuted = _mutedChats.contains(chatId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isMuted ? 'Chat muted' : 'Chat unmuted'),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showChatOptions(_MockChatItem chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Chat info
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(chat.emoji,
                      style: const TextStyle(
                          fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    chat.isOnline
                        ? 'Online'
                        : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: chat.isOnline
                          ? AppColors.success
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.person_outline_rounded,
              label: 'View Profile',
              onTap: () {
                Navigator.pop(context);
                context.push(
                    '/profile/${chat.chatId}');
              },
            ),
            _OptionTile(
              icon: _mutedChats.contains(chat.chatId)
                  ? Icons.notifications_outlined
                  : Icons.notifications_off_outlined,
              label: _mutedChats.contains(chat.chatId)
                  ? 'Unmute Chat'
                  : 'Mute Chat',
              onTap: () {
                Navigator.pop(context);
                _toggleMute(chat.chatId);
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Chat',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _deleteChat(chat.chatId);
              },
            ),
            _OptionTile(
              icon: Icons.flag_outlined,
              label: 'Block / Report',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  content: Text(
                      'User reported successfully'),
                  behavior:
                  SnackBarBehavior.floating,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          _buildHeader(),
          if (_isSearching) _buildSearchBar(),
          Expanded(
            child: filtered.isEmpty
                ? _query.isNotEmpty
                ? _buildSearchEmpty()
                : _buildEmptyState()
                : _buildChatList(filtered),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding:
      EdgeInsets.fromLTRB(20, topPad + 10, 16, 14),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.messages,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (_totalUnread > 0)
                Text(
                  '$_totalUnread unread message${_totalUnread > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Colors.white.withOpacity(0.7),
                  ),
                )
              else
                Text(
                  AppStrings.yourConversations,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Colors.white.withOpacity(0.7),
                  ),
                ),
            ],
          ),
          Row(children: [
            // Search toggle
            _HeaderIcon(
              icon: _isSearching
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              onTap: _toggleSearch,
            ),
            const SizedBox(width: 8),
            // New chat (placeholder)
            _HeaderIcon(
              icon: Icons.edit_outlined,
              onTap: () =>
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                    content: Text(
                        'New chat coming soon'),
                    behavior:
                    SnackBarBehavior.floating,
                  )),
            ),
          ]),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.crimson,
      padding:
      const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(
              color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded,
                size: 18,
                color:
                Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(
                vertical: 12),
          ),
          onChanged: (v) =>
              setState(() => _query = v),
        ),
      ),
    );
  }

  // ── CHAT LIST ─────────────────────────────────────────
  Widget _buildChatList(
      List<_MockChatItem> chats) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: chats.length,
      itemBuilder: (_, i) =>
          _buildChatTile(chats[i]),
    );
  }

  Widget _buildChatTile(_MockChatItem chat) {
    final isMuted = _mutedChats.contains(chat.chatId);
    final hasUnread =
        chat.unreadCount > 0 && !isMuted;

    return Dismissible(
      key: Key(chat.chatId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 24),
            const SizedBox(height: 4),
            const Text(
              'Delete',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16)),
            title: const Text(
                'Delete conversation?'),
            content: Text(
                'Delete your conversation with ${chat.name}?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.error),
                onPressed: () =>
                    Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(
                        color: Colors.white)),
              ),
            ],
          ),
        ) ??
            false;
      },
      onDismissed: (_) => _deleteChat(chat.chatId),
      child: GestureDetector(
        onTap: () =>
            context.push('/chat/${chat.chatId}'),
        onLongPress: () => _showChatOptions(chat),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasUnread
                ? AppColors.crimsonSurface
                .withOpacity(0.4)
                : AppColors.white,
            border: const Border(
              bottom: BorderSide(
                  color: AppColors.border,
                  width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              // Avatar with online indicator
              Stack(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.crimsonSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnread
                          ? AppColors.crimson
                          .withOpacity(0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(chat.emoji,
                        style: const TextStyle(
                            fontSize: 26)),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white,
                            width: 2),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // Name row
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Expanded(
                          child: Row(children: [
                            Flexible(
                              child: Text(
                                chat.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow
                                    .ellipsis,
                              ),
                            ),
                            if (isMuted) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons
                                    .notifications_off_outlined,
                                size: 13,
                                color: AppColors.muted,
                              ),
                            ],
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(
                              chat.lastMessageTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread
                                ? AppColors.crimson
                                : AppColors.muted,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Last message row
                    Row(
                      children: [
                        Expanded(
                          child: Row(children: [
                            if (chat.isMe) ...[
                              const Icon(
                                Icons
                                    .done_all_rounded,
                                size: 14,
                                color:
                                AppColors.info,
                              ),
                              const SizedBox(
                                  width: 4),
                            ],
                            Expanded(
                              child: Text(
                                chat.lastMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: hasUnread
                                      ? AppColors
                                      .inkSoft
                                      : AppColors.muted,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight
                                      .w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow
                                    .ellipsis,
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        // Unread badge
                        if (hasUnread)
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.crimson,
                              borderRadius:
                              BorderRadius.circular(
                                  100),
                            ),
                            child: Text(
                              chat.unreadCount > 99
                                  ? '99+'
                                  : '${chat.unreadCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else if (isMuted)
                          const SizedBox(width: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── EMPTY STATES ──────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.crimsonSurface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💬',
                    style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.noChats,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              AppStrings.noChatsSubtext,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    context.go('/interests'),
                child: const Text(
                    AppStrings.viewConnections),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍',
                style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No results for "$_query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with a different name',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      final h = time.hour > 12
          ? time.hour - 12
          : (time.hour == 0 ? 12 : time.hour);
      final m =
      time.minute.toString().padLeft(2, '0');
      final period =
      time.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $period';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      const days = [
        'Mon', 'Tue', 'Wed',
        'Thu', 'Fri', 'Sat', 'Sun'
      ];
      return days[time.weekday - 1];
    }
    return '${time.day}/${time.month}/${time.year.toString().substring(2)}';
  }
}

// ── PRIVATE WIDGETS ───────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(icon,
              size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isDestructive ? AppColors.error : AppColors.inkSoft;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.errorSurface
                  : AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Center(
                child:
                Icon(icon, size: 18, color: color)),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ]),
      ),
    );
  }
}