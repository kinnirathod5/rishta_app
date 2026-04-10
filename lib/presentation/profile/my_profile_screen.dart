import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {

  // ── FIXED: Preview ab navigate karta hai ──────────────
  void _previewProfile() => context.push('/profile-preview');

  void _editPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Photo edit jald aayega! 🚀'),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog() {
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
            ),
            onPressed: () => context.go('/welcome'),
            child: const Text('Logout Karo'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    // FIXED: Navigate to delete-account screen instead of inline dialog
    context.push('/delete-account');
  }

  void _showDeleteDialog() {
    // FIXED: Navigate to delete-account screen
    context.push('/delete-account');
  }

  // ── PROFILE HEADER ────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      decoration:
      const BoxDecoration(gradient: AppColors.crimsonGradient),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  // FIXED: Preview button navigate karta hai
                  GestureDetector(
                    onTap: _previewProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.notifications_outlined,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.goldLight, width: 3),
                  ),
                  child: const Center(
                    child: Text('👩',
                        style: TextStyle(fontSize: 44)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _editPhoto,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 2.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              const Text(
                'Priya Sharma',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12,
                        color: Colors.white.withOpacity(0.70)),
                    const SizedBox(width: 4),
                    Text(
                      'Delhi • Brahmin',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.work_outline_rounded,
                        size: 12,
                        color: Colors.white.withOpacity(0.70)),
                    const SizedBox(width: 5),
                    Text(
                      'Software Engineer • TCS',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.80)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── SCORE CARD ────────────────────────────────────────
  Widget _buildScoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Score',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '78% Complete',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '78%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.crimson,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 8,
                  width: constraints.maxWidth * 0.78,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.crimson, AppColors.crimsonLight],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pura karo score badhao:',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            children: [
              _buildScoreItem('🏠 Horoscope add karo', '+15%'),
              _buildScoreItem('📸 2 aur photos', '+7%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String score) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.inkSoft)),
          const SizedBox(width: 5),
          Text(
            score,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS ROW ─────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildStatBox('124', 'Profile\nViews',
              Icons.visibility_outlined, AppColors.crimson,
                  () => context.push('/who-viewed')),
          _buildStatBox('18', 'Interests\nAaye',
              Icons.favorite_outlined, const Color(0xFFE91E63),
                  () => context.go('/interests')),
          _buildStatBox('3', 'Connected',
              Icons.handshake_outlined, AppColors.success,
                  () => context.go('/interests')),
          _buildStatBox('6', 'Shortlisted',
              Icons.bookmark_rounded, AppColors.gold,
                  () => context.push('/shortlisted')),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label,
      IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
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
                  color: color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Icon(icon, size: 18, color: color)),
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
                style: const TextStyle(
                    fontSize: 11, color: AppColors.muted, height: 1.3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── EDIT ROW ──────────────────────────────────────────
  Widget _buildEditRow(
      String emoji,
      String title,
      String subtitle,
      bool isComplete,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.border.withOpacity(0.5)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isComplete
                    ? AppColors.successSurface
                    : AppColors.crimsonSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isComplete) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldSurface,
                      borderRadius: BorderRadius.circular(100),
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
                ],
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.muted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSections() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border:
              Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Edit Karo',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Container(
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
              ],
            ),
          ),
          _buildEditRow('📋', 'Basic Info',
              'Naam, DOB, height, city', true,
                  () => context.push('/setup/step1')),
          _buildEditRow('🛕', 'Religion & Caste',
              'Hindu • Brahmin • Kashyap', true,
                  () => context.push('/setup/step2')),
          _buildEditRow('🎓', 'Education & Career',
              'B.Tech • TCS • 8-12 LPA', true,
                  () => context.push('/setup/step3')),
          _buildEditRow('👨‍👩‍👦', 'Family Info',
              'Sanyukt parivar • Agra', true,
                  () => context.push('/setup/step4')),
          _buildEditRow('📸', 'Photos',
              '6 photos uploaded', true,
                  () => context.push('/setup/step5')),
          // FIXED: Horoscope navigate karta hai
          _buildEditRow('⭐', 'Horoscope',
              'Abhi add nahi kiya', false,
                  () => context.push('/horoscope')),
          // FIXED: Partner Preference navigate karta hai
          _buildEditRow('💝', 'Partner Preference',
              'Age 26-34 • Delhi • Graduate+', true,
                  () => context.push('/partner-preference')),
          // FIXED: ID Verification navigate karta hai
          _buildEditRow('🔐', 'ID Verification',
              'Verify karein — badge milega', false,
                  () => context.push('/id-verification')),
        ],
      ),
    );
  }

  // ── SETTINGS ROW ──────────────────────────────────────
  Widget _buildSettingRow(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap, {
        bool isGold = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.border.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                isGold ? AppColors.goldSurface : AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: isGold ? AppColors.gold : AppColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isGold ? AppColors.gold : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettings() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border:
              Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          _buildSettingRow(
              Icons.notifications_outlined,
              'Notifications',
              'Manage alerts',
                  () => context.push('/notifications')),
          _buildSettingRow(
              Icons.lock_outline_rounded,
              'Privacy Settings',
              'Who can see your profile',
                  () => context.push('/privacy')),
          _buildSettingRow(
              Icons.workspace_premium_rounded,
              'Premium Plans',
              'Unlock all features',
                  () => context.push('/premium'),
              isGold: true),
          // FIXED: Help & Support navigate karta hai
          _buildSettingRow(
              Icons.help_outline_rounded,
              'Help & Support',
              'FAQ aur contact us',
                  () => context.push('/help-support')),
          _buildSettingRow(
              Icons.block_rounded,
              'Blocked Users',
              'Block kiye hue log',
                  () => context.push('/blocked-users')),
          _buildSettingRow(
              Icons.info_outline_rounded,
              'App ke Baare Mein',
              'Version 1.0.0',
                  () {}),
        ],
      ),
    );
  }

  // ── DANGER ZONE ───────────────────────────────────────
  Widget _buildDangerRow(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap, {
        bool isRed = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isRed ? AppColors.errorSurface : null,
          border: Border(
            bottom: BorderSide(
                color: AppColors.border.withOpacity(0.5)),
          ),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: isRed ? AppColors.error : AppColors.inkSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isRed ? AppColors.error : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.15)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: AppColors.error.withOpacity(0.10)),
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
          _buildDangerRow(
              Icons.logout_rounded,
              'Logout Karo',
              'Apne account se logout',
              _showLogoutDialog),
          // FIXED: Deactivate → delete-account screen
          _buildDangerRow(
              Icons.pause_circle_outline_rounded,
              'Account Deactivate Karo',
              'Temporarily profile hide karo',
                  () => context.push('/delete-account')),
          // FIXED: Delete → delete-account screen
          _buildDangerRow(
              Icons.delete_forever_rounded,
              'Account Delete Karo',
              'Permanently account hatao',
                  () => context.push('/delete-account'),
              isRed: true),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildProfileHeader(),
                  Positioned(
                    bottom: -30,
                    left: 16,
                    right: 16,
                    child: _buildScoreCard(),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildEditSections()),
            SliverToBoxAdapter(child: _buildQuickSettings()),
            SliverToBoxAdapter(child: _buildDangerZone()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}