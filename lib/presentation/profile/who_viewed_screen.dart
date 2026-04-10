import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

// ── MOCK DATA ─────────────────────────────────────────────

class MockViewer {
  final String id;
  final String name;
  final String emoji;
  final String caste;
  final String city;
  final String profession;
  final String timeAgo;
  final bool isVerified;
  final bool isPremium;
  final bool hasViewedBefore;

  const MockViewer({
    required this.id,
    required this.name,
    required this.emoji,
    required this.caste,
    required this.city,
    required this.profession,
    required this.timeAgo,
    required this.isVerified,
    required this.isPremium,
    required this.hasViewedBefore,
  });
}

const List<MockViewer> _mockViewers = [
  MockViewer(
    id: 'v1', name: 'Rahul Sharma', emoji: '👨‍💻',
    caste: 'Brahmin', city: 'Delhi', profession: 'Engineer',
    timeAgo: '2 ghante pehle', isVerified: true,
    isPremium: false, hasViewedBefore: false,
  ),
  MockViewer(
    id: 'v2', name: 'Amit Gupta', emoji: '👨‍💼',
    caste: 'Kayastha', city: 'Mumbai', profession: 'Manager',
    timeAgo: '4 ghante pehle', isVerified: false,
    isPremium: true, hasViewedBefore: true,
  ),
  MockViewer(
    id: 'v3', name: 'Vikram Singh', emoji: '👨‍⚕️',
    caste: 'Rajput', city: 'Jaipur', profession: 'Doctor',
    timeAgo: '6 ghante pehle', isVerified: true,
    isPremium: false, hasViewedBefore: false,
  ),
  MockViewer(
    id: 'v4', name: 'Arjun Patel', emoji: '👨‍🏫',
    caste: 'Patel', city: 'Ahmedabad', profession: 'CA',
    timeAgo: '8 ghante pehle', isVerified: true,
    isPremium: true, hasViewedBefore: true,
  ),
  MockViewer(
    id: 'v5', name: 'Rohan Mehta', emoji: '👨‍🔬',
    caste: 'Brahmin', city: 'Pune', profession: 'Developer',
    timeAgo: 'Kal', isVerified: false,
    isPremium: false, hasViewedBefore: false,
  ),
  MockViewer(
    id: 'v6', name: 'Suresh Kumar', emoji: '👨‍🎓',
    caste: 'Kayastha', city: 'Noida', profession: 'Professor',
    timeAgo: 'Kal', isVerified: true,
    isPremium: false, hasViewedBefore: false,
  ),
  MockViewer(
    id: 'v7', name: 'Deepak Sharma', emoji: '👨‍💻',
    caste: 'Brahmin', city: 'Bangalore', profession: 'IIT Engineer',
    timeAgo: '2 din pehle', isVerified: true,
    isPremium: true, hasViewedBefore: true,
  ),
  MockViewer(
    id: 'v8', name: 'Karan Malhotra', emoji: '👨‍🎨',
    caste: 'Khatri', city: 'Chandigarh', profession: 'Designer',
    timeAgo: '2 din pehle', isVerified: false,
    isPremium: false, hasViewedBefore: false,
  ),
  MockViewer(
    id: 'v9', name: 'Nikhil Joshi', emoji: '👨‍💼',
    caste: 'Brahmin', city: 'Lucknow', profession: 'IAS Officer',
    timeAgo: '3 din pehle', isVerified: true,
    isPremium: false, hasViewedBefore: false,
  ),
  MockViewer(
    id: 'v10', name: 'Arun Nair', emoji: '👨‍🔧',
    caste: 'Nair', city: 'Kochi', profession: 'Architect',
    timeAgo: '3 din pehle', isVerified: false,
    isPremium: false, hasViewedBefore: false,
  ),
  MockViewer(
    id: 'v11', name: 'Raj Iyer', emoji: '👨‍⚕️',
    caste: 'Iyer', city: 'Chennai', profession: 'Surgeon',
    timeAgo: '4 din pehle', isVerified: true,
    isPremium: true, hasViewedBefore: true,
  ),
  MockViewer(
    id: 'v12', name: 'Mohit Verma', emoji: '👨‍🎓',
    caste: 'Brahmin', city: 'Agra', profession: 'Teacher',
    timeAgo: '5 din pehle', isVerified: false,
    isPremium: false, hasViewedBefore: false,
  ),
];

// ── SCREEN ────────────────────────────────────────────────

class WhoViewedScreen extends StatefulWidget {
  const WhoViewedScreen({super.key});

  @override
  State<WhoViewedScreen> createState() => _WhoViewedScreenState();
}

