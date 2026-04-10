import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController =
  TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'OTP nahi aa raha hai — kya karein?',
      'a':
      'OTP aane mein 1-2 minute lag sakte hain. Agar na aaye toh:\n• Apna number check karein\n• Network connection check karein\n• 60 second baad "Dobara Bhejo" tap karein\n• Agar phir bhi na aaye toh hume contact karein',
    },
    {
      'q': 'Profile verified badge kaise milega?',
      'a':
      'Verified badge ke liye:\n1. My Profile → ID Verification pe jaao\n2. Government ID upload karein (Aadhar/PAN/Passport)\n3. Selfie lein document ke saath\n4. Submit karein\n5. 24-48 ghante mein badge mil jaata hai',
    },
    {
      'q': 'Photo approve nahi ho rahi — kya karna hai?',
      'a':
      'Photo reject hone ke reasons:\n• Blurry ya dark photo\n• Group photo\n• Sunglasses wali photo\n• Edited/filtered photo\n\nClear, bright, solo photo upload karein. Chehra clearly dikhna chahiye.',
    },
    {
      'q': 'Interest bheja par reply nahi aaya?',
      'a':
      'Agar reply nahi aaya toh:\n• Profile complete karein — better profiles pe zyada reply aate hain\n• Photos add karein\n• About section fill karein\n• Alag profiles try karein\n\nYaad rakho: Doosra person busy ho sakta hai.',
    },
    {
      'q': 'Premium subscription cancel kaise karein?',
      'a':
      'Premium cancel karne ke liye:\n1. My Profile → Premium Plans pe jaao\n2. "Manage Subscription" tap karein\n3. "Cancel Subscription" select karein\n\nNote: Remaining days ka refund nahi milta. Premium expiry tak features available rahenge.',
    },
    {
      'q': 'Kisi ko block karna hai — kaise karein?',
      'a':
      'Profile block karne ke 2 tarike:\n1. Profile detail pe jaao → "..." menu → "Block Karo"\n2. Settings → Blocked Users se manage karein\n\nBlocked person aapki profile nahi dekh sakta aur contact nahi kar sakta.',
    },
    {
      'q': 'Account delete karne ke baad data wapas mil sakta hai?',
      'a':
      'Account delete karne ke baad:\n• 30 din ka grace period hota hai\n• Is period mein account recover ho sakta hai\n• 30 din ke baad poora data permanently delete ho jaata hai\n• Deleted account recover nahi ho sakta',
    },
    {
      'q': 'Privacy settings kaise change karein?',
      'a':
      'Privacy settings ke liye:\n1. My Profile → Privacy Settings tap karein\n2. Profile visibility set karein\n3. Photo visibility control karein\n4. Phone number visibility set karein\n5. Online status show/hide karein',
    },
    {
      'q': 'Match algorithm kaise kaam karta hai?',
      'a':
      'Matches is basis pe suggest hote hain:\n• Aapki partner preference\n• Religion/Caste match\n• Location proximity\n• Age range\n• Education compatibility\n• Profile completeness\n\nZyada complete profile = better matches!',
    },
    {
      'q': 'Refund policy kya hai?',
      'a':
      'Hamare refund policy:\n• Technical issues pe full refund\n• Change of mind pe refund nahi\n• Partial period ka refund nahi milta\n• Refund ke liye 7 din ke andar contact karein\n\nEmail: support@rishtaapp.com',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs.where((faq) {
      return faq['q']!
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          faq['a']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildQuickContactSection(),
                    _buildFaqSection(),
                    _buildContactSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Help & Support",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  "Hum madad karne ke liye hain",
                  style: TextStyle(
                      fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded,
                size: 18, color: AppColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) =>
                    setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "FAQ search karein...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: AppColors.disabled, fontSize: 14),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.ink),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── QUICK CONTACT ──────────────────────────────────
  Widget _buildQuickContactSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickContact(
              '💬',
              'Live Chat',
              'Abhi available',
              AppColors.infoSurface,
              AppColors.info,
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                    const Text('Live chat jald aayega! 🚀'),
                    backgroundColor: AppColors.ink,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickContact(
              '📧',
              'Email Karein',
              'support@rishtaapp.com',
              AppColors.goldSurface,
              AppColors.gold,
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Email: support@rishtaapp.com'),
                    backgroundColor: AppColors.ink,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContact(
      String emoji,
      String title,
      String subtitle,
      Color bgColor,
      Color textColor,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: textColor.withOpacity(0.2)),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── FAQ SECTION ────────────────────────────────────
  Widget _buildFaqSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_outlined,
                  size: 18, color: AppColors.crimson),
              const SizedBox(width: 8),
              const Text(
                "Aksar Poochhe Jaane Wale Sawaal",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${_filteredFaqs.length} sawaal",
            style: TextStyle(
                fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),

          if (_filteredFaqs.isEmpty)
            Center(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Text('🔍',
                        style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(
                      "Koi sawaal nahi mila",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: List.generate(
                    _filteredFaqs.length, (index) {
                  final faq = _filteredFaqs[index];
                  final isExpanded = _expandedIndex == index;
                  final isLast =
                      index == _filteredFaqs.length - 1;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _expandedIndex =
                          isExpanded ? null : index;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? AppColors.crimsonSurface
                                : AppColors.white,
                            borderRadius: isLast && !isExpanded
                                ? const BorderRadius.vertical(
                                bottom: Radius.circular(14))
                                : BorderRadius.zero,
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
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
                                  child: Icon(
                                    isExpanded
                                        ? Icons.remove_rounded
                                        : Icons.add_rounded,
                                    size: 16,
                                    color: isExpanded
                                        ? Colors.white
                                        : AppColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  faq['q']!,
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
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(
                              56, 0, 16, 16),
                          decoration: BoxDecoration(
                            color: AppColors.crimsonSurface,
                            borderRadius: isLast
                                ? const BorderRadius.vertical(
                                bottom: Radius.circular(14))
                                : BorderRadius.zero,
                          ),
                          child: Text(
                            faq['a']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                              height: 1.7,
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
                            height: 1,
                            color: AppColors.border),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ── CONTACT SECTION ────────────────────────────────
  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B0F0F), AppColors.crimson],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🤝',
                    style: TextStyle(fontSize: 24)),
                SizedBox(width: 10),
                Text(
                  "Aur Madad Chahiye?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Humari team 24/7 available hai",
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildContactButton(
                    Icons.email_outlined,
                    "Email",
                        () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: const Text(
                              "Email: support@rishtaapp.com"),
                          backgroundColor: AppColors.ink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildContactButton(
                    Icons.chat_bubble_outline_rounded,
                    "WhatsApp",
                        () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: const Text(
                              "WhatsApp jald aayega! 🚀"),
                          backgroundColor: AppColors.ink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                "Response time: 2-4 ghante (working hours)",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
      IconData icon,
      String label,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
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