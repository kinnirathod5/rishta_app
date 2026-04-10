import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _hideProfile = false;
  String _profileVisibility = 'Sabko';
  bool _showPhotos = true;
  String _phoneVisibility = 'Connected';
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  bool _anonymousBrowsing = false;

  void _showHideConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profile Hide Karein?'),
        content: const Text(
          'Aapka profile sabke feeds se\nhata diya jayega. '
          'Kya aap sure hain?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crimson,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _hideProfile = true);
            },
            child: const Text('Haan, Hide Karo'),
          ),
        ],
      ),
    );
  }

  // ── SECTION BUILDER ───────────────────────────────────
  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
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
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Column(children: items),
        ],
      ),
    );
  }

  // ── TOGGLE SETTING ────────────────────────────────────
  Widget _buildToggleSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Icon(icon, size: 18, color: AppColors.muted)),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.crimson,
          ),
        ],
      ),
    );
  }

  // ── SEGMENT SETTING ───────────────────────────────────
  Widget _buildSegmentSetting(
    String title,
    String subtitle,
    IconData icon,
    List<String> options,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Icon(icon, size: 18, color: AppColors.muted)),
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
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: options.map((option) {
              final isSelected = value == option;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.crimson
                          : AppColors.ivoryDark,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.crimson
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.inkSoft,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── NAVIGATION ROW ────────────────────────────────────
  Widget _buildNavigationRow(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Icon(icon, size: 18, color: AppColors.muted)),
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

  // ── MASTER HIDE SWITCH ────────────────────────────────
  Widget _buildMasterHideSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: _hideProfile ? AppColors.crimsonSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hideProfile
              ? AppColors.crimson.withOpacity(0.30)
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _hideProfile
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                      color: _hideProfile
                          ? AppColors.crimson
                          : AppColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Profile Hide Karo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _hideProfile
                            ? AppColors.crimson
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kisi ko bhi profile nahi dikhegi',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                if (_hideProfile) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonSurface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      '🚫 Profile abhi hidden hai',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.crimson,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: _hideProfile,
            onChanged: (val) {
              if (val) {
                _showHideConfirmation();
              } else {
                setState(() => _hideProfile = false);
              }
            },
            activeColor: AppColors.crimson,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: AppColors.softShadow,
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
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16, color: AppColors.ink),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Privacy Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Aapka profile kaun dekhe',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Content ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMasterHideSwitch(),
                    const SizedBox(height: 14),
                    _buildSettingsSection(
                      'Profile Visibility',
                      [
                        _buildSegmentSetting(
                          'Profile Visible To',
                          'Kaun aapka profile dekh sakta hai',
                          Icons.public_rounded,
                          const ['Sabko', 'Premium Only', 'Hidden'],
                          _profileVisibility,
                          (val) => setState(
                              () => _profileVisibility = val),
                        ),
                        _buildToggleSetting(
                          'Photos Dikhao',
                          'Profile photos visible rahein',
                          Icons.photo_outlined,
                          _showPhotos,
                          (val) =>
                              setState(() => _showPhotos = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSettingsSection(
                      'Contact Privacy',
                      [
                        _buildSegmentSetting(
                          'Phone Number',
                          'Phone number kaun dekhe',
                          Icons.phone_outlined,
                          const ['Connected', 'Premium', 'Hidden'],
                          _phoneVisibility,
                          (val) => setState(
                              () => _phoneVisibility = val),
                        ),
                        _buildToggleSetting(
                          'Online Status',
                          'Doosron ko online status dikhao',
                          Icons.circle_outlined,
                          _showOnlineStatus,
                          (val) => setState(
                              () => _showOnlineStatus = val),
                        ),
                        _buildToggleSetting(
                          'Last Seen',
                          'Kab last active tha',
                          Icons.access_time_rounded,
                          _showLastSeen,
                          (val) =>
                              setState(() => _showLastSeen = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSettingsSection(
                      'Profile Views',
                      [
                        _buildToggleSetting(
                          'Anonymous Browsing',
                          'Profile views anonymous rakho',
                          Icons.privacy_tip_outlined,
                          _anonymousBrowsing,
                          (val) => setState(
                              () => _anonymousBrowsing = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSettingsSection(
                      'Blocked Users',
                      [
                        _buildNavigationRow(
                          Icons.block_rounded,
                          'Blocked Users List',
                          '2 users blocked',
                          () {},
                        ),
                      ],
                    ),
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
}
