// lib/core/widgets/block_report_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────

enum _DialogStep {
  options,    // Block or Report choice
  reportForm, // Report reason selection
  confirm,    // Final confirm screen
  done,       // Success screen
}

enum ReportReason {
  fakeProfile,
  inappropriatePhotos,
  harassment,
  spam,
  underage,
  scam,
  other,
}

extension ReportReasonLabel on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.fakeProfile:
        return 'Fake Profile';
      case ReportReason.inappropriatePhotos:
        return 'Inappropriate Photos';
      case ReportReason.harassment:
        return 'Harassment or Abuse';
      case ReportReason.spam:
        return 'Spam or Misleading';
      case ReportReason.underage:
        return 'Underage User';
      case ReportReason.scam:
        return 'Fraud or Scam';
      case ReportReason.other:
        return 'Other Reason';
    }
  }

  String get emoji {
    switch (this) {
      case ReportReason.fakeProfile:
        return '👤';
      case ReportReason.inappropriatePhotos:
        return '🖼️';
      case ReportReason.harassment:
        return '⚠️';
      case ReportReason.spam:
        return '📢';
      case ReportReason.underage:
        return '🔞';
      case ReportReason.scam:
        return '💸';
      case ReportReason.other:
        return '📝';
    }
  }
}

// ─────────────────────────────────────────────────────────
// BLOCK REPORT DIALOG
// ─────────────────────────────────────────────────────────

/// Multi-step block/report dialog.
///
/// Usage:
/// ```dart
/// BlockReportDialog.show(
///   context,
///   userName: 'Priya Sharma',
///   userEmoji: '👩',
///   userId: profile.id,
///   onBlocked: () {
///     context.pop();
///     context.showSuccessSnack('User blocked');
///   },
///   onReported: (reason) {
///     context.showSuccessSnack('Report submitted');
///   },
/// );
/// ```
class BlockReportDialog extends StatefulWidget {
  final String userName;
  final String userEmoji;
  final String userId;
  final VoidCallback? onBlocked;
  final void Function(ReportReason reason)? onReported;

  const BlockReportDialog({
    super.key,
    required this.userName,
    required this.userEmoji,
    required this.userId,
    this.onBlocked,
    this.onReported,
  });

  // ── STATIC SHOW ───────────────────────────────────────

  static Future<void> show(
      BuildContext context, {
        required String userName,
        required String userEmoji,
        required String userId,
        VoidCallback? onBlocked,
        void Function(ReportReason)? onReported,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlockReportDialog(
        userName: userName,
        userEmoji: userEmoji,
        userId: userId,
        onBlocked: onBlocked,
        onReported: onReported,
      ),
    );
  }

  @override
  State<BlockReportDialog> createState() =>
      _BlockReportDialogState();
}

