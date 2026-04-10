import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  bool _isValidPhone() {
    final val = _phoneController.text.trim();
    return val.length == 10 && RegExp(r'^[6-9][0-9]{9}$').hasMatch(val);
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Simulate OTP send — Firebase integration later
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.go(
      AppRoutePaths.otp,
      extra: '+91${_phoneController.text.trim()}',
    );
  }

  void _signInWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Google login jald aayega! 🚀'),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 32),
                _buildTopSection(),
                const SizedBox(height: 36),
                _buildPhoneInputSection(),
                const SizedBox(height: 12),
                _buildInfoChips(),
                const SizedBox(height: 32),
                _buildSendOtpButton(),
                const SizedBox(height: 28),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildGoogleButton(),
                const SizedBox(height: 28),
                _buildBottomText(),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutePaths.welcome);
            }
          },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📱', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 16),
        const Text(
          'Apna Number\nDaalo',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          AppStrings.phoneSubtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  // ── PHONE INPUT ───────────────────────────────────────────
  Widget _buildPhoneInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.phoneHint,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Country code box
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🇮🇳', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 6),
                  Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Phone number field
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) {
                  if (_isValidPhone()) _sendOtp();
                },
                validator: Validators.phone,
                decoration: InputDecoration(
                  hintText: '98765 43210',
                  hintStyle: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.crimson,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── INFO CHIPS ────────────────────────────────────────────
  Widget _buildInfoChips() {
    const chips = ['✓ 10 digits', '✓ 6/7/8/9 se shuru', '✓ India only'];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: chips.map((text) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.ivoryDark,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── SEND OTP BUTTON ───────────────────────────────────────
  Widget _buildSendOtpButton() {
    final isValid = _isValidPhone();
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isValid && !_isLoading ? _sendOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? AppColors.crimson : AppColors.disabled,
          disabledBackgroundColor:
              isValid ? AppColors.crimson : AppColors.disabled,
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
                      'Bhej rahe hain...',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                )
              : const Row(
                  key: ValueKey('idle'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.btnSendOtp,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── DIVIDER ───────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'YA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  // ── GOOGLE BUTTON ─────────────────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.btnGoogleLogin,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM TEXT ───────────────────────────────────────────
  Widget _buildBottomText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(fontSize: 11, color: AppColors.muted),
          children: [
            TextSpan(text: 'Login karke aap hamare '),
            TextSpan(
              text: 'Terms & Conditions',
              style: TextStyle(
                color: AppColors.crimson,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' aur '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: AppColors.crimson,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' se agree karte hain'),
          ],
        ),
      ),
    );
  }
}
