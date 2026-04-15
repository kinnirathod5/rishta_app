// lib/presentation/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';

// ── MOCK DATA ─────────────────────────────────────────────
class MockProfile {
  final String id;
  final String name;
  final int age;
  final String caste;
  final String city;
  final String profession;
  final String emoji;
  final bool isVerified;
  final bool isPremium;

  const MockProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.caste,
    required this.city,
    required this.profession,
    required this.emoji,
    required this.isVerified,
    required this.isPremium,
  });
}

const List<MockProfile> mockProfiles = [
  MockProfile(id: '1', name: 'Priya Sharma',   age: 26, caste: 'Brahmin',  city: 'Delhi',     profession: 'Software Engineer', emoji: '👩',    isVerified: true,  isPremium: false),
  MockProfile(id: '2', name: 'Anjali Gupta',   age: 24, caste: 'Kayastha', city: 'Mumbai',    profession: 'Marketing Manager', emoji: '👩‍💼', isVerified: false, isPremium: true),
  MockProfile(id: '3', name: 'Meera Singh',    age: 28, caste: 'Rajput',   city: 'Jaipur',    profession: 'Doctor',            emoji: '👩‍⚕️', isVerified: true,  isPremium: true),
  MockProfile(id: '4', name: 'Sneha Patel',    age: 25, caste: 'Patel',    city: 'Ahmedabad', profession: 'CA',                emoji: '👩‍🏫', isVerified: true,  isPremium: false),
  MockProfile(id: '5', name: 'Ritu Verma',     age: 27, caste: 'Brahmin',  city: 'Lucknow',   profession: 'IIT Graduate',      emoji: '👩‍🔬', isVerified: true,  isPremium: false),
  MockProfile(id: '6', name: 'Pooja Iyer',     age: 23, caste: 'Iyer',     city: 'Chennai',   profession: 'Dentist',           emoji: '🧑‍⚕️', isVerified: false, isPremium: false),
  MockProfile(id: '7', name: 'Kavya Reddy',    age: 26, caste: 'Reddy',    city: 'Hyderabad', profession: 'Data Scientist',    emoji: '👩‍💻', isVerified: true,  isPremium: true),
  MockProfile(id: '8', name: 'Nisha Jain',     age: 25, caste: 'Jain',     city: 'Pune',      profession: 'Business',          emoji: '👩‍🚀', isVerified: false, isPremium: false),
  MockProfile(id: '9', name: 'Arya Nair',      age: 27, caste: 'Nair',     city: 'Kochi',     profession: 'Professor',         emoji: '👩‍🏫', isVerified: true,  isPremium: false),
  MockProfile(id: '10', name: 'Simran Kaur',   age: 24, caste: 'Jat Sikh', city: 'Chandigarh',profession: 'Civil Services',    emoji: '👩‍✈️', isVerified: true,  isPremium: true),
];