class _BlockReportDialogState
    extends State<BlockReportDialog>
    with SingleTickerProviderStateMixin {
  _DialogStep _step = _DialogStep.options;
  ReportReason? _selectedReason;
  bool _isBlockAction = false;
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _goToStep(_DialogStep step) {
    _animCtrl.reverse().then((_) {
      if (mounted) {
        setState(() => _step = step);
        _animCtrl.forward();
      }
    });
  }

  Future<void> _handleBlock() async {
    setState(() {
      _isBlockAction = true;
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(
        const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);
    _goToStep(_DialogStep.done);

    // Callback after done animation
    await Future.delayed(
        const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onBlocked?.call();
  }

  Future<void> _handleReport() async {
    if (_selectedReason == null) return;

    setState(() => _isLoading = true);

    await Future.delayed(
        const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);
    _goToStep(_DialogStep.done);

    await Future.delayed(
        const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onReported?.call(_selectedReason!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              _Handle(),
              // Step content
              FadeTransition(
                opacity: _fadeAnim,
                child: _buildStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _DialogStep.options:
        return _OptionsStep(
          userName: widget.userName,
          userEmoji: widget.userEmoji,
          onBlock: () {
            HapticFeedback.lightImpact();
            _goToStep(_DialogStep.confirm);
            setState(
                    () => _isBlockAction = true);
          },
          onReport: () {
            HapticFeedback.lightImpact();
            _goToStep(_DialogStep.reportForm);
            setState(
                    () => _isBlockAction = false);
          },
          onCancel: () =>
              Navigator.pop(context),
        );

      case _DialogStep.reportForm:
        return _ReportFormStep(
          userName: widget.userName,
          userEmoji: widget.userEmoji,
          selectedReason: _selectedReason,
          onReasonSelected: (r) =>
              setState(() => _selectedReason = r),
          onBack: () =>
              _goToStep(_DialogStep.options),
          onNext: () => _selectedReason != null
              ? _goToStep(_DialogStep.confirm)
              : null,
        );

      case _DialogStep.confirm:
        return _ConfirmStep(
          userName: widget.userName,
          userEmoji: widget.userEmoji,
          isBlock: _isBlockAction,
          reason: _selectedReason,
          isLoading: _isLoading,
          onConfirm: _isBlockAction
              ? _handleBlock
              : _handleReport,
          onBack: () => _goToStep(
            _isBlockAction
                ? _DialogStep.options
                : _DialogStep.reportForm,
          ),
        );

      case _DialogStep.done:
        return _DoneStep(
          isBlock: _isBlockAction,
          userName: widget.userName,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────
// STEP 1 — OPTIONS
// ─────────────────────────────────────────────────────────

class _OptionsStep extends StatelessWidget {
  final String userName;
  final String userEmoji;
  final VoidCallback onBlock;
  final VoidCallback onReport;
  final VoidCallback onCancel;

  const _OptionsStep({
    required this.userName,
    required this.userEmoji,
    required this.onBlock,
    required this.onReport,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          24, 4, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User preview
          _UserPreview(
              name: userName, emoji: userEmoji),
          const SizedBox(height: 24),

          // Block option
          _OptionCard(
            icon: Icons.block_rounded,
            iconColor: AppColors.error,
            iconBg: AppColors.errorSurface,
            title: 'Block ${userName.split(' ').first}',
            subtitle:
            'They will not be able to view your\nprofile or send you messages',
            onTap: onBlock,
            isDestructive: true,
          ),

          const SizedBox(height: 10),

          // Report option
          _OptionCard(
            icon: Icons.flag_outlined,
            iconColor: AppColors.warning,
            iconBg: AppColors.warningSurface,
            title: 'Report Profile',
            subtitle:
            'Report inappropriate content\nor suspicious behavior',
            onTap: onReport,
          ),

          const SizedBox(height: 16),

          // Cancel
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor:
                AppColors.ivoryDark,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge
                    .copyWith(
                    color: AppColors.inkSoft),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 2 — REPORT FORM
// ─────────────────────────────────────────────────────────

class _ReportFormStep extends StatelessWidget {
  final String userName;
  final String userEmoji;
  final ReportReason? selectedReason;
  final ValueChanged<ReportReason> onReasonSelected;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _ReportFormStep({
    required this.userName,
    required this.userEmoji,
    required this.selectedReason,
    required this.onReasonSelected,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          24, 4, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.ivoryDark,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 14,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Profile',
                  style: AppTextStyles.h4,
                ),
                Text(
                  'Why are you reporting ${userName.split(' ').first}?',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ]),

          const SizedBox(height: 20),

          // Reason list
          ...ReportReason.values.map((reason) {
            final isSelected =
                selectedReason == reason;
            return GestureDetector(
              onTap: () =>
                  onReasonSelected(reason),
              child: AnimatedContainer(
                duration: const Duration(
                    milliseconds: 150),
                margin: const EdgeInsets.only(
                    bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.crimsonSurface
                      : AppColors.white,
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.crimson
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Text(reason.emoji,
                      style: const TextStyle(
                          fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reason.label,
                      style: AppTextStyles
                          .labelLarge
                          .copyWith(
                        color: isSelected
                            ? AppColors.crimson
                            : AppColors.ink,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.crimson,
                    )
                  else
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.border,
                            width: 1.5),
                      ),
                    ),
                ]),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Next button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selectedReason != null
                  ? onNext
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                selectedReason != null
                    ? AppColors.crimson
                    : AppColors.disabled,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 3 — CONFIRM
// ─────────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  final String userName;
  final String userEmoji;
  final bool isBlock;
  final ReportReason? reason;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const _ConfirmStep({
    required this.userName,
    required this.userEmoji,
    required this.isBlock,
    required this.reason,
    required this.isLoading,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = userName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          24, 4, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isBlock
                  ? AppColors.errorSurface
                  : AppColors.warningSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isBlock
                    ? Icons.block_rounded
                    : Icons.flag_rounded,
                size: 32,
                color: isBlock
                    ? AppColors.error
                    : AppColors.warning,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            isBlock
                ? 'Block $firstName?'
                : 'Report $firstName?',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // What will happen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  isBlock
                      ? 'After blocking:'
                      : reason != null
                      ? 'Reason: ${reason!.label}'
                      : 'After reporting:',
                  style:
                  AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 10),
                if (isBlock) ...[
                  _ConsequenceRow(
                    icon: Icons
                        .visibility_off_outlined,
                    text:
                    'They cannot view your profile',
                  ),
                  _ConsequenceRow(
                    icon: Icons
                        .chat_bubble_outline_rounded,
                    text:
                    'All messages will be blocked',
                  ),
                  _ConsequenceRow(
                    icon: Icons
                        .favorite_border_rounded,
                    text:
                    'Existing connection will be removed',
                  ),
                  _ConsequenceRow(
                    icon: Icons.undo_rounded,
                    text:
                    'You can unblock anytime from settings',
                    isPositive: true,
                  ),
                ] else ...[
                  _ConsequenceRow(
                    icon: Icons.security_rounded,
                    text:
                    'Our team will review this report',
                    isPositive: true,
                  ),
                  _ConsequenceRow(
                    icon: Icons
                        .admin_panel_settings_outlined,
                    text:
                    'Action will be taken if rules are violated',
                    isPositive: true,
                  ),
                  _ConsequenceRow(
                    icon:
                    Icons.lock_outline_rounded,
                    text:
                    'Your identity stays anonymous',
                    isPositive: true,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
              isLoading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlock
                    ? AppColors.error
                    : AppColors.crimson,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBlock
                        ? 'Blocking...'
                        : 'Submitting...',
                    style: AppTextStyles
                        .buttonPrimary,
                  ),
                ],
              )
                  : Text(
                isBlock
                    ? 'Yes, Block $firstName'
                    : 'Submit Report',
                style:
                AppTextStyles.buttonPrimary,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Back button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: onBack,
              child: Text(
                'Go Back',
                style: AppTextStyles.labelLarge
                    .copyWith(
                    color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 4 — DONE
// ─────────────────────────────────────────────────────────

class _DoneStep extends StatefulWidget {
  final bool isBlock;
  final String userName;

  const _DoneStep({
    required this.isBlock,
    required this.userName,
  });

  @override
  State<_DoneStep> createState() =>
      _DoneStepState();
}

class _DoneStepState extends State<_DoneStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _scale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
    ));

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstName =
        widget.userName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          24, 8, 24, 40),
      child: FadeTransition(
        opacity: _fade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: widget.isBlock
                      ? AppColors.errorSurface
                      : AppColors.successSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    widget.isBlock
                        ? Icons.block_rounded
                        : Icons
                        .check_circle_rounded,
                    size: 40,
                    color: widget.isBlock
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.isBlock
                  ? '$firstName Blocked'
                  : 'Report Submitted',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              widget.isBlock
                  ? '$firstName can no longer view\nyour profile or contact you'
                  : 'Thank you for keeping\nour community safe',
              style: AppTextStyles.bodyMedium
                  .copyWith(
                  color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _UserPreview extends StatelessWidget {
  final String name;
  final String emoji;

  const _UserPreview({
    required this.name,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.crimsonSurface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(emoji,
              style: const TextStyle(
                  fontSize: 24)),
        ),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(name,
              style: AppTextStyles.h5),
          Text(
            'What would you like to do?',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    ]);
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDestructive
                ? AppColors.error.withOpacity(0.2)
                : AppColors.border,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon,
                  size: 20, color: iconColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge
                      .copyWith(
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.muted,
          ),
        ]),
      ),
    );
  }
}

class _ConsequenceRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPositive;

  const _ConsequenceRow({
    required this.icon,
    required this.text,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: isPositive
                ? AppColors.success
                : AppColors.inkSoft,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall
                  .copyWith(
                  color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}