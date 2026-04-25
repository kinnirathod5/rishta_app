// lib/presentation/interests/interests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────────────────

enum _MockStatus { pending, accepted, declined }

class _MockInterest {
  final String id;
  final String name;
  final String emoji;
  final int age;
  final String city;
  final String caste;
  final String profession;
  final bool isVerified;
  final _MockStatus status;
  final bool isMe;
  final DateTime time;
  final String? message;

  const _MockInterest({
    required this.id,
    required this.name,
    required this.emoji,
    required this.age,
    required this.city,
    required this.caste,
    required this.profession,
    required this.isVerified,
    required this.status,
    required this.isMe,
    required this.time,
    this.message,
  });
}

final _mockReceived = [
  _MockInterest(
    id: 'r1', name: 'Rahul Sharma', emoji: '👨', age: 29,
    city: 'Delhi', caste: 'Brahmin', profession: 'Software Engineer',
    isVerified: true, status: _MockStatus.pending, isMe: false,
    time: DateTime.now().subtract(const Duration(hours: 2)),
    message: 'Hi! I found your profile very interesting.',
  ),
  _MockInterest(
    id: 'r2', name: 'Arjun Patel', emoji: '👨‍💼', age: 31,
    city: 'Mumbai', caste: 'Patel', profession: 'Business',
    isVerified: false, status: _MockStatus.pending, isMe: false,
    time: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  _MockInterest(
    id: 'r3', name: 'Vikram Singh', emoji: '👨‍⚕️', age: 30,
    city: 'Jaipur', caste: 'Rajput', profession: 'Doctor',
    isVerified: true, status: _MockStatus.accepted, isMe: false,
    time: DateTime.now().subtract(const Duration(days: 1)),
  ),
  _MockInterest(
    id: 'r4', name: 'Karan Mehta', emoji: '👨‍🔬', age: 28,
    city: 'Bangalore', caste: 'Brahmin', profession: 'Data Scientist',
    isVerified: true, status: _MockStatus.declined, isMe: false,
    time: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final _mockSent = [
  _MockInterest(
    id: 's1', name: 'Priya Sharma', emoji: '👩', age: 26,
    city: 'Delhi', caste: 'Brahmin', profession: 'Software Engineer',
    isVerified: true, status: _MockStatus.pending, isMe: true,
    time: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  _MockInterest(
    id: 's2', name: 'Anjali Gupta', emoji: '👩‍💼', age: 24,
    city: 'Mumbai', caste: 'Kayastha', profession: 'Marketing Manager',
    isVerified: false, status: _MockStatus.accepted, isMe: true,
    time: DateTime.now().subtract(const Duration(days: 1)),
  ),
  _MockInterest(
    id: 's3', name: 'Meera Singh', emoji: '👩‍⚕️', age: 28,
    city: 'Jaipur', caste: 'Rajput', profession: 'Doctor',
    isVerified: true, status: _MockStatus.declined, isMe: true,
    time: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

final _mockConnections = [
  _MockInterest(
    id: 'c1', name: 'Anjali Gupta', emoji: '👩‍💼', age: 24,
    city: 'Mumbai', caste: 'Kayastha', profession: 'Marketing Manager',
    isVerified: false, status: _MockStatus.accepted, isMe: true,
    time: DateTime.now().subtract(const Duration(days: 1)),
  ),
  _MockInterest(
    id: 'c2', name: 'Vikram Singh', emoji: '👨‍⚕️', age: 30,
    city: 'Jaipur', caste: 'Rajput', profession: 'Doctor',
    isVerified: true, status: _MockStatus.accepted, isMe: false,
    time: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// ─────────────────────────────────────────────────────────
// INTERESTS SCREEN
// ─────────────────────────────────────────────────────────

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Map<String, _MockStatus> _receivedStatus = {};
  final Set<String> _withdrawnIds = {};

  int get _pendingCount => _mockReceived
      .where((i) =>
  i.status == _MockStatus.pending &&
      _receivedStatus[i.id] == null)
      .length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _acceptInterest(String id) {
    HapticFeedback.mediumImpact();
    setState(() => _receivedStatus[id] = _MockStatus.accepted);
    _showSnack('✅ Connected! You can now chat.', AppColors.success);
  }

  void _declineInterest(String id) {
    HapticFeedback.lightImpact();
    setState(() => _receivedStatus[id] = _MockStatus.declined);
    _showSnack('Interest declined', AppColors.inkSoft);
  }

  void _withdrawInterest(String id) {
    HapticFeedback.lightImpact();
    setState(() => _withdrawnIds.add(id));
    _showSnack('Interest withdrawn', AppColors.inkSoft);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          // ✅ FIX: Header + TabBar ek saath — seamless gradient
          _buildHeaderWithTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReceivedTab(),
                _buildSentTab(),
                _buildConnectionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER + TAB BAR — ek seamless block ─────────────

  Widget _buildHeaderWithTabs() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.crimsonGradient,
      ),
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Interests',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _pendingCount > 0
                ? '$_pendingCount new interest${_pendingCount > 1 ? 's' : ''} waiting'
                : 'Manage your connections',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Tab bar — same container mein, no cut
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(3),
              dividerColor: Colors.transparent,
              labelColor: AppColors.crimson,
              unselectedLabelColor: Colors.white.withOpacity(0.9),
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500),
              tabAlignment: TabAlignment.fill,
              padding: EdgeInsets.zero,
              tabs: [
                _TabLabel(label: 'Received', badge: _pendingCount),
                const _TabLabel(label: 'Sent'),
                _TabLabel(
                  label: 'Connected',
                  badge: _mockConnections.length,
                  badgeColor: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── RECEIVED TAB ──────────────────────────────────────

  Widget _buildReceivedTab() {
    if (_mockReceived.isEmpty) {
      return _EmptyState(
        emoji: '💌',
        title: 'No Interests Yet',
        subtitle: 'When someone sends you an interest,\nit will appear here.',
        actionLabel: 'Browse Profiles',
        onAction: () => context.go('/search'),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _mockReceived.length,
      itemBuilder: (_, i) {
        final interest = _mockReceived[i];
        final status = _receivedStatus[interest.id] ?? interest.status;
        return _ReceivedCard(
          interest: interest,
          status: status,
          onAccept: () => _acceptInterest(interest.id),
          onDecline: () => _declineInterest(interest.id),
          onViewProfile: () => context.push('/profile/${interest.id}'),
          onChat: () => context.push('/chat/${interest.id}'),
        );
      },
    );
  }

  // ── SENT TAB ──────────────────────────────────────────

  Widget _buildSentTab() {
    final visible = _mockSent
        .where((i) => !_withdrawnIds.contains(i.id))
        .toList();
    if (visible.isEmpty) {
      return _EmptyState(
        emoji: '💝',
        title: 'No Interests Sent',
        subtitle: 'Browse profiles and send\nyour first interest.',
        actionLabel: 'Browse Profiles',
        onAction: () => context.go('/search'),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: visible.length,
      itemBuilder: (_, i) {
        final interest = visible[i];
        return _SentCard(
          interest: interest,
          onWithdraw: () => _withdrawInterest(interest.id),
          onViewProfile: () => context.push('/profile/${interest.id}'),
        );
      },
    );
  }

  // ── CONNECTIONS TAB ───────────────────────────────────

  Widget _buildConnectionsTab() {
    if (_mockConnections.isEmpty) {
      return _EmptyState(
        emoji: '🤝',
        title: 'No Connections Yet',
        subtitle: 'Accept interests to start\nchatting with matches.',
        actionLabel: 'View Received',
        onAction: () => _tabController.animateTo(0),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _mockConnections.length,
      itemBuilder: (_, i) {
        final conn = _mockConnections[i];
        return _ConnectionCard(
          interest: conn,
          onViewProfile: () => context.push('/profile/${conn.id}'),
          onChat: () => context.push('/chat/${conn.id}'),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// RECEIVED CARD
// ─────────────────────────────────────────────────────────

class _ReceivedCard extends StatelessWidget {
  final _MockInterest interest;
  final _MockStatus status;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewProfile;
  final VoidCallback onChat;

  const _ReceivedCard({
    required this.interest,
    required this.status,
    required this.onAccept,
    required this.onDecline,
    required this.onViewProfile,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == _MockStatus.pending;
    final isAccepted = status == _MockStatus.accepted;
    final isDeclined = status == _MockStatus.declined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending
              ? AppColors.crimson.withOpacity(0.2)
              : isAccepted
              ? AppColors.success.withOpacity(0.2)
              : AppColors.border,
          width: isPending || isAccepted ? 1.5 : 1,
        ),
        boxShadow: isPending
            ? AppColors.crimsonShadow
            : AppColors.softShadow,
      ),
      child: Column(
        children: [
          // ── Top — Profile info ────────────────
          GestureDetector(
            onTap: onViewProfile,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Stack(children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: isPending
                            ? const LinearGradient(
                          colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : isAccepted
                            ? const LinearGradient(
                          colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: isDeclined ? AppColors.ivoryDark : null,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPending
                              ? AppColors.crimson.withOpacity(0.25)
                              : isAccepted
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(interest.emoji,
                            style: const TextStyle(fontSize: 30)),
                      ),
                    ),
                    if (interest.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.check_rounded,
                                size: 11, color: Colors.white),
                          ),
                        ),
                      ),
                    if (isPending)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.crimson,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${interest.name}, ${interest.age}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _StatusPill(status: status),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(children: [
                          const Icon(Icons.work_outline_rounded,
                              size: 13, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              interest.profession,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.inkSoft),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${interest.city} • ${interest.caste}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _timeAgo(interest.time),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted.withOpacity(0.8),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Message bubble ───────────────────
          if (interest.message != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.crimsonSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.crimson.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 16, color: AppColors.crimson.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      interest.message!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkSoft,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Action buttons ───────────────────
          // ✅ FIX 3: View Profile hataya — sirf Decline + Accept, properly designed
          if (isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(children: [
                // ✅ FIX: Decline — fixed width icon button, no overflow
                SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(
                          color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      backgroundColor: AppColors.white,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.inkSoft),
                  ),
                ),
                const SizedBox(width: 10),
                // Accept — full remaining width
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_rounded,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            )
          else if (isAccepted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.crimson,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Start Chat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SENT CARD
// ─────────────────────────────────────────────────────────

class _SentCard extends StatelessWidget {
  final _MockInterest interest;
  final VoidCallback onWithdraw;
  final VoidCallback onViewProfile;

  const _SentCard({
    required this.interest,
    required this.onWithdraw,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = interest.status == _MockStatus.accepted;
    final isPending = interest.status == _MockStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted
              ? AppColors.success.withOpacity(0.2)
              : AppColors.border,
          width: isAccepted ? 1.5 : 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: GestureDetector(
        onTap: onViewProfile,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Avatar
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: isAccepted ? AppColors.successSurface : AppColors.ivoryDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAccepted
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(interest.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${interest.name}, ${interest.age}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusPill(status: interest.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    interest.profession,
                    style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.muted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${interest.city} • ${interest.caste}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _timeAgo(interest.time),
                      style: TextStyle(
                          fontSize: 11, color: AppColors.muted.withOpacity(0.8)),
                    ),
                  ]),
                ],
              ),
            ),

            // Withdraw button — sirf pending mein
            if (isPending) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Withdraw Interest?',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 17)),
                      content: Text(
                        'Your interest to ${interest.name} will be removed.',
                        style: const TextStyle(
                            color: AppColors.inkSoft, fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: AppColors.muted)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onWithdraw();
                          },
                          child: const Text('Withdraw',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Icon(Icons.undo_rounded, size: 16, color: AppColors.error),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// CONNECTION CARD
// ─────────────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final _MockInterest interest;
  final VoidCallback onViewProfile;
  final VoidCallback onChat;

  const _ConnectionCard({
    required this.interest,
    required this.onViewProfile,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          ...AppColors.softShadow,
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onViewProfile,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Stack(children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.4),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(interest.emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.favorite_rounded,
                            size: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${interest.name}, ${interest.age}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(interest.profession,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.inkSoft)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.muted),
                        const SizedBox(width: 3),
                        Text(
                          '${interest.city} • ${interest.caste}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.handshake_outlined,
                          size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'Connected',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 15, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────

class _TabLabel extends StatelessWidget {
  final String label;
  final int badge;
  final Color badgeColor;

  const _TabLabel({
    required this.label,
    this.badge = 0,
    this.badgeColor = AppColors.crimson,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge > 0) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _MockStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    late String label;
    late IconData icon;

    switch (status) {
      case _MockStatus.pending:
        bg = AppColors.warningSurface;
        fg = AppColors.warning;
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      case _MockStatus.accepted:
        bg = AppColors.successSurface;
        fg = AppColors.success;
        label = 'Accepted';
        icon = Icons.check_circle_outline_rounded;
        break;
      case _MockStatus.declined:
        bg = AppColors.errorSurface;
        fg = AppColors.error;
        label = 'Declined';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.crimsonSurface, AppColors.ivoryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// UTILS
// ─────────────────────────────────────────────────────────

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}