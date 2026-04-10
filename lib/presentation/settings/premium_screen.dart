import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

const Color _silverColor = Color(0xFF9E9E9E);
const Color _platinumColor = Color(0xFF7E57C2);

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'gold';
  int _selectedDuration = 1;

  String _getPriceForDuration(String plan) {
    final prices = {
      'silver': {1: 499, 3: 1299, 6: 2199},
      'gold': {1: 999, 3: 2599, 6: 4499},
      'platinum': {1: 1999, 3: 4999, 6: 8999},
    };
    final price = prices[plan]![_selectedDuration]!;
    final label = _selectedDuration == 1
        ? 'mahina'
        : '$_selectedDuration mahine';
    return '₹$price / $label';
  }

  void _handlePurchase() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Purchase Confirm Karein'),
        content: Text(
          '${_selectedPlan.toUpperCase()} Plan\n'
          '${_getPriceForDuration(_selectedPlan)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      '🎉 Premium activated! (Demo mode)'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Pay Karo'),
          ),
        ],
      ),
    );
  }

  // ── HERO SECTION ──────────────────────────────────────
  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.crimsonDark,
            AppColors.crimson,
            Color(0xFF2A0A0A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 16, color: Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.close_rounded,
                        size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('👑', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          const Text(
            'Premium Baniye',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Rishta dhundhna aur aasaan karo',
            style: TextStyle(
                fontSize: 14, color: Colors.white.withOpacity(0.70)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeroBenefit('💌', 'Unlimited\nInterests'),
              _buildHeroBenefit('📞', 'Contact\nDekhein'),
              _buildHeroBenefit('💬', 'Direct\nChat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBenefit(String emoji, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.80),
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── DURATION TOGGLE ───────────────────────────────────
  Widget _buildDurationToggle() {
    final options = [
      {'label': '1 Mahina', 'value': 1, 'savings': null},
      {'label': '3 Mahine', 'value': 3, 'savings': 'Save 13%'},
      {'label': '6 Mahine', 'value': 6, 'savings': 'Save 25%'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((opt) {
          final val = opt['value'] as int;
          final isSelected = _selectedDuration == val;
          final savings = opt['savings'] as String?;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  setState(() => _selectedDuration = val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      opt['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.ink
                            : Colors.white.withOpacity(0.60),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (savings != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        savings,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.inkSoft
                              : AppColors.gold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── PLAN CARDS ────────────────────────────────────────
  Widget _buildFeatureItem(String feature, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.check_rounded,
                  size: 10, color: color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.80)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String emoji,
    required String price,
    required Color color,
    required List<String> features,
    required bool isPopular,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : Colors.white.withOpacity(0.10),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(emoji,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white
                                    .withOpacity(0.70),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'Selected ✓',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  children: features
                      .map((f) => _buildFeatureItem(f, color))
                      .toList(),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  '⭐ MOST POPULAR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCards() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        children: [
          _buildPlanCard(
            name: 'Silver',
            emoji: '🥈',
            price: _getPriceForDuration('silver'),
            color: _silverColor,
            features: const [
              '50 contacts dekho',
              'Chat karein',
              'Profile boost (1 baar)',
              'Ads-free experience',
            ],
            isPopular: false,
            isSelected: _selectedPlan == 'silver',
            onTap: () =>
                setState(() => _selectedPlan = 'silver'),
          ),
          const SizedBox(height: 20),
          _buildPlanCard(
            name: 'Gold',
            emoji: '🥇',
            price: _getPriceForDuration('gold'),
            color: AppColors.gold,
            features: const [
              '200 contacts dekho',
              'Unlimited chat',
              'Profile boost (5 baar)',
              'Video call (10 baar)',
              'Who viewed me dekho',
              'Priority support',
            ],
            isPopular: true,
            isSelected: _selectedPlan == 'gold',
            onTap: () =>
                setState(() => _selectedPlan = 'gold'),
          ),
          const SizedBox(height: 14),
          _buildPlanCard(
            name: 'Platinum',
            emoji: '💎',
            price: _getPriceForDuration('platinum'),
            color: _platinumColor,
            features: const [
              'Unlimited contacts',
              'Unlimited chat + video',
              'Dedicated relationship manager',
              'Profile featured for 30 days',
              'Unlimited profile boosts',
              'Priority matchmaking',
            ],
            isPopular: false,
            isSelected: _selectedPlan == 'platinum',
            onTap: () =>
                setState(() => _selectedPlan = 'platinum'),
          ),
        ],
      ),
    );
  }

  // ── BUY BUTTON ────────────────────────────────────────
  Widget _buildBuyButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handlePurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Abhi Kharido — ${_getPriceForDuration(_selectedPlan)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── COMPARISON TABLE ──────────────────────────────────
  Widget _buildCheck(bool has, Color color) {
    return SizedBox(
      width: 40,
      child: Center(
        child: has
            ? Icon(Icons.check_circle_rounded,
                size: 18, color: color)
            : Icon(Icons.remove_rounded,
                size: 18,
                color: Colors.white.withOpacity(0.20)),
      ),
    );
  }

  Widget _buildCompareRow(
      String feature, bool silver, bool gold, bool platinum) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.70)),
            ),
          ),
          _buildCheck(silver, _silverColor),
          _buildCheck(gold, AppColors.gold),
          _buildCheck(platinum, _platinumColor),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kya Milega?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          // Header row
          Row(
            children: [
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text('🥈',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text('🥇',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text('💎',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCompareRow(
              'Contacts Dekhein', true, true, true),
          _buildCompareRow('Chat Karein', true, true, true),
          _buildCompareRow('Video Call', false, true, true),
          _buildCompareRow('Profile Boost', true, true, true),
          _buildCompareRow(
              'Who Viewed Me', false, true, true),
          _buildCompareRow('RM Support', false, false, true),
          _buildCompareRow(
              'Featured Profile', false, false, true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(),
              _buildDurationToggle(),
              _buildPlanCards(),
              _buildBuyButton(),
              _buildComparisonTable(),
            ],
          ),
        ),
      ),
    );
  }
}
