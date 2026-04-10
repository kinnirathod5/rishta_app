import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';

class ExploreFirstScreen extends StatefulWidget {
  const ExploreFirstScreen({super.key});

  @override
  State<ExploreFirstScreen> createState() => _ExploreFirstScreenState();
}

class _ExploreFirstScreenState extends State<ExploreFirstScreen> {
  String _selectedOption = 'register';

  void _onContinue() {
    if (_selectedOption == 'guest') {
      context.go(AppRoutePaths.home);
    } else {
      context.go(AppRoutePaths.profileType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildTopSection(),
              const SizedBox(height: 32),
              _buildGuestCard(),
              const SizedBox(height: 12),
              _buildRegisterCard(),
              const Spacer(),
              _buildContinueButton(),
              const SizedBox(height: 16),
              _buildBottomNote(),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOP SECTION ───────────────────────────────────────────
  Widget _buildTopSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('💑', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            AppStrings.exploreTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Account banao ya pehle browse karo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // ── GUEST CARD ────────────────────────────────────────────
  Widget _buildGuestCard() {
    final isSelected = _selectedOption == 'guest';
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = 'guest'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.crimson : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected ? AppColors.cardShadow : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRadio(isSelected),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('👀', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.guestCardTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.guestCardSubtitle,
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: const [
                      _GuestChip(label: AppStrings.guestFeature1),
                      _GuestChip(label: AppStrings.guestFeature2),
                      _GuestChip(label: AppStrings.guestFeature3),
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

  // ── REGISTER CARD ─────────────────────────────────────────
  Widget _buildRegisterCard() {
    final isSelected = _selectedOption == 'register';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedOption = 'register'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.crimsonSurface : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.crimson : AppColors.border,
                width: 2,
              ),
              boxShadow: isSelected ? AppColors.cardShadow : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadio(isSelected),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.registerCardTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.crimson
                                  : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.registerCardSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.crimson.withOpacity(0.70)
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _RegisterChip(
                            label: AppStrings.registerFeature1,
                            isSelected: isSelected,
                          ),
                          _RegisterChip(
                            label: AppStrings.registerFeature2,
                            isSelected: isSelected,
                          ),
                          _RegisterChip(
                            label: AppStrings.registerFeature3,
                            isSelected: isSelected,
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
        // RECOMMENDED badge
        Positioned(
          top: -10,
          right: 14,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⭐', style: TextStyle(fontSize: 10)),
                SizedBox(width: 4),
                Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── RADIO INDICATOR ───────────────────────────────────────
  Widget _buildRadio(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.crimson : AppColors.border,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.crimson,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  // ── CONTINUE BUTTON ───────────────────────────────────────
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            key: ValueKey(_selectedOption),
            _selectedOption == 'guest'
                ? '${AppStrings.guestCardTitle} →'
                : '${AppStrings.registerCardTitle} →',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NOTE ───────────────────────────────────────────
  Widget _buildBottomNote() {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded, size: 13, color: AppColors.muted),
          SizedBox(width: 5),
          Text(
            'Baad mein bhi account bana sakte ho',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ── CHIP WIDGETS ──────────────────────────────────────────────
class _GuestChip extends StatelessWidget {
  const _GuestChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.muted),
      ),
    );
  }
}

class _RegisterChip extends StatelessWidget {
  const _RegisterChip({required this.label, required this.isSelected});
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.white : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(100),
        border: isSelected
            ? Border.all(
                color: AppColors.crimson.withOpacity(0.30),
                width: 1,
              )
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.success : AppColors.muted,
        ),
      ),
    );
  }
}
