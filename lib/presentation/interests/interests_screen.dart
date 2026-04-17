// lib/presentation/interests/interests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/providers/auth_provider.dart';

// ── MOCK DATA ─────────────────────────────────────────────
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
    id: 'r1',
    name: 'Rahul Sharma',
    emoji: '👨',
    age: 29,
    city: 'Delhi',
    caste: 'Brahmin',
    profession: 'Software Engineer',
    isVerified: true,
    status: _MockStatus.pending,
    isMe: false,
    time: DateTime.now()
        .subtract(const Duration(hours: 2)),
    message:
    'Hi! I found your profile very interesting.',
  ),
  _MockInterest(
    id: 'r2',
    name: 'Arjun Patel',
    emoji: '👨‍💼',
    age: 31,
    city: 'Mumbai',
    caste: 'Patel',
    profession: 'Business',
    isVerified: false,
    status: _MockStatus.pending,
    isMe: false,
    time: DateTime.now()
        .subtract(const Duration(hours: 5)),
  ),
  _MockInterest(
    id: 'r3',
    name: 'Vikram Singh',
    emoji: '👨‍⚕️',
    age: 30,
    city: 'Jaipur',
    caste: 'Rajput',
    profession: 'Doctor',
    isVerified: true,
    status: _MockStatus.accepted,
    isMe: false,
    time: DateTime.now()
        .subtract(const Duration(days: 1)),
  ),
  _MockInterest(
    id: 'r4',
    name: 'Karan Mehta',
    emoji: '👨‍🔬',
    age: 28,
    city: 'Bangalore',
    caste: 'Brahmin',
    profession: 'Data Scientist',
    isVerified: true,
    status: _MockStatus.declined,
    isMe: false,
    time: DateTime.now()
        .subtract(const Duration(days: 2)),
  ),
];

final _mockSent = [
  _MockInterest(
    id: 's1',
    name: 'Priya Sharma',
    emoji: '👩',
    age: 26,
    city: 'Delhi',
    caste: 'Brahmin',
    profession: 'Software Engineer',
    isVerified: true,
    status: _MockStatus.pending,
    isMe: true,
    time: DateTime.now()
        .subtract(const Duration(hours: 3)),
  ),
  _MockInterest(
    id: 's2',
    name: 'Anjali Gupta',
    emoji: '👩‍💼',
    age: 24,
    city: 'Mumbai',
    caste: 'Kayastha',
    profession: 'Marketing Manager',
    isVerified: false,
    status: _MockStatus.accepted,
    isMe: true,
    time: DateTime.now()
        .subtract(const Duration(days: 1)),
  ),
  _MockInterest(
    id: 's3',
    name: 'Meera Singh',
    emoji: '👩‍⚕️',
    age: 28,
    city: 'Jaipur',
    caste: 'Rajput',
    profession: 'Doctor',
    isVerified: true,
    status: _MockStatus.declined,
    isMe: true,
    time: DateTime.now()
        .subtract(const Duration(days: 3)),
  ),
];

final _mockConnections = [
  _MockInterest(
    id: 'c1',
    name: 'Anjali Gupta',
    emoji: '👩‍💼',
    age: 24,
    city: 'Mumbai',
    caste: 'Kayastha',
    profession: 'Marketing Manager',
    isVerified: false,
    status: _MockStatus.accepted,
    isMe: true,
    time: DateTime.now()
        .subtract(const Duration(days: 1)),
  ),
  _MockInterest(
    id: 'c2',
    name: 'Vikram Singh',
    emoji: '👨‍⚕️',
    age: 30,
    city: 'Jaipur',
    caste: 'Rajput',
    profession: 'Doctor',
    isVerified: true,
    status: _MockStatus.accepted,
    isMe: false,
    time: DateTime.now()
        .subtract(const Duration(days: 1)),
  ),
];

// ── SCREEN ────────────────────────────────────────────────
class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() =>
      _InterestsScreenState();
}

