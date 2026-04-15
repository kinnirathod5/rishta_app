// lib/core/widgets/empty_state.dart

import 'package:flutter/material.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// EMPTY STATE WIDGET
// ─────────────────────────────────────────────────────────

/// Reusable empty state widget for all screens.
///
/// Usage:
/// ```dart
/// // Basic:
/// EmptyState(
///   emoji: '💌',
///   title: 'No Interests Yet',
///   subtitle: 'Browse profiles and send interests',
/// )
///
/// // With action button:
/// EmptyState(
///   emoji: '🔍',
///   title: 'No Results Found',
///   subtitle: 'Try different search terms',
///   actionLabel: 'Reset Filters',
///   onAction: () => _resetFilters(),
/// )
///
/// // Predefined type:
/// EmptyState.noInterests(
///   onAction: () => context.go('/search'),
/// )
/// ```
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final EmptyStateSize size;
  final Color? iconBgColor;
  final Widget? customIcon;
  final bool animate;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.size = EmptyStateSize.medium,
    this.iconBgColor,
    this.customIcon,
    this.animate = true,
  });

  // ── PREDEFINED EMPTY STATES ───────────────────────────

  /// No matches / search results
  factory EmptyState.noMatches({
    VoidCallback? onAction,
    String? message,
  }) =>
      EmptyState(
        emoji: '🔍',
        title: 'No Profiles Found',
        subtitle: message ??
            'Try adjusting your filters\nor search with different terms',
        actionLabel: 'Reset Filters',
        onAction: onAction,
      );

  /// No interests received
  factory EmptyState.noInterests({
    VoidCallback? onAction,
  }) =>
      EmptyState(
        emoji: '💌',
        title: 'No Interests Yet',
        subtitle:
        'When someone sends you an interest,\nit will appear here',
        actionLabel: 'Browse Profiles',
        onAction: onAction,
      );

  /// No interests sent
  factory EmptyState.noSentInterests({
    VoidCallback? onAction,
  }) =>
      EmptyState(
        emoji: '💝',
        title: 'No Interests Sent',
        subtitle:
        'Browse profiles and send\nyour first interest',
        actionLabel: 'Browse Profiles',
        onAction: onAction,
      );

  /// No connections
  factory EmptyState.noConnections({
    VoidCallback? onAction,
  }) =>
      EmptyState(
        emoji: '🤝',
        title: 'No Connections Yet',
        subtitle:
        'Accept interests to\nbuild your connections',
        actionLabel: 'View Interests',
        onAction: onAction,
      );

  /// No chats
  factory EmptyState.noChats({
    VoidCallback? onAction,
  }) =>
      EmptyState(
        emoji: '💬',
        title: 'No Conversations Yet',
        subtitle:
        'Connect with profiles\nand start chatting',
        actionLabel: 'View Connections',
        onAction: onAction,
      );

  /// No notifications
  factory EmptyState.noNotifications() =>
      const EmptyState(
        emoji: '🔔',
        title: 'No Notifications Yet',
        subtitle:
        'Your matches and activities\nwill appear here',
      );

  /// No shortlisted profiles
  factory EmptyState.noShortlisted({
    VoidCallback? onAction,
  }) =>
      EmptyState(
        emoji: '🔖',
        title: 'No Saved Profiles',
        subtitle:
        'Bookmark profiles you like\nto view them later',
        actionLabel: 'Browse Profiles',
        onAction: onAction,
      );

  /// No profile views
  factory EmptyState.noViews() =>
      const EmptyState(
        emoji: '👁️',
        title: 'No Profile Views Yet',
        subtitle:
        'Upgrade to Premium to\nsee who viewed your profile',
        iconBgColor: AppColors.goldSurface,
      );

  /// Search no results
  factory EmptyState.searchEmpty({
    required String query,
    VoidCallback? onAction,
  }) =>
      EmptyState(
        emoji: '🔍',
        title: 'No results for "$query"',
        subtitle:
        'Try a different name, city\nor profession',
        actionLabel: onAction != null
            ? 'Clear Search'
            : null,
        onAction: onAction,
      );

  /// Network error
  factory EmptyState.networkError({
    VoidCallback? onRetry,
  }) =>
      EmptyState(
        emoji: '📡',
        title: 'No Internet Connection',
        subtitle:
        'Please check your network\nand try again',
        actionLabel: 'Retry',
        onAction: onRetry,
        iconBgColor: AppColors.warningSurface,
      );

  /// Generic error
  factory EmptyState.error({
    String? message,
    VoidCallback? onRetry,
  }) =>
      EmptyState(
        emoji: '😕',
        title: 'Something Went Wrong',
        subtitle: message ??
            'An error occurred.\nPlease try again.',
        actionLabel: 'Try Again',
        onAction: onRetry,
        iconBgColor: AppColors.errorSurface,
      );

  /// Photos empty
  factory EmptyState.noPhotos({
    VoidCallback? onAction,
  }) =>
      EmptyState(
        emoji: '📸',
        title: 'No Photos Added',
        subtitle:
        'Add photos to your profile\nto attract more matches',
        actionLabel: 'Add Photos',
        onAction: onAction,
      );

  /// Blocked users empty
  factory EmptyState.noBlockedUsers() =>
      const EmptyState(
        emoji: '✅',
        title: 'No Blocked Users',
        subtitle:
        'Users you block will\nappear here',
      );

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return _AnimatedEmptyState(child: _build());
    }
    return _build();
  }

  Widget _build() {
    switch (size) {
      case EmptyStateSize.small:
        return _SmallEmpty(this);
      case EmptyStateSize.medium:
        return _MediumEmpty(this);
      case EmptyStateSize.large:
        return _LargeEmpty(this);
    }
  }
}

