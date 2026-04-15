// lib/presentation/chat/chat_window_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/message_model.dart';

// ── MOCK DATA ─────────────────────────────────────────────
class _MockChat {
  final String name;
  final String emoji;
  final bool isOnline;
  final String lastSeen;

  const _MockChat({
    required this.name,
    required this.emoji,
    required this.isOnline,
    required this.lastSeen,
  });
}

const _mockChats = {
  'chat1': _MockChat(
    name: 'Priya Sharma',
    emoji: '👩',
    isOnline: true,
    lastSeen: 'Online',
  ),
  'chat2': _MockChat(
    name: 'Anjali Gupta',
    emoji: '👩‍💼',
    isOnline: false,
    lastSeen: 'Last seen 2 hrs ago',
  ),
};

class _MockMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;

  const _MockMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.status,
  });
}

// ── SCREEN ────────────────────────────────────────────────
class ChatWindowScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatWindowScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ChatWindowScreen> createState() =>
      _ChatWindowScreenState();
}

class _ChatWindowScreenState
    extends ConsumerState<ChatWindowScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isTyping = false;
  bool _showScrollToBottom = false;
  final List<_MockMessage> _messages = [];

  _MockChat get _chatInfo =>
      _mockChats[widget.chatId] ??
          const _MockChat(
            name: 'Unknown',
            emoji: '👤',
            isOnline: false,
            lastSeen: '',
          );

  @override
  void initState() {
    super.initState();
    _loadMockMessages();
    _scrollController.addListener(_onScroll);
  }

  void _loadMockMessages() {
    final now = DateTime.now();
    setState(() {
      _messages.addAll([
        _MockMessage(
          id: '1',
          text: 'Hello! How are you? 😊',
          isMe: false,
          time: now.subtract(
              const Duration(minutes: 45)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '2',
          text: 'I am doing great, thank you! How about you?',
          isMe: true,
          time: now.subtract(
              const Duration(minutes: 43)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '3',
          text: 'Doing well! I saw your profile and found it really interesting.',
          isMe: false,
          time: now.subtract(
              const Duration(minutes: 40)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '4',
          text: 'Thank you so much! I liked your profile too 😊',
          isMe: true,
          time: now.subtract(
              const Duration(minutes: 38)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '5',
          text: 'Would you like to tell me more about yourself?',
          isMe: false,
          time: now.subtract(
              const Duration(minutes: 30)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '6',
          text: 'Sure! I am a software engineer at TCS. I love reading books and traveling.',
          isMe: true,
          time: now.subtract(
              const Duration(minutes: 28)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '7',
          text: 'That is wonderful! I also love traveling. Where have you been recently?',
          isMe: false,
          time: now.subtract(
              const Duration(minutes: 20)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '8',
          text: 'I visited Manali last month. It was absolutely beautiful! ❤️',
          isMe: true,
          time: now.subtract(
              const Duration(minutes: 18)),
          status: MessageStatus.delivered,
        ),
        _MockMessage(
          id: '9',
          text: 'Oh wow! I have been wanting to visit Manali. Did you go with family?',
          isMe: false,
          time: now.subtract(
              const Duration(minutes: 10)),
          status: MessageStatus.read,
        ),
        _MockMessage(
          id: '10',
          text: 'Yes, with my family. It was a great trip! 🏔️',
          isMe: true,
          time: now.subtract(
              const Duration(minutes: 5)),
          status: MessageStatus.sent,
        ),
      ]);
    });

    WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom());
  }

  void _onScroll() {
    final isNearBottom = _scrollController.offset <
        _scrollController.position.maxScrollExtent - 200;
    if (isNearBottom != _showScrollToBottom) {
      setState(() => _showScrollToBottom = isNearBottom);
    }
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMsg = _MockMessage(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(),
      text: text,
      isMe: true,
      time: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(newMsg);
      _messageController.clear();
      _isTyping = false;
    });

    _scrollToBottom(animated: true);

    // Simulate sent status
    Future.delayed(const Duration(milliseconds: 500),
            () {
          if (!mounted) return;
          setState(() {
            final idx = _messages
                .indexWhere((m) => m.id == newMsg.id);
            if (idx != -1) {
              _messages[idx] = _MockMessage(
                id: newMsg.id,
                text: newMsg.text,
                isMe: newMsg.isMe,
                time: newMsg.time,
                status: MessageStatus.sent,
              );
            }
          });
        });

    // Simulate auto-reply
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final replies = [
        'That sounds wonderful! 😊',
        'I agree completely!',
        'That is great to know.',
        'Tell me more about it!',
        'Sounds amazing! ✨',
      ];
      final reply = replies[
      DateTime.now().second % replies.length];
      setState(() {
        _messages.add(_MockMessage(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          text: reply,
          isMe: false,
          time: DateTime.now(),
          status: MessageStatus.read,
        ));
      });
      _scrollToBottom(animated: true);
    });
  }

  void _onLongPressMessage(_MockMessage msg) {
    HapticFeedback.mediumImpact();
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
            const SizedBox(height: 16),
            // Message preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkSoft),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            _MessageAction(
              icon: Icons.copy_rounded,
              label: 'Copy Message',
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: msg.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content:
                    const Text('Copied to clipboard'),
                    backgroundColor: AppColors.ink,
                    behavior:
                    SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10)),
                    duration:
                    const Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (msg.isMe)
              _MessageAction(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Message',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _messages
                      .removeWhere(
                          (m) => m.id == msg.id));
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Stack(
              children: [
                _buildMessageList(),
                if (_showScrollToBottom)
                  _buildScrollToBottomButton(),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────
  Widget _buildAppBar() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding:
      EdgeInsets.fromLTRB(8, topPad + 8, 8, 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white),
          ),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: _chatInfo.isOnline
                    ? AppColors.success
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(_chatInfo.emoji,
                  style:
                  const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 10),
          // Name + status
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
                  '/profile/chat_user',
                  extra: null),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    _chatInfo.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    if (_chatInfo.isOnline)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(
                            right: 5),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      _chatInfo.isOnline
                          ? AppStrings.online
                          : _chatInfo.lastSeen,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white
                            .withOpacity(0.75),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          // Actions
          IconButton(
            onPressed: () => _showChatOptions(),
            icon: const Icon(Icons.more_vert_rounded,
                size: 22, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── MESSAGE LIST ──────────────────────────────────────
  Widget _buildMessageList() {
    // Group messages by date
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 12),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final prevMsg = i > 0 ? _messages[i - 1] : null;

        // Show date separator if needed
        final showDate = prevMsg == null ||
            !_isSameDay(msg.time, prevMsg.time);

        // Show avatar only for last consecutive
        // message from same sender
        final nextMsg = i < _messages.length - 1
            ? _messages[i + 1]
            : null;
        final isLastInGroup = nextMsg == null ||
            nextMsg.isMe != msg.isMe;

        return Column(
          children: [
            if (showDate) _buildDateChip(msg.time),
            _buildMessageBubble(
              msg,
              isLastInGroup: isLastInGroup,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateChip(DateTime time) {
    final now = DateTime.now();
    String label;

    if (_isSameDay(time, now)) {
      label = 'Today';
    } else if (_isSameDay(
        time, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label =
      '${time.day} ${_monthName(time.month)} ${time.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ivoryDark,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildMessageBubble(
      _MockMessage msg, {
        required bool isLastInGroup,
      }) {
    final isMe = msg.isMe;

    return GestureDetector(
      onLongPress: () => _onLongPressMessage(msg),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: isLastInGroup ? 10 : 3,
          top: 0,
        ),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Other user avatar
            if (!isMe) ...[
              if (isLastInGroup)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                    AppColors.crimsonSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _chatInfo.emoji,
                      style: const TextStyle(
                          fontSize: 16),
                    ),
                  ),
                )
              else
                const SizedBox(width: 30),
              const SizedBox(width: 8),
            ],

            // Bubble
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context)
                          .size
                          .width *
                          0.72,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.crimson
                          : AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(
                            isMe ? 16 : (isLastInGroup ? 4 : 16)),
                        bottomRight: Radius.circular(
                            isMe ? (isLastInGroup ? 4 : 16) : 16),
                      ),
                      boxShadow: AppColors.softShadow,
                      border: isMe
                          ? null
                          : Border.all(
                          color: AppColors.border),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe
                            ? Colors.white
                            : AppColors.ink,
                        height: 1.45,
                      ),
                    ),
                  ),
                  // Time + status
                  if (isLastInGroup)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 4, left: 4, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(msg.time),
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.muted),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _StatusIcon(
                                status: msg.status),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),

            if (isMe) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ── SCROLL TO BOTTOM BUTTON ───────────────────────────
  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: GestureDetector(
        onTap: () => _scrollToBottom(animated: true),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.crimson,
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: const Center(
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // ── INPUT BAR ─────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            top: BorderSide(color: AppColors.border)),
        boxShadow: AppColors.modalShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment
          GestureDetector(
            onTap: _showAttachmentOptions,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                    Icons.add_rounded,
                    size: 22,
                    color: AppColors.muted),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                  maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.crimson
                      .withOpacity(0.4)
                      : Colors.transparent,
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textCapitalization:
                TextCapitalization.sentences,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: AppStrings.typeMessage,
                  hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.disabled),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onChanged: (v) => setState(
                        () => _isTyping = v.trim().isNotEmpty),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: _isTyping ? _sendMessage : null,
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isTyping
                    ? AppColors.crimson
                    : AppColors.ivoryDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: _isTyping
                      ? Colors.white
                      : AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CHAT OPTIONS ──────────────────────────────────────
  void _showChatOptions() {
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
            const SizedBox(height: 16),
            _MessageAction(
              icon: Icons.person_outline_rounded,
              label: 'View Profile',
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/chat_user');
              },
            ),
            _MessageAction(
              icon: Icons.notifications_off_outlined,
              label: 'Mute Notifications',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  content: Text(
                      'Notifications muted'),
                  behavior:
                  SnackBarBehavior.floating,
                ));
              },
            ),
            _MessageAction(
              icon: Icons.delete_outline_rounded,
              label: 'Clear Chat',
              onTap: () {
                Navigator.pop(context);
                setState(() => _messages.clear());
              },
            ),
            _MessageAction(
              icon: Icons.flag_outlined,
              label: 'Block / Report',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  content: Text('User reported'),
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

  // ── ATTACHMENT OPTIONS ────────────────────────────────
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            24, 8, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 20),
            const Text(
              'Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [
                _AttachmentOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                      content: Text(
                          'Photo sharing coming soon'),
                      behavior:
                      SnackBarBehavior.floating,
                    ));
                  },
                ),
                _AttachmentOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  color: AppColors.crimson,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _AttachmentOption(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Document',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _formatTime(DateTime time) {
    final h = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

// ── PRIVATE WIDGETS ───────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.muted,
          ),
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check_rounded,
          size: 13,
          color: AppColors.muted,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all_rounded,
          size: 13,
          color: AppColors.muted,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all_rounded,
          size: 13,
          color: AppColors.info,
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error_outline_rounded,
          size: 13,
          color: AppColors.error,
        );
    }
  }
}

class _MessageAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MessageAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : AppColors.inkSoft;

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
            child:
            Center(child: Icon(icon, size: 18, color: color)),
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

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                  color: color.withOpacity(0.2)),
            ),
            child: Center(
              child:
              Icon(icon, size: 26, color: color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.inkSoft,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}