class _InterestsScreenState
    extends ConsumerState<InterestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final Map<String, _MockStatus> _receivedStatus =
  {};
  final Set<String> _withdrawnIds = {};

  int get _pendingCount => _mockReceived
      .where((i) =>
  i.status == _MockStatus.pending &&
      !(_receivedStatus[i.id] != null))
      .length;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _acceptInterest(String id) {
    setState(() =>
    _receivedStatus[id] =
        _MockStatus.accepted);
    _showSnack(
      '✅ Interest accepted! You are now connected.',
      AppColors.success,
    );
  }

  void _declineInterest(String id) {
    setState(() =>
    _receivedStatus[id] =
        _MockStatus.declined);
    _showSnack('Interest declined', AppColors.ink);
  }

  void _withdrawInterest(String id) {
    setState(() => _withdrawnIds.add(id));
    _showSnack('Interest withdrawn', AppColors.ink);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
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

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader() {
    final topPad =
        MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(
          20, topPad + 10, 20, 14),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.interests,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                _pendingCount > 0
                    ? '$_pendingCount pending'
                    ' response${_pendingCount > 1 ? 's' : ''}'
                    : 'Manage your connections',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
          Row(children: [
            _StatBadge(
              label: 'Received',
              count: _mockReceived.length,
              color: AppColors.goldLight,
            ),
            const SizedBox(width: 8),
            _StatBadge(
              label: 'Connected',
              count: _mockConnections.length,
              color: AppColors.success,
            ),
          ]),
        ],
      ),
    );
  }

  // ── TAB BAR ───────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: AppColors.crimson,
      padding:
      const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize:
          TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.crimson,
          unselectedLabelColor:
          Colors.white.withOpacity(0.8),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            _TabItem(
              label: 'Received',
              count: _pendingCount,
            ),
            const Tab(text: 'Sent'),
            _TabItem(
              label: 'Connected',
              count: _mockConnections.length,
              countColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  // ── RECEIVED TAB ──────────────────────────────────────
  Widget _buildReceivedTab() {
    if (_mockReceived.isEmpty) {
      return _EmptyState(
        emoji: '💌',
        title: 'No Interests Yet',
        subtitle:
        'When someone sends you an interest,\n'
            'it will appear here.',
        actionLabel: AppStrings.browseProfiles,
        onAction: () => context.go('/search'),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 100),
      itemCount: _mockReceived.length,
      itemBuilder: (_, i) {
        final interest = _mockReceived[i];
        final status =
            _receivedStatus[interest.id] ??
                interest.status;
        return _ReceivedCard(
          interest: interest,
          status: status,
          onAccept: () =>
              _acceptInterest(interest.id),
          onDecline: () =>
              _declineInterest(interest.id),
          onViewProfile: () => context
              .push('/profile/${interest.id}'),
        );
      },
    );
  }

  // ── SENT TAB ──────────────────────────────────────────
  Widget _buildSentTab() {
    final visible = _mockSent
        .where((i) =>
    !_withdrawnIds.contains(i.id))
        .toList();
    if (visible.isEmpty) {
      return _EmptyState(
        emoji: '💝',
        title: 'No Interests Sent',
        subtitle:
        'Browse profiles and send\n'
            'your first interest.',
        actionLabel: AppStrings.browseProfiles,
        onAction: () => context.go('/search'),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 100),
      itemCount: visible.length,
      itemBuilder: (_, i) {
        final interest = visible[i];
        return _SentCard(
          interest: interest,
          onWithdraw: () =>
              _withdrawInterest(interest.id),
          onViewProfile: () => context
              .push('/profile/${interest.id}'),
        );
      },
    );
  }

  // ── CONNECTIONS TAB ───────────────────────────────────
  Widget _buildConnectionsTab() {
    if (_mockConnections.isEmpty) {
      return _EmptyState(
        emoji: '🤝',
        title: AppStrings.noConnections,
        subtitle: AppStrings.noConnectionsSub,
        actionLabel: 'View Received Interests',
        onAction: () =>
            _tabController.animateTo(0),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 100),
      itemCount: _mockConnections.length,
      itemBuilder: (_, i) {
        final conn = _mockConnections[i];
        return _ConnectionCard(
          interest: conn,
          onViewProfile: () =>
              context.push('/profile/${conn.id}'),
          onChat: () =>
              context.push('/chat/${conn.id}'),
        );
      },
    );
  }
}

// ── RECEIVED CARD ─────────────────────────────────────────
class _ReceivedCard extends StatelessWidget {
  final _MockInterest interest;
  final _MockStatus status;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewProfile;

