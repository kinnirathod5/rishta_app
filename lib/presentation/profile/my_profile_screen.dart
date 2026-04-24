// lib/presentation/profile/my_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/providers/app_state_provider.dart';
import 'package:rishta_app/providers/auth_provider.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// MY PROFILE SCREEN
// ─────────────────────────────────────────────────────────

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final score = ref.watch(profileScoreProvider);
    final isPremium = ref.watch(isPremiumActiveProvider);
    final pendingInterests =
    ref.watch(pendingInterestsCountProvider);
    final connectionCount =
    ref.watch(connectionCountProvider);
    final unread =
    ref.watch(unreadNotificationsCountProvider);

    final name = profile?.firstName ?? 'User';
    final fullName = profile?.fullName ?? 'Priya Sharma';
    final city = profile?.currentCity ?? 'Delhi';
    final caste = profile?.caste ?? 'Brahmin';
    final profession =
        profile?.professionDisplay ?? 'Software Engineer';
    final emoji = '👩';

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(
                  context,
                  fullName: fullName,
                  city: city,
                  caste: caste,
                  profession: profession,
                  emoji: emoji,
                  isPremium: isPremium,
                  unread: unread,
                ),
                Positioned(
                  bottom: -36,
                  left: 16,
                  right: 16,
                  child: _buildScoreCard(
                    context,
                    score: score,
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 52)),

          // Stats row
          SliverToBoxAdapter(
            child: _buildStatsRow(
              context,
              pendingInterests: pendingInterests,
              connectionCount: connectionCount,
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 12)),

          // Profile edit sections
          SliverToBoxAdapter(
            child: _buildProfileSections(context),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 12)),

          // Quick settings
          SliverToBoxAdapter(
            child: _buildQuickSettings(
                context, isPremium),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 12)),

          // Account / Danger zone
          SliverToBoxAdapter(
            child: _buildAccountSection(context, ref),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, {
        required String fullName,
        required String city,
        required String caste,
        required String profession,
        required String emoji,
        required bool isPremium,
        required int unread,
      }) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
          gradient: AppColors.crimsonGradient),
      padding: EdgeInsets.fromLTRB(
          20, topPad + 12, 20, 52),
      child: Column(
        children: [
          // Top row
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mera Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage your profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white
                          .withOpacity(0.65),
                    ),
                  ),
                ],
              ),
              Row(children: [
                // Preview button
                GestureDetector(
                  onTap: () => context
                      .push('/profile-preview'),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.15),
                      borderRadius:
                      BorderRadius.circular(100),
                      border: Border.all(
                          color: Colors.white
                              .withOpacity(0.25)),
                    ),
                    child: const Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                            Icons
                                .visibility_outlined,
                            size: 14,
                            color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Notification bell
                GestureDetector(
                  onTap: () => context
                      .push('/notifications'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.15),
                          borderRadius:
                          BorderRadius.circular(
                              10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons
                                .notifications_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration:
                            BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                  Colors.white,
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '$unread',
                                style:
                                const TextStyle(
                                  fontSize: 8,
                                  color:
                                  Colors.white,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 20),

          // Avatar
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.goldLight,
                      width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.15),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(emoji,
                      style: const TextStyle(
                          fontSize: 44)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Photo edit Phase 3 mein aayega!'),
                        backgroundColor:
                        AppColors.ink,
                        behavior:
                        SnackBarBehavior.floating,
                        shape:
                        RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                10)),
                        duration: const Duration(
                            seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white,
                          width: 2.5),
                    ),
                    child: const Center(
                      child: Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              // Premium crown
              if (isPremium)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white,
                          width: 2),
                    ),
                    child: const Center(
                      child: Text('👑',
                          style: TextStyle(
                              fontSize: 11)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name + location + profession
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 12,
                    color: Colors.white
                        .withOpacity(0.75)),
                const SizedBox(width: 4),
                Text(
                  '$city • $caste',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                        .withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(100),
              border: Border.all(
                  color:
                  Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.work_outline_rounded,
                    size: 12,
                    color: Colors.white
                        .withOpacity(0.75)),
                const SizedBox(width: 5),
                Text(
                  profession,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                        .withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SCORE CARD ────────────────────────────────────────

  Widget _buildScoreCard(
      BuildContext context, {
        required int score,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text('Profile Score',
                      style: AppTextStyles.h5),
                  const SizedBox(height: 2),
                  Text(
                    '$score% Complete',
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                        color:
                        AppColors.crimson),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.crimson,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LayoutBuilder(
            builder: (_, constraints) => Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius:
                    BorderRadius.circular(100),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(
                      milliseconds: 600),
                  height: 8,
                  width: constraints.maxWidth *
                      (score / 100),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.crimson,
                        AppColors.crimsonLight,
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Score improvement tips
          if (score < 80) ...[
            Text(
              'Yeh karo, score badhao:',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (score < 70)
                  _ScoreTip(
                    label: '⭐ Horoscope add karo',
                    points: '+15%',
                    onTap: () => context
                        .push('/horoscope'),
                  ),
                _ScoreTip(
                  label: '📸 2 aur photos',
                  points: '+7%',
                  onTap: () =>
                      context.push('/setup/step5'),
                ),
                _ScoreTip(
                  label: '🔐 ID Verify karo',
                  points: '+8%',
                  onTap: () => context
                      .push('/id-verification'),
                ),
              ],
            ),
          ] else
            Row(children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 6),
              Text(
                'Excellent profile score! 🎉',
                style: AppTextStyles.labelMedium
                    .copyWith(
                    color: AppColors.success),
              ),
            ]),
        ],
      ),
    );
  }

  // ── STATS ROW ─────────────────────────────────────────

  Widget _buildStatsRow(
      BuildContext context, {
        required int pendingInterests,
        required int connectionCount,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _StatBox(
              value: '124',
              label: 'Profile\nViews',
              icon: Icons.visibility_outlined,
              color: AppColors.crimson,
              onTap: () =>
                  context.push('/who-viewed'),
            ),
            _StatBox(
              value: '$pendingInterests',
              label: 'Interests\nAaye',
              icon: Icons.favorite_outlined,
              color: const Color(0xFFE91E63),
              onTap: () => context.go('/interests'),
            ),
            _StatBox(
              value: '$connectionCount',
              label: 'Connected',
              icon: Icons.handshake_outlined,
              color: AppColors.success,
              onTap: () => context.go('/interests'),
            ),
            _StatBox(
              value: '6',
              label: 'Shortlisted',
              icon: Icons.bookmark_rounded,
              color: AppColors.gold,
              onTap: () =>
                  context.push('/shortlisted'),
            ),
          ],
        ),
      ),
    );
  }

  // ── PROFILE EDIT SECTIONS ─────────────────────────────

  Widget _buildProfileSections(
      BuildContext context) {
    return _SectionCard(
      title: 'Profile Edit Karo',
      trailing: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Text(
          'Auto Saved ✓',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      children: [
        _EditRow(
          emoji: '📋',
          title: 'Basic Info',
          subtitle: 'Naam, DOB, height, city',
          isComplete: true,
          onTap: () =>
              context.push('/setup/step1'),
        ),
        _EditRow(
          emoji: '🛕',
          title: 'Religion & Caste',
          subtitle: 'Hindu • Brahmin • Kashyap',
          isComplete: true,
          onTap: () =>
              context.push('/setup/step2'),
        ),
        _EditRow(
          emoji: '🎓',
          title: 'Education & Career',
          subtitle: 'B.Tech • TCS • 8-12 LPA',
          isComplete: true,
          onTap: () =>
              context.push('/setup/step3'),
        ),
        _EditRow(
          emoji: '👨‍👩‍👦',
          title: 'Family Info',
          subtitle: 'Sanyukt parivar • Agra',
          isComplete: true,
          onTap: () =>
              context.push('/setup/step4'),
        ),
        _EditRow(
          emoji: '📸',
          title: 'Photos',
          subtitle: '6 photos uploaded',
          isComplete: true,
          onTap: () =>
              context.push('/setup/step5'),
        ),
        _EditRow(
          emoji: '⭐',
          title: 'Horoscope',
          subtitle: 'Abhi add nahi kiya',
          isComplete: false,
          onTap: () =>
              context.push('/horoscope'),
        ),
        _EditRow(
          emoji: '💝',
          title: 'Partner Preference',
          subtitle: 'Age 26-34 • Delhi • Graduate+',
          isComplete: true,
          onTap: () => context
              .push('/partner-preference'),
        ),
        _EditRow(
          emoji: '🔐',
          title: 'ID Verification',
          subtitle: 'Verify karein — badge milega',
          isComplete: false,
          isLast: true,
          onTap: () => context
              .push('/id-verification'),
        ),
      ],
    );
  }

  // ── QUICK SETTINGS ────────────────────────────────────

  Widget _buildQuickSettings(
      BuildContext context, bool isPremium) {
    return _SectionCard(
      title: 'Quick Settings',
      children: [
        _SettingRow(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage alerts aur reminders',
          onTap: () =>
              context.push('/notifications'),
        ),
        _SettingRow(
          icon: Icons.lock_outline_rounded,
          title: 'Privacy Settings',
          subtitle:
          'Profile visibility control karo',
          onTap: () => context.push('/privacy'),
        ),
        _SettingRow(
          icon: Icons.workspace_premium_rounded,
          title: 'Premium Plans',
          subtitle: isPremium
              ? 'Active — Premium Member 👑'
              : 'Unlock all features',
          isGold: true,
          onTap: () => context.push('/premium'),
        ),
        _SettingRow(
          icon: Icons.tune_rounded,
          title: 'Partner Preference',
          subtitle: 'Match filters set karo',
          onTap: () =>
              context.push('/partner-preference'),
        ),
        _SettingRow(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQ aur contact us',
          onTap: () =>
              context.push('/help-support'),
        ),
        _SettingRow(
          icon: Icons.block_rounded,
          title: 'Blocked Users',
          subtitle: 'Block kiye hue log',
          onTap: () =>
              context.push('/blocked-users'),
        ),
        _SettingRow(
          icon: Icons.info_outline_rounded,
          title: 'App ke Baare Mein',
          subtitle: 'Version 1.0.0 • RishtaApp',
          isLast: true,
          onTap: () {},
        ),
      ],
    );
  }

  // ── ACCOUNT SECTION ───────────────────────────────────

  Widget _buildAccountSection(
      BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
              AppColors.error.withOpacity(0.15)),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.border
                          .withOpacity(0.5)),
                ),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),

            // Logout
            _DangerRow(
              icon: Icons.logout_rounded,
              title: 'Logout Karo',
              subtitle: 'Apne account se logout',
              onTap: () => _showLogoutDialog(
                  context, ref),
            ),

            // Deactivate
            _DangerRow(
              icon: Icons
                  .pause_circle_outline_rounded,
              title: 'Account Deactivate Karo',
              subtitle:
              'Temporarily profile hide karo',
              onTap: () => context
                  .push('/delete-account'),
            ),

            // Delete
            _DangerRow(
              icon: Icons.delete_forever_rounded,
              title: 'Account Delete Karo',
              subtitle:
              'Permanently account hatao',
              isRed: true,
              isLast: true,
              onTap: () => context
                  .push('/delete-account'),
            ),
          ],
        ),
      ),
    );
  }

  // ── LOGOUT DIALOG ─────────────────────────────────────

  void _showLogoutDialog(
      BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout Karein?'),
        content: const Text(
            'Kya aap sach mein logout karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(authProvider.notifier)
                  .signOut();
              context.go('/welcome');
            },
            child: const Text('Logout Karo'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SECTION CARD — reusable container
// ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: AppTextStyles.h5),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// EDIT ROW
// ─────────────────────────────────────────────────────────

class _EditRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isComplete;
  final bool isLast;
  final VoidCallback onTap;

  const _EditRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
              bottom: BorderSide(
                  color: AppColors.border
                      .withOpacity(0.5))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isComplete
                    ? AppColors.successSurface
                    : AppColors.crimsonSurface,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(
                          fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles
                          .labelMedium),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isComplete) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldSurface,
                  borderRadius:
                  BorderRadius.circular(100),
                ),
                child: const Text(
                  'Add Karo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ] else ...[
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SETTING ROW
// ─────────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isGold;
  final bool isLast;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isGold = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
              bottom: BorderSide(
                  color: AppColors.border
                      .withOpacity(0.5))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isGold
                    ? AppColors.goldSurface
                    : AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: isGold
                      ? AppColors.gold
                      : AppColors.inkSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                      color: isGold
                          ? AppColors.gold
                          : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style:
                      AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// DANGER ROW
// ─────────────────────────────────────────────────────────

class _DangerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isRed;
  final bool isLast;

  const _DangerRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isRed = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isRed
              ? AppColors.errorSurface
              .withOpacity(0.5)
              : null,
          border: isLast
              ? null
              : Border(
              bottom: BorderSide(
                  color: AppColors.border
                      .withOpacity(0.5))),
          borderRadius: isLast
              ? const BorderRadius.vertical(
              bottom: Radius.circular(14))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRed
                    ? AppColors.errorSurface
                    : AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: isRed
                      ? AppColors.error
                      : AppColors.inkSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                      color: isRed
                          ? AppColors.error
                          : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style:
                      AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STAT BOX
// ─────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Icon(icon,
                        size: 18, color: color)),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SCORE TIP CHIP
// ─────────────────────────────────────────────────────────

class _ScoreTip extends StatelessWidget {
  final String label;
  final String points;
  final VoidCallback onTap;

  const _ScoreTip({
    required this.label,
    required this.points,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.goldSurface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: AppColors.gold.withOpacity(
                  0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall
                  .copyWith(
                  color: AppColors.inkSoft),
            ),
            const SizedBox(width: 5),
            Text(
              points,
              style: AppTextStyles.labelSmall
                  .copyWith(
                  color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}