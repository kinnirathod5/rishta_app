import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

// ── MOCK DATA ─────────────────────────────────────────────

enum MessageStatus { sent, delivered, read }

class MockMessage {
  final String id;
  final String text;
  final bool isSent;
  final String time;
  final MessageStatus status;
  final String? date;

  const MockMessage({
    required this.id,
    required this.text,
    required this.isSent,
    required this.time,
    required this.status,
    this.date,
  });
}

final List<MockMessage> _mockMessages = [
  const MockMessage(
    id: '1',
    text: '',
    isSent: false,
    time: '',
    status: MessageStatus.read,
    date: 'Kal',
  ),
  const MockMessage(
    id: '2',
    text: 'Namaste! Aapka profile dekha 😊',
    isSent: false,
    time: '2:28 PM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '3',
    text: 'Bahut achha laga, engineer hain aap?',
    isSent: false,
    time: '2:28 PM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '4',
    text: 'Haan, TCS mein hoon. Aap?',
    isSent: true,
    time: '2:30 PM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '5',
    text: 'Main marketing mein hoon, Mumbai mein',
    isSent: false,
    time: '2:31 PM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '6',
    text: 'Bahut achha! Family kahan se hain aapki?',
    isSent: true,
    time: '2:32 PM',
    status: MessageStatus.delivered,
  ),
  const MockMessage(
    id: '7',
    text: 'Agra se hain, joint family hai',
    isSent: false,
    time: '2:45 PM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '8',
    text: '',
    isSent: false,
    time: '',
    status: MessageStatus.read,
    date: 'Aaj',
  ),
  const MockMessage(
    id: '9',
    text: 'Good morning! Kya aap free hain baat karne ke liye?',
    isSent: false,
    time: '10:15 AM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '10',
    text: 'Haan bilkul, batao',
    isSent: true,
    time: '10:30 AM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '11',
    text: 'Actually family ek baar milna chahti hai',
    isSent: false,
    time: '10:31 AM',
    status: MessageStatus.read,
  ),
  const MockMessage(
    id: '12',
    text: 'Zaroor! Hum arrange karte hain 😊',
    isSent: true,
    time: '10:32 AM',
    status: MessageStatus.sent,
  ),
];

// ── SCREEN ────────────────────────────────────────────────

class ChatWindowScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserEmoji;
  final String otherUserCaste;
  final String otherUserCity;

  const ChatWindowScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserEmoji,
    required this.otherUserCaste,
    required this.otherUserCity,
  });

  @override
  State<ChatWindowScreen> createState() => _ChatWindowScreenState();
}

class _ChatWindowScreenState extends State<ChatWindowScreen> {
  late List<MockMessage> _messages;
  final TextEditingController _messageController =
      TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List.from(_mockMessages);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final min = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMsg = MockMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isSent: true,
      time: _getCurrentTime(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMsg);
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final replies = [
        'Haan, zaroor! 😊',
        'Theek hai, main family se baat karta/karti hoon',
        'Bahut achha laga baat karke',
        'Aap bahut samajhdar lagte/lagti hain',
      ];
      final replyMsg = MockMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: replies[DateTime.now().second % replies.length],
        isSent: false,
        time: _getCurrentTime(),
        status: MessageStatus.read,
      );
      setState(() => _messages.add(replyMsg));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kya Share Karein?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(ctx, '📷', 'Camera',
                    AppColors.infoSurface, AppColors.info),
                _buildAttachOption(ctx, '🖼️', 'Gallery',
                    AppColors.successSurface, AppColors.success),
                _buildAttachOption(ctx, '📄', 'Document',
                    AppColors.goldSurface, AppColors.gold),
              ],
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '(Premium feature)',
                style: TextStyle(
                    fontSize: 12, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption(
    BuildContext sheetCtx,
    String emoji,
    String label,
    Color bg,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(sheetCtx);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jald aayega! 🚀')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child:
                  Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showChatInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.crimsonSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      widget.otherUserEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.otherUserCaste} • ${widget.otherUserCity}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoOption(
              ctx,
              Icons.person_outline_rounded,
              'Profile Dekho',
              AppColors.ink,
              () {
                Navigator.pop(ctx);
                context.go('/profile/1');
              },
            ),
            _buildInfoOption(
              ctx,
              Icons.volume_off_outlined,
              'Mute Karo',
              AppColors.ink,
              () {},
            ),
            _buildInfoOption(
              ctx,
              Icons.delete_outline_rounded,
              'Chat Delete Karo',
              AppColors.error,
              () {},
            ),
            _buildInfoOption(
              ctx,
              Icons.block_rounded,
              'Block Karo',
              AppColors.error,
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoOption(
    BuildContext sheetCtx,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: Text(label, style: TextStyle(fontSize: 15, color: color)),
      onTap: () {
        onTap();
        Navigator.pop(sheetCtx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildMessagesList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.crimson,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar with online dot
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.otherUserEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.crimson, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Name + info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName.isNotEmpty
                      ? widget.otherUserName
                      : 'Chat',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.otherUserCaste} • ${widget.otherUserCity}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.call_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.videocam_outlined,
                      size: 18,
                      color: AppColors.goldLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showChatInfo,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) =>
          _buildMessageItem(_messages[index]),
    );
  }

  Widget _buildMessageItem(MockMessage msg) {
    if (msg.date != null) {
      return _buildDateSeparator(msg.date!);
    }
    if (msg.isSent) {
      return _buildSentBubble(msg);
    }
    return _buildReceivedBubble(msg);
  }

  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
              child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Expanded(
              child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }

  Widget _buildReceivedBubble(MockMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                widget.otherUserEmoji,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.72,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: AppColors.softShadow,
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.ink,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            msg.time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentBubble(MockMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.72,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.crimson,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            msg.time,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _buildReadReceipt(msg.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadReceipt(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icon(
          Icons.check_rounded,
          size: 12,
          color: Colors.white.withOpacity(0.6),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all_rounded,
          size: 12,
          color: Colors.white.withOpacity(0.6),
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all_rounded,
          size: 12,
          color: AppColors.goldLight,
        );
    }
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Emoji button
          GestureDetector(
            onTap: () {},
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  size: 22,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(22),
                border:
                    Border.all(color: AppColors.border, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: 5,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Message likhein...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: AppColors.disabled, fontSize: 14),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.ink),
                textInputAction: TextInputAction.newline,
                onChanged: (val) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Attach button
          GestureDetector(
            onTap: _showAttachOptions,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  Icons.attach_file_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _messageController.text.trim().isNotEmpty
                    ? AppColors.crimson
                    : AppColors.ivoryDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.send_rounded,
                  size: 18,
                  color:
                      _messageController.text.trim().isNotEmpty
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
}