// ─────────────────────────────────────────────────────────
// SIZE ENUM
// ─────────────────────────────────────────────────────────

enum EmptyStateSize {
  small,   // Inline — inside a card/section
  medium,  // Standard — full screen center
  large,   // Hero — with illustration area
}

// ─────────────────────────────────────────────────────────
// SIZE VARIANTS
// ─────────────────────────────────────────────────────────

class _SmallEmpty extends StatelessWidget {
  final EmptyState config;
  const _SmallEmpty(this.config);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 10),
          Text(
            config.title,
            style: AppTextStyles.h5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            config.subtitle,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (config.actionLabel != null) ...[
            const SizedBox(height: 14),
            _ActionButton(
              label: config.actionLabel!,
              onTap: config.onAction,
              isSmall: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _MediumEmpty extends StatelessWidget {
  final EmptyState config;
  const _MediumEmpty(this.config);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            config.customIcon ??
                _EmojiContainer(
                  emoji: config.emoji,
                  bgColor: config.iconBgColor,
                  size: 80,
                  emojiSize: 38,
                ),
            const SizedBox(height: 22),
            Text(
              config.title,
              style: AppTextStyles.emptyTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              config.subtitle,
              style: AppTextStyles.emptySubtitle,
              textAlign: TextAlign.center,
            ),
            if (config.actionLabel != null) ...[
              const SizedBox(height: 28),
              _ActionButton(
                label: config.actionLabel!,
                onTap: config.onAction,
              ),
            ],
            if (config.secondaryLabel != null) ...[
              const SizedBox(height: 12),
              _SecondaryButton(
                label: config.secondaryLabel!,
                onTap: config.onSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LargeEmpty extends StatelessWidget {
  final EmptyState config;
  const _LargeEmpty(this.config);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large illustration container
            config.customIcon ??
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: config.iconBgColor ??
                        AppColors.crimsonSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      config.emoji,
                      style: const TextStyle(
                          fontSize: 64),
                    ),
                  ),
                ),
            const SizedBox(height: 32),
            Text(
              config.title,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              config.subtitle,
              style: AppTextStyles.bodyLarge
                  .copyWith(
                  color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (config.actionLabel != null) ...[
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: config.onAction,
                  child:
                  Text(config.actionLabel!),
                ),
              ),
            ],
            if (config.secondaryLabel != null) ...[
              const SizedBox(height: 12),
              _SecondaryButton(
                label: config.secondaryLabel!,
                onTap: config.onSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ANIMATED WRAPPER
// ─────────────────────────────────────────────────────────

class _AnimatedEmptyState extends StatefulWidget {
  final Widget child;
  const _AnimatedEmptyState({required this.child});

  @override
  State<_AnimatedEmptyState> createState() =>
      _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState
    extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6,
          curve: Curves.easeOut),
    ));

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────

class _EmojiContainer extends StatelessWidget {
  final String emoji;
  final Color? bgColor;
  final double size;
  final double emojiSize;

  const _EmojiContainer({
    required this.emoji,
    this.bgColor,
    required this.size,
    required this.emojiSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.crimsonSurface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: emojiSize),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSmall;

  const _ActionButton({
    required this.label,
    this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isSmall ? null : double.infinity,
      height: isSmall ? 38 : 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: isSmall
              ? const EdgeInsets.symmetric(
              horizontal: 24)
              : null,
          minimumSize: Size.zero,
        ),
        child: Text(
          label,
          style: isSmall
              ? AppTextStyles.buttonSmall
              : AppTextStyles.buttonPrimary,
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: AppTextStyles.buttonSecondary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// EMPTY STATE BUILDER — Conditional wrapper
// ─────────────────────────────────────────────────────────

/// Shows empty state or child based on condition.
///
/// ```dart
/// EmptyStateBuilder(
///   isEmpty: profiles.isEmpty,
///   isLoading: _isLoading,
///   emptyWidget: EmptyState.noMatches(
///     onAction: _resetFilters,
///   ),
///   child: _buildList(profiles),
/// )
/// ```
class EmptyStateBuilder extends StatelessWidget {
  final bool isEmpty;
  final bool isLoading;
  final Widget emptyWidget;
  final Widget child;
  final Widget? loadingWidget;

  const EmptyStateBuilder({
    super.key,
    required this.isEmpty,
    required this.emptyWidget,
    required this.child,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.crimson,
              ),
            ),
          );
    }
    if (isEmpty) return emptyWidget;
    return child;
  }
}