// lib/core/widgets/match_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/profile_avatar.dart';

// ─────────────────────────────────────────────────────────
// CARD STYLE ENUM
// ─────────────────────────────────────────────────────────

enum MatchCardStyle {
  horizontal,   // Home screen horizontal scroll
  grid,         // Search screen 2-col grid
  list,         // Full width list item
  featured,     // Premium featured card
}

// ─────────────────────────────────────────────────────────
// MATCH CARD DATA MODEL
// ─────────────────────────────────────────────────────────

class MatchCardData {
  final String id;
  final String name;
  final int age;
  final String city;
  final String caste;
  final String religion;
  final String profession;
  final String? company;
  final String? photoUrl;
  final String emoji;
  final bool isVerified;
  final bool isPremium;
  final bool isOnline;
  final String height;     // e.g. "5'4\""
  final String education;
  final String? income;
  final String? about;
  final double? matchPercent;

  const MatchCardData({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.caste,
    required this.religion,
    required this.profession,
    this.company,
    this.photoUrl,
    required this.emoji,
    this.isVerified = false,
    this.isPremium = false,
    this.isOnline = false,
    required this.height,
    required this.education,
    this.income,
    this.about,
    this.matchPercent,
  });

  String get displayProfession => company != null
      ? '$profession • $company'
      : profession;

  String get displayLocation => '$city • $caste';
}

// ─────────────────────────────────────────────────────────
// MATCH CARD WIDGET
// ─────────────────────────────────────────────────────────

class MatchCard extends StatefulWidget {
  final MatchCardData data;
  final MatchCardStyle style;
  final bool isInterested;
  final bool isShortlisted;
  final bool isLocked;
  final VoidCallback? onTap;
  final VoidCallback? onInterest;
  final VoidCallback? onShortlist;
  final VoidCallback? onLockedTap;

  const MatchCard({
    super.key,
    required this.data,
    this.style = MatchCardStyle.horizontal,
    this.isInterested = false,
    this.isShortlisted = false,
    this.isLocked = false,
    this.onTap,
    this.onInterest,
    this.onShortlist,
    this.onLockedTap,
  });

  // ── CONVENIENCE CONSTRUCTORS ───────────────────────

  const MatchCard.horizontal({
    super.key,
    required this.data,
    this.isInterested = false,
    this.isShortlisted = false,
    this.isLocked = false,
    this.onTap,
    this.onInterest,
    this.onShortlist,
    this.onLockedTap,
  }) : style = MatchCardStyle.horizontal;

  const MatchCard.grid({
    super.key,
    required this.data,
    this.isInterested = false,
    this.isShortlisted = false,
    this.isLocked = false,
    this.onTap,
    this.onInterest,
    this.onShortlist,
    this.onLockedTap,
  }) : style = MatchCardStyle.grid;

  const MatchCard.list({
    super.key,
    required this.data,
    this.isInterested = false,
    this.isShortlisted = false,
    this.isLocked = false,
    this.onTap,
    this.onInterest,
    this.onShortlist,
    this.onLockedTap,
  }) : style = MatchCardStyle.list;

  const MatchCard.featured({
    super.key,
    required this.data,
    this.isInterested = false,
    this.isShortlisted = false,
    this.onTap,
    this.onInterest,
    this.onShortlist,
  })  : style = MatchCardStyle.featured,
        isLocked = false,
        onLockedTap = null;

