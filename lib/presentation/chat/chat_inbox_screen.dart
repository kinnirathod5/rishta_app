import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

// ── MOCK DATA ─────────────────────────────────────────────

class MockChat {
  final String id;
  final String name;
  final String emoji;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;
  final String caste;
  final String city;
  final bool isRead;

  const MockChat({
    required this.id,
    required this.name,
    required this.emoji,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.isPinned,
    required this.isMuted,
    required this.caste,
    required this.city,
    required this.isRead,
  });
}

const List<MockChat> _mockChats = [
  MockChat(
    id: 'chat1',
    name: 'Anjali Gupta',
    emoji: '👩‍💼',
    caste: 'Kayastha',
    city: 'Mumbai',
    lastMessage: 'Namaste! Profile dekhi, bahut achhi lagi 😊',
    time: '2:30 PM',
    unreadCount: 3,
    isOnline: true,
    isPinned: true,
    isMuted: false,
    isRead: false,
  ),
  MockChat(
    id: 'chat2',
    name: 'Rahul Sharma',
    emoji: '👨‍💻',
    caste: 'Brahmin',
    city: 'Delhi',
    lastMessage: 'Theek hai, hum baat karte hain',
    time: 'Kal',
    unreadCount: 0,
    isOnline: false,
    isPinned: false,
    isMuted: false,
    isRead: true,
  ),
  MockChat(
    id: 'chat3',
    name: 'Priya Singh',
    emoji: '👩‍⚕️',
    caste: 'Rajput',
    city: 'Jaipur',
    lastMessage: 'Aap kab free hote ho?',
    time: 'Mon',
    unreadCount: 1,
    isOnline: true,
    isPinned: false,
    isMuted: false,
    isRead: false,
  ),
  MockChat(
    id: 'chat4',
    name: 'Vikram Patel',
    emoji: '👨‍🏫',
    caste: 'Patel',
    city: 'Ahmedabad',
    lastMessage: 'Photo share karo na 😊',
    time: 'Sun',
    unreadCount: 0,
    isOnline: false,
    isPinned: false,
    isMuted: true,
    isRead: true,
  ),
  MockChat(
    id: 'chat5',
    name: 'Meera Iyer',
    emoji: '👩‍🔬',
    caste: 'Iyer',
    city: 'Chennai',
    lastMessage: 'Bilkul, family se baat karte hain',
    time: '12 Apr',
    unreadCount: 0,
    isOnline: false,
    isPinned: false,
    isMuted: false,
    isRead: true,
  ),
];

const List<MockChat> _mockRequests = [
  MockChat(
    id: 'req1',
    name: 'Arjun Mehta',
    emoji: '👨‍🔬',
    caste: 'Brahmin',
    city: 'Pune',
    lastMessage: 'Hi! Aapka profile bahut accha laga',
    time: '1 din',
    unreadCount: 1,
    isOnline: false,
    isPinned: false,
    isMuted: false,
    isRead: false,
  ),
  MockChat(
    id: 'req2',
    name: 'Rohan Kumar',
    emoji: '👨‍💼',
    caste: 'Kayastha',
    city: 'Noida',
    lastMessage: 'Namaste, kya hum baat kar sakte hain?',
    time: '2 din',
    unreadCount: 1,
    isOnline: false,
    isPinned: false,
    isMuted: false,
    isRead: false,
  ),
];

