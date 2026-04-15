// lib/core/widgets/profile_avatar.dart

import 'package:flutter/material.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// AVATAR SIZE ENUM
// ─────────────────────────────────────────────────────────

enum AvatarSize {
  xs,   // 28px — inline mentions
  sm,   // 36px — chat list
  md,   // 48px — cards
  lg,   // 64px — profile header
  xl,   // 88px — profile detail
  xxl,  // 120px — profile preview
}

extension AvatarSizeValues on AvatarSize {
  double get dimension {
    switch (this) {
      case AvatarSize.xs:  return 28;
      case AvatarSize.sm:  return 36;
      case AvatarSize.md:  return 48;
      case AvatarSize.lg:  return 64;
      case AvatarSize.xl:  return 88;
      case AvatarSize.xxl: return 120;
    }
  }

  double get emojiSize {
    switch (this) {
      case AvatarSize.xs:  return 14;
      case AvatarSize.sm:  return 18;
      case AvatarSize.md:  return 24;
      case AvatarSize.lg:  return 32;
      case AvatarSize.xl:  return 44;
      case AvatarSize.xxl: return 60;
    }
  }

  double get initialsSize {
    switch (this) {
      case AvatarSize.xs:  return 10;
      case AvatarSize.sm:  return 13;
      case AvatarSize.md:  return 16;
      case AvatarSize.lg:  return 20;
      case AvatarSize.xl:  return 26;
      case AvatarSize.xxl: return 34;
    }
  }

  double get badgeSize {
    switch (this) {
      case AvatarSize.xs:  return 0;  // no badge
      case AvatarSize.sm:  return 10;
      case AvatarSize.md:  return 13;
      case AvatarSize.lg:  return 16;
      case AvatarSize.xl:  return 20;
      case AvatarSize.xxl: return 24;
    }
  }

  double get borderWidth {
    switch (this) {
      case AvatarSize.xs:  return 1;
      case AvatarSize.sm:  return 1.5;
      case AvatarSize.md:  return 2;
      case AvatarSize.lg:  return 2.5;
      case AvatarSize.xl:  return 3;
      case AvatarSize.xxl: return 3.5;
    }
  }

  double get onlineDotSize {
    switch (this) {
      case AvatarSize.xs:  return 0;
      case AvatarSize.sm:  return 8;
      case AvatarSize.md:  return 10;
      case AvatarSize.lg:  return 12;
      case AvatarSize.xl:  return 14;
      case AvatarSize.xxl: return 18;
    }
  }
}

// ─────────────────────────────────────────────────────────
// PROFILE AVATAR WIDGET
// ─────────────────────────────────────────────────────────

