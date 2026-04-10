import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'home_screen.dart'; // To import MockProfile and mockProfiles

class ProfileDetailScreen extends StatefulWidget {
  final String uid;
  final MockProfile? profile;

  const ProfileDetailScreen({
    super.key,
    required this.uid,
    this.profile,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  int _currentTab = 0;
  bool _isShortlisted = false;
  bool _interestSent = false;
  bool _isLoadingInterest = false;
  final bool _isLoading = false;

  late MockProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile ?? mockProfiles.firstWhere(
      (p) => p.id == widget.uid,
      orElse: () => mockProfiles.first,
    );
  }

  void _toggleShortlist() {
    setState(() {
      _isShortlisted = !_isShortlisted;
    });
  }

  void _sendInterest() async {
    setState(() => _isLoadingInterest = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _isLoadingInterest = false;
      _interestSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.favorite_rounded, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text("Interest bhej diya! 💌"),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
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
              _buildOptionTile(
                Icons.share_outlined,
                'Profile Share Karo',
                AppColors.crimson,
                () => Navigator.pop(context),
              ),
              _buildOptionTile(
                Icons.block_rounded,
                'Block Karo',
                AppColors.error,
                () => Navigator.pop(context),
              ),
              _buildOptionTile(
                Icons.flag_outlined,
                'Report Karo',
                AppColors.error,
                () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Icon(icon, size: 20, color: color)),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeroSection(),
              SliverToBoxAdapter(child: _buildQuickInfoChips()),
              SliverToBoxAdapter(child: _buildTabSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildBottomActionBar(),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.crimson,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _toggleShortlist,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 18,
                color: _isShortlisted ? AppColors.gold : Colors.white,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _showMoreOptions,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.more_vert_rounded, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // PHOTO AREA
            Container(
              color: _profile.isVerified ? AppColors.crimsonSurface : const Color(0xFFF3F4F6),
              child: Center(
                child: Text(_profile.emoji, style: const TextStyle(fontSize: 120)),
              ),
            ),
            // GRADIENT OVERLAY
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // PROFILE INFO
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${_profile.name}, ${_profile.age}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (_profile.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                "Verified",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(
                        "${_profile.city} • ${_profile.religion}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoChips() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickChip(Icons.school_outlined, _profile.education),
            _buildQuickChip(Icons.work_outline_rounded, _profile.profession),
            _buildQuickChip(Icons.height_rounded, _profile.height),
            _buildQuickChip(Icons.temple_hindu_outlined, _profile.caste),
            _buildQuickChip(Icons.favorite_border_rounded, 'Never Married'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.crimson),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          // TAB BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
            ),
            child: Row(
              children: [
                _buildTabItem(0, 'Baare Mein'),
                _buildTabItem(1, 'Details'),
                _buildTabItem(2, 'Family'),
                _buildTabItem(3, 'Partner'),
              ],
            ),
          ),
          // TAB CONTENT
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _getTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    bool active = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.crimson : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? AppColors.crimson : AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_currentTab) {
      case 0: return _buildAboutTab();
      case 1: return _buildDetailsTab();
      case 2: return _buildFamilyTab();
      case 3: return _buildPartnerPrefTab();
      default: return _buildAboutTab();
    }
  }

  Widget _buildAboutTab() {
    return Padding(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Apne Baare Mein", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 8),
          Text(
            _profile.about.length < 50 
              ? "Software engineer at TCS hoon. Delhi mein rehti hoon. Family-oriented hoon, traditional values ke saath modern thinking. Hobbies mein reading, cooking aur travel pasand hai. Life partner mein honesty aur respect chahiye."
              : _profile.about,
            style: const TextStyle(fontSize: 14, color: AppColors.inkSoft, height: 1.7),
          ),
          const SizedBox(height: 20),
          const Text("Photos", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  height: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Text(_profile.emoji, style: const TextStyle(fontSize: 36))),
                      if (index > 0)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.1),
                              child: const Center(
                                child: Icon(Icons.lock_outline, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection("Personal Info", [
            _buildDetailRow(Icons.person_outline, "Naam", _profile.name),
            _buildDetailRow(Icons.cake_outlined, "Umar", "${_profile.age} saal"),
            _buildDetailRow(Icons.height_rounded, "Lambai", _profile.height),
            _buildDetailRow(Icons.location_on_outlined, "Sheher", _profile.city),
            _buildDetailRow(Icons.language_rounded, "Matrubhasha", "Hindi"),
            _buildDetailRow(Icons.favorite_outline, "Vivah Status", "Kabhi Shaadi Nahi Hui"),
          ]),
          const SizedBox(height: 16),
          _buildDetailSection("Shiksha & Kaam", [
            _buildDetailRow(Icons.school_outlined, "Shiksha", _profile.education),
            _buildDetailRow(Icons.work_outline_rounded, "Profession", _profile.profession),
            _buildDetailRow(Icons.business_outlined, "Company", "TCS"),
            _buildDetailRow(Icons.currency_rupee_rounded, "Income", "8-12 LPA"),
          ]),
          const SizedBox(height: 16),
          _buildDetailSection("Religion & Caste", [
            _buildDetailRow(Icons.temple_hindu_outlined, "Dharm", _profile.religion),
            _buildDetailRow(Icons.people_outline_rounded, "Jaati", _profile.caste),
            _buildDetailRow(Icons.family_restroom_outlined, "Gotra", "Kashyap"),
            _buildDetailRow(Icons.stars_outlined, "Manglik", "Nahi"),
          ]),
        ],
      ),
    );
  }

  Widget _buildFamilyTab() {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection("Parivar ki Jankari", [
            _buildDetailRow(Icons.home_outlined, "Parivar Prakar", "Sanyukt Parivar"),
            _buildDetailRow(Icons.favorite_outline, "Parivar ki Soch", "Madhyam"),
            _buildDetailRow(Icons.location_city_outlined, "Parivar ka Sheher", "Agra"),
            _buildDetailRow(Icons.people_outline_rounded, "Parivar ki Sthiti", "Madhyam Varg"),
          ]),
          const SizedBox(height: 16),
          _buildDetailSection("Mata-Pita", [
            _buildDetailRow(Icons.person_outline, "Pita ka Kaam", "Business"),
            _buildDetailRow(Icons.person_outline, "Mata ka Kaam", "Homemaker"),
            _buildDetailRow(Icons.people_outline_rounded, "Bhai", "1"),
            _buildDetailRow(Icons.people_outline_rounded, "Behen", "0"),
          ]),
        ],
      ),
    );
  }

  Widget _buildPartnerPrefTab() {
    return Padding(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💝', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Chahte hain ki partner honest aur caring ho. Age 26-34, well-educated, family-oriented. Location preference: Delhi NCR ya Mumbai.",
                    style: TextStyle(fontSize: 14, color: AppColors.inkSoft, height: 1.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailSection("Partner ki Preference", [
            _buildDetailRow(Icons.cake_outlined, "Umar", "26-34 saal"),
            _buildDetailRow(Icons.height_rounded, "Lambai", "5'6\" - 6'2\""),
            _buildDetailRow(Icons.temple_hindu_outlined, "Dharm", "Hindu"),
            _buildDetailRow(Icons.people_outline_rounded, "Jaati", "Brahmin, Kayastha"),
            _buildDetailRow(Icons.school_outlined, "Shiksha", "Graduate+"),
            _buildDetailRow(Icons.currency_rupee_rounded, "Income", "6 LPA+"),
            _buildDetailRow(Icons.location_on_outlined, "Location", "Delhi, Mumbai"),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
          ),
          ...rows.asMap().entries.map((entry) {
            int idx = entry.key;
            Widget row = entry.value;
            if (idx == rows.length - 1) return row;
            return Column(
              children: [
                row,
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.muted),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.ink, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
        child: Row(
          children: [
            // SHORTLIST BUTTON
            GestureDetector(
              onTap: _toggleShortlist,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _isShortlisted ? AppColors.goldSurface : AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isShortlisted ? AppColors.gold.withValues(alpha: 0.3) : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isShortlisted ? AppColors.gold : AppColors.muted,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // INTEREST BUTTON
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_interestSent && !_isLoadingInterest) _sendInterest();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _interestSent ? AppColors.success : AppColors.crimson,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isLoadingInterest
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _interestSent ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _interestSent ? "Interest Bheja ✓" : "❤️ Interest Bhejo",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // CHAT BUTTON
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: const Center(
                child: Icon(Icons.chat_bubble_outline_rounded, size: 22, color: AppColors.info),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
