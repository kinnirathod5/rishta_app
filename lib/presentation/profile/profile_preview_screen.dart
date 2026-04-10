import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../home/profile_detail_screen.dart';
import '../home/home_screen.dart';

class ProfilePreviewScreen extends StatefulWidget {
  const ProfilePreviewScreen({super.key});

  @override
  State<ProfilePreviewScreen> createState() =>
      _ProfilePreviewScreenState();
}

class _ProfilePreviewScreenState
    extends State<ProfilePreviewScreen> {
  int _currentTab = 0;

  // Mock current user profile (same structure as MockProfile)
  final MockProfile _myProfile = const MockProfile(
    id: 'me',
    name: 'Priya Sharma',
    age: 26,
    caste: 'Brahmin',
    religion: 'Hindu',
    city: 'Delhi',
    education: 'B.Tech',
    profession: 'Software Engineer',
    emoji: '👩',
    isVerified: true,
    isPremium: false,
    height: "5'4\"",
    about:
    'Software engineer at TCS hoon. Delhi mein rehti hoon. '
        'Family-oriented hoon, traditional values ke saath modern thinking. '
        'Hobbies mein reading, cooking aur travel pasand hai. '
        'Life partner mein honesty aur respect chahiye.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          // ── MAIN PROFILE CONTENT ──────────────────
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.crimson,
                automaticallyImplyLeading: false,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(
                        right: 16, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: AppColors.gold.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.goldLight),
                        SizedBox(width: 5),
                        Text(
                          'Preview Mode',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo area
                      Container(
                        color: AppColors.crimsonSurface,
                        child: const Center(
                          child: Text('👩',
                              style: TextStyle(fontSize: 120)),
                        ),
                      ),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Profile info
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${_myProfile.name}, ${_myProfile.age}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius:
                                    BorderRadius.circular(
                                        100),
                                  ),
                                  child: const Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      Icon(
                                          Icons.verified_rounded,
                                          size: 12,
                                          color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                            FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 14,
                                    color: Colors.white
                                        .withOpacity(0.8)),
                                const SizedBox(width: 4),
                                Text(
                                  "${_myProfile.city} • ${_myProfile.religion}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white
                                        .withOpacity(0.85),
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
              ),

              // Quick info chips
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickChip(
                            Icons.school_outlined,
                            _myProfile.education),
                        _buildQuickChip(
                            Icons.work_outline_rounded,
                            _myProfile.profession),
                        _buildQuickChip(Icons.height_rounded,
                            _myProfile.height),
                        _buildQuickChip(
                            Icons.temple_hindu_outlined,
                            _myProfile.caste),
                        _buildQuickChip(
                            Icons.favorite_border_rounded,
                            'Never Married'),
                      ],
                    ),
                  ),
                ),
              ),

              // Tabs
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      // Tab bar
                      Container(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 4),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            'Baare Mein',
                            'Details',
                            'Family',
                            'Partner Pref'
                          ]
                              .asMap()
                              .entries
                              .map((e) {
                            final isActive =
                                _currentTab == e.key;
                            return GestureDetector(
                              onTap: () => setState(
                                      () => _currentTab = e.key),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isActive
                                          ? AppColors.crimson
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: isActive
                                        ? AppColors.crimson
                                        : AppColors.muted,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab content
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildTabContent(),
                ),
              ),

              // Bottom spacing for action bar
              const SliverToBoxAdapter(
                  child: SizedBox(height: 100)),
            ],
          ),

          // ── PREVIEW BANNER (top) ──────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                    16, 60, 16, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.ink.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Yeh aapki profile hai jaise doosre dekhte hain",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BOTTOM PREVIEW BAR ────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 +
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  // Profile score
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.ivory,
                        borderRadius:
                        BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Profile Score",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                "78%",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.crimson,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(
                                      100),
                                  child: LinearProgressIndicator(
                                    value: 0.78,
                                    backgroundColor:
                                    AppColors.ivoryDark,
                                    valueColor:
                                    const AlwaysStoppedAnimation<
                                        Color>(
                                        AppColors.crimson),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Edit Profile button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.crimson,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 16,
                                color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "Profile Edit Karo",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildQuickChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.crimson),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildAboutTab();
      case 1:
        return _buildDetailsTab();
      case 2:
        return _buildFamilyTab();
      case 3:
        return _buildPartnerPrefTab();
      default:
        return _buildAboutTab();
    }
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Apne Baare Mein",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _myProfile.about,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.inkSoft,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Photos",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                width: 80,
                height: 100,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    index == 0 ? '👩' : '📸',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailSection("Personal Info", [
            _buildDetailRow(Icons.person_outline, "Naam",
                _myProfile.name),
            _buildDetailRow(Icons.cake_outlined, "Umar",
                "${_myProfile.age} saal"),
            _buildDetailRow(Icons.height_rounded, "Lambai",
                _myProfile.height),
            _buildDetailRow(Icons.location_on_outlined,
                "Sheher", _myProfile.city),
            _buildDetailRow(Icons.language_rounded,
                "Matrubhasha", "Hindi"),
            _buildDetailRow(Icons.favorite_outline,
                "Vivah Status", "Kabhi Shaadi Nahi Hui"),
          ]),
          const SizedBox(height: 16),
          _buildDetailSection("Shiksha & Kaam", [
            _buildDetailRow(Icons.school_outlined, "Shiksha",
                _myProfile.education),
            _buildDetailRow(Icons.work_outline_rounded,
                "Profession", _myProfile.profession),
            _buildDetailRow(
                Icons.business_outlined, "Company", "TCS"),
            _buildDetailRow(Icons.currency_rupee_rounded,
                "Income", "8-12 LPA"),
          ]),
          const SizedBox(height: 16),
          _buildDetailSection("Religion & Caste", [
            _buildDetailRow(Icons.temple_hindu_outlined,
                "Dharm", _myProfile.religion),
            _buildDetailRow(Icons.people_outline_rounded,
                "Jaati", _myProfile.caste),
            _buildDetailRow(
                Icons.family_restroom_outlined, "Gotra",
                "Kashyap"),
            _buildDetailRow(
                Icons.stars_outlined, "Manglik", "Nahi"),
          ]),
        ],
      ),
    );
  }

  Widget _buildFamilyTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailSection("Parivar ki Jankari", [
            _buildDetailRow(Icons.home_outlined,
                "Parivar Prakar", "Sanyukt Parivar"),
            _buildDetailRow(Icons.favorite_outline,
                "Parivar ki Soch", "Madhyam"),
            _buildDetailRow(Icons.location_city_outlined,
                "Parivar ka Sheher", "Agra"),
            _buildDetailRow(Icons.people_outline_rounded,
                "Parivar ki Sthiti", "Madhyam Varg"),
          ]),
          const SizedBox(height: 16),
          _buildDetailSection("Mata-Pita", [
            _buildDetailRow(Icons.person_outline,
                "Pita ka Kaam", "Business"),
            _buildDetailRow(Icons.person_outline,
                "Mata ka Kaam", "Homemaker"),
            _buildDetailRow(
                Icons.people_outline_rounded, "Bhai", "1"),
            _buildDetailRow(
                Icons.people_outline_rounded, "Behen", "0"),
          ]),
        ],
      ),
    );
  }

  Widget _buildPartnerPrefTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.gold.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💝',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Chahte hain ki partner honest aur caring ho. "
                        "Age 26-34, well-educated, family-oriented. "
                        "Location preference: Delhi NCR ya Mumbai.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSoft,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailSection("Partner ki Preference", [
            _buildDetailRow(
                Icons.cake_outlined, "Umar", "26-34 saal"),
            _buildDetailRow(Icons.height_rounded, "Lambai",
                "5'6\" - 6'2\""),
            _buildDetailRow(Icons.temple_hindu_outlined,
                "Dharm", "Hindu"),
            _buildDetailRow(Icons.people_outline_rounded,
                "Jaati", "Brahmin, Kayastha"),
            _buildDetailRow(
                Icons.school_outlined, "Shiksha", "Graduate+"),
            _buildDetailRow(Icons.currency_rupee_rounded,
                "Income", "6 LPA+"),
            _buildDetailRow(Icons.location_on_outlined,
                "Location", "Delhi, Mumbai"),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.border)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.muted),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}