// lib/presentation/auth/phone_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/providers/auth_provider.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() =>
      _PhoneEntryScreenState();
}

class _PhoneEntryScreenState
    extends ConsumerState<PhoneEntryScreen>
    with SingleTickerProviderStateMixin {

  final _phoneCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  String _phone = '';
  bool _hasError = false;
  String _errorText = '';

  // Entry animation
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _entryCtrl.forward();
    // Auto focus after animation
    Future.delayed(
        const Duration(milliseconds: 500),
            () {
          if (mounted) _phoneFocus.requestFocus();
        });
  }

  void _setupAnimations() {
    _entryCtrl = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ── VALIDATION ────────────────────────────────────────

  bool _validate() {
    final clean = _phone.replaceAll(' ', '');
    if (clean.isEmpty) {
      setState(() {
        _hasError = true;
        _errorText = AppStrings.phoneRequired;
      });
      return false;
    }
    if (clean.length != 10 ||
        !RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
      setState(() {
        _hasError = true;
        _errorText = AppStrings.phoneInvalid;
      });
      return false;
    }
    setState(() {
      _hasError = false;
      _errorText = '';
    });
    return true;
  }

  // ── SEND OTP ──────────────────────────────────────────

  Future<void> _sendOtp() async {
    _phoneFocus.unfocus();
    if (!_validate()) return;

    final clean =
    _phone.replaceAll(' ', '');

    await ref.read(authProvider.notifier).sendOtp(
      phoneNumber: clean,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        context.push(
          '/otp',
          extra: '+91 ${_formatDisplay(clean)}',
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _errorText = error;
        });
      },
    );
  }

  String _formatDisplay(String digits) {
    if (digits.length == 10) {
      return '${digits.substring(0, 5)} '
          '${digits.substring(5)}';
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
        authProvider.select((s) => s.isLoading));

    return Scaffold(
      backgroundColor: AppColors.ivory,
      resizeToAvoidBottomInset: true,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  24, 16, 24, 40),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildPhoneField(),
                  const SizedBox(height: 8),
                  _buildErrorMessage(),
                  const SizedBox(height: 28),
                  _buildSendButton(isLoading),
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildGuestButton(isLoading),
                  const SizedBox(height: 32),
                  _buildTerms(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── BACK BUTTON ───────────────────────────────────────

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.go('/welcome'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📱',
          style: TextStyle(fontSize: 44),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.enterPhone,
          style: AppTextStyles.onboardTitle,
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.otpWillBeSent,
          style: AppTextStyles.onboardSubtitle,
        ),
      ],
    );
  }

  // ── PHONE FIELD ───────────────────────────────────────

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(children: [
          Text(
            AppStrings.mobileNumber,
            style: AppTextStyles.inputLabel,
          ),
          Text(' *',
              style: AppTextStyles.inputLabel
                  .copyWith(
                  color: AppColors.crimson)),
        ]),
        const SizedBox(height: 7),
        // Field
        AnimatedContainer(
          duration:
          const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
            BorderRadius.circular(12),
            border: Border.all(
              color: _hasError
                  ? AppColors.error
                  : _phoneFocus.hasFocus
                  ? AppColors.crimson
                  : AppColors.border,
              width: (_hasError ||
                  _phoneFocus.hasFocus)
                  ? 2
                  : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Country code prefix
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 15),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                        color: AppColors.border,
                        width: 1.5),
                  ),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🇮🇳',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+91',
                        style: AppTextStyles.inputText
                            .copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
                    ]),
              ),
              // Phone number input
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  focusNode: _phoneFocus,
                  keyboardType:
                  TextInputType.phone,
                  textInputAction:
                  TextInputAction.done,
                  maxLength: 11,
                  // 10 digits + 1 space
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                    _PhoneFormatter(),
                  ],
                  style: AppTextStyles.inputText
                      .copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  cursorColor: AppColors.crimson,
                  decoration: InputDecoration(
                    hintText:
                    AppStrings.phonePlaceholder,
                    hintStyle: AppTextStyles
                        .inputHint
                        .copyWith(
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                    border: InputBorder.none,
                    enabledBorder:
                    InputBorder.none,
                    focusedBorder:
                    InputBorder.none,
                    counterText: '',
                    contentPadding:
                    const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14),
                    // Clear button
                    suffixIcon: _phone.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _phoneCtrl.clear();
                        setState(() {
                          _phone = '';
                          _hasError = false;
                        });
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    )
                        : null,
                  ),
                  onChanged: (v) {
                    setState(() {
                      _phone = v;
                      if (_hasError) {
                        _hasError = false;
                        _errorText = '';
                      }
                    });
                  },
                  onSubmitted: (_) => _sendOtp(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── ERROR MESSAGE ─────────────────────────────────────

  Widget _buildErrorMessage() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: _hasError
          ? Padding(
        padding: const EdgeInsets.only(
            top: 6),
        child: Row(children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _errorText,
              style: AppTextStyles
                  .inputError,
            ),
          ),
        ]),
      )
          : const SizedBox.shrink(),
    );
  }

  // ── SEND BUTTON ───────────────────────────────────────

  Widget _buildSendButton(bool isLoading) {
    final canSend =
        _phone.replaceAll(' ', '').length == 10 &&
            !isLoading;

    return PrimaryButton(
      label: isLoading
          ? AppStrings.sendingOtp
          : AppStrings.sendOtp,
      isLoading: isLoading,
      icon: isLoading
          ? null
          : Icons.send_rounded,
      onPressed: canSend ? _sendOtp : null,
    );
  }

  // ── DIVIDER ───────────────────────────────────────────

  Widget _buildDivider() {
    return Row(children: [
      const Expanded(
          child: Divider(
              color: AppColors.border)),
      Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16),
        child: Text(
          AppStrings.orDivider,
          style: AppTextStyles.labelSmall,
        ),
      ),
      const Expanded(
          child: Divider(
              color: AppColors.border)),
    ]);
  }

  // ── GUEST BUTTON ──────────────────────────────────────

  Widget _buildGuestButton(bool isLoading) {
    return SecondaryButton(
      label: 'Explore Without Account',
      leadingIcon: Icons.explore_outlined,
      borderColor: AppColors.border,
      textColor: AppColors.inkSoft,
      onPressed: isLoading
          ? null
          : () async {
        final ok = await ref
            .read(authProvider.notifier)
            .signInAnonymously();
        if (!mounted) return;
        if (ok) context.go('/explore');
      },
    );
  }

  // ── TERMS ─────────────────────────────────────────────

  Widget _buildTerms() {
    return Center(
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.bodySmall,
          children: [
            TextSpan(
                text: AppStrings.termsPrefix),
            TextSpan(
              text: AppStrings.termsLink,
              style: const TextStyle(
                color: AppColors.crimson,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.crimson,
              ),
            ),
            TextSpan(text: AppStrings.andText),
            TextSpan(
              text: AppStrings.privacyLink,
              style: const TextStyle(
                color: AppColors.crimson,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.crimson,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PHONE FORMATTER
// Auto-formats: 9876543210 → 98765 43210
// ─────────────────────────────────────────────────────────

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '');

    final limited = digits.length > 10
        ? digits.substring(0, 10)
        : digits;

    String formatted = limited;
    if (limited.length > 5) {
      formatted =
      '${limited.substring(0, 5)} '
          '${limited.substring(5)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
          offset: formatted.length),
    );
  }
}