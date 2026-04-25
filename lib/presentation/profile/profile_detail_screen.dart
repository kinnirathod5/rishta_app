// lib/presentation/home/profile_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/block_report_dialog.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/providers/profile_provider.dart';
import 'package:rishta_app/data/mock/mock_profiles.dart';

// ─────────────────────────────────────────────────────────
// PROFILE DETAIL SCREEN
// ─────────────────────────────────────────────────────────

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String profileId;
  final MockProfile? profile;

  const ProfileDetailScreen({
    super.key,
    required this.profileId,
    this.profile,
  });

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState
    extends ConsumerState<ProfileDetailScreen>
    with TickerProviderStateMixin {

  late final TabController _tabCtrl;
  bool _isShortlisted = false;
  int _currentPhoto = 0;

  // Mock full profile data
  MockProfile get _p =>
      widget.profile ??
          const MockProfile(
            id: '0',
            name: 'Priya Sharma',
            age: 26,
            caste: 'Brahmin',
            city: 'Delhi',
            profession: 'Software Engineer',
            emoji: '👩',
            isVerified: true,
            isPremium: false,
          );

  // Mock extended details
  final Map<String, String> _details = {
    'religion':    'Hindu',
    'gotra':       'Kashyap',
    'manglik':     'Non-Manglik',
    'height':      "5'4\" (163 cm)",
    'marital':     'Never Married',
    'mothertongue':'Hindi',
    'nativeCity':  'Lucknow',
    'qualification':'B.Tech — Computer Science',
    'college':     'IIT Delhi',
    'employment':  'Private Sector',
    'company':     'Google India',
    'income':      '₹12 – 20 LPA',
    'familyType':  'Nuclear Family',
    'familyValues':'Moderate',
    'fatherOcc':   'Retired Engineer',
    'motherOcc':   'Homemaker',
    'brothers':    '1 Brother (Married)',
    'sisters':     'None',
    'familyCity':  'Lucknow',
    'about':
    'I am a software engineer at Google with a passion for technology and travel. '
        'I love reading books, cooking and spending time with family. '
        'Looking for someone who values family, is career-oriented and has a good sense of humour. '
        'Family is everything to me and I believe in building a life together. 😊',
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── ACTIONS ───────────────────────────────────────────

  void _toggleInterest() {
    HapticFeedback.lightImpact();
    final sentIds = ref.read(sentInterestIdsProvider);
    final isSent = sentIds.contains(_p.id);
    if (!isSent) {
      ref.read(interestsProvider.notifier).sendInterest(
        receiverId: _p.id,
        receiverProfileId: _p.id,
      );
      _showSnack(
          'Interest sent to ${_p.name.split(' ').first}! 💌',
          AppColors.success);
    }
  }

  void _toggleShortlist() {
    HapticFeedback.selectionClick();
    setState(() => _isShortlisted = !_isShortlisted);
    _showSnack(
      _isShortlisted
          ? '${_p.name.split(' ').first} shortlist mein add hua ✓'
          : 'Shortlist se remove kiya',
      _isShortlisted ? AppColors.gold : AppColors.ink,
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => _MoreOptionsSheet(
        name: _p.name.split(' ').first,
        onBlock: () {
          Navigator.pop(context);
          BlockReportDialog.show(
            context,
            userName: _p.name,
            userEmoji: _p.emoji,
            userId: _p.id,
            onBlocked: () => context.pop(),
          );
        },
        onReport: () {
          Navigator.pop(context);
          BlockReportDialog.show(
            context,
            userName: _p.name,
            userEmoji: _p.emoji,
            userId: _p.id,
            onReported: (_) => context.pop(),
          );
        },
        onShare: () {
          Navigator.pop(context);
          _showSnack('Share jald aayega!', AppColors.ink);
        },
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white)),
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
    final sentIds =
    ref.watch(sentInterestIdsProvider);
    final isSent = sentIds.contains(_p.id);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          CustomScrollView(
            physics:
            const BouncingScrollPhysics(),
            slivers: [
              // Photo section
              _buildPhotoSliver(),
              // Profile content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    _buildQuickStats(),
                    if (_details['about'] != null)
                      _buildAboutSection(),
                    _buildTabSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          // Floating back + more buttons
          _buildTopButtons(),
          // Fixed bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isSent),
          ),
        ],
      ),
    );
  }

  // ── PHOTO SLIVER ──────────────────────────────────────

  Widget _buildPhotoSliver() {
    // Mock: 3 photo slots
    final photos = [_p.emoji, _p.emoji, _p.emoji];

    return SliverAppBar(
      expandedHeight: 360,
      pinned: false,
      floating: false,
      snap: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo area
            PageView.builder(
              itemCount: photos.length,
              onPageChanged: (i) =>
                  setState(() => _currentPhoto = i),
              itemBuilder: (_, i) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.crimsonSurface,
                      AppColors.ivoryDark,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Text(
                    photos[i],
                    style: const TextStyle(
                        fontSize: 130),
                  ),
                ),
              ),
            ),
            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.ivory,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Photo indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: List.generate(
                    photos.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(
                        milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 3),
                    width:
                    _currentPhoto == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPhoto == i
                          ? AppColors.crimson
                          : Colors.white
                          .withOpacity(0.5),
                      borderRadius:
                      BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
            // Photo count
            Positioned(
              bottom: 38,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ink
                      .withOpacity(0.6),
                  borderRadius:
                  BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 11,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${photos.length} Photos',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BUTTONS (Back + More) ─────────────────────────

  Widget _buildTopButtons() {
    final topPad =
        MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          _CircleBtn(
            icon: Icons.arrow_back_ios_new,
            onTap: () => context.pop(),
          ),
          Row(children: [
            _CircleBtn(
              icon: _isShortlisted
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _isShortlisted
                  ? AppColors.gold
                  : null,
              onTap: _toggleShortlist,
            ),
            const SizedBox(width: 8),
            _CircleBtn(
              icon: Icons.more_vert_rounded,
              onTap: _showMoreOptions,
            ),
          ]),
        ],
      ),
    );
  }

  // ── PROFILE HEADER ────────────────────────────────────

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + verified + premium
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${_p.name}, ${_p.age}',
                  style: AppTextStyles.h2,
                ),
              ),
              if (_p.isPremium)
                Container(
                  margin: const EdgeInsets.only(
                      left: 6),
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldSurface,
                    borderRadius:
                    BorderRadius.circular(100),
                    border: Border.all(
                        color: AppColors.gold
                            .withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('👑',
                          style: TextStyle(
                              fontSize: 10)),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Verified badge
          if (_p.isVerified) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius:
                BorderRadius.circular(100),
                border: Border.all(
                    color: AppColors.success
                        .withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      size: 12,
                      color: AppColors.success),
                  SizedBox(width: 5),
                  Text(
                    'ID Verified Profile',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Key info row
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _InfoChip(
                  icon: Icons.work_outline_rounded,
                  label: _p.profession),
              _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: _p.city),
              _InfoChip(
                  icon: Icons.people_outline,
                  label: _p.caste),
              _InfoChip(
                  icon: Icons.straighten_rounded,
                  label: _details['height'] ??
                      "5'4\""),
              _InfoChip(
                  icon:
                  Icons.school_outlined,
                  label: 'B.Tech'),
            ],
          ),
        ],
      ),
    );
  }

  // ── QUICK STATS ───────────────────────────────────────

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          _StatItem(
            emoji: '🛕',
            label: 'Religion',
            value: _details['religion'] ?? '—',
          ),
          _StatDivider(),
          _StatItem(
            emoji: '💍',
            label: 'Status',
            value: 'Never\nMarried',
          ),
          _StatDivider(),
          _StatItem(
            emoji: '🏠',
            label: 'Family',
            value: _details['familyType']
                ?.replaceAll(' Family', '') ??
                '—',
          ),
          _StatDivider(),
          _StatItem(
            emoji: '💰',
            label: 'Income',
            value: '12–20\nLPA',
          ),
        ],
      ),
    );
  }

  // ── ABOUT SECTION ─────────────────────────────────────

  Widget _buildAboutSection() {
    final about = _details['about'] ?? '';
    final isLong = about.length > 150;
    bool _expanded = false;

    return StatefulBuilder(
        builder: (context, setLocal) {
          return Container(
            margin: const EdgeInsets.fromLTRB(
                20, 16, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: AppColors.border),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('💬',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('About Me',
                      style: AppTextStyles.h5),
                ]),
                const SizedBox(height: 10),
                Text(
                  _expanded || !isLong
                      ? about
                      : '${about.substring(0, 150)}...',
                  style: AppTextStyles.bodyMedium
                      .copyWith(
                    color: AppColors.inkSoft,
                    height: 1.7,
                  ),
                ),
                if (isLong) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        setLocal(() =>
                        _expanded = !_expanded),
                    child: Text(
                      _expanded
                          ? 'Less padhein ↑'
                          : 'Aur padhein ↓',
                      style: AppTextStyles
                          .labelSmall
                          .copyWith(
                        color: AppColors.crimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        });
  }

  // ── TAB SECTION ───────────────────────────────────────

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          20, 20, 20, 0),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                BorderRadius.circular(10),
                boxShadow: AppColors.softShadow,
              ),
              indicatorSize:
              TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.crimson,
              unselectedLabelColor:
              AppColors.muted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle:
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Religion'),
                Tab(text: 'Career'),
                Tab(text: 'Family'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Tab views — fixed height
          SizedBox(
            height: 340,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildReligionTab(),
                _buildCareerTab(),
                _buildFamilyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── RELIGION TAB ──────────────────────────────────────

  Widget _buildReligionTab() {
    return _InfoCard(rows: [
      _InfoRow(
        icon: Icons.temple_hindu_outlined,
        label: 'Religion',
        value: _details['religion'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.groups_outlined,
        label: 'Caste',
        value: _p.caste,
      ),
      _InfoRow(
        icon: Icons.family_restroom_rounded,
        label: 'Gotra',
        value: _details['gotra'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.stars_rounded,
        label: 'Manglik',
        value: _details['manglik'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.language_outlined,
        label: 'Mother Tongue',
        value: _details['mothertongue'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.location_city_outlined,
        label: 'Native City',
        value: _details['nativeCity'] ?? '—',
      ),
    ]);
  }

  // ── CAREER TAB ────────────────────────────────────────

  Widget _buildCareerTab() {
    return _InfoCard(rows: [
      _InfoRow(
        icon: Icons.school_outlined,
        label: 'Qualification',
        value: _details['qualification'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.account_balance_outlined,
        label: 'College',
        value: _details['college'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.work_outline_rounded,
        label: 'Employment',
        value: _details['employment'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.business_outlined,
        label: 'Company',
        value: _details['company'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.badge_outlined,
        label: 'Designation',
        value: _p.profession,
      ),
      _InfoRow(
        icon: Icons.currency_rupee_rounded,
        label: 'Annual Income',
        value: _details['income'] ?? '—',
      ),
    ]);
  }

  // ── FAMILY TAB ────────────────────────────────────────

  Widget _buildFamilyTab() {
    return _InfoCard(rows: [
      _InfoRow(
        icon: Icons.home_outlined,
        label: 'Family Type',
        value: _details['familyType'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.people_outline,
        label: 'Family Values',
        value: _details['familyValues'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.man_outlined,
        label: "Father's Occ.",
        value: _details['fatherOcc'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.woman_outlined,
        label: "Mother's Occ.",
        value: _details['motherOcc'] ?? '—',
      ),
      _InfoRow(
        icon: Icons.people_alt_outlined,
        label: 'Brothers',
        value: _details['brothers'] ?? 'None',
      ),
      _InfoRow(
        icon: Icons.people_alt_outlined,
        label: 'Sisters',
        value: _details['sisters'] ?? 'None',
      ),
    ]);
  }

  // ── BOTTOM BAR ────────────────────────────────────────

  Widget _buildBottomBar(bool isSent) {
    final bottomPad =
        MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, bottomPad + 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
            top: BorderSide(
                color: AppColors.border)),
        boxShadow: AppColors.modalShadow,
      ),
      child: Row(children: [
        // Chat button
        GestureDetector(
          onTap: () {
            context.push('/chat/${_p.id}');
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.border),
            ),
            child: const Center(
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 22,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Send interest button
        Expanded(
          child: GestureDetector(
            onTap: isSent ? null : _toggleInterest,
            child: AnimatedContainer(
              duration: const Duration(
                  milliseconds: 250),
              height: 52,
              decoration: BoxDecoration(
                color: isSent
                    ? AppColors.successSurface
                    : AppColors.crimson,
                borderRadius:
                BorderRadius.circular(14),
                border: isSent
                    ? Border.all(
                    color: AppColors.success
                        .withOpacity(0.4))
                    : null,
                boxShadow: isSent
                    ? null
                    : [
                  BoxShadow(
                    color: AppColors.crimson
                        .withOpacity(0.35),
                    blurRadius: 12,
                    offset:
                    const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    isSent
                        ? Icons.favorite_rounded
                        : Icons
                        .favorite_border_rounded,
                    size: 18,
                    color: isSent
                        ? AppColors.success
                        : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSent
                        ? 'Interest Sent ✓'
                        : AppStrings.sendInterest,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSent
                          ? AppColors.success
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: AppColors.softShadow,
        ),
        child: Center(
          child: Icon(icon,
              size: 18,
              color: color ?? AppColors.ink),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.inkSoft),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _StatItem({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 48,
        color: AppColors.border);
  }
}

// ─────────────────────────────────────────────────────────
// INFO CARD — for tab content
// ─────────────────────────────────────────────────────────

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

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
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          final isLast = i == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.crimsonSurface,
                      borderRadius:
                      BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Icon(row.icon,
                          size: 16,
                          color: AppColors.crimson),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.label,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  Text(
                    row.value,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.ink),
                    textAlign: TextAlign.right,
                  ),
                ]),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 16,
                    color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// MORE OPTIONS SHEET
// ─────────────────────────────────────────────────────────

class _MoreOptionsSheet extends StatelessWidget {
  final String name;
  final VoidCallback onBlock;
  final VoidCallback onReport;
  final VoidCallback onShare;

  const _MoreOptionsSheet({
    required this.name,
    required this.onBlock,
    required this.onReport,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad =
        MediaQuery.of(context).padding.bottom;
    return Padding(
      padding:
      EdgeInsets.fromLTRB(0, 8, 0, bottomPad + 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin:
              const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                20, 0, 20, 12),
            child: Text('More Options',
                style: AppTextStyles.h4),
          ),
          const Divider(
              height: 1, color: AppColors.border),
          _SheetOption(
            icon: Icons.share_rounded,
            label: 'Share Profile',
            onTap: onShare,
          ),
          _SheetOption(
            icon: Icons.block_rounded,
            label: 'Block $name',
            onTap: onBlock,
            isDestructive: true,
          ),
          _SheetOption(
            icon: Icons.flag_outlined,
            label: 'Report $name',
            onTap: onReport,
            isDestructive: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                20, 8, 20, 0),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: Text('Cancel',
                    style: AppTextStyles.labelMedium
                        .copyWith(
                        color: AppColors.muted)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : AppColors.inkSoft;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.border,
                width: 0.5),
          ),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.errorSurface
                  : AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon,
                  size: 18, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ]),
      ),
    );
  }
}