  @override
  State<MatchCard> createState() =>
      _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
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

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLocked
          ? widget.onLockedTap
          : widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    switch (widget.style) {
      case MatchCardStyle.horizontal:
        return _HorizontalCard(
          data: widget.data,
          isInterested: widget.isInterested,
          isShortlisted: widget.isShortlisted,
          isLocked: widget.isLocked,
          onInterest: widget.onInterest,
          onShortlist: widget.onShortlist,
        );
      case MatchCardStyle.grid:
        return _GridCard(
          data: widget.data,
          isInterested: widget.isInterested,
          isShortlisted: widget.isShortlisted,
          isLocked: widget.isLocked,
          onInterest: widget.onInterest,
          onShortlist: widget.onShortlist,
        );
      case MatchCardStyle.list:
        return _ListCard(
          data: widget.data,
          isInterested: widget.isInterested,
          isShortlisted: widget.isShortlisted,
          isLocked: widget.isLocked,
          onInterest: widget.onInterest,
          onShortlist: widget.onShortlist,
        );
      case MatchCardStyle.featured:
        return _FeaturedCard(
          data: widget.data,
          isInterested: widget.isInterested,
          isShortlisted: widget.isShortlisted,
          onInterest: widget.onInterest,
          onShortlist: widget.onShortlist,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────
// HORIZONTAL CARD (Home screen)
// ─────────────────────────────────────────────────────────

class _HorizontalCard extends StatelessWidget {
  final MatchCardData data;
  final bool isInterested;
  final bool isShortlisted;
  final bool isLocked;
  final VoidCallback? onInterest;
  final VoidCallback? onShortlist;

  const _HorizontalCard({
    required this.data,
    required this.isInterested,
    required this.isShortlisted,
    required this.isLocked,
    this.onInterest,
    this.onShortlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo section
          _PhotoSection(
            data: data,
            isLocked: isLocked,
            height: 112,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13)),
            showShortlist: true,
            isShortlisted: isShortlisted,
            onShortlist: onShortlist,
          ),
          // Info section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  9, 8, 9, 9),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.name.split(' ').first}, ${data.age}',
                    style: AppTextStyles
                        .profileNameSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.displayLocation,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.profession,
                    style: AppTextStyles.bodySmall
                        .copyWith(
                        color: AppColors.inkSoft,
                        fontWeight:
                        FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Interest button
                  _InterestButton(
                    isInterested: isInterested,
                    isCompact: true,
                    onTap: onInterest,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// GRID CARD (Search screen)
// ─────────────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final MatchCardData data;
  final bool isInterested;
  final bool isShortlisted;
  final bool isLocked;
  final VoidCallback? onInterest;
  final VoidCallback? onShortlist;

  const _GridCard({
    required this.data,
    required this.isInterested,
    required this.isShortlisted,
    required this.isLocked,
    this.onInterest,
    this.onShortlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo — flex expand
          Expanded(
            child: _PhotoSection(
              data: data,
              isLocked: isLocked,
              borderRadius:
              const BorderRadius.vertical(
                  top: Radius.circular(13)),
              showShortlist: true,
              isShortlisted: isShortlisted,
              onShortlist: onShortlist,
              shortlistPosition:
              ShortlistPosition.bottomRight,
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(
                12, 10, 12, 12),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.name.split(' ').first}, ${data.age}',
                  style:
                  AppTextStyles.profileNameSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  data.profession,
                  style: AppTextStyles.bodySmall
                      .copyWith(
                      color: AppColors.inkSoft),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: AppColors.muted),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      data.displayLocation,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                _InterestButton(
                  isInterested: isInterested,
                  isCompact: false,
                  onTap: onInterest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LIST CARD (Full width)
// ─────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final MatchCardData data;
  final bool isInterested;
  final bool isShortlisted;
  final bool isLocked;
  final VoidCallback? onInterest;
  final VoidCallback? onShortlist;

  const _ListCard({
    required this.data,
    required this.isInterested,
    required this.isShortlisted,
    required this.isLocked,
    this.onInterest,
    this.onShortlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Avatar
            ProfileAvatar(
              emoji: data.emoji,
              photoUrl: data.photoUrl,
              size: AvatarSize.lg,
              isVerified: data.isVerified,
              isPremium: data.isPremium,
              isOnline: data.isOnline,
              isGuest: isLocked,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        '${data.name}, ${data.age}',
                        style: AppTextStyles
                            .profileNameMedium,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),
                    // Match %
                    if (data.matchPercent != null)
                      _MatchPercentBadge(
                          percent:
                          data.matchPercent!),
                  ]),
                  const SizedBox(height: 5),
                  _InfoRow(
                    icon: Icons.work_outline_rounded,
                    text: data.displayProfession,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: data.displayLocation,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.school_outlined,
                    text: data.education,
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: _InterestButton(
                        isInterested: isInterested,
                        onTap: onInterest,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ShortlistIconButton(
                      isShortlisted: isShortlisted,
                      onTap: onShortlist,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// FEATURED CARD (Premium)
// ─────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final MatchCardData data;
  final bool isInterested;
  final bool isShortlisted;
  final VoidCallback? onInterest;
  final VoidCallback? onShortlist;

  const _FeaturedCard({
    required this.data,
    required this.isInterested,
    required this.isShortlisted,
    this.onInterest,
    this.onShortlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.gold.withOpacity(0.4)),
        boxShadow: AppColors.goldShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo with gradient overlay
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15)),
            child: Stack(children: [
              // Photo
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Container(
                  color: data.isVerified
                      ? AppColors.crimsonSurface
                      : AppColors.ivoryDark,
                  child: Center(
                    child: Text(data.emoji,
                        style: const TextStyle(
                            fontSize: 80)),
                  ),
                ),
              ),
              // Dark bottom gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.ink
                            .withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Name overlay
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        '${data.name}, ${data.age}',
                        style: AppTextStyles
                            .profileNameMedium
                            .copyWith(
                            color: Colors.white),
                      ),
                      if (data.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.success),
                      ],
                    ]),
                    Text(
                      data.displayLocation,
                      style: AppTextStyles.bodySmall
                          .copyWith(
                          color: Colors.white70),
                    ),
                  ],
                ),
              ),
              // Premium crown
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius:
                    BorderRadius.circular(100),
                    boxShadow: AppColors.goldShadow,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('👑',
                          style:
                          TextStyle(fontSize: 11)),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Shortlist
              Positioned(
                top: 10,
                left: 10,
                child: _ShortlistCircleButton(
                  isShortlisted: isShortlisted,
                  onTap: onShortlist,
                ),
              ),
            ]),
          ),
          // Info + actions
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // Quick info chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _QuickInfoChip(
                        icon: Icons.school_outlined,
                        label: data.education),
                    _QuickInfoChip(
                        icon: Icons
                            .straighten_rounded,
                        label: data.height),
                    if (data.income != null)
                      _QuickInfoChip(
                          icon: Icons
                              .currency_rupee_rounded,
                          label: data.income!),
                  ],
                ),
                const SizedBox(height: 14),
                // Action buttons
                Row(children: [
                  Expanded(
                    child: _InterestButton(
                      isInterested: isInterested,
                      onTap: onInterest,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SHARED COMPONENTS
// ─────────────────────────────────────────────────────────

// ── PHOTO SECTION ─────────────────────────────────────────

enum ShortlistPosition { topRight, bottomRight }

class _PhotoSection extends StatelessWidget {
  final MatchCardData data;
  final bool isLocked;
  final double? height;
  final BorderRadius borderRadius;
  final bool showShortlist;
  final bool isShortlisted;
  final VoidCallback? onShortlist;
  final ShortlistPosition shortlistPosition;

  const _PhotoSection({
    required this.data,
    required this.isLocked,
    this.height,
    required this.borderRadius,
    this.showShortlist = false,
    this.isShortlisted = false,
    this.onShortlist,
    this.shortlistPosition = ShortlistPosition.topRight,
  });

  @override
  Widget build(BuildContext context) {
    Widget photoWidget = Container(
      height: height,
      color: data.isVerified
          ? AppColors.crimsonSurface
          : const Color(0xFFF3F4F6),
      child: Center(
        child: isLocked
            ? _LockedOverlay(emoji: data.emoji)
            : Text(data.emoji,
            style: const TextStyle(fontSize: 60)),
      ),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(children: [
        // Photo
        SizedBox(
          height: height,
          width: double.infinity,
          child: photoWidget,
        ),
        // Verified badge
        if (data.isVerified && !isLocked)
          const Positioned(
            top: 8,
            left: 8,
            child: _VerifiedBadge(),
          ),
        // Premium badge
        if (data.isPremium && !isLocked)
          Positioned(
            top: 8,
            right: showShortlist &&
                shortlistPosition ==
                    ShortlistPosition.topRight
                ? 40
                : 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👑',
                    style: TextStyle(fontSize: 11)),
              ),
            ),
          ),
        // Shortlist button
        if (showShortlist && !isLocked)
          Positioned(
            top: shortlistPosition ==
                ShortlistPosition.topRight
                ? 8
                : null,
            bottom: shortlistPosition ==
                ShortlistPosition.bottomRight
                ? 8
                : null,
            right: 8,
            child: _ShortlistCircleButton(
              isShortlisted: isShortlisted,
              onTap: onShortlist,
            ),
          ),
        // Match percent
        if (data.matchPercent != null && !isLocked)
          Positioned(
            bottom: 8,
            left: 8,
            child: _MatchPercentBadge(
                percent: data.matchPercent!),
          ),
      ]),
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  final String emoji;
  const _LockedOverlay({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.6),
            BlendMode.srcOver,
          ),
          child: Text(emoji,
              style: const TextStyle(fontSize: 60)),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 22, color: AppColors.crimson),
            const SizedBox(height: 4),
            Text(
              'Register\nto View',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall
                  .copyWith(
                  color: AppColors.crimson,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

// ── INTEREST BUTTON ───────────────────────────────────────

class _InterestButton extends StatelessWidget {
  final bool isInterested;
  final bool isCompact;
  final VoidCallback? onTap;

  const _InterestButton({
    required this.isInterested,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: isCompact ? 5 : 8),
        decoration: BoxDecoration(
          color: isInterested
              ? AppColors.crimson
              : AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(8),
          border: isInterested
              ? null
              : Border.all(
              color: AppColors.crimson
                  .withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(
                  milliseconds: 200),
              child: Icon(
                isInterested
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isInterested),
                size: isCompact ? 12 : 14,
                color: isInterested
                    ? Colors.white
                    : AppColors.crimson,
              ),
            ),
            SizedBox(width: isCompact ? 3 : 5),
            Text(
              isInterested
                  ? 'Sent ✓'
                  : 'Send Interest',
              style: TextStyle(
                fontSize: isCompact ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: isInterested
                    ? Colors.white
                    : AppColors.crimson,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SHORTLIST BUTTONS ─────────────────────────────────────

class _ShortlistIconButton extends StatelessWidget {
  final bool isShortlisted;
  final VoidCallback? onTap;

  const _ShortlistIconButton({
    required this.isShortlisted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isShortlisted
              ? AppColors.goldSurface
              : AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isShortlisted
                ? AppColors.gold
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            isShortlisted
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 18,
            color: isShortlisted
                ? AppColors.gold
                : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class _ShortlistCircleButton extends StatelessWidget {
  final bool isShortlisted;
  final VoidCallback? onTap;

  const _ShortlistCircleButton({
    required this.isShortlisted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isShortlisted
              ? AppColors.gold
              : Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: AppColors.softShadow,
        ),
        child: Center(
          child: Icon(
            isShortlisted
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 15,
            color: isShortlisted
                ? Colors.white
                : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

// ── INFO ROW ──────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13, color: AppColors.muted),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.inkSoft),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}

// ── VERIFIED BADGE ────────────────────────────────────────

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded,
              size: 10, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── MATCH PERCENT BADGE ───────────────────────────────────

class _MatchPercentBadge extends StatelessWidget {
  final double percent;

  const _MatchPercentBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.75),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '${percent.toInt()}% Match',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── QUICK INFO CHIP ───────────────────────────────────────

class _QuickInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.ivoryDark,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}