/// Versatile profile avatar widget.
///
/// Supports:
/// - Emoji placeholder (no photo)
/// - Network image (with CachedNetworkImage)
/// - Initials fallback
/// - Verified badge
/// - Premium crown badge
/// - Online indicator
/// - Edit camera button
/// - Multiple sizes via [AvatarSize]
///
/// Usage:
/// ```dart
/// ProfileAvatar(
///   emoji: '👩',
///   size: AvatarSize.lg,
///   isVerified: true,
///   isOnline: true,
/// )
/// ```
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? emoji;
  final String? name;           // for initials fallback
  final AvatarSize size;
  final bool isVerified;
  final bool isPremium;
  final bool isOnline;
  final bool showEditButton;
  final bool isSelected;        // for selection state
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final Color? borderColor;
  final bool showBorder;
  final bool isGuest;           // locked/blurred state

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.emoji,
    this.name,
    this.size = AvatarSize.md,
    this.isVerified = false,
    this.isPremium = false,
    this.isOnline = false,
    this.showEditButton = false,
    this.isSelected = false,
    this.onTap,
    this.onEditTap,
    this.borderColor,
    this.showBorder = false,
    this.isGuest = false,
  });

  // ── CONVENIENCE CONSTRUCTORS ──────────────────────

  /// Small avatar for chat list
  const ProfileAvatar.chat({
    super.key,
    this.photoUrl,
    this.emoji,
    this.name,
    this.isOnline = false,
    this.isVerified = false,
    this.isPremium = false,
    this.onTap,
  })  : size = AvatarSize.sm,
        showEditButton = false,
        isSelected = false,
        onEditTap = null,
        borderColor = null,
        showBorder = false,
        isGuest = false;

  /// Large avatar for profile header
  const ProfileAvatar.profile({
    super.key,
    this.photoUrl,
    this.emoji,
    this.name,
    this.isVerified = false,
    this.isPremium = false,
    this.showEditButton = false,
    this.onEditTap,
    this.onTap,
  })  : size = AvatarSize.xl,
        isOnline = false,
        isSelected = false,
        borderColor = null,
        showBorder = true,
        isGuest = false;

  /// Extra-large for preview screen
  const ProfileAvatar.preview({
    super.key,
    this.photoUrl,
    this.emoji,
    this.name,
    this.isVerified = false,
    this.isPremium = false,
  })  : size = AvatarSize.xxl,
        isOnline = false,
        showEditButton = false,
        isSelected = false,
        onTap = null,
        onEditTap = null,
        borderColor = null,
        showBorder = true,
        isGuest = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildAvatar(),
          if (isVerified &&
              size.badgeSize > 0)
            _buildVerifiedBadge(),
          if (isPremium &&
              !isVerified &&
              size.badgeSize > 0)
            _buildPremiumBadge(),
          if (isOnline &&
              size.onlineDotSize > 0)
            _buildOnlineDot(),
          if (showEditButton)
            _buildEditButton(),
        ],
      ),
    );
  }

  // ── AVATAR BODY ───────────────────────────────────
  Widget _buildAvatar() {
    final dimension = size.dimension;
    final effectiveBorderColor = isSelected
        ? AppColors.crimson
        : borderColor ??
        (showBorder
            ? AppColors.goldLight
            : Colors.transparent);

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColor(),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected
              ? size.borderWidth + 1
              : size.borderWidth,
        ),
        boxShadow: showBorder || isSelected
            ? AppColors.softShadow
            : null,
      ),
      child: ClipOval(
        child: isGuest
            ? _buildLockedContent()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Network image
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return _buildNetworkImage();
    }
    // Emoji placeholder
    if (emoji != null && emoji!.isNotEmpty) {
      return _buildEmoji();
    }
    // Initials fallback
    if (name != null && name!.isNotEmpty) {
      return _buildInitials();
    }
    // Default person icon
    return _buildDefaultIcon();
  }

  Widget _buildNetworkImage() {
    // TODO: Phase 3 — replace with CachedNetworkImage
    // return CachedNetworkImage(
    //   imageUrl: photoUrl!,
    //   fit: BoxFit.cover,
    //   placeholder: (ctx, url) => _buildEmoji(),
    //   errorWidget: (ctx, url, err) => _buildEmoji(),
    // );
    return Image.network(
      photoUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildEmoji(),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.crimson,
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded /
                progress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  Widget _buildEmoji() {
    return Center(
      child: Text(
        emoji ?? '👤',
        style: TextStyle(fontSize: size.emojiSize),
      ),
    );
  }

  Widget _buildInitials() {
    final words = name!
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    final initials = words.length >= 2
        ? '${words[0][0]}${words[words.length - 1][0]}'
        .toUpperCase()
        : words[0][0].toUpperCase();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size.initialsSize,
          fontWeight: FontWeight.w700,
          color: AppColors.crimson,
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Center(
      child: Icon(
        Icons.person_outline_rounded,
        size: size.emojiSize,
        color: AppColors.muted,
      ),
    );
  }

  Widget _buildLockedContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred emoji
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            AppColors.white.withOpacity(0.6),
            BlendMode.srcOver,
          ),
          child: _buildEmoji(),
        ),
        // Lock icon overlay
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: size.emojiSize * 0.5,
                color: AppColors.crimson,
              ),
              if (size.dimension >= 48) ...[
                const SizedBox(height: 3),
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: size.initialsSize * 0.8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.crimson,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── BADGES ────────────────────────────────────────

  Widget _buildVerifiedBadge() {
    final badgeSize = size.badgeSize;
    final iconSize = badgeSize * 0.55;

    return Positioned(
      bottom: 0,
      right: isPremium ? badgeSize * 0.8 : 0,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white,
            width: size.borderWidth * 0.6,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.check_rounded,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    final badgeSize = size.badgeSize;

    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white,
            width: size.borderWidth * 0.6,
          ),
        ),
        child: Center(
          child: Text(
            '👑',
            style: TextStyle(
                fontSize: badgeSize * 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineDot() {
    final dotSize = size.onlineDotSize;

    return Positioned(
      bottom: size.badgeSize > 0 ? dotSize * 0.5 : 2,
      right: size.badgeSize > 0 ? 0 : 2,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white,
            width: size.borderWidth * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    final editSize = size.dimension * 0.32;

    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: onEditTap,
        child: Container(
          width: editSize,
          height: editSize,
          decoration: BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white,
              width: size.borderWidth * 0.7,
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Center(
            child: Icon(
              Icons.camera_alt_rounded,
              size: editSize * 0.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────

  Color _backgroundColor() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return AppColors.ivoryDark;
    }
    if (isSelected) return AppColors.crimsonSurface;
    if (isGuest) return const Color(0xFFF3F4F6);
    return AppColors.crimsonSurface;
  }
}

// ─────────────────────────────────────────────────────────
// AVATAR GROUP WIDGET
// Shows multiple avatars overlapping each other
// ─────────────────────────────────────────────────────────

/// Shows overlapping avatars — e.g. "124 viewers"
///
/// ```dart
/// AvatarGroup(
///   emojis: ['👩', '👨', '👩‍💼'],
///   count: 124,
///   size: AvatarSize.xs,
/// )
/// ```
class AvatarGroup extends StatelessWidget {
  final List<String> emojis;
  final int count;
  final AvatarSize size;
  final int maxVisible;

  const AvatarGroup({
    super.key,
    required this.emojis,
    required this.count,
    this.size = AvatarSize.xs,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visible =
    emojis.take(maxVisible).toList();
    final overlap = size.dimension * 0.35;
    final totalWidth = visible.length *
        (size.dimension - overlap) +
        overlap +
        (count > maxVisible ? 40 : 0);

    return SizedBox(
      height: size.dimension,
      width: totalWidth,
      child: Stack(
        children: [
          // Overlapping avatars
          ...visible.asMap().entries.map((e) {
            return Positioned(
              left: e.key *
                  (size.dimension - overlap),
              child: ProfileAvatar(
                emoji: e.value,
                size: size,
                showBorder: true,
                borderColor: AppColors.white,
              ),
            );
          }),
          // Count bubble
          if (count > maxVisible)
            Positioned(
              left: visible.length *
                  (size.dimension - overlap),
              child: Container(
                width: size.dimension,
                height: size.dimension,
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: size.borderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    count > 999
                        ? '999+'
                        : '+${count - maxVisible}',
                    style: TextStyle(
                      fontSize: size.initialsSize *
                          0.75,
                      fontWeight: FontWeight.w700,
                      color: AppColors.crimson,
                    ),
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
// AVATAR SHIMMER (Loading Placeholder)
// ─────────────────────────────────────────────────────────

/// Shimmer placeholder while avatar loads
class AvatarShimmer extends StatefulWidget {
  final AvatarSize size;

  const AvatarShimmer({
    super.key,
    this.size = AvatarSize.md,
  });

  @override
  State<AvatarShimmer> createState() =>
      _AvatarShimmerState();
}

class _AvatarShimmerState
    extends State<AvatarShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.size.dimension,
        height: widget.size.dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.ivoryDark
              .withOpacity(_animation.value),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// AVATAR WITH LABEL
// ─────────────────────────────────────────────────────────

/// Avatar with name below — for connected list etc.
class AvatarWithLabel extends StatelessWidget {
  final String? emoji;
  final String? photoUrl;
  final String name;
  final AvatarSize size;
  final bool isVerified;
  final bool isOnline;
  final VoidCallback? onTap;

  const AvatarWithLabel({
    super.key,
    this.emoji,
    this.photoUrl,
    required this.name,
    this.size = AvatarSize.md,
    this.isVerified = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // First name only for display
    final displayName = name.split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(
            emoji: emoji,
            photoUrl: photoUrl,
            name: name,
            size: size,
            isVerified: isVerified,
            isOnline: isOnline,
            onTap: onTap,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size.dimension + 8,
            child: Text(
              displayName,
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}