// lib/presentation/auth/otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_strings.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpScreen> createState() =>
      _OtpScreenState();
}

class _OtpScreenState
    extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {

  // ── OTP CONTROLLERS ───────────────────────────────────
  final List<TextEditingController> _ctrls =
  List.generate(6,
          (_) => TextEditingController());
  final List<FocusNode> _focuses =
  List.generate(6, (_) => FocusNode());

  bool _hasError = false;
  String _otp = '';

  // ── RESEND TIMER ──────────────────────────────────────
  int _secondsLeft = 30;
  bool _canResend = false;
  Timer? _timer;

  // ── ENTRY ANIMATION ───────────────────────────────────
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _entryCtrl.forward();
    _startTimer();
    // Auto-focus first box
    Future.delayed(
        const Duration(milliseconds: 400),
            () {
          if (mounted) {
            _focuses[0].requestFocus();
          }
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

  // ── TIMER ─────────────────────────────────────────────

  void _startTimer() {
    setState(() {
      _secondsLeft = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  // ── OTP LOGIC ─────────────────────────────────────────

  String get _currentOtp =>
      _ctrls.map((c) => c.text).join();

  bool get _isComplete =>
      _currentOtp.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) {
      // Backspace — go back
      if (index > 0) {
        _focuses[index - 1].requestFocus();
      }
    } else if (value.length == 1) {
      // Move to next
      if (index < 5) {
        _focuses[index + 1].requestFocus();
      } else {
        // Last digit — unfocus and auto verify
        _focuses[index].unfocus();
        _autoVerify();
      }
    } else if (value.length > 1) {
      // Paste handling
      _handlePaste(value);
    }

    setState(() {
      _otp = _currentOtp;
      if (_hasError) _hasError = false;
    });
  }

  void _handlePaste(String pasted) {
    final digits = pasted
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 6) {
      for (int i = 0; i < 6; i++) {
        _ctrls[i].text = digits[i];
      }
      setState(() => _otp = digits.substring(0, 6));
      _focuses[5].unfocus();
      _autoVerify();
    }
  }

  void _autoVerify() {
    if (_isComplete) {
      Future.delayed(
          const Duration(milliseconds: 200),
          _verify);
    }
  }

  // ── VERIFY ────────────────────────────────────────────

  Future<void> _verify() async {
    if (!_isComplete) return;
    final otp = _currentOtp;

    final ok = await ref
        .read(authProvider.notifier)
        .verifyOtp(otp);

    if (!mounted) return;

    if (ok) {
      HapticFeedback.heavyImpact();
      _navigateAfterAuth();
    } else {
      HapticFeedback.vibrate();
      setState(() => _hasError = true);
      _shakeBoxes();
    }
  }

  void _navigateAfterAuth() {
    final state = ref.read(authProvider);
    if (state.isAnonymous) {
      context.go('/explore');
    } else if (state.hasCompletedSetup) {
      context.go('/home');
    } else {
      context.go('/profile-type');
    }
  }

  void _shakeBoxes() {
    // Clear all boxes on error
    for (final c in _ctrls) {
      c.clear();
    }
    setState(() => _otp = '');
    Future.delayed(
        const Duration(milliseconds: 100), () {
      if (mounted) _focuses[0].requestFocus();
    });
  }

  // ── RESEND ────────────────────────────────────────────

  Future<void> _resend() async {
    if (!_canResend) return;

    for (final c in _ctrls) c.clear();
    setState(() {
      _otp = '';
      _hasError = false;
    });

    ref.read(authProvider.notifier).clearError();

    await ref
        .read(authProvider.notifier)
        .resendOtp(
      onCodeSent: (_) {
        if (mounted) {
          _startTimer();
          _focuses[0].requestFocus();
          _showSnack('OTP resent successfully');
        }
      },
      onError: (e) {
        if (mounted) {
          _showSnack(e, isError: true);
        }
      },
    );
  }

  void _showSnack(String msg,
      {bool isError = false}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white)),
      backgroundColor:
      isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entryCtrl.dispose();
    for (final c in _ctrls) c.dispose();
    for (final f in _focuses) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
                  _buildBackButton(isLoading),
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildOtpBoxes(isLoading),
                  const SizedBox(height: 12),
                  _buildErrorRow(authState),
                  const SizedBox(height: 32),
                  _buildVerifyButton(isLoading),
                  const SizedBox(height: 28),
                  _buildResendRow(isLoading),
                  const SizedBox(height: 32),
                  _buildDevHint(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── BACK BUTTON ───────────────────────────────────────

  Widget _buildBackButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () => context.go('/phone'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: isLoading
                ? AppColors.muted
                : AppColors.ink,
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
          '🔐',
          style: TextStyle(fontSize: 44),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.verifyNumber,
          style: AppTextStyles.onboardTitle,
        ),
        const SizedBox(height: 10),
        // Phone number display
        RichText(
          text: TextSpan(
            style: AppTextStyles.onboardSubtitle,
            children: [
              TextSpan(
                  text: AppStrings.otpSentTo +
                      ' '),
              TextSpan(
                text: widget.phoneNumber,
                style: AppTextStyles
                    .onboardSubtitle
                    .copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Change number
        GestureDetector(
          onTap: () => context.go('/phone'),
          child: Text(
            AppStrings.changeNumber,
            style:
            AppTextStyles.bodySmall.copyWith(
              color: AppColors.crimson,
              fontWeight: FontWeight.w600,
              decoration:
              TextDecoration.underline,
              decorationColor: AppColors.crimson,
            ),
          ),
        ),
      ],
    );
  }

  // ── OTP BOXES ─────────────────────────────────────────

  Widget _buildOtpBoxes(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.enterOtp,
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) =>
              _OtpBox(
                controller: _ctrls[i],
                focusNode: _focuses[i],
                hasError: _hasError,
                isDisabled: isLoading,
                onChanged: (v) =>
                    _onDigitChanged(i, v),
              )),
        ),
      ],
    );
  }

  // ── ERROR ROW ─────────────────────────────────────────

  Widget _buildErrorRow(AuthState authState) {
    final errorMsg = _hasError
        ? AppStrings.invalidOtp
        : (authState.hasError
        ? authState.error
        : null);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: errorMsg != null
          ? Row(children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 14,
          color: AppColors.error,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            errorMsg,
            style: AppTextStyles.inputError,
          ),
        ),
      ])
          : const SizedBox.shrink(),
    );
  }

  // ── VERIFY BUTTON ─────────────────────────────────────

  Widget _buildVerifyButton(bool isLoading) {
    return PrimaryButton(
      label: isLoading
          ? AppStrings.verifying
          : AppStrings.verify,
      isLoading: isLoading,
      onPressed:
      _isComplete && !isLoading
          ? _verify
          : null,
    );
  }

  // ── RESEND ROW ────────────────────────────────────────

  Widget _buildResendRow(bool isLoading) {
    return Center(
      child: _canResend
          ? GestureDetector(
        onTap: isLoading ? null : _resend,
        child: Container(
          padding:
          const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10),
          decoration: BoxDecoration(
            color:
            AppColors.crimsonSurface,
            borderRadius:
            BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.crimson
                  .withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.refresh_rounded,
                size: 15,
                color: AppColors.crimson,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.resendOtp,
                style: AppTextStyles
                    .labelMedium
                    .copyWith(
                    color:
                    AppColors.crimson),
              ),
            ],
          ),
        ),
      )
          : Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.didntReceive,
            style:
            AppTextStyles.bodySmall,
          ),
          // Countdown
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 30,
              end: _secondsLeft.toDouble(),
            ),
            duration: const Duration(
                milliseconds: 500),
            builder: (_, val, __) =>
                Text(
                  '${val.ceil()}s)',
                  style: AppTextStyles
                      .bodySmall
                      .copyWith(
                    fontWeight:
                    FontWeight.w700,
                    color: AppColors.crimson,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // ── DEV HINT ──────────────────────────────────────────

  Widget _buildDevHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.code_rounded,
            size: 16,
            color: AppColors.gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:
                AppTextStyles.bodySmall,
                children: [
                  const TextSpan(
                    text: 'Dev Mode: Use OTP ',
                  ),
                  TextSpan(
                    text: '1 2 3 4 5 6',
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                      fontWeight:
                      FontWeight.w700,
                      color: AppColors.gold,
                      letterSpacing: 3,
                    ),
                  ),
                  const TextSpan(
                    text: ' to login',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// OTP BOX WIDGET
// ─────────────────────────────────────────────────────────

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool isDisabled;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.isDisabled,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() =>
      _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode
        .addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(
            () => _isFocused =
            widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode
        .removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilled =
        widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration:
      const Duration(milliseconds: 180),
      width: 46,
      height: 54,
      decoration: BoxDecoration(
        color: widget.isDisabled
            ? AppColors.ivoryDark
            : widget.hasError
            ? AppColors.errorSurface
            : hasFilled
            ? AppColors.crimsonSurface
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.hasError
              ? AppColors.error
              : _isFocused
              ? AppColors.crimson
              : hasFilled
              ? AppColors.crimson
              .withOpacity(0.4)
              : AppColors.border,
          width: (_isFocused ||
              widget.hasError)
              ? 2
              : 1.5,
        ),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: AppColors.crimson
                .withOpacity(0.12),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: !widget.isDisabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 2,
        // 2 to handle paste
        inputFormatters: [
          FilteringTextInputFormatter
              .digitsOnly,
        ],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: widget.hasError
              ? AppColors.error
              : AppColors.ink,
          letterSpacing: 0,
        ),
        cursorColor: AppColors.crimson,
        cursorWidth: 2,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}