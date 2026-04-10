import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';

class ProfileTypeScreen extends StatefulWidget {
  const ProfileTypeScreen({super.key});

  @override
  State<ProfileTypeScreen> createState() => _ProfileTypeScreenState();
}

class _ProfileTypeScreenState extends State<ProfileTypeScreen> {
  String _profileFor = 'self';
  String _candidateGender = 'male';

  void _onContinue() => context.go(AppRoutePaths.setupStep1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBackButton(),
                const SizedBox(height: 28),
                _buildTopSection(),
                const SizedBox(height: 32),
                _buildSelfCard(),
                const SizedBox(height: 12),
                _buildParentCard(),
                const SizedBox(height: 28),
                _buildGenderSection(),
                const SizedBox(height: 24),
                _buildContinueButton(),
                const SizedBox(height: 16),
                _buildStepIndicator(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── BACK BUTTON ───────────────────────────────────────────
  Widget _buildBackButton() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutePaths.explore),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
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
              child: Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            AppStrings.profileTypeTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sahi option chunne se better matches milenge',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // ── SELF CARD ─────────────────────────────────────────────
  Widget _buildSelfCard() {
    final isSelected = _profileFor == 'self';
    return GestureDetector(
      onTap: () => setState(() => _profileFor = 'self'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon box
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.crimson : AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.selfCardTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.crimson : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppStrings.selfCardSubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.white
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Age 18-35 • Modern approach',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? AppColors.crimson : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Radio
            _buildRadio(isSelected: isSelected, color: AppColors.crimson),
          ],
        ),
      ),
    );
  }

  // ── PARENT CARD ───────────────────────────────────────────
  Widget _buildParentCard() {
    final isSelected = _profileFor == 'parent';
    return GestureDetector(
      onTap: () => setState(() => _profileFor = 'parent'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldSurface : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected ? AppColors.cardShadow : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon box
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold : AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('👨‍👩‍👦', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.parentCardTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.gold : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppStrings.parentCardSubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.white
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Family-oriented • Traditional values',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.gold : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Radio
            _buildRadio(isSelected: isSelected, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  // ── GENDER SECTION ────────────────────────────────────────
  Widget _buildGenderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person_outline_rounded,
                  size: 16, color: AppColors.muted),
              SizedBox(width: 8),
              Text(
                AppStrings.genderLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildGenderButton(
                emoji: '👨',
                label: 'Male',
                value: 'male',
              ),
              const SizedBox(width: 12),
              _buildGenderButton(
                emoji: '👩',
                label: 'Female',
                value: 'female',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info note
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.info.withOpacity(0.20),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Yeh choice baad mein Settings se change kar sakte ho',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required String emoji,
    required String label,
    required String value,
  }) {
    final isSelected = _candidateGender == value;
    return GestureDetector(
      onTap: () => setState(() => _candidateGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.crimson : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.crimson : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.btnContinue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  // ── STEP INDICATOR ────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final isActive = index == 0;
          return Padding(
            padding: EdgeInsets.only(right: index < 4 ? 5 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.crimson : AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── RADIO INDICATOR ───────────────────────────────────────
  Widget _buildRadio({required bool isSelected, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : AppColors.border,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
