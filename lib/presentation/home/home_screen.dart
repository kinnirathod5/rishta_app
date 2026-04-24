// lib/presentation/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/providers/auth_provider.dart';
import 'package:rishta_app/providers/app_state_provider.dart';
import 'package:rishta_app/providers/interest_provider.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────────────────

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
  MockProfile(id: '1',  name: 'Priya Sharma',   age: 26, caste: 'Brahmin',  city: 'Delhi',      profession: 'Software Engineer', emoji: '👩',    isVerified: true,  isPremium: false),
  MockProfile(id: '2',  name: 'Anjali Gupta',   age: 24, caste: 'Kayastha', city: 'Mumbai',     profession: 'Marketing Manager', emoji: '👩‍💼', isVerified: false, isPremium: true),
  MockProfile(id: '3',  name: 'Meera Singh',    age: 28, caste: 'Rajput',   city: 'Jaipur',     profession: 'Doctor',            emoji: '👩‍⚕️', isVerified: true,  isPremium: true),
  MockProfile(id: '4',  name: 'Sneha Patel',    age: 25, caste: 'Patel',    city: 'Ahmedabad',  profession: 'CA',                emoji: '👩‍🏫', isVerified: true,  isPremium: false),
  MockProfile(id: '5',  name: 'Ritu Verma',     age: 27, caste: 'Brahmin',  city: 'Lucknow',    profession: 'IIT Graduate',      emoji: '👩‍🔬', isVerified: true,  isPremium: false),
  MockProfile(id: '6',  name: 'Pooja Iyer',     age: 23, caste: 'Iyer',     city: 'Chennai',    profession: 'Dentist',           emoji: '🧑‍⚕️', isVerified: false, isPremium: false),
  MockProfile(id: '7',  name: 'Kavya Reddy',    age: 26, caste: 'Reddy',    city: 'Hyderabad',  profession: 'Data Scientist',    emoji: '👩‍💻', isVerified: true,  isPremium: true),
  MockProfile(id: '8',  name: 'Nisha Jain',     age: 25, caste: 'Jain',     city: 'Pune',       profession: 'Business',          emoji: '👩‍🚀', isVerified: false, isPremium: false),
  MockProfile(id: '9',  name: 'Arya Nair',      age: 27, caste: 'Nair',     city: 'Kochi',      profession: 'Professor',         emoji: '👩‍🏫', isVerified: true,  isPremium: false),
  MockProfile(id: '10', name: 'Simran Kaur',    age: 24, caste: 'Jat Sikh', city: 'Chandigarh', profession: 'Civil Services',    emoji: '👩‍✈️', isVerified: true,  isPremium: true),
];

