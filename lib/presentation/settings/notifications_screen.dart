import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class MockNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String timeAgo;
  final String emoji;
  final bool isRead;
  final String actionRoute;

  const MockNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.emoji,
    required this.isRead,
    required this.actionRoute,
  });

  MockNotification copyWith({bool? isRead}) {
    return MockNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      timeAgo: timeAgo,
      emoji: emoji,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<MockNotification> _notifications = const [
    MockNotification(
      id: 'n1',
      type: 'interest',
      title: 'Naya Interest! 💌',
      body: 'Rahul Sharma ne aapko interest bheja',
      timeAgo: '2 ghante pehle',
      emoji: '💌',
      isRead: false,
      actionRoute: '/interests',
    ),
    MockNotification(
      id: 'n2',
      type: 'accepted',
      title: 'Interest Accept Ho Gaya! 🎉',
      body: 'Anjali Gupta ne aapka interest accept kiya',
      timeAgo: '5 ghante pehle',
      emoji: '✅',
      isRead: false,
      actionRoute: '/interests',
    ),
    MockNotification(
      id: 'n3',
      type: 'message',
      title: 'Naya Message 💬',
      body: 'Anjali: Namaste! Profile dekhi bahut...',
      timeAgo: '6 ghante pehle',
      emoji: '💬',
      isRead: false,
      actionRoute: '/chat',
    ),
    MockNotification(
      id: 'n4',
      type: 'view',
      title: '5 Logon Ne Profile Dekhi',
      body: 'Aaj 5 naye log aapka profile dekha',
      timeAgo: '8 ghante pehle',
      emoji: '👁️',
      isRead: true,
      actionRoute: '/my-profile',
    ),
    MockNotification(
      id: 'n5',
      type: 'premium',
      title: '👑 Premium Expire Hone Wala Hai',
      body: '3 din mein premium expire hoga, renew karo',
      timeAgo: 'Kal',
      emoji: '👑',
      isRead: true,
      actionRoute: '/premium',
    ),
    MockNotification(
      id: 'n6',
      type: 'interest',
      title: 'Naya Interest! 💌',
      body: 'Vikram Singh ne interest bheja',
      timeAgo: '1 din pehle',
      emoji: '💌',
      isRead: true,
      actionRoute: '/interests',
    ),
    MockNotification(
      id: 'n7',
      type: 'photo',
      title: 'Photo Approve Ho Gayi ✓',
      body: 'Aapki profile photo approve ho gayi',
      timeAgo: '2 din pehle',
      emoji: '📸',
      isRead: true,
      actionRoute: '/my-profile',
    ),
    MockNotification(
      id: 'n8',
      type: 'match',
      title: 'Naya Match Mila! 💑',
      body: 'Aapki preference ke 12 naye profiles',
      timeAgo: '2 din pehle',
      emoji: '💑',
      isRead: true,
      actionRoute: '/home',
    ),
    MockNotification(
      id: 'n9',
      type: 'message',
      title: 'Naya Message 💬',
      body: 'Rahul: Kya aap kal free hain?',
      timeAgo: '3 din pehle',
      emoji: '💬',
      isRead: true,
      actionRoute: '/chat',
    ),
    MockNotification(
      id: 'n10',
      type: 'complete',
      title: 'Profile Score Badha! 🎯',
      body: 'Profile 78% complete hui, horoscope add karo',
      timeAgo: '5 din pehle',
      emoji: '🎯',
      isRead: true,
      actionRoute: '/my-profile',
    ),
  ];

  int get _unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        final updated = List<MockNotification>.from(_notifications);
        updated[idx] = _notifications[idx].copyWith(isRead: true);
        _notifications = updated;
      }
    });
  }

  void _markAllRead() {
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications =
          _notifications.where((n) => n.id != id).toList();
    });
  }

  String _getGroup(MockNotification n) {
    if (n.timeAgo.contains('ghante')) return 'Aaj';
    if (n.timeAgo == 'Kal') return 'Kal';
    return 'Is Hafte';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'interest':
        return AppColors.crimsonSurface;
      case 'accepted':
        return AppColors.successSurface;
      case 'message':
        return AppColors.infoSurface;
      case 'view':
        return AppColors.goldSurface;
      case 'premium':
        return AppColors.goldSurface;
      case 'photo':
        return AppColors.successSurface;
      case 'match':
        return AppColors.crimsonSurface;
      case 'complete':
        return AppColors.goldSurface;
      default:
        return AppColors.ivoryDark;
    }
  }

  List<MapEntry<String, List<MockNotification>>>
      _getGroupedNotifications() {
    final groups = <String, List<MockNotification>>{
      'Aaj': [],
      'Kal': [],
      'Is Hafte': [],
    };
    for (final n in _notifications) {
      groups[_getGroup(n)]!.add(n);
    }
    return groups.entries
        .where((e) => e.value.isNotEmpty)
        .toList();
  }

  Widget _buildNotificationItem(MockNotification notif) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration:
            const BoxDecoration(color: AppColors.errorSurface),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 24),
      ),
      onDismissed: (_) => _removeNotification(notif.id),
      child: GestureDetector(
        onTap: () {
          _markAsRead(notif.id);
          context.pop();
          context.push(notif.actionRoute);
        },
        child: Container(
          decoration: BoxDecoration(
            color: notif.isRead ? AppColors.white : AppColors.crimsonSurface,
            border: Border(
              bottom: BorderSide(
                  color: AppColors.border.withOpacity(0.4)),
            ),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getTypeColor(notif.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(notif.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notif.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.timeAgo,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (!notif.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.crimson,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getGroupedNotifications();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: AppColors.softShadow,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.ivoryDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'Aapki activities',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.crimsonSurface,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'Sab Padha ✓',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.crimson,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── Notifications List ───────────────────────
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('🔔',
                              style: TextStyle(fontSize: 56)),
                          SizedBox(height: 16),
                          Text(
                            'Koi Notification Nahi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Yahan aapki activities\naur matches dikhenge',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.muted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final group in groups) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Text(
                                group.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                boxShadow: AppColors.softShadow,
                              ),
                              child: Column(
                                children: group.value
                                    .map(_buildNotificationItem)
                                    .toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