// ── SCREEN ────────────────────────────────────────────────

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<MockChat> _allChats = List.from(_mockChats);
  List<MockChat> _filteredChats = List.from(_mockChats);
  final List<MockChat> _requestChats = List.from(_mockRequests);

  int get totalUnread =>
      _allChats.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChats = _allChats;
      } else {
        _filteredChats = _allChats
            .where((c) =>
                c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showChatOptions(MockChat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(chat.emoji,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${chat.caste} • ${chat.city}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildChatOption(
              ctx,
              Icons.push_pin_outlined,
              chat.isPinned ? 'Unpin Karo' : 'Pin Karo',
              AppColors.ink,
              () {},
            ),
            _buildChatOption(
              ctx,
              chat.isMuted
                  ? Icons.volume_up_outlined
                  : Icons.volume_off_outlined,
              chat.isMuted ? 'Unmute Karo' : 'Mute Karo',
              AppColors.ink,
              () {},
            ),
            _buildChatOption(
              ctx,
              Icons.archive_outlined,
              'Archive Karo',
              AppColors.ink,
              () {},
            ),
            _buildChatOption(
              ctx,
              Icons.delete_outline_rounded,
              'Delete Karo',
              AppColors.error,
              () {},
            ),
            _buildChatOption(
              ctx,
              Icons.block_rounded,
              'Block Karo',
              AppColors.error,
              () {},
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOption(
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatsList(),
                  _buildRequestsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppColors.softShadow,
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Aapki conversations',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.inkSoft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.white),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded,
                size: 18, color: AppColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search conversations...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: AppColors.disabled, fontSize: 13),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
                style: const TextStyle(
                    fontSize: 13, color: AppColors.ink),
                onChanged: _filterChats,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            bottom: BorderSide(color: AppColors.border)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.crimson,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.crimson,
        indicatorWeight: 3,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Chats'),
                if (totalUnread > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.crimson,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$totalUnread',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Requests'),
                if (_requestChats.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.crimson,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${_requestChats.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    if (_filteredChats.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) =>
          _buildChatTile(_filteredChats[index]),
    );
  }

  Widget _buildChatTile(MockChat chat) {
    return Dismissible(
      key: Key(chat.id),
      background: Container(
        color: AppColors.success,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.archive_outlined, color: AppColors.white),
            SizedBox(width: 8),
            Text(
              'Archive',
              style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: AppColors.white),
          ],
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _allChats.removeWhere((c) => c.id == chat.id);
          _filteredChats.removeWhere((c) => c.id == chat.id);
        });
      },
      child: GestureDetector(
        onTap: () => context.push('/chat/${chat.id}', extra: {
          'name': chat.name,
          'emoji': chat.emoji,
          'caste': chat.caste,
          'city': chat.city,
        }),
        onLongPress: () => _showChatOptions(chat),
        child: Container(
          decoration: BoxDecoration(
            color: chat.isRead
                ? AppColors.white
                : AppColors.crimsonSurface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withOpacity(0.5),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(chat),
              const SizedBox(width: 12),
              Expanded(child: _buildChatContent(chat)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(MockChat chat) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: chat.isOnline
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: chat.isOnline
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(chat.emoji,
                style: const TextStyle(fontSize: 26)),
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
                    color: AppColors.white, width: 2),
              ),
            ),
          ),
        if (chat.isPinned)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.push_pin_rounded,
                  size: 8,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatContent(MockChat chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              chat.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: chat.isRead
                    ? FontWeight.w500
                    : FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            Text(
              chat.time,
              style: TextStyle(
                fontSize: 11,
                color: chat.unreadCount > 0
                    ? AppColors.crimson
                    : AppColors.muted,
                fontWeight: chat.unreadCount > 0
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (chat.isRead && chat.unreadCount == 0) ...[
                    const Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (chat.isMuted) ...[
                    const Icon(
                      Icons.volume_off_outlined,
                      size: 13,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Expanded(
                    child: Text(
                      chat.lastMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: chat.isRead
                            ? AppColors.muted
                            : AppColors.inkSoft,
                        fontWeight: chat.isRead
                            ? FontWeight.w400
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (chat.unreadCount > 0)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: chat.isMuted
                      ? AppColors.muted
                      : AppColors.crimson,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      itemCount: _requestChats.length,
      itemBuilder: (context, index) =>
          _buildRequestTile(_requestChats[index]),
    );
  }

  Widget _buildRequestTile(MockChat chat) {
    return GestureDetector(
      onTap: () => context.go('/chat/${chat.id}', extra: {
        'name': chat.name,
        'emoji': chat.emoji,
        'caste': chat.caste,
        'city': chat.city,
      }),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(
                color: AppColors.border.withOpacity(0.5)),
          ),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(chat.emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.ivoryDark,
                          borderRadius:
                              BorderRadius.circular(100),
                          border:
                              Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Message Request',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${chat.caste} • ${chat.city}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.crimson,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Accept',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.ivoryDark,
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.border),
                            ),
                            child: const Center(
                              child: Text(
                                'Decline',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💬', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'Koi Conversation Nahi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connected profiles se\nbaat karna shuru karo',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () => context.go('/interests'),
              child: const Text('Connections Dekhein'),
            ),
          ),
        ],
      ),
    );
  }
}
