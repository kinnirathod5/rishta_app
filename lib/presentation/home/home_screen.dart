import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

// ── MOCK DATA ─────────────────────────────────────────────────
class MockProfile {
  final String id;
  final String name;
  final int age;
  final String caste;
  final String religion;
  final String city;
  final String education;
  final String profession;
  final String emoji;
  final bool isVerified;
  final bool isPremium;
  final String height;
  final String about;

  const MockProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.caste,
    required this.religion,
    required this.city,
    required this.education,
    required this.profession,
    required this.emoji,
    required this.isVerified,
    required this.isPremium,
    required this.height,
    required this.about,
  });
}

const List<MockProfile> mockProfiles = [
  MockProfile(
    id: '1', name: 'Priya Sharma', age: 26,
    caste: 'Brahmin', religion: 'Hindu',
    city: 'Delhi', education: 'B.Tech',
    profession: 'Software Engineer',
    emoji: '👩', isVerified: true, isPremium: false,
    height: "5'4\"", about: 'Software engineer at TCS...',
  ),
  MockProfile(
    id: '2', name: 'Anjali Gupta', age: 24,
    caste: 'Kayastha', religion: 'Hindu',
    city: 'Mumbai', education: 'MBA',
    profession: 'Marketing Manager',
    emoji: '👩‍💼', isVerified: false, isPremium: true,
    height: "5'3\"", about: 'Marketing professional...',
  ),
  MockProfile(
    id: '3', name: 'Meera Singh', age: 28,
    caste: 'Rajput', religion: 'Hindu',
    city: 'Jaipur', education: 'MBBS',
    profession: 'Doctor',
    emoji: '👩‍⚕️', isVerified: true, isPremium: true,
    height: "5'5\"", about: 'Doctor at Fortis Hospital...',
  ),
  MockProfile(
    id: '4', name: 'Sneha Patel', age: 25,
    caste: 'Patel', religion: 'Hindu',
    city: 'Ahmedabad', education: 'B.Com',
    profession: 'CA',
    emoji: '👩‍🏫', isVerified: true, isPremium: false,
    height: "5'2\"", about: 'Chartered Accountant...',
  ),
  MockProfile(
    id: '5', name: 'Ritu Verma', age: 27,
    caste: 'Brahmin', religion: 'Hindu',
    city: 'Lucknow', education: 'M.Tech',
    profession: 'IIT Graduate',
    emoji: '👩‍🔬', isVerified: true, isPremium: false,
    height: "5'4\"", about: 'Research engineer...',
  ),
  MockProfile(
    id: '6', name: 'Pooja Iyer', age: 23,
    caste: 'Iyer', religion: 'Hindu',
    city: 'Chennai', education: 'BDS',
    profession: 'Dentist',
    emoji: '🧑‍⚕️', isVerified: false, isPremium: false,
    height: "5'1\"", about: 'Dentist in Chennai...',
  ),
  MockProfile(
    id: '7', name: 'Kavya Reddy', age: 26,
    caste: 'Reddy', religion: 'Hindu',
    city: 'Hyderabad', education: 'B.Tech',
    profession: 'Data Scientist',
    emoji: '👩‍💻', isVerified: true, isPremium: true,
    height: "5'3\"", about: 'Data scientist at Amazon...',
  ),
  MockProfile(
    id: '8', name: 'Nisha Jain', age: 25,
    caste: 'Jain', religion: 'Jain',
    city: 'Pune', education: 'MBA',
    profession: 'Business',
    emoji: '👩‍🚀', isVerified: false, isPremium: false,
    height: "5'2\"", about: 'Family business...',
  ),
  MockProfile(
    id: '9', name: 'Arya Nair', age: 27,
    caste: 'Nair', religion: 'Hindu',
    city: 'Kochi', education: 'M.Sc',
    profession: 'Professor',
    emoji: '👩‍🏫', isVerified: true, isPremium: false,
    height: "5'5\"", about: 'Assistant professor...',
  ),
  MockProfile(
    id: '10', name: 'Simran Kaur', age: 24,
    caste: 'Jat Sikh', religion: 'Sikh',
    city: 'Chandigarh', education: 'B.A',
    profession: 'Civil Services',
    emoji: '👩‍✈️', isVerified: true, isPremium: true,
    height: "5'6\"", about: 'IAS aspirant...',
  ),
];

