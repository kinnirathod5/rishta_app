// lib/presentation/settings/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// FAQ DATA MODEL
// ─────────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  final String category;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

// ─────────────────────────────────────────────────────────
// FAQ DATA
// ─────────────────────────────────────────────────────────

const List<String> _categories = [
  'All',
  'Account',
  'Profile',
  'Premium',
  'Privacy',
  'Technical',
];

const List<_FaqItem> _faqs = [
  // Account
  _FaqItem(
    category: 'Account',
    question: 'OTP nahi aa raha — kya karein?',
    answer:
    'OTP aane mein 1-2 minute lag sakte hain.\n\n'
        '• Apna number check karein\n'
        '• Network connection check karein\n'
        '• 60 second baad "Resend OTP" tap karein\n'
        '• Spam/Blocked SMS folder check karein\n'
        '• Agar phir bhi na aaye toh hume email karein',
  ),
  _FaqItem(
    category: 'Account',
    question: 'Account delete karne ke baad data wapas milega?',
    answer:
    'Account delete karne ke baad:\n\n'
        '• 30 din ka grace period hota hai\n'
        '• Is period mein account recover ho sakta hai\n'
        '• 30 din ke baad poora data permanently delete\n'
        '• Deleted account recover nahi ho sakta\n\n'
        'Account recover karne ke liye same number se login karein.',
  ),
  _FaqItem(
    category: 'Account',
    question: 'Phone number change kaise karein?',
    answer:
    'Phone number change ke liye:\n\n'
        '1. Settings → Privacy pe jaao\n'
        '2. "Change Phone Number" tap karein\n'
        '3. Naya number enter karein\n'
        '4. OTP verify karein\n\n'
        'Note: Purane number pe verification OTP aayega.',
  ),

  // Profile
  _FaqItem(
    category: 'Profile',
    question: 'Verified badge kaise milega?',
    answer:
    'Verified badge ke liye:\n\n'
        '1. My Profile → ID Verification pe jaao\n'
        '2. Government ID upload karein\n'
        '   (Aadhar / PAN / Passport)\n'
        '3. ID ke saath selfie lein\n'
        '4. Submit karein\n\n'
        '24-48 ghante mein badge mil jaata hai.',
  ),
  _FaqItem(
    category: 'Profile',
    question: 'Photo approve nahi ho rahi — kya karein?',
    answer:
    'Photo reject hone ke common reasons:\n\n'
        '• Blurry ya dark photo\n'
        '• Group photo upload ki\n'
        '• Sunglasses wali photo\n'
        '• Heavy filter/edit wali photo\n'
        '• Chehra clearly nahi dikh raha\n\n'
        'Clear, bright, solo, unfiltered photo upload karein.',
  ),
  _FaqItem(
    category: 'Profile',
    question: 'Interest bheja par reply nahi aaya?',
    answer:
    'Reply nahi aaya toh:\n\n'
        '• Profile complete karein (score 80%+ rakhein)\n'
        '• Photos add karein — photos wale profiles pe '
        'zyada reply aate hain\n'
        '• About section achhi tarah fill karein\n'
        '• Match preference update karein\n\n'
        'Remember: Doosra person busy ho sakta hai. '
        'Patience rakhein! 😊',
  ),
  _FaqItem(
    category: 'Profile',
    question: 'Profile score kaise improve karein?',
    answer:
    'Profile score improve karne ke liye:\n\n'
        '• All 5 setup steps complete karein\n'
        '• Minimum 3 photos upload karein\n'
        '• About section 50+ words mein likhein\n'
        '• Partner preference fill karein\n'
        '• ID verification karein\n\n'
        '80%+ score = 3x zyada matches!',
  ),

  // Premium
  _FaqItem(
    category: 'Premium',
    question: 'Premium subscription cancel kaise karein?',
    answer:
    'Premium cancel karne ke liye:\n\n'
        '1. My Profile → Premium Plans pe jaao\n'
        '2. "Manage Subscription" tap karein\n'
        '3. "Cancel Subscription" select karein\n'
        '4. Reason select karein\n'
        '5. Confirm karein\n\n'
        'Note: Remaining days ka refund nahi milta. '
        'Premium expiry tak features available rahenge.',
  ),
  _FaqItem(
    category: 'Premium',
    question: 'Refund policy kya hai?',
    answer:
    'Hamare refund policy:\n\n'
        '• Technical issues pe full refund milta hai\n'
        '• Change of mind pe refund nahi milta\n'
        '• Partial period ka refund nahi milta\n'
        '• Refund ke liye 7 din ke andar contact karein\n\n'
        'Refund request ke liye:\n'
        'support@rishtaapp.com pe email karein',
  ),
  _FaqItem(
    category: 'Premium',
    question: 'Premium ke kya kya benefits hain?',
    answer:
    'Premium members ko milta hai:\n\n'
        '• Unlimited interest bhejne ka option\n'
        '• See who viewed your profile\n'
        '• Advanced filters (income, education)\n'
        '• Priority in search results\n'
        '• Read receipts in chat\n'
        '• Profile boost (weekly)\n'
        '• No ads\n\n'
        '3 plans available: Silver, Gold, Diamond',
  ),

  // Privacy
  _FaqItem(
    category: 'Privacy',
    question: 'Kisi ko block kaise karein?',
    answer:
    'Profile block karne ke 2 tarike:\n\n'
        'Tarika 1 (Profile se):\n'
        '1. Profile detail pe jaao\n'
        '2. "..." menu tap karein\n'
        '3. "Block" select karein\n\n'
        'Tarika 2 (Settings se):\n'
        'Settings → Blocked Users → Manage\n\n'
        'Blocked person aapki profile nahi dekh sakta.',
  ),
  _FaqItem(
    category: 'Privacy',
    question: 'Privacy settings kaise change karein?',
    answer:
    'Privacy settings ke liye:\n\n'
        '1. My Profile → Privacy Settings\n'
        '2. Profile visibility set karein\n'
        '   (Everyone / Matches Only / Hidden)\n'
        '3. Photo visibility control karein\n'
        '4. Phone number visibility set karein\n'
        '5. Online status show/hide karein\n\n'
        'Changes immediately apply hote hain.',
  ),
  _FaqItem(
    category: 'Privacy',
    question: 'Meri data kaise use hoti hai?',
    answer:
    'Aapka data hamara responsibility hai:\n\n'
        '• Data kabhi bhi sell nahi hoti\n'
        '• Sirf match suggestions ke liye use hoti hai\n'
        '• Government requirement pe hi share hoti hai\n'
        '• Account delete pe poora data erase hota hai\n\n'
        'Full privacy policy: rishtaapp.com/privacy',
  ),

  // Technical
  _FaqItem(
    category: 'Technical',
    question: 'App crash ho raha hai — kya karein?',
    answer:
    'App crash fix karne ke steps:\n\n'
        '1. App force close karein aur dobara open karein\n'
        '2. Phone restart karein\n'
        '3. App update check karein (Play Store)\n'
        '4. App cache clear karein:\n'
        '   Settings → Apps → RishtaApp → Clear Cache\n'
        '5. Agar phir bhi ho toh uninstall/reinstall\n\n'
        'Issue persist kare toh screenshot ke saath '
        'hume email karein.',
  ),
  _FaqItem(
    category: 'Technical',
    question: 'Chat messages nahi aa rahe?',
    answer:
    'Chat issue fix karne ke liye:\n\n'
        '• Internet connection check karein\n'
        '• App background refresh enable karein\n'
        '• Notifications permission check karein:\n'
        '  Phone Settings → Apps → RishtaApp → '
        'Notifications → Allow\n\n'
        'Agar dono online hain aur phir bhi nahi aa raha '
        'toh support ko contact karein.',
  ),
  _FaqItem(
    category: 'Technical',
    question: 'Match algorithm kaise kaam karta hai?',
    answer:
    'Matches is basis pe suggest hote hain:\n\n'
        '• Aapki partner preference (age, religion, city)\n'
        '• Religion / Caste compatibility\n'
        '• Location proximity\n'
        '• Education compatibility\n'
        '• Profile completeness score\n'
        '• Recent activity\n\n'
        'Tip: Partner preference regularly update karte '
        'rehein for better matches!',
  ),
];