class _WhoViewedScreenState extends State<WhoViewedScreen> {
  bool _isPremiumUser = false;
  final List<MockViewer> _viewers = _mockViewers;
  final Set<String> _sentInterests = {};

  bool _isVisible(int index) => _isPremiumUser || index < 3;

  void _sendInterest(String id) {
    setState(() {
      if (_sentInterests.contains(id)) {
        _sentInterests.remove(id);
      } else {
        _sentInterests.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsBar(),
            if (!_isPremiumUser) _buildPremiumBanner(),
            Expanded(child: _buildViewersList()),
            if (!_isPremiumUser) _buildFreeBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.crimsonGradient),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Dekhi Kisne?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last 30 din ki activity',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Premium toggle for demo
          GestureDetector(
            onTap: () => setState(() => _isPremiumUser = !_isPremiumUser),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isPremiumUser
                    ? AppColors.gold.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: _isPremiumUser
                      ? AppColors.gold
                      : Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isPremiumUser ? '👑' : '🔒',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isPremiumUser ? 'Premium' : 'Free',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

  // ── STATS BAR ───────────────────────────────────────────

  Widget _buildStatsBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppColors.softShadow,
      ),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('124', 'Total Views',
                Icons.visibility_outlined, AppColors.crimson),
            _buildDivider(),
            _buildStatItem('48', 'Is Hafte',
                Icons.date_range_rounded, AppColors.info),
            _buildDivider(),
            _buildStatItem('12', 'Aaj',
                Icons.today_rounded, AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border,
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Center(child: Icon(icon, size: 18, color: color)),
        ),
        const SizedBox(height: 5),
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
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── PREMIUM BANNER ──────────────────────────────────────

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B0F0F), AppColors.crimson],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Premium Feature',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Dekhein kaun aapka profile\ndekh raha hai — naam aur details ke saath',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/premium'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Unlock Karein →',
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
          const SizedBox(width: 12),
          const Text('🔓', style: TextStyle(fontSize: 36)),
        ],
      ),
    );
  }

  // ── VIEWERS LIST ─────────────────────────────────────────

  Widget _buildViewersList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _viewers.length,
      itemBuilder: (context, index) =>
          _buildViewerTile(_viewers[index], index),
    );
  }

  Widget _buildViewerTile(MockViewer viewer, int index) {
    final visible = _isVisible(index);

    return GestureDetector(
      onTap: () {
        if (visible) {
          context.push('/profile/${viewer.id}');
        } else {
          context.push('/premium');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
          border: Border.all(
            color: viewer.hasViewedBefore
                ? AppColors.info.withValues(alpha: 0.15)
                : AppColors.border,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(viewer, visible),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo(viewer, visible)),
            const SizedBox(width: 8),
            _buildActions(viewer, visible),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(MockViewer viewer, bool visible) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: visible
                ? const Color(0xFFF3F4F6)
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: visible
              ? Center(
                  child: Text(viewer.emoji,
                      style: const TextStyle(fontSize: 26)))
              : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          size: 18, color: AppColors.muted),
                      SizedBox(height: 2),
                      Text(
                        '?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (viewer.isVerified && visible)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.verified_rounded,
                    size: 9, color: Colors.white),
              ),
            ),
          ),
        if (viewer.hasViewedBefore)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.replay_rounded,
                    size: 9, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(MockViewer viewer, bool visible) {
    if (visible) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewer.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${viewer.caste} • ${viewer.city}',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.work_outline_rounded,
                  size: 12, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(
                viewer.profession,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (viewer.hasViewedBefore) ...[
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.infoSurface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay_rounded,
                          size: 10, color: AppColors.info),
                      SizedBox(width: 3),
                      Text(
                        'Dobara Dekha',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Text(
                viewer.timeAgo,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ],
      );
    }

    // Blurred info for locked viewers
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 12,
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 12,
          width: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.push('/premium'),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.crimson.withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open_rounded,
                    size: 10, color: AppColors.crimson),
                SizedBox(width: 4),
                Text(
                  'Unlock Karein',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.crimson,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(MockViewer viewer, bool visible) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final isSent = _sentInterests.contains(viewer.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          viewer.timeAgo,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _sendInterest(viewer.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSent ? AppColors.crimson : AppColors.crimsonSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isSent ? '✓ Bheja' : '❤️ Interest',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSent ? Colors.white : AppColors.crimson,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── FREE BOTTOM BAR ──────────────────────────────────────

  Widget _buildFreeBottomBar() {
    final lockedCount = _viewers.length - 3;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔒 $lockedCount aur log dekh rahe hain',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Premium mein sab unlock ho jayega',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/premium'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.crimson,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Unlock ₹999',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