// ── SCREEN ────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── STATE ─────────────────────────────────────────────
  final bool _isGuest = false;
  final Set<String> _sentInterests = {};
  final Set<String> _shortlisted = {};

  void _toggleInterest(String id) {
    setState(() {
      if (_sentInterests.contains(id)) {
        _sentInterests.remove(id);
      } else {
        _sentInterests.add(id);
      }
    });
  }

  void _toggleShortlist(String id) {
    setState(() {
      if (_shortlisted.contains(id)) {
        _shortlisted.remove(id);
      } else {
        _shortlisted.add(id);
      }
    });
  }

  // ── BUILD ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildWelcomeCard()),
              SliverToBoxAdapter(child: _buildActivityStrip()),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Aaj ke Matches', '💫',
                    showSeeAll: true),
              ),
              SliverToBoxAdapter(child: _buildTodayMatchesSection()),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Naaye Members', '✨',
                    showSeeAll: true),
              ),
              SliverToBoxAdapter(child: _buildRecentlyJoinedSection()),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Featured Profiles', '👑',
                    showSeeAll: false),
              ),
              SliverToBoxAdapter(child: _buildFeaturedSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          if (_isGuest) _buildGuestBanner(),
        ],
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────
  Widget _buildTopBar() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('💍', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RishtaApp',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Apna rishta dhundho',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Actions
          Row(
            children: [
              _buildTopBarIcon(Icons.search_rounded,
                  onTap: () => context.go('/search')),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildTopBarIcon(Icons.notifications_outlined,
                      onTap: () => context.push('/notifications')),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              _buildTopBarIcon(Icons.workspace_premium_rounded,
                  iconColor: AppColors.goldLight,
                  onTap: () => context.push('/premium')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarIcon(IconData icon,
      {required VoidCallback onTap, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(icon, size: 20, color: iconColor ?? AppColors.white),
        ),
      ),
    );
  }

  // ── WELCOME CARD ──────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste, Priya! 👋',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Aaj 12 naye matches hain',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.crimsonGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 14, color: AppColors.goldLight),
                SizedBox(width: 5),
                Text(
                  '78% Complete',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ACTIVITY STRIP ────────────────────────────────────
  Widget _buildActivityStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActivityChip(
              emoji: '💌',
              label: '3 Naye Interests',
              chipColor: AppColors.crimsonSurface,
              borderColor: AppColors.crimson.withValues(alpha: 0.2),
              textColor: AppColors.crimson,
              onTap: () => context.go('/interests'),
            ),
            _buildActivityChip(
              emoji: '👁️',
              label: '12 Profile Views',
              chipColor: AppColors.goldSurface,
              borderColor: AppColors.gold.withValues(alpha: 0.2),
              textColor: AppColors.gold,
              onTap: () {},
            ),
            _buildActivityChip(
              emoji: '🤝',
              label: '2 Connected',
              chipColor: AppColors.successSurface,
              borderColor: AppColors.success.withValues(alpha: 0.2),
              textColor: AppColors.success,
              onTap: () => context.go('/interests'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChip({
    required String emoji,
    required String label,
    required Color chipColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────
  Widget _buildSectionHeader(String title, String emoji,
      {bool showSeeAll = true}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: () => context.go('/search'),
              child: const Text(
                'Sab Dekhein →',
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
  Widget _buildTodayMatchesSection() {
    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildHorizontalMatchCard(mockProfiles[index], index);
        },
      ),
    );
  }

  Widget _buildHorizontalMatchCard(MockProfile profile, int index) {
    final bool isLocked = _isGuest && index > 1;
    final bool interested = _sentInterests.contains(profile.id);
    final bool bookmarked = _shortlisted.contains(profile.id);

    return GestureDetector(
      onTap: () => context.push('/profile/${profile.id}', extra: profile),
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: isLocked
                        ? _buildLockedPhoto(profile.emoji)
                        : Container(
                            color: profile.isVerified
                                ? AppColors.crimsonSurface
                                : const Color(0xFFF3F4F6),
                            child: Center(
                              child: Text(
                                profile.emoji,
                                style: const TextStyle(fontSize: 54),
                              ),
                            ),
                          ),
                  ),
                ),
                // Verified badge
                if (profile.isVerified && !isLocked)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildVerifiedBadge(),
                  ),
                // Premium badge
                if (profile.isPremium && !isLocked)
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
                        child: Text('👑', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
              ],
            ),

            // Info area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
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
                      '${profile.caste} • ${profile.city}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.profession,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSoft,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isGuest) {
                                _showGuestModal();
                              } else {
                                _toggleInterest(profile.id);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: interested
                                    ? AppColors.crimson
                                    : AppColors.crimsonSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: interested
                                    ? const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.favorite_rounded,
                                              size: 12,
                                              color: AppColors.white),
                                          SizedBox(width: 3),
                                          Text(
                                            'Bheja ✓',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.favorite_border_rounded,
                                              size: 12,
                                              color: AppColors.crimson),
                                          SizedBox(width: 3),
                                          Text(
                                            'Interest',
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
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _toggleShortlist(profile.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: bookmarked
                                  ? AppColors.goldSurface
                                  : AppColors.ivoryDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                bookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 15,
                                color: bookmarked
                                    ? AppColors.gold
                                    : AppColors.muted,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ── RECENTLY JOINED ───────────────────────────────────
  Widget _buildRecentlyJoinedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return _buildGridMatchCard(mockProfiles[index + 6]);
        },
      ),
    );
  }

  Widget _buildGridMatchCard(MockProfile profile) {
    final bool interested = _sentInterests.contains(profile.id);

    return GestureDetector(
      onTap: () => context.push('/profile/${profile.id}', extra: profile),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo area — Expanded so it takes remaining space,
            // preventing overflow regardless of screen width.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: Center(
                        child: Text(
                          profile.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  if (profile.isVerified)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildVerifiedBadge(),
                    ),
                ],
              ),
            ),

            // Info area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.name}, ${profile.age}',
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
                    '${profile.caste} • ${profile.city}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded,
                          size: 12, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.profession,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.inkSoft,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _toggleInterest(profile.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: interested
                            ? AppColors.crimson
                            : AppColors.crimsonSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          interested ? '✓ Bheja' : '❤️ Interest',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: interested
                                ? AppColors.white
                                : AppColors.crimson,
                          ),
                        ),
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

  // ── FEATURED SECTION ──────────────────────────────────
  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B0F0F), AppColors.crimson],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('👑', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'Premium Members',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verified aur premium profiles\nsirf aapke liye',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/premium'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Dekhein →',
                        style: TextStyle(
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
            const Stack(
              clipBehavior: Clip.none,
              children: [
                Text('👑', style: TextStyle(fontSize: 52)),
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: Text('✨', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── GUEST BANNER ──────────────────────────────────────
  Widget _buildGuestBanner() {
    return Positioned(
      bottom: 70,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.crimsonGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔒 Limited Access',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Register karke sab features unlock karein',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.white,
                  ),
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
                  borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('🔒', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              const Text(
                'Register Karein — Free Hai!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Interest bhejne ke liye account\nbanana zaroori hai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildBenefit('✓', 'Unlimited photos dekhein'),
              _buildBenefit('✓', 'Interest bhejein aur receive karein'),
              _buildBenefit('✓', 'Direct chat karein'),
              const SizedBox(height: 24),
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
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register Karo — Bilkul Free 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Center(
                  child: Text(
                    'Baad Mein',
                    style: TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefit(String check, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.successSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                check,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED HELPERS ────────────────────────────────────
  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 10, color: AppColors.white),
          SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedPhoto(String emoji) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFFF3F4F6),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 44)),
          ),
        ),
        Container(color: AppColors.white.withValues(alpha: 0.6)),
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 20, color: AppColors.crimson),
              SizedBox(height: 4),
              Text(
                'Register\nKarein',
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
      ],
    );
  }
}
