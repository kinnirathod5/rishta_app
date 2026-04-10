import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ── HOW TO USE ────────────────────────────────────────────
// Kisi bhi screen se call karo:
//
// BlockReportDialog.show(
//   context,
//   userName: 'Rahul Sharma',
//   userEmoji: '👨‍💻',
//   userId: 'uid_123',
//   onBlocked: () {
//     // User blocked — screen se remove karo
//   },
// );
// ─────────────────────────────────────────────────────────

class BlockReportDialog {
  static void show(
      BuildContext context, {
        required String userName,
        required String userEmoji,
        required String userId,
        VoidCallback? onBlocked,
        VoidCallback? onReported,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BlockReportSheet(
        userName: userName,
        userEmoji: userEmoji,
        userId: userId,
        onBlocked: onBlocked,
        onReported: onReported,
      ),
    );
  }
}

class _BlockReportSheet extends StatefulWidget {
  final String userName;
  final String userEmoji;
  final String userId;
  final VoidCallback? onBlocked;
  final VoidCallback? onReported;

  const _BlockReportSheet({
    required this.userName,
    required this.userEmoji,
    required this.userId,
    this.onBlocked,
    this.onReported,
  });

  @override
  State<_BlockReportSheet> createState() =>
      _BlockReportSheetState();
}

class _BlockReportSheetState extends State<_BlockReportSheet> {
  String _selectedView = 'main'; // 'main' | 'report'
  String _selectedReason = '';
  bool _alsoBlock = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _reportReasons = [
    {
      'id': 'fake',
      'label': 'Fake Profile',
      'desc': 'Yeh profile real nahi lagti',
      'emoji': '🎭',
    },
    {
      'id': 'inappropriate',
      'label': 'Inappropriate Photos',
      'desc': 'Objectionable ya offensive photos',
      'emoji': '🖼️',
    },
    {
      'id': 'spam',
      'label': 'Spam / Advertisement',
      'desc': 'Business promote kar raha/rahi hai',
      'emoji': '📢',
    },
    {
      'id': 'harassment',
      'label': 'Harassment',
      'desc': 'Pareshan kar raha/rahi hai',
      'emoji': '😤',
    },
    {
      'id': 'wrong_info',
      'label': 'Galat Jankari',
      'desc': 'Profile details sahi nahi hain',
      'emoji': '❌',
    },
    {
      'id': 'underage',
      'label': 'Umar Kam Lagti Hai',
      'desc': '18 saal se kam lag raha/rahi hai',
      'emoji': '⚠️',
    },
    {
      'id': 'other',
      'label': 'Koi Aur Reason',
      'desc': 'Upar wale mein nahi aata',
      'emoji': '💬',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _selectedView == 'main'
            ? _buildMainView()
            : _buildReportView(),
      ),
    );
  }

  // ── MAIN VIEW ──────────────────────────────────────
  Widget _buildMainView() {
    return Padding(
      key: const ValueKey('main'),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
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

          // User info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    widget.userEmoji,
                    style: const TextStyle(fontSize: 24),
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
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      "Iske baare mein kya karna hai?",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.ink),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),

          // Options
          _buildOptionTile(
            Icons.block_rounded,
            "Block Karo",
            "${widget.userName} aapko nahi dekh sakenge",
            AppColors.error,
            AppColors.errorSurface,
            _showBlockConfirmation,
          ),

          _buildOptionTile(
            Icons.flag_outlined,
            "Report Karo",
            "Hamari team review karegi",
            AppColors.warning,
            AppColors.warningSurface,
                () => setState(() => _selectedView = 'report'),
          ),

          _buildOptionTile(
            Icons.person_off_outlined,
            "Profile Na Dikhao",
            "Feeds mein nahi aayega/aayegi",
            AppColors.muted,
            AppColors.ivoryDark,
                () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "${widget.userName} ab feeds mein nahi dikhenge"),
                  backgroundColor: AppColors.ink,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10)),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),

          // Cancel
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Rehne Do",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkSoft,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      Color bgColor,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, size: 20, color: color),
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
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  // ── BLOCK CONFIRMATION ─────────────────────────────
  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text("${widget.userName} ko Block Karein?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Block karne ke baad:",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildBlockPoint(
                "Aapki profile nahi dekh sakenge"),
            _buildBlockPoint("Interest nahi bhej sakenge"),
            _buildBlockPoint("Message nahi kar sakenge"),
            _buildBlockPoint(
                "Feeds mein bhi nahi dikhenge"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close sheet
              widget.onBlocked?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "${widget.userName} ko block kar diya ✓"),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text("Haan, Block Karo"),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline,
              size: 14, color: AppColors.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── REPORT VIEW ────────────────────────────────────
  Widget _buildReportView() {
    return Padding(
      key: const ValueKey('report'),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
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

          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    setState(() => _selectedView = 'main'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 14,
                      color: AppColors.ink),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${widget.userName} ko Report Karein",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reason list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
              MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: _reportReasons.map((reason) {
                  final isSelected =
                      _selectedReason == reason['id'];
                  return GestureDetector(
                    onTap: () => setState(() =>
                    _selectedReason =
                    reason['id'] as String),
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 150),
                      margin:
                      const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.crimsonSurface
                            : AppColors.white,
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.crimson
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(reason['emoji'] as String,
                              style: const TextStyle(
                                  fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reason['label'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.crimson
                                        : AppColors.ink,
                                  ),
                                ),
                                Text(
                                  reason['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 150),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.crimson
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration:
                                const BoxDecoration(
                                  color:
                                  AppColors.crimson,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Also block toggle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _alsoBlock
                  ? AppColors.errorSurface
                  : AppColors.ivory,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _alsoBlock
                    ? AppColors.error.withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 18,
                  color: _alsoBlock
                      ? AppColors.error
                      : AppColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${widget.userName} ko bhi block karein",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _alsoBlock
                          ? AppColors.error
                          : AppColors.inkSoft,
                    ),
                  ),
                ),
                Switch(
                  value: _alsoBlock,
                  activeColor: AppColors.error,
                  onChanged: (val) =>
                      setState(() => _alsoBlock = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedReason.isEmpty || _isSubmitting
                  ? null
                  : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedReason.isNotEmpty
                    ? AppColors.crimson
                    : AppColors.disabled,
                disabledBackgroundColor: AppColors.disabled,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Text(
                "Report Submit Karein",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pop(context);

    if (_alsoBlock) {
      widget.onBlocked?.call();
    }
    widget.onReported?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.flag_rounded,
                size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _alsoBlock
                    ? "${widget.userName} ko report aur block kar diya ✓"
                    : "${widget.userName} ki report bhej di gayi ✓",
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}