// ── SCREEN ────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Local UI state — will move to provider in Phase 3
  final Set<String> _sentInterests = {};
  final Set<String> _shortlisted = {};
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    // Check guest status from auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      setState(() => _isGuest = authState.isAnonymous);
    });
  }

  void _toggleInterest(String id) {
    if (_isGuest) {
      _showGuestModal();
      return;
    }
    setState(() {
      if (_sentInterests.contains(id)) {
        _sentInterests.remove(id);
      } else {
        _sentInterests.add(id);
      }
    });
    // TODO: Phase 3 — call InterestRepository
  }

  void _toggleShortlist(String id) {
    if (_isGuest) {
      _showGuestModal();
      return;
    }
    setState(() {
      if (_shortlisted.contains(id)) {
        _shortlisted.remove(id);
      } else {
        _shortlisted.add(id);
      }
    });
    // TODO: Phase 3 — call ProfileRepository
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
    ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: _buildTopBar(unreadCount)),
              SliverToBoxAdapter(
                  child: _buildWelcomeCard()),
              SliverToBoxAdapter(
                  child: _buildActivityStrip()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  AppStrings.todayMatches,
                  '💫',
                  showSeeAll: true,
                ),
              ),
              SliverToBoxAdapter(
                  child: _buildTodayMatches()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  AppStrings.newMembers,
                  '✨',
                  showSeeAll: true,
                ),
              ),
              SliverToBoxAdapter(
                  child: _buildNewMembers()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  AppStrings.featuredProfiles,
                  '👑',
                  showSeeAll: false,
                ),
              ),
              SliverToBoxAdapter(
                  child: _buildFeaturedBanner()),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 100)),
            ],
          ),
          if (_isGuest) _buildGuestBanner(),
        ],
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────
  Widget _buildTopBar(int unreadCount) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding:
      EdgeInsets.fromLTRB(20, topPad + 8, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('💍',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ]),
          // Actions
          Row(children: [
            _TopBarIcon(
              icon: Icons.search_rounded,
              onTap: () => context.go('/search'),
            ),
            const SizedBox(width: 8),
            _TopBarIcon(
              icon: Icons.notifications_outlined,
              onTap: () =>
                  context.push('/notifications'),
              badgeCount: unreadCount,
            ),
            const SizedBox(width: 8),
            _TopBarIcon(
              icon: Icons.workspace_premium_rounded,
              iconColor: AppColors.goldLight,
              onTap: () => context.push('/premium'),
            ),
          ]),
        ],
      ),
    );
  }

  // ── WELCOME CARD ──────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, Priya! 👋',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '12 ${AppStrings.newMatchesCount}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/my-profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.crimsonGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: AppColors.goldLight),
                  const SizedBox(width: 5),
                  Text(
                    '78${AppStrings.profileComplete}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ACTIVITY STRIP ────────────────────────────────────
  Widget _buildActivityStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActivityChip(
              emoji: '💌',
              label: '3 ${AppStrings.newInterests}',
              bg: AppColors.crimsonSurface,
              border: AppColors.crimson.withOpacity(0.2),
              textColor: AppColors.crimson,
              onTap: () => context.go('/interests'),
            ),
            _ActivityChip(
              emoji: '👁️',
              label: '12 ${AppStrings.profileViews}',
              bg: AppColors.goldSurface,
              border: AppColors.gold.withOpacity(0.2),
              textColor: AppColors.gold,
              onTap: () => context.push('/who-viewed'),
            ),
            _ActivityChip(
              emoji: '🤝',
              label: '2 ${AppStrings.connected}',
              bg: AppColors.successSurface,
              border: AppColors.success.withOpacity(0.2),
              textColor: AppColors.success,
              onTap: () => context.go('/interests'),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────
  Widget _buildSectionHeader(String title, String emoji,
      {bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(emoji,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
          ]),
          if (showSeeAll)
            GestureDetector(
              onTap: () => context.go('/search'),
              child: const Text(
                AppStrings.viewAll,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.crimson,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── TODAY'S MATCHES ───────────────────────────────────
  Widget _buildTodayMatches() {
    return SizedBox(
      height: 238,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
        const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (_, i) =>
            _buildHorizontalCard(mockProfiles[i], i),
      ),
    );
  }

  Widget _buildHorizontalCard(
      MockProfile p, int index) {
    final isLocked = _isGuest && index > 1;
    final interested = _sentInterests.contains(p.id);
    final bookmarked = _shortlisted.contains(p.id);

    return GestureDetector(
      onTap: isLocked
          ? _showGuestModal
          : () => context.push(
          '/profile/${p.id}', extra: p),
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Photo area
            Stack(children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                    top: Radius.circular(13)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: isLocked
                      ? _LockedPhoto(emoji: p.emoji)
                      : Container(
                    color: p.isVerified
                        ? AppColors
                        .crimsonSurface
                        : const Color(
                        0xFFF3F4F6),
                    child: Center(
                      child: Text(p.emoji,
                          style: const TextStyle(
                              fontSize: 54)),
                    ),
                  ),
                ),
              ),
              if (p.isVerified && !isLocked)
                Positioned(
                    top: 8,
                    left: 8,
                    child: _VerifiedBadge()),
              if (p.isPremium && !isLocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('👑',
                          style:
                          TextStyle(fontSize: 11)),
                    ),
                  ),
                ),
            ]),

            // Info area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.name}, ${p.age}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.caste} • ${p.city}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.profession,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSoft,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Action buttons
                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _toggleInterest(p.id),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 5),
                            decoration: BoxDecoration(
                              color: interested
                                  ? AppColors.crimson
                                  : AppColors
                                  .crimsonSurface,
                              borderRadius:
                              BorderRadius.circular(
                                  8),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: [
                                Icon(
                                  interested
                                      ? Icons
                                      .favorite_rounded
                                      : Icons
                                      .favorite_border_rounded,
                                  size: 12,
                                  color: interested
                                      ? Colors.white
                                      : AppColors
                                      .crimson,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  interested
                                      ? AppStrings
                                      .interestSent
                                      : AppStrings
                                      .sendInterest,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: interested
                                        ? Colors.white
                                        : AppColors
                                        .crimson,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            _toggleShortlist(p.id),
                        child: AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 200),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: bookmarked
                                ? AppColors.goldSurface
                                : AppColors.ivoryDark,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              bookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons
                                  .bookmark_border_rounded,
                              size: 15,
                              color: bookmarked
                                  ? AppColors.gold
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── NEW MEMBERS GRID ──────────────────────────────────
  Widget _buildNewMembers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: 4,
        itemBuilder: (_, i) =>
            _buildGridCard(mockProfiles[i + 6]),
      ),
    );
  }

  Widget _buildGridCard(MockProfile p) {
    final interested = _sentInterests.contains(p.id);

    return GestureDetector(
      onTap: () =>
          context.push('/profile/${p.id}', extra: p),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(
                          top: Radius.circular(13)),
                      child: Container(
                        color: const Color(0xFFF3F4F6),
                        child: Center(
                          child: Text(p.emoji,
                              style: const TextStyle(
                                  fontSize: 56)),
                        ),
                      ),
                    ),
                    if (p.isVerified)
                      Positioned(
                          top: 8,
                          left: 8,
                          child: _VerifiedBadge()),
                  ]),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.name}, ${p.age}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.caste} • ${p.city}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(
                        Icons.work_outline_rounded,
                        size: 12,
                        color: AppColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        p.profession,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.inkSoft,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  // Interest button
                  GestureDetector(
                    onTap: () =>
                        _toggleInterest(p.id),
                    child: AnimatedContainer(
                      duration: const Duration(
                          milliseconds: 200),
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 7),
                      decoration: BoxDecoration(
                        color: interested
                            ? AppColors.crimson
                            : AppColors.crimsonSurface,
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(
                            interested
                                ? Icons.favorite_rounded
                                : Icons
                                .favorite_border_rounded,
                            size: 12,
                            color: interested
                                ? Colors.white
                                : AppColors.crimson,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            interested
                                ? AppStrings.interestSent
                                : AppStrings.sendInterest,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: interested
                                  ? Colors.white
                                  : AppColors.crimson,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FEATURED BANNER ───────────────────────────────────
  Widget _buildFeaturedBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.crimsonDark,
              AppColors.crimson
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('👑',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.premiumMembers,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  AppStrings.premiumSubtext,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () =>
                      context.push('/premium'),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStrings.viewNow,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.crimson,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('👑',
              style: TextStyle(fontSize: 56)),
        ]),
      ),
    );
  }

  // ── GUEST BANNER ──────────────────────────────────────
  Widget _buildGuestBanner() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.crimsonGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.limitedAccess,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.registerUnlock,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => context.go('/phone'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: const Text(
                  'Register →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.crimson,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GUEST MODAL ───────────────────────────────────────
  void _showGuestModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('🔒',
                style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              AppStrings.createFreeAccount,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.needAccountFor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            _BenefitRow(label: AppStrings.viewUnlimited),
            _BenefitRow(label: AppStrings.sendReceive),
            _BenefitRow(
                label: AppStrings.chatDirectlyFull),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/phone');
                },
                child:
                Text(AppStrings.registerFree),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: Text(
                  AppStrings.maybeLater,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PRIVATE WIDGETS ───────────────────────────────────────

class _TopBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final int badgeCount;

  const _TopBarIcon({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon,
                size: 20,
                color: iconColor ?? Colors.white),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.crimson, width: 1.5),
              ),
            ),
          ),
      ]),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color bg;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;

  const _ActivityChip({
    required this.emoji,
    required this.label,
    required this.bg,
    required this.border,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji,
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  )),
            ]),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
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
            AppStrings.verified,
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

class _LockedPhoto extends StatelessWidget {
  final String emoji;
  const _LockedPhoto({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Container(
        color: const Color(0xFFF3F4F6),
        child: Center(
          child: Text(emoji,
              style: const TextStyle(fontSize: 44)),
        ),
      ),
      Container(
          color: Colors.white.withOpacity(0.65)),
      const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 20, color: AppColors.crimson),
            SizedBox(height: 4),
            Text(
              'Register\nto View',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.crimson,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _BenefitRow extends StatelessWidget {
  final String label;
  const _BenefitRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.successSurface,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_rounded,
                size: 13, color: AppColors.success),
          ),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.inkSoft)),
      ]),
    );
  }
}