// lib/presentation/shell/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/providers/app_state_provider.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/providers/chat_provider.dart';

// ─────────────────────────────────────────────────────────
// NAV ITEM MODEL
// ─────────────────────────────────────────────────────────

class _NavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<_NavItem> _navItems = [
  _NavItem(
    route: '/home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  _NavItem(
    route: '/search',
    icon: Icons.search_outlined,
    activeIcon: Icons.search_rounded,
    label: 'Search',
  ),
  _NavItem(
    route: '/interests',
    icon: Icons.favorite_outline_rounded,
    activeIcon: Icons.favorite_rounded,
    label: 'Interests',
  ),
  _NavItem(
    route: '/chat',
    icon: Icons.chat_bubble_outline_rounded,
    activeIcon: Icons.chat_bubble_rounded,
    label: 'Messages',
  ),
  _NavItem(
    route: '/my-profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

// ─────────────────────────────────────────────────────────
// MAIN SHELL
// ─────────────────────────────────────────────────────────

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  // ── CURRENT INDEX ─────────────────────────────────────

  int _currentIndex(String location) {
    if (location.startsWith('/search'))      return 1;
    if (location.startsWith('/interests'))   return 2;
    if (location.startsWith('/chat') &&
        !location.contains('/chat/'))        return 3;
    if (location.startsWith('/my-profile'))  return 4;
    return 0;
  }

  void _onTabTap(
      BuildContext context,
      int index,
      int currentIndex,
      ) {
    if (index == currentIndex) {
      // Same tab tapped — scroll to top
      // Phase 3: ScrollController use karo
      return;
    }

    HapticFeedback.selectionClick();

    switch (index) {
      case 0: context.go('/home');       break;
      case 1: context.go('/search');     break;
      case 2: context.go('/interests');  break;
      case 3: context.go('/chat');       break;
      case 4: context.go('/my-profile'); break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context)
        .uri
        .toString();
    final currentIndex = _currentIndex(location);

    // Badge counts
    final interestCount = ref.watch(
        pendingInterestsCountProvider);
    final chatCount =
    ref.watch(totalUnreadProvider);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: child,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        interestBadge: interestCount,
        chatBadge: chatCount,
        onTap: (i) => _onTabTap(
            context, i, currentIndex),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BOTTOM NAV BAR
// ─────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final int interestBadge;
  final int chatBadge;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.interestBadge,
    required this.chatBadge,
    required this.onTap,
  });

  int _badgeFor(int index) {
    if (index == 2) return interestBadge;
    if (index == 3) return chatBadge;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad =
        MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: AppColors.modalShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(
              _navItems.length,
                  (i) => Expanded(
                child: _NavButton(
                  item: _navItems[i],
                  isActive: i == currentIndex,
                  badgeCount: _badgeFor(i),
                  onTap: () => onTap(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// NAV BUTTON
// ─────────────────────────────────────────────────────────

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() =>
      _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ctrl.forward().then(
                (_) => _ctrl.reverse());
        widget.onTap();
      },
      onTapDown: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Icon
                  AnimatedSwitcher(
                    duration: const Duration(
                        milliseconds: 200),
                    transitionBuilder:
                        (child, anim) =>
                        ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                    child: Icon(
                      widget.isActive
                          ? widget.item.activeIcon
                          : widget.item.icon,
                      key: ValueKey(
                          widget.isActive),
                      size: 24,
                      color: widget.isActive
                          ? AppColors.crimson
                          : AppColors.muted,
                    ),
                  ),

                  // Badge
                  if (widget.badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: _Badge(
                          count: widget.badgeCount),
                    ),
                ],
              ),

              const SizedBox(height: 4),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(
                    milliseconds: 200),
                style: widget.isActive
                    ? AppTextStyles.navSelected
                    : AppTextStyles.navUnselected,
                child: Text(widget.item.label),
              ),

              // Active indicator dot
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(
                    milliseconds: 250),
                curve: Curves.easeInOut,
                width: widget.isActive ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.crimson,
                  borderRadius:
                  BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BADGE WIDGET
// ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label =
    count > 99 ? '99+' : '$count';
    final isWide = count > 9;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 5 : 4,
        vertical: 2,
      ),
      constraints: const BoxConstraints(
          minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.crimson,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.white,
          width: 1.5,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}