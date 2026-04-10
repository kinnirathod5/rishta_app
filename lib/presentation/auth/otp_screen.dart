import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  String _otpValue = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _timerSeconds = 60;
  Timer? _timer;

  // Format phone number for display
  String get _displayPhone {
    final p = widget.phoneNumber.trim();
    return p.startsWith('+91') ? p : '+91 $p';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length != 6) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    // Simulate verification — Firebase integration later
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Mock: "123456" is the correct OTP for testing
    if (otp == '123456') {
      setState(() => _isLoading = false);
      context.go(AppRoutePaths.explore);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Galat OTP hai, dobara try karo';
      });
      _otpController.clear();
      setState(() => _otpValue = '');
    }
  }

  void _resendOtp() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _otpValue = '';
    });
    _otpController.clear();
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP dobara bhej diya gaya ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(),
              const SizedBox(height: 32),
              _buildTopSection(),
              const SizedBox(height: 36),
              _buildOtpInputSection(),
              const SizedBox(height: 8),
              _buildErrorMessage(),
              const SizedBox(height: 28),
              _buildVerifyButton(),
              const SizedBox(height: 24),
              _buildResendSection(),
              const SizedBox(height: 28),
              _buildSecureBadge(),
            ],
          ),
        ),
      ),
    );
  }

  // ── BACK BUTTON ───────────────────────────────────────────
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.go(AppRoutePaths.phone),
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
    );
  }

  // ── TOP SECTION ───────────────────────────────────────────
  Widget _buildTopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔐', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 16),
        const Text(
          'Verify Karo',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'OTP bheja gaya  ',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            Text(
              _displayPhone,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.crimson,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => context.go(AppRoutePaths.phone),
          child: const Text(
            'Number change karna hai?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.crimson,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.crimson,
            ),
          ),
        ),
      ],
    );
  }

  // ── OTP INPUT ─────────────────────────────────────────────
  Widget _buildOtpInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6-digit OTP daalo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 14),
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: _otpController,
          focusNode: _otpFocusNode,
          keyboardType: TextInputType.number,
          animationType: AnimationType.fade,
          autoFocus: true,
          enableActiveFill: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          cursorColor: AppColors.crimson,
          backgroundColor: Colors.transparent,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            fieldHeight: 52,
            fieldWidth: 44,
            activeFillColor: AppColors.white,
            inactiveFillColor: AppColors.white,
            selectedFillColor: AppColors.white,
            activeColor: AppColors.crimson,
            inactiveColor: AppColors.border,
            selectedColor: AppColors.crimson,
            borderWidth: 2,
          ),
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          onChanged: (val) => setState(() => _otpValue = val),
          onCompleted: _verifyOtp,
        ),
      ],
    );
  }

  // ── ERROR MESSAGE ─────────────────────────────────────────
  Widget _buildErrorMessage() {
    return AnimatedOpacity(
      opacity: _hasError ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: AppColors.error),
          const SizedBox(width: 5),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  // ── VERIFY BUTTON ─────────────────────────────────────────
  Widget _buildVerifyButton() {
    final isReady = _otpValue.length == 6;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isReady && !_isLoading ? () => _verifyOtp(_otpValue) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? AppColors.crimson : AppColors.disabled,
          disabledBackgroundColor:
              isReady ? AppColors.crimson : AppColors.disabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? const Row(
                  key: ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Verify ho raha hai...',
                      style: TextStyle(fontSize: 15, color: AppColors.white),
                    ),
                  ],
                )
              : const Row(
                  key: ValueKey('idle'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                      color: AppColors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Verify Karo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── RESEND SECTION ────────────────────────────────────────
  Widget _buildResendSection() {
    return Center(
      child: Column(
        children: [
          const Divider(color: AppColors.border),
          const SizedBox(height: 20),
          _timerSeconds > 0
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.muted),
                    children: [
                      const TextSpan(text: 'OTP nahi aaya? '),
                      const TextSpan(text: 'Dobara bhejo ('),
                      TextSpan(
                        text: '$_timerSeconds s',
                        style: const TextStyle(
                          color: AppColors.crimson,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ')'),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: _resendOtp,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 13, color: AppColors.muted),
                      children: [
                        TextSpan(text: 'OTP nahi aaya? '),
                        TextSpan(
                          text: 'Dobara Bhejo',
                          style: TextStyle(
                            color: AppColors.crimson,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.crimson,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── SECURE BADGE ──────────────────────────────────────────
  Widget _buildSecureBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: AppColors.muted,
            ),
            SizedBox(width: 6),
            Text(
              'Secure OTP — 10 minute mein expire',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