// ─────────────────────────────────────────────────────────
// HELP & SUPPORT SCREEN
// ─────────────────────────────────────────────────────────

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState
    extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _query = '';
  String _selectedCategory = 'All';
  int? _expandedIndex;

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── FILTER ────────────────────────────────────────

  List<_FaqItem> get _filtered {
    return _faqs.where((f) {
      final matchCat = _selectedCategory == 'All' ||
          f.category == _selectedCategory;
      final matchQ = _query.isEmpty ||
          f.question
              .toLowerCase()
              .contains(_query.toLowerCase()) ||
          f.answer
              .toLowerCase()
              .contains(_query.toLowerCase());
      return matchCat && matchQ;
    }).toList();
  }

  void _onCategoryTap(String cat) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = cat;
      _expandedIndex = null;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white)),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10)),
        duration:
        const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollCtrl,
                  physics:
                  const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                        child: _buildSearchBar()),
                    SliverToBoxAdapter(
                        child:
                        _buildCategoryChips()),
                    SliverToBoxAdapter(
                        child:
                        _buildQuickActions()),
                    SliverToBoxAdapter(
                        child: _buildFaqHeader()),
                    SliverToBoxAdapter(
                        child: _buildFaqList()),
                    SliverToBoxAdapter(
                        child:
                        _buildContactCard()),
                    SliverToBoxAdapter(
                        child:
                        _buildAppVersion()),
                    const SliverToBoxAdapter(
                        child:
                        SizedBox(height: 40)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────

  Widget _buildHeader() {
    final topPad =
        MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(
          16, topPad + 10, 16, 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(10),
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
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Hum madad karne ke liye hain 🤝',
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
        // Chat badge
        GestureDetector(
          onTap: () => _showSnack(
              'Live chat jald aayega! 🚀'),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(100),
              border: Border.all(
                  color: Colors.white
                      .withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .chat_bubble_outline_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  'Live Chat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.crimson,
      padding:
      const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
              Colors.white.withOpacity(0.3)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(
              color: Colors.white, fontSize: 14),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search karein...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: Colors.white.withOpacity(0.7),
            ),
            suffixIcon: _query.isNotEmpty
                ? GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: Colors.white
                    .withOpacity(0.7),
              ),
            )
                : null,
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(
                vertical: 12),
          ),
          onChanged: (v) {
            setState(() {
              _query = v;
              _expandedIndex = null;
            });
          },
        ),
      ),
    );
  }

  // ── CATEGORY CHIPS ────────────────────────────────

  Widget _buildCategoryChips() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children:
          _categories.map((cat) {
            final isSelected =
                _selectedCategory == cat;
            return GestureDetector(
              onTap: () => _onCategoryTap(cat),
              child: AnimatedContainer(
                duration: const Duration(
                    milliseconds: 200),
                margin: const EdgeInsets.only(
                    right: 8),
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.crimson
                      : AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.crimson
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : AppColors.inkSoft,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── QUICK ACTIONS ─────────────────────────────────

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Help',
              style: AppTextStyles.h5),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _QuickActionCard(
                  emoji: '💬',
                  title: 'Live Chat',
                  subtitle: 'Online 9am–9pm',
                  color: AppColors.info,
                  bgColor: AppColors.infoSurface,
                  onTap: () => _showSnack(
                      'Live chat jald aayega! 🚀'),
                )),
            const SizedBox(width: 10),
            Expanded(
                child: _QuickActionCard(
                  emoji: '📧',
                  title: 'Email',
                  subtitle:
                  'support@rishtaapp.com',
                  color: AppColors.gold,
                  bgColor: AppColors.goldSurface,
                  onTap: () => _showSnack(
                      'Email: support@rishtaapp.com'),
                )),
            const SizedBox(width: 10),
            Expanded(
                child: _QuickActionCard(
                  emoji: '📱',
                  title: 'WhatsApp',
                  subtitle: 'Jald aayega',
                  color: AppColors.success,
                  bgColor: AppColors.successSurface,
                  onTap: () => _showSnack(
                      'WhatsApp support jald aayega! 🚀'),
                )),
          ]),
        ],
      ),
    );
  }

  // ── FAQ HEADER ────────────────────────────────────

  Widget _buildFaqHeader() {
    final count = _filtered.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          16, 24, 16, 10),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Text('❓',
                style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Aksar Poochhe Jaane Wale Sawaal',
                style: AppTextStyles.h5),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius:
              BorderRadius.circular(100),
            ),
            child: Text(
              '$count sawaal',
              style: AppTextStyles.labelSmall
                  .copyWith(
                  color: AppColors.crimson),
            ),
          ),
        ],
      ),
    );
  }

  // ── FAQ LIST ──────────────────────────────────────

  Widget _buildFaqList() {
    final faqs = _filtered;

    if (faqs.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Text('🔍',
                style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Koi sawaal nahi mila',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 6),
            Text(
              '"$_query" ke liye koi result nahi',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() {
                  _query = '';
                  _selectedCategory = 'All';
                });
              },
              child: Text(
                'Sab sawaal dikhao',
                style: AppTextStyles.labelMedium
                    .copyWith(
                  color: AppColors.crimson,
                  decoration:
                  TextDecoration.underline,
                  decorationColor:
                  AppColors.crimson,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: List.generate(faqs.length,
                  (i) {
                final faq = faqs[i];
                final isExpanded = _expandedIndex == i;
                final isLast = i == faqs.length - 1;

                return _FaqTile(
                  faq: faq,
                  index: i,
                  isExpanded: isExpanded,
                  isLast: isLast,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _expandedIndex =
                      isExpanded ? null : i;
                    });
                  },
                );
              }),
        ),
      ),
    );
  }

  // ── CONTACT CARD ──────────────────────────────────

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B0F0F),
            AppColors.crimson,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('🤝',
                style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aur Madad Chahiye?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Team 24/7 available hai',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _ContactButton(
                icon: Icons.email_outlined,
                label: 'Email',
                onTap: () => _showSnack(
                    'Email: support@rishtaapp.com'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ContactButton(
                icon: Icons
                    .chat_bubble_outline_rounded,
                label: 'WhatsApp',
                onTap: () => _showSnack(
                    'WhatsApp support jald aayega!'),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Response time: 2-4 ghante (9am–9pm)',
              style: TextStyle(
                fontSize: 11,
                color:
                Colors.white.withOpacity(0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── APP VERSION ───────────────────────────────────

  Widget _buildAppVersion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.crimsonGradient,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('💍',
                  style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.labelLarge,
                ),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            'Up to date ✓',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.success),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// FAQ TILE WIDGET
// ─────────────────────────────────────────────────────────

class _FaqTile extends StatelessWidget {
  final _FaqItem faq;
  final int index;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  const _FaqTile({
    required this.faq,
    required this.index,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Question row
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration:
            const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isExpanded
                  ? AppColors.crimsonSurface
                  : AppColors.white,
              borderRadius: !isExpanded && isLast
                  ? const BorderRadius.vertical(
                  bottom: Radius.circular(14))
                  : BorderRadius.zero,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // Index number
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? AppColors.crimson
                        : AppColors.ivoryDark,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isExpanded
                        ? const Icon(
                      Icons.remove_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                        : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.question,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isExpanded
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isExpanded
                              ? AppColors.crimson
                              : AppColors.ink,
                          height: 1.4,
                        ),
                      ),
                      if (!isExpanded) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                            AppColors.ivoryDark,
                            borderRadius:
                            BorderRadius
                                .circular(100),
                          ),
                          child: Text(
                            faq.category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded
                      ? Icons
                      .keyboard_arrow_up_rounded
                      : Icons
                      .keyboard_arrow_down_rounded,
                  size: 20,
                  color: isExpanded
                      ? AppColors.crimson
                      : AppColors.muted,
                ),
              ],
            ),
          ),
        ),

        // Answer
        AnimatedCrossFade(
          firstChild:
          const SizedBox(width: double.infinity),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                56, 4, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius: isLast
                  ? const BorderRadius.vertical(
                  bottom: Radius.circular(14))
                  : BorderRadius.zero,
            ),
            child: Text(
              faq.answer,
              style: AppTextStyles.bodySmall
                  .copyWith(
                color: AppColors.inkSoft,
                height: 1.8,
              ),
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration:
          const Duration(milliseconds: 250),
        ),

        if (!isLast)
          const Divider(
              height: 1, color: AppColors.border),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// QUICK ACTION CARD WIDGET
// ─────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withOpacity(0.2)),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(emoji,
                style:
                const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// CONTACT BUTTON WIDGET
// ─────────────────────────────────────────────────────────

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color:
              Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}