  const _ReceivedCard({
    required this.interest,
    required this.status,
    required this.onAccept,
    required this.onDecline,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == _MockStatus.pending;
    final isAccepted =
        status == _MockStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppColors.crimson.withOpacity(0.25)
              : AppColors.border,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onViewProfile,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Stack(children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                        AppColors.crimsonSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPending
                              ? AppColors.crimson
                              .withOpacity(0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          interest.emoji,
                          style: const TextStyle(
                              fontSize: 28),
                        ),
                      ),
                    ),
                    if (interest.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                AppColors.white,
                                width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${interest.name},'
                                    ' ${interest.age}',
                                style:
                                const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                                overflow: TextOverflow
                                    .ellipsis,
                              ),
                            ),
                            _StatusChip(
                                status: status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          interest.profession,
                          style: const TextStyle(
                              fontSize: 13,
                              color:
                              AppColors.inkSoft),
                        ),
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 12,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${interest.city} • '
                                '${interest.caste}',
                            style: const TextStyle(
                                fontSize: 12,
                                color:
                                AppColors.muted),
                          ),
                          const Spacer(),
                          Text(
                            _timeAgo(interest.time),
                            style: const TextStyle(
                                fontSize: 11,
                                color:
                                AppColors.muted),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (interest.message != null)
            Container(
              margin: const EdgeInsets.fromLTRB(
                  14, 0, 14, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 16,
                    color: AppColors.crimson,
                  ),
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
          if (isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  14, 12, 14, 14),
              child: Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style:
                      OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.border,
                            width: 1.5),
                        shape:
                        RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                10)),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded,
                              size: 16,
                              color: AppColors.muted),
                          SizedBox(width: 6),
                          Text(
                            AppStrings.decline,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w600,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.success,
                        shape:
                        RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                10)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 16,
                              color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            AppStrings.accept,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w600,
                              color: Colors.white,
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
              padding: const EdgeInsets.fromLTRB(
                  14, 8, 14, 14),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => context
                      .push('/chat/${interest.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.crimson,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            10)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                          Icons
                              .chat_bubble_outline_rounded,
                          size: 16,
                          color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Start Chat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ── SENT CARD ─────────────────────────────────────────────
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
    final isAccepted =
        interest.status == _MockStatus.accepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: GestureDetector(
        onTap: onViewProfile,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isAccepted
                      ? AppColors.successSurface
                      : AppColors.ivoryDark,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    interest.emoji,
                    style: const TextStyle(
                        fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${interest.name},'
                                ' ${interest.age}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusChip(
                            status: interest.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      interest.profession,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${interest.city} • '
                              '${interest.caste}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted),
                        ),
                      ),
                      Text(
                        _timeAgo(interest.time),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CONNECTION CARD ───────────────────────────────────────
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onViewProfile,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Stack(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                      AppColors.successSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success
                            .withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        interest.emoji,
                        style: const TextStyle(
                            fontSize: 28),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white,
                            width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.handshake_outlined,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${interest.name},'
                            ' ${interest.age}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        interest.profession,
                        style: const TextStyle(
                            fontSize: 13,
                            color:
                            AppColors.inkSoft),
                      ),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${interest.city} • '
                              '${interest.caste}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted),
                        ),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius:
                    BorderRadius.circular(100),
                    border: Border.all(
                        color: AppColors.success
                            .withOpacity(0.3)),
                  ),
                  child: const Text(
                    '🤝 Connected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                        Icons
                            .chat_bubble_outline_rounded,
                        size: 16,
                        color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

// ── PRIVATE WIDGETS ───────────────────────────────────────

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final Color countColor;

  const _TabItem({
    super.key,
    required this.label,
    this.count = 0,
    this.countColor = AppColors.crimson,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 5),
            Container(
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: countColor,
                borderRadius:
                BorderRadius.circular(100),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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



class _StatusChip extends StatelessWidget {
  final _MockStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color textColor;
    late String label;
    late IconData icon;

    switch (status) {
      case _MockStatus.pending:
        bg = AppColors.warningSurface;
        textColor = AppColors.warning;
        label = 'Pending';
        icon = Icons.hourglass_top_rounded;
        break;
      case _MockStatus.accepted:
        bg = AppColors.successSurface;
        textColor = AppColors.success;
        label = 'Accepted';
        icon = Icons.check_circle_outline_rounded;
        break;
      case _MockStatus.declined:
        bg = AppColors.errorSurface;
        textColor = AppColors.error;
        label = 'Declined';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            color:
            Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color:
              Colors.white.withOpacity(0.8),
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.crimsonSurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(
                        fontSize: 38)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
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
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}