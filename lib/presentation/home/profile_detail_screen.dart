// lib/presentation/home/profile_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../home/home_screen.dart';
import '../../core/widgets/block_report_dialog.dart';

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
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isInterested = false;
  bool _isShortlisted = false;
  bool _isExpanded = false;

  // Mock full profile data
  MockProfile get _profile =>
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

  // ── ACTIONS ───────────────────────────────────────────
  void _toggleInterest() {
    setState(() => _isInterested = !_isInterested);
    // TODO: Phase 3 — InterestRepository.sendInterest()
    _showSnack(
      _isInterested
          ? 'Interest sent to ${_profile.name}! 💌'
          : 'Interest withdrawn',
      _isInterested ? AppColors.success : AppColors.ink,
    );
  }

  void _toggleShortlist() {
    setState(() => _isShortlisted = !_isShortlisted);
    // TODO: Phase 3 — ProfileRepository.toggleShortlist()
    _showSnack(
      _isShortlisted
          ? '${_profile.name} added to shortlist ✓'
          : 'Removed from shortlist',
      AppColors.gold,
    );
  }

  void _startChat() {
    _showSnack(
        'Connect first to start chatting', AppColors.ink);
    // TODO: Phase 3 — Navigate to chat after connection
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
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
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.bookmark_border_rounded,
              label: _isShortlisted
                  ? 'Remove from Shortlist'
                  : 'Add to Shortlist',
              onTap: () {
                Navigator.pop(context);
                _toggleShortlist();
              },
            ),
            _OptionTile(
              icon: Icons.share_outlined,
              label: 'Share Profile',
              onTap: () {
                Navigator.pop(context);
                _showSnack(
                    'Share feature coming soon',
                    AppColors.ink);
              },
            ),
            _OptionTile(
              icon: Icons.flag_outlined,
              label: 'Block / Report',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                BlockReportDialog.show(
                  context,
                  userName: _profile.name,
                  userEmoji: _profile.emoji,
                  userId: _profile.id,
                  onBlocked: () => context.pop(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          // ── MAIN SCROLL ─────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                  child: _buildProfileHeader()),
              SliverToBoxAdapter(
                  child: _buildQuickStats()),
              SliverToBoxAdapter(
                  child: _buildTabSection()),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 120)),
            ],
          ),
          // ── FIXED TOP ACTIONS ───────────────────
          _buildTopActions(),
          // ── FIXED BOTTOM BAR ────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR (Photo) ────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 340,
      collapsedHeight: 0,
      pinned: false,
      floating: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo placeholder
            Container(
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
                  _profile.emoji,
                  style: const TextStyle(fontSize: 120),
                ),
              ),
            ),
            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
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
            // Photo count badge
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.ink.withOpacity(0.7),
                  borderRadius:
                  BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                        Icons.photo_library_outlined,
                        size: 12,
                        color: Colors.white),
                    const SizedBox(width: 4),
                    const Text(
                      '6 Photos',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
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

  // ── TOP ACTIONS (Back + More) ─────────────────────────
  Widget _buildTopActions() {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          // Back
          _CircleAction(
            icon: Icons.arrow_back_ios_new,
            onTap: () => context.pop(),
          ),
          // More options
          _CircleAction(
            icon: Icons.more_vert_rounded,
            onTap: _showMoreOptions,
          ),
        ],
      ),
    );
  }

  // ── PROFILE HEADER ────────────────────────────────────
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + age row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        '${_profile.name}, ${_profile.age}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_profile.isVerified)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius:
                            BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  Icons.verified_rounded,
                                  size: 11,
                                  color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                AppStrings.verified,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(
                          Icons.work_outline_rounded,
                          size: 14,
                          color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text(
                        _profile.profession,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.inkSoft),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text(
                        '${_profile.city} • ${_profile.caste}',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.inkSoft),
                      ),
                    ]),
                  ],
                ),
              ),
              // Profile score ring
              _ProfileScoreRing(score: 78),
            ],
          ),

          const SizedBox(height: 16),

          // About snippet
          GestureDetector(
            onTap: () =>
                setState(() => _isExpanded = !_isExpanded),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  duration:
                  const Duration(milliseconds: 250),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    'Software engineer at TCS with 3 years of experience. Love traveling, cooking and reading. Looking for a kind, understanding partner.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSoft,
                      height: 1.6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: const Text(
                    'Software engineer at TCS with 3 years of experience. Love traveling, cooking and reading. Looking for a kind, understanding partner who values family.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSoft,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isExpanded
                      ? 'Show less ▲'
                      : 'Read more ▼',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.crimson,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK STATS ───────────────────────────────────────
  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          _StatBox(
              emoji: '📏',
              value: "5'4\"",
              label: 'Height'),
          _StatBox(
              emoji: '🛕',
              value: 'Hindu',
              label: 'Religion'),
          _StatBox(
              emoji: '🎓',
              value: 'B.Tech',
              label: 'Education'),
          _StatBox(
              emoji: '💰',
              value: '8-12 L',
              label: 'Income'),
        ],
      ),
    );
  }

  // ── TAB SECTION ───────────────────────────────────────
  Widget _buildTabSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.ivoryDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.crimson,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.muted,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Family'),
              Tab(text: 'Preferences'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tab content
        SizedBox(
          height: 420,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAboutTab(),
              _buildFamilyTab(),
              _buildPreferencesTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ── ABOUT TAB ─────────────────────────────────────────
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          _InfoCard(
            title: 'Basic Details',
            icon: Icons.person_outline_rounded,
            rows: const [
              _InfoRow(
                  label: 'Full Name',
                  value: 'Priya Sharma'),
              _InfoRow(
                  label: 'Date of Birth',
                  value: '12 Mar 1998 • 26 yrs'),
              _InfoRow(
                  label: 'Height',
                  value: "5'4\" (163 cm)"),
              _InfoRow(
                  label: 'Current City',
                  value: 'Delhi, India'),
              _InfoRow(
                  label: 'Mother Tongue',
                  value: 'Hindi'),
              _InfoRow(
                  label: 'Marital Status',
                  value: 'Never Married'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Religion & Community',
            icon: Icons.temple_hindu_outlined,
            rows: const [
              _InfoRow(
                  label: 'Religion',
                  value: 'Hindu'),
              _InfoRow(
                  label: 'Caste',
                  value: 'Brahmin'),
              _InfoRow(
                  label: 'Sub Caste',
                  value: 'Kanyakubja'),
              _InfoRow(
                  label: 'Gotra',
                  value: 'Kashyap'),
              _InfoRow(
                  label: 'Manglik',
                  value: 'No'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Education & Career',
            icon: Icons.school_outlined,
            rows: const [
              _InfoRow(
                  label: 'Qualification',
                  value: 'B.Tech'),
              _InfoRow(
                  label: 'College',
                  value: 'Delhi Technological Univ.'),
              _InfoRow(
                  label: 'Employed In',
                  value: 'Private Sector'),
              _InfoRow(
                  label: 'Company',
                  value: 'TCS'),
              _InfoRow(
                  label: 'Designation',
                  value: 'Software Engineer'),
              _InfoRow(
                  label: 'Annual Income',
                  value: '8-12 LPA'),
            ],
          ),
        ],
      ),
    );
  }

  // ── FAMILY TAB ────────────────────────────────────────
  Widget _buildFamilyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          _InfoCard(
            title: 'Family Background',
            icon: Icons.home_outlined,
            rows: const [
              _InfoRow(
                  label: 'Family Type',
                  value: 'Joint Family'),
              _InfoRow(
                  label: 'Family Values',
                  value: 'Traditional'),
              _InfoRow(
                  label: 'Family Status',
                  value: 'Middle Class'),
              _InfoRow(
                  label: 'Family City',
                  value: 'Lucknow, UP'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Parents & Siblings',
            icon: Icons.people_outline_rounded,
            rows: const [
              _InfoRow(
                  label: 'Father',
                  value: 'Business'),
              _InfoRow(
                  label: 'Mother',
                  value: 'Homemaker'),
              _InfoRow(
                  label: 'Brothers',
                  value: '1 (Married)'),
              _InfoRow(
                  label: 'Sisters',
                  value: 'None'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Horoscope',
            icon: Icons.stars_rounded,
            rows: const [
              _InfoRow(
                  label: 'Rashi',
                  value: 'Kanya (Virgo)'),
              _InfoRow(
                  label: 'Nakshatra',
                  value: 'Hasta'),
              _InfoRow(
                  label: 'Birth Place',
                  value: 'Lucknow'),
              _InfoRow(
                  label: 'Kundali',
                  value: 'Available'),
            ],
          ),
        ],
      ),
    );
  }

  // ── PREFERENCES TAB ───────────────────────────────────
  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          _InfoCard(
            title: 'Partner Preferences',
            icon: Icons.favorite_outline_rounded,
            rows: const [
              _InfoRow(
                  label: 'Age Range',
                  value: '27 – 35 yrs'),
              _InfoRow(
                  label: 'Height Range',
                  value: "5'5\" – 6'0\""),
              _InfoRow(
                  label: 'Religion',
                  value: 'Hindu'),
              _InfoRow(
                  label: 'Caste',
                  value: 'Brahmin, Kayastha'),
              _InfoRow(
                  label: 'Education',
                  value: 'Graduate & above'),
              _InfoRow(
                  label: 'Income',
                  value: '8 LPA & above'),
              _InfoRow(
                  label: 'Location',
                  value: 'Delhi, Mumbai, Bangalore'),
              _InfoRow(
                  label: 'Marital Status',
                  value: 'Never Married'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.gold),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Partner preferences are indicative. Final decision is always personal.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.inkSoft,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ACTION BAR ─────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: AppColors.modalShadow,
      ),
      child: Row(children: [
        // Shortlist button
        GestureDetector(
          onTap: _toggleShortlist,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _isShortlisted
                  ? AppColors.goldSurface
                  : AppColors.ivoryDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isShortlisted
                    ? AppColors.gold
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                _isShortlisted
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 22,
                color: _isShortlisted
                    ? AppColors.gold
                    : AppColors.muted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Chat button
        GestureDetector(
          onTap: _startChat,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.border, width: 1.5),
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
        const SizedBox(width: 10),

        // Send Interest button
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            child: ElevatedButton(
              onPressed: _toggleInterest,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isInterested
                    ? AppColors.success
                    : AppColors.crimson,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    _isInterested
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isInterested
                        ? AppStrings.interestSent
                        : AppStrings.sendInterest,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

// ── PRIVATE WIDGETS ───────────────────────────────────────

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppColors.softShadow,
        ),
        child: Center(
          child: Icon(icon,
              size: 18, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _ProfileScoreRing extends StatelessWidget {
  final int score;
  const _ProfileScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 5,
              backgroundColor: AppColors.ivoryDark,
              valueColor: const AlwaysStoppedAnimation(
                  AppColors.crimson),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.crimson,
                ),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 4),
        const Text(
          'Profile',
          style: TextStyle(
              fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatBox({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji,
                style:
                const TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.rows,
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
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 14, 16, 10),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon,
                      size: 16,
                      color: AppColors.crimson),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ]),
          ),
          const Divider(
              height: 1, color: AppColors.border),
          // Rows
          ...rows.map((row) => _buildRow(row)),
        ],
      ),
    );
  }

  Widget _buildRow(_InfoRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.border,
              width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            row.label,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              row.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
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
            vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.border, width: 0.5),
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
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.muted),
        ]),
      ),
    );
  }
}