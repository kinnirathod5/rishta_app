import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState
    extends State<DeleteAccountScreen> {
  String _selectedAction = ''; // 'deactivate' or 'delete'
  String _selectedReason = '';
  final TextEditingController _confirmController =
  TextEditingController();
  bool _isProcessing = false;
  bool _isDone = false;

  final List<String> _reasons = [
    'Mujhe mera rishta mil gaya 💍',
    'App se satisfied nahi hoon',
    'Privacy concerns hain',
    'Bahut zyada notifications aate hain',
    'Technical problems aa rahe hain',
    'Kuch time ke liye break lena hai',
    'Doosri app use kar raha/rahi hoon',
    'Koi aur reason',
  ];

  bool get _canProceed {
    if (_selectedAction.isEmpty) return false;
    if (_selectedReason.isEmpty) return false;
    if (_selectedAction == 'delete') {
      return _confirmController.text.trim() == 'DELETE';
    }
    return true;
  }

  Future<void> _proceed() async {
    if (!_canProceed) return;

    // Show final confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          _selectedAction == 'delete'
              ? '⚠️ Account Permanently Delete Karein?'
              : 'Account Deactivate Karein?',
        ),
        content: Text(
          _selectedAction == 'delete'
              ? 'Aapka poora data 30 din ke baad permanently delete ho jaayega. Yeh action undo nahi ho sakta.'
              : 'Aapka profile temporarily hide ho jaayega. Aap baad mein wapas aa sakte hain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedAction == 'delete'
                  ? AppColors.error
                  : AppColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _selectedAction == 'delete'
                  ? 'Haan, Delete Karo'
                  : 'Haan, Deactivate Karo',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isDone = true;
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
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
              child: _isDone
                  ? _buildDoneState()
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildWarningBanner(),
                    const SizedBox(height: 20),
                    _buildActionSelection(),
                    const SizedBox(height: 20),
                    if (_selectedAction.isNotEmpty) ...[
                      _buildReasonSection(),
                      const SizedBox(height: 20),
                    ],
                    if (_selectedAction == 'delete' &&
                        _selectedReason.isNotEmpty) ...[
                      _buildConfirmSection(),
                      const SizedBox(height: 20),
                    ],
                    if (_selectedReason.isNotEmpty)
                      _buildProceedButton(),
                    const SizedBox(height: 20),
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
                  "Account Manage Karein",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  "Deactivate ya Delete",
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

  // ── WARNING BANNER ─────────────────────────────────
  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️',
              style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chhor kar jaane se pehle...",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Kya aapne yeh try kiya?",
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _buildTryItem('Notification settings quiet karein'),
                _buildTryItem('Privacy settings adjust karein'),
                _buildTryItem('Premium try karein — better matches'),
                _buildTryItem(
                    'Temporarily hide karein account ko'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTryItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.inkSoft,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── ACTION SELECTION ───────────────────────────────
  Widget _buildActionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.settings_outlined,
                size: 18, color: AppColors.crimson),
            SizedBox(width: 8),
            Text(
              "Kya Karna Chahte Ho?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Deactivate option
        GestureDetector(
          onTap: () => setState(
                  () => _selectedAction = 'deactivate'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedAction == 'deactivate'
                  ? AppColors.warningSurface
                  : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedAction == 'deactivate'
                    ? AppColors.warning
                    : AppColors.border,
                width: _selectedAction == 'deactivate' ? 2 : 1,
              ),
              boxShadow: _selectedAction == 'deactivate'
                  ? AppColors.cardShadow
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedAction == 'deactivate'
                        ? AppColors.warning.withOpacity(0.15)
                        : AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('⏸️',
                        style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account Deactivate Karo",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                          _selectedAction == 'deactivate'
                              ? AppColors.warning
                              : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Profile temporarily hide ho jaayegi\nKisi bhi waqt wapas aa sakte ho",
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius:
                          BorderRadius.circular(100),
                        ),
                        child: const Text(
                          "✓ Data safe rehta hai",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedAction == 'deactivate'
                          ? AppColors.warning
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: _selectedAction == 'deactivate'
                      ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null,
                ),
              ],
            ),
          ),
        ),

        // Delete option
        GestureDetector(
          onTap: () =>
              setState(() => _selectedAction = 'delete'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedAction == 'delete'
                  ? AppColors.errorSurface
                  : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedAction == 'delete'
                    ? AppColors.error
                    : AppColors.border,
                width: _selectedAction == 'delete' ? 2 : 1,
              ),
              boxShadow: _selectedAction == 'delete'
                  ? AppColors.cardShadow
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedAction == 'delete'
                        ? AppColors.error.withOpacity(0.12)
                        : AppColors.ivoryDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('🗑️',
                        style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account Delete Karo",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _selectedAction == 'delete'
                              ? AppColors.error
                              : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Poora data 30 din mein delete\nYeh action permanent hai",
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius:
                          BorderRadius.circular(100),
                          border: Border.all(
                              color: AppColors.error
                                  .withOpacity(0.3)),
                        ),
                        child: const Text(
                          "⚠️ Permanent action",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedAction == 'delete'
                          ? AppColors.error
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: _selectedAction == 'delete'
                      ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── REASON SECTION ─────────────────────────────────
  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.help_outline_rounded,
                size: 18, color: AppColors.crimson),
            SizedBox(width: 8),
            Text(
              "Aap kyun ja rahe hain?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(width: 5),
            Text('*',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.error,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Aapka feedback hamein improve karne mein help karta hai",
          style: TextStyle(
              fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            children: List.generate(_reasons.length, (i) {
              final reason = _reasons[i];
              final isSelected = _selectedReason == reason;
              final isLast = i == _reasons.length - 1;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedReason = reason),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.crimsonSurface
                        : AppColors.white,
                    borderRadius: isLast
                        ? const BorderRadius.vertical(
                        bottom: Radius.circular(14))
                        : BorderRadius.zero,
                    border: isLast
                        ? null
                        : const Border(
                        bottom: BorderSide(
                            color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.crimson
                                : AppColors.ink,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
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
                            width: 10,
                            height: 10,
                            decoration:
                            const BoxDecoration(
                              color: AppColors.crimson,
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
            }),
          ),
        ),
      ],
    );
  }

  // ── CONFIRM SECTION (Delete only) ──────────────────
  Widget _buildConfirmSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text(
                "Confirm Karein",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Neeche box mein exactly 'DELETE' type karein (capital letters mein):",
            style: TextStyle(
                fontSize: 13, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.error,
            ),
            decoration: InputDecoration(
              hintText: "DELETE",
              hintStyle: TextStyle(
                color: AppColors.error.withOpacity(0.3),
                letterSpacing: 2,
              ),
              filled: true,
              fillColor: AppColors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: AppColors.error.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.error, width: 2),
              ),
            ),
          ),
          if (_confirmController.text.isNotEmpty &&
              _confirmController.text.trim() != 'DELETE') ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.close_rounded,
                    size: 13, color: AppColors.error),
                const SizedBox(width: 5),
                Text(
                  "Exactly 'DELETE' type karein",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
          if (_confirmController.text.trim() == 'DELETE') ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.check_rounded,
                    size: 13, color: AppColors.success),
                const SizedBox(width: 5),
                Text(
                  "Confirmed ✓",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── PROCEED BUTTON ─────────────────────────────────
  Widget _buildProceedButton() {
    final isDelete = _selectedAction == 'delete';
    final btnColor =
    isDelete ? AppColors.error : AppColors.warning;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
            _canProceed && !_isProcessing ? _proceed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _canProceed ? btnColor : AppColors.disabled,
              disabledBackgroundColor: AppColors.disabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Processing...",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
                : Text(
              isDelete
                  ? "Account Delete Karo"
                  : "Account Deactivate Karo",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            "Nahi, Wapas Jaao",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── DONE STATE ─────────────────────────────────────
  Widget _buildDoneState() {
    final isDelete = _selectedAction == 'delete';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDelete
                    ? AppColors.errorSurface
                    : AppColors.warningSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDelete
                      ? AppColors.error.withOpacity(0.3)
                      : AppColors.warning.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  isDelete ? '🗑️' : '⏸️',
                  style: const TextStyle(fontSize: 44),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isDelete
                  ? "Account Delete Request\nSubmit Ho Gayi"
                  : "Account Deactivate\nHo Gaya!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isDelete
                  ? "Aapka data 30 din mein permanently delete ho jaayega.\nIs dauraan account recover kiya ja sakta hai."
                  : "Aapka profile ab hide hai.\nKisi bhi waqt login karke wapas aa sakte hain.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isDelete)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.info.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "30 din ke andar wapas aana chahte hain? support@rishtaapp.com pe email karein",
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/welcome'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Welcome Page Pe Jaao",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}