// ─────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {

  final _scrollCtrl = ScrollController();
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      setState(() => _isGuest = auth.isAnonymous);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showGuestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _GuestModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
    ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(
              const Duration(milliseconds: 800));
        },
        color: AppColors.crimson,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
                child: _buildTopBar(unreadCount)),
            SliverToBoxAdapter(
                child: _buildWelcomeCard()),
            if (_isGuest)
              SliverToBoxAdapter(
                  child: _buildGuestBanner()),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                AppStrings.todayMatches,
                '💑',
                onViewAll: () =>
                    context.go('/search'),
              ),
            ),
            SliverToBoxAdapter(
                child: _buildTodayMatches()),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                AppStrings.newMembers,
                '✨',
                onViewAll: () =>
                    context.go('/search'),
              ),
            ),
            SliverToBoxAdapter(
                child: _buildNewMembers()),
            SliverToBoxAdapter(
                child: _buildFeaturedBanner()),
            const SliverToBoxAdapter(
                child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────
  // Sirf Logo + App name + Notification bell

  Widget _buildTopBar(int unreadCount) {
    final topPad =
        MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.crimsonGradient,
      ),
      padding: EdgeInsets.fromLTRB(
          20, topPad + 12, 16, 16),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.2),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('💍',
                  style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          // App name + tagline
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white
                        .withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          // Only notification bell
          _NotificationBell(
            badgeCount: unreadCount,
            onTap: () =>
                context.push('/notifications'),
          ),
        ],
      ),
    );
  }

  // ── WELCOME CARD ──────────────────────────────────────

  Widget _buildWelcomeCard() {
    final profile =
    ref.watch(currentProfileProvider);
    final score = ref.watch(profileScoreProvider);
    final name = profile?.firstName ?? 'There';
    final greeting = _getGreeting();

    return Container(
      decoration: const BoxDecoration(
          gradient: AppColors.crimsonGradient),
      padding: const EdgeInsets.fromLTRB(
          20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color:
              Colors.white.withOpacity(0.2)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $name! 👋',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: AppColors.goldLight,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '12 ${AppStrings.newMatchesCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white
                          .withOpacity(0.85),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                // Complete profile CTA if score low
                if (score < 80)
                  GestureDetector(
                    onTap: () =>
                        context.go('/edit-profile'),
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.18),
                        borderRadius:
                        BorderRadius.circular(
                            100),
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons
                                .edit_note_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Complete profile →',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                              color: Colors.white
                                  .withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Profile score ring
          GestureDetector(
            onTap: () =>
                context.go('/my-profile'),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child:
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 5,
                        backgroundColor:
                        Colors.white
                            .withOpacity(0.2),
                        valueColor:
                        AlwaysStoppedAnimation(
                          score >= 80
                              ? AppColors.goldLight
                              : Colors.white
                              .withOpacity(0.7),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$score%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────

  Widget _buildSectionHeader(
      String title,
      String emoji, {
        required VoidCallback onViewAll,
      }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          16, 20, 16, 8),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(emoji,
                style: const TextStyle(
                    fontSize: 20)),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.h4),
          ]),
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.crimsonSurface,
                borderRadius:
                BorderRadius.circular(100),
              ),
              child: Text(
                AppStrings.viewAll,
                style: AppTextStyles.labelSmall
                    .copyWith(
                    color: AppColors.crimson),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TODAY'S MATCHES — Horizontal scroll ───────────────

  Widget _buildTodayMatches() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            16, 0, 16, 8),
        itemCount: mockProfiles.length,
        itemBuilder: (_, i) =>
            _buildHorizontalCard(mockProfiles[i]),
      ),
    );
  }

  Widget _buildHorizontalCard(MockProfile p) {
    final sentIds =
    ref.watch(sentInterestIdsProvider);
    final isSent = sentIds.contains(p.id);

    return GestureDetector(
      onTap: () => context.push(
          '/profile/${p.id}',
          extra: p),
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            // Photo
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                    top: Radius.circular(15)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color:
                      AppColors.crimsonSurface,
                      child: Center(
                        child: Text(p.emoji,
                            style: const TextStyle(
                                fontSize: 54)),
                      ),
                    ),
                    // Premium badge
                    if (p.isPremium)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration:
                          BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors
                                    .gold
                                    .withOpacity(
                                    0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('👑',
                                style: TextStyle(
                                    fontSize: 12)),
                          ),
                        ),
                      ),
                    // Verified bar
                    if (p.isVerified)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          color: AppColors.success
                              .withOpacity(0.9),
                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                            children: [
                              Icon(
                                  Icons
                                      .verified_rounded,
                                  size: 11,
                                  color:
                                  Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                  Colors.white,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  10, 8, 10, 10),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.name.split(' ').first}, ${p.age}',
                    style:
                    AppTextStyles.profileNameSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: AppColors.muted),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${p.city} • ${p.caste}',
                        style:
                        AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 7),
                  _InterestButton(
                    isSent: isSent,
                    onTap: () {
                      if (_isGuest) {
                        _showGuestModal();
                        return;
                      }
                      HapticFeedback.lightImpact();
                      if (!isSent) {
                        ref
                            .read(interestsProvider
                            .notifier)
                            .sendInterest(
                          receiverId: p.id,
                          receiverProfileId:
                          p.id,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── NEW MEMBERS — Grid ────────────────────────────────

  Widget _buildNewMembers() {
    final newOnes =
    mockProfiles.reversed.take(4).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          16, 0, 16, 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
        const NeverScrollableScrollPhysics(),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: newOnes.length,
        itemBuilder: (_, i) =>
            _buildGridCard(newOnes[i]),
      ),
    );
  }

  Widget _buildGridCard(MockProfile p) {
    final sentIds =
    ref.watch(sentInterestIdsProvider);
    final isSent = sentIds.contains(p.id);

    return GestureDetector(
      onTap: () => context.push(
          '/profile/${p.id}',
          extra: p),
      child: Container(
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
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                    top: Radius.circular(13)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color:
                      AppColors.crimsonSurface,
                      child: Center(
                        child: Text(p.emoji,
                            style: const TextStyle(
                                fontSize: 48)),
                      ),
                    ),
                    if (p.isVerified)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius:
                            BorderRadius
                                .circular(100),
                          ),
                          child: const Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              Icon(
                                  Icons
                                      .verified_rounded,
                                  size: 9,
                                  color:
                                  Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius:
                          BorderRadius.circular(
                              100),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight:
                            FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  10, 8, 10, 10),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.name.split(' ').first}, ${p.age}',
                    style:
                    AppTextStyles.profileNameSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.profession,
                    style: AppTextStyles.bodySmall
                        .copyWith(
                        color: AppColors.inkSoft),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: AppColors.muted),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        p.city,
                        style:
                        AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _InterestButton(
                    isSent: isSent,
                    onTap: () {
                      if (_isGuest) {
                        _showGuestModal();
                        return;
                      }
                      HapticFeedback.lightImpact();
                      if (!isSent) {
                        ref
                            .read(interestsProvider
                            .notifier)
                            .sendInterest(
                          receiverId: p.id,
                          receiverProfileId:
                          p.id,
                        );
                      }
                    },
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
    return Container(
      margin: const EdgeInsets.fromLTRB(
          16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.9),
            AppColors.goldDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.goldShadow,
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                  Colors.white.withOpacity(0.2),
                  borderRadius:
                  BorderRadius.circular(100),
                ),
                child: const Text(
                  '⭐ PREMIUM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.premiumMembers,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.premiumSubtext,
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () =>
                    context.push('/premium'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(100),
                  ),
                  child: Text(
                    AppStrings.viewNow,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
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
    );
  }

  // ── GUEST BANNER ──────────────────────────────────────

  Widget _buildGuestBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crimsonSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color:
            AppColors.crimson.withOpacity(0.25)),
      ),
      child: Row(children: [
        const Text('🔒',
            style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.limitedAccess,
                style: AppTextStyles.labelLarge
                    .copyWith(
                    color: AppColors.crimson),
              ),
              const SizedBox(height: 3),
              Text(
                AppStrings.registerUnlock,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/phone'),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.crimson,
              borderRadius:
              BorderRadius.circular(8),
            ),
            child: const Text(
              'Join Free',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── HELPERS ───────────────────────────────────────────

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

// ─────────────────────────────────────────────────────────
// INTEREST BUTTON — Reusable widget
// ─────────────────────────────────────────────────────────

class _InterestButton extends StatelessWidget {
  final bool isSent;
  final VoidCallback onTap;

  const _InterestButton({
    required this.isSent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSent
              ? AppColors.crimson
              : AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(8),
          border: isSent
              ? null
              : Border.all(
              color: AppColors.crimson
                  .withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isSent
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 12,
              color: isSent
                  ? Colors.white
                  : AppColors.crimson,
            ),
            const SizedBox(width: 4),
            Text(
              isSent
                  ? AppStrings.interestSent
                  : AppStrings.sendInterest,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSent
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

// ─────────────────────────────────────────────────────────
// NOTIFICATION BELL
// ─────────────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  final int badgeCount;
  final VoidCallback onTap;

  const _NotificationBell({
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 22,
                color: Colors.white,
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white,
                        width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9
                          ? '9+'
                          : '$badgeCount',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
}

// ─────────────────────────────────────────────────────────
// GUEST MODAL
// ─────────────────────────────────────────────────────────

class _GuestModal extends StatelessWidget {
  const _GuestModal();

  @override
  Widget build(BuildContext context) {
    final bottomPad =
        MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 8, 24, bottomPad + 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin:
              const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.crimsonGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💍',
                  style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.createFreeAccount,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.needAccountFor,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...[
            (Icons.photo_library_outlined,
            AppStrings.viewUnlimited),
            (Icons.favorite_outline_rounded,
            AppStrings.sendReceive),
            (Icons.chat_bubble_outline_rounded,
            AppStrings.chatDirectlyFull),
          ].map((item) => Padding(
            padding:
            const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(item.$1,
                      size: 16,
                      color: AppColors.crimson),
                ),
              ),
              const SizedBox(width: 12),
              Text(item.$2,
                  style:
                  AppTextStyles.labelMedium),
            ]),
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/phone');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimson,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                AppStrings.registerFree,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: Text(
              AppStrings.maybeLater,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}