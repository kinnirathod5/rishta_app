// lib/presentation/profile/profile_preview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/profile_provider.dart';

class ProfilePreviewScreen extends ConsumerStatefulWidget {
  const ProfilePreviewScreen({super.key});

  @override
  ConsumerState<ProfilePreviewScreen> createState() =>
      _ProfilePreviewScreenState();
}

class _ProfilePreviewScreenState
    extends ConsumerState<ProfilePreviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isAboutExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                  child: _buildPreviewBanner()),
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
          _buildTopActions(),
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

  // ── SLIVER APP BAR ────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: false,
      floating: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.crimsonSurface,
                    AppColors.ivoryDark,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Text(
                  '👩',
                  style: TextStyle(fontSize: 110),
                ),
              ),
            ),
            // Bottom fade
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
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
            // Photo grid dots
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 3),
                    width: i == 0 ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? AppColors.crimson
                          : Colors.white
                          .withOpacity(0.6),
                      borderRadius:
                      BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP ACTIONS ───────────────────────────────────────
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
          _CircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => context.pop(),
          ),
          // Preview badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.ink.withOpacity(0.75),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility_outlined,
                    size: 13, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Preview Mode',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _CircleButton(
            icon: Icons.edit_rounded,
            onTap: () => context.push('/setup/step1'),
          ),
        ],
      ),
    );
  }

  // ── PREVIEW BANNER ────────────────────────────────────
  Widget _buildPreviewBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.gold.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.visibility_outlined,
                  size: 18, color: AppColors.gold),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'This is how others see your profile',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Make edits to improve your profile score',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PROFILE HEADER ────────────────────────────────────
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text(
                        'Priya Sharma, 26',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius:
                          BorderRadius.circular(
                              100),
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
                    _buildInfoRow(
                        Icons.work_outline_rounded,
                        'Software Engineer • TCS'),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                        Icons.location_on_outlined,
                        'Delhi • Brahmin'),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                        Icons.school_outlined,
                        'B.Tech • 8-12 LPA'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Score ring
              _ProfileScoreRing(score: 78),
            ],
          ),

          const SizedBox(height: 16),

          // Incomplete sections
          _buildIncompletePrompts(),

          const SizedBox(height: 16),

          // About
          GestureDetector(
            onTap: () => setState(
                    () => _isAboutExpanded =
                !_isAboutExpanded),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  duration:
                  const Duration(milliseconds: 250),
                  crossFadeState: _isAboutExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const Text(
                    'Software engineer at TCS with 3 years of experience. Love traveling, cooking and reading. Looking for a kind, understanding partner.',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.inkSoft,
                        height: 1.6),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: const Text(
                    'Software engineer at TCS with 3 years of experience. Love traveling, cooking and reading. Looking for a kind, understanding partner who values family.',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.inkSoft,
                        height: 1.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAboutExpanded
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.muted),
      const SizedBox(width: 6),
      Text(
        text,
        style: const TextStyle(
            fontSize: 13, color: AppColors.inkSoft),
      ),
    ]);
  }

  // ── INCOMPLETE PROMPTS ────────────────────────────────
  Widget _buildIncompletePrompts() {
    final items = [
      _IncompleteItem(
        emoji: '⭐',
        label: 'Add Horoscope',
        score: '+15%',
        route: '/horoscope',
      ),
      _IncompleteItem(
        emoji: '📸',
        label: 'Add more photos',
        score: '+7%',
        route: '/setup/step5',
      ),
      _IncompleteItem(
        emoji: '🔐',
        label: 'Verify ID',
        score: '+10%',
        route: '/id-verification',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 14, color: AppColors.gold),
          const SizedBox(width: 6),
          const Text(
            'Complete your profile to get more matches',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items
                .map((item) => GestureDetector(
              onTap: () =>
                  context.push(item.route),
              child: Container(
                margin: const EdgeInsets.only(
                    right: 8),
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.goldSurface,
                  borderRadius:
                  BorderRadius.circular(
                      100),
                  border: Border.all(
                    color: AppColors.gold
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.emoji,
                        style: const TextStyle(
                            fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w500,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.score,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ))
                .toList(),
          ),
        ),
      ],
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
      child: const Row(
        children: [
          _StatBox(emoji: '📏', value: "5'4\"", label: 'Height'),
          _StatBox(emoji: '🛕', value: 'Hindu',  label: 'Religion'),
          _StatBox(emoji: '🎓', value: 'B.Tech', label: 'Education'),
          _StatBox(emoji: '💰', value: '8-12 L', label: 'Income'),
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
                fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Family'),
              Tab(text: 'Preferences'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            physics:
            const NeverScrollableScrollPhysics(),
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

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: [
        _InfoCard(
          title: 'Basic Details',
          icon: Icons.person_outline_rounded,
          onEdit: () => context.push('/setup/step1'),
          rows: const [
            _InfoRow(label: 'Full Name',      value: 'Priya Sharma'),
            _InfoRow(label: 'Date of Birth',  value: '12 Mar 1998 • 26 yrs'),
            _InfoRow(label: 'Height',         value: "5'4\" (163 cm)"),
            _InfoRow(label: 'Current City',   value: 'Delhi, India'),
            _InfoRow(label: 'Mother Tongue',  value: 'Hindi'),
            _InfoRow(label: 'Marital Status', value: 'Never Married'),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Religion & Community',
          icon: Icons.temple_hindu_outlined,
          onEdit: () => context.push('/setup/step2'),
          rows: const [
            _InfoRow(label: 'Religion',  value: 'Hindu'),
            _InfoRow(label: 'Caste',     value: 'Brahmin'),
            _InfoRow(label: 'Sub Caste', value: 'Kanyakubja'),
            _InfoRow(label: 'Gotra',     value: 'Kashyap'),
            _InfoRow(label: 'Manglik',   value: 'No'),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Education & Career',
          icon: Icons.school_outlined,
          onEdit: () => context.push('/setup/step3'),
          rows: const [
            _InfoRow(label: 'Qualification', value: 'B.Tech'),
            _InfoRow(label: 'College',       value: 'DTU'),
            _InfoRow(label: 'Employed In',   value: 'Private Sector'),
            _InfoRow(label: 'Company',       value: 'TCS'),
            _InfoRow(label: 'Annual Income', value: '8-12 LPA'),
          ],
        ),
      ]),
    );
  }

  Widget _buildFamilyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: [
        _InfoCard(
          title: 'Family Background',
          icon: Icons.home_outlined,
          onEdit: () => context.push('/setup/step4'),
          rows: const [
            _InfoRow(label: 'Family Type',   value: 'Joint Family'),
            _InfoRow(label: 'Family Values', value: 'Traditional'),
            _InfoRow(label: 'Family Status', value: 'Middle Class'),
            _InfoRow(label: 'Family City',   value: 'Lucknow, UP'),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Parents & Siblings',
          icon: Icons.people_outline_rounded,
          onEdit: () => context.push('/setup/step4'),
          rows: const [
            _InfoRow(label: 'Father',   value: 'Business'),
            _InfoRow(label: 'Mother',   value: 'Homemaker'),
            _InfoRow(label: 'Brothers', value: '1 (Married)'),
            _InfoRow(label: 'Sisters',  value: 'None'),
          ],
        ),
        const SizedBox(height: 12),
        // Horoscope incomplete card
        _IncompleteCard(
          title: 'Horoscope',
          icon: Icons.stars_rounded,
          message: 'Add your horoscope details to attract more matches',
          scoreGain: '+15%',
          onAdd: () => context.push('/horoscope'),
        ),
      ]),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: [
        _InfoCard(
          title: 'Partner Preferences',
          icon: Icons.favorite_outline_rounded,
          onEdit: () =>
              context.push('/partner-preference'),
          rows: const [
            _InfoRow(label: 'Age Range',      value: '27 – 35 yrs'),
            _InfoRow(label: 'Height',         value: "5'5\" – 6'0\""),
            _InfoRow(label: 'Religion',       value: 'Hindu'),
            _InfoRow(label: 'Caste',          value: 'Brahmin, Kayastha'),
            _InfoRow(label: 'Education',      value: 'Graduate & above'),
            _InfoRow(label: 'Income',         value: '8 LPA & above'),
            _InfoRow(label: 'Location',       value: 'Delhi, Mumbai'),
            _InfoRow(label: 'Marital Status', value: 'Never Married'),
          ],
        ),
      ]),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            top: BorderSide(color: AppColors.border)),
        boxShadow: AppColors.modalShadow,
      ),
      child: Row(children: [
        // Share
        _ActionButton(
          icon: Icons.share_outlined,
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
            content: Text('Share feature coming soon'),
            behavior: SnackBarBehavior.floating,
          )),
        ),
        const SizedBox(width: 10),
        // Edit Profile
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () =>
                  context.push('/setup/step1'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: AppColors.crimson,
                    width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded,
                      size: 18,
                      color: AppColors.crimson),
                  SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.crimson,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Upgrade
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  context.push('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text('👑',
                      style:
                      TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text(
                    'Go Premium',
                    style: TextStyle(
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

// ── DATA MODELS ───────────────────────────────────────────

class _IncompleteItem {
  final String emoji;
  final String label;
  final String score;
  final String route;

  const _IncompleteItem({
    required this.emoji,
    required this.label,
    required this.score,
    required this.route,
  });
}

// ── PRIVATE WIDGETS ───────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton(
      {required this.icon, required this.onTap});

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
          child:
          Icon(icon, size: 18, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: Icon(icon,
              size: 22, color: AppColors.inkSoft),
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
          Text(
            '$score%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.crimson,
            ),
          ),
        ]),
        const SizedBox(height: 4),
        const Text(
          'Score',
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
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<_InfoRow> rows;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.onEdit,
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
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
              16, 14, 12, 10),
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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            // Edit button
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius:
                  BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded,
                        size: 12,
                        color: AppColors.crimson),
                    SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.crimson,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
        const Divider(
            height: 1, color: AppColors.border),
        ...rows.map((row) => _buildRow(row)),
      ]),
    );
  }

  Widget _buildRow(_InfoRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(row.label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted)),
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
  const _InfoRow(
      {required this.label, required this.value});
}

class _IncompleteCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final String scoreGain;
  final VoidCallback onAdd;

  const _IncompleteCard({
    required this.title,
    required this.icon,
    required this.message,
    required this.scoreGain,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.gold.withOpacity(0.4)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
              16, 14, 12, 10),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.goldSurface,
                borderRadius:
                BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon,
                    size: 16, color: AppColors.gold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius:
                BorderRadius.circular(100),
              ),
              child: Text(
                scoreGain,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ]),
        ),
        const Divider(
            height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    height: 1.5),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.goldSurface,
                  borderRadius:
                  BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.gold
                          .withOpacity(0.3)),
                ),
                child: const Text(
                  'Add Now',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}