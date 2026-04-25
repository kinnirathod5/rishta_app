// lib/core/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// CUSTOM TEXT FIELD
// ─────────────────────────────────────────────────────────

/// Branded text field for RishtaApp.
///
/// Usage:
/// ```dart
/// // Basic:
/// AppTextField(
///   label: 'Full Name',
///   hint: 'e.g. Priya Sharma',
///   controller: _nameController,
///   validator: Validators.name,
/// )
///
/// // Phone field:
/// AppTextField.phone(
///   controller: _phoneController,
///   onChanged: (v) => setState(() {}),
/// )
///
/// // Password:
/// AppTextField.password(
///   controller: _passController,
/// )
///
/// // Search:
/// AppTextField.search(
///   hint: 'Search profiles...',
///   onChanged: _onSearch,
/// )
/// ```
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final int minLines;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final bool showCounter;
  final bool required;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final VoidCallback? onSuffixTap;
  final Color? fillColor;
  final String? initialValue;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.showCounter = false,
    this.required = false,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixWidget,
    this.prefixWidget,
    this.onSuffixTap,
    this.fillColor,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
  });

  // ── CONVENIENCE CONSTRUCTORS ──────────────────────

  /// Phone number field
  factory AppTextField.phone({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool autofocus = false,
  }) =>
      AppTextField(
        key: key,
        label: 'Mobile Number',
        hint: '98765 43210',
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        prefixIcon: Icons.phone_outlined,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        validator: validator,
        autofocus: autofocus,
        required: true,
      );

  /// Password field
  factory AppTextField.password({
    Key? key,
    String? label,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    TextInputAction textInputAction = TextInputAction.done,
  }) =>
      _PasswordTextField(
        key: key,
        label: label ?? 'Password',
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        onChanged: onChanged,
        textInputAction: textInputAction,
      ) as AppTextField;

  /// Search field
  factory AppTextField.search({
    Key? key,
    String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool autofocus = false,
  }) =>
      AppTextField(
        key: key,
        hint: hint ?? 'Search...',
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        prefixIcon: Icons.search_rounded,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        fillColor: AppColors.ivoryDark,
      );

  /// Multiline text area
  factory AppTextField.multiline({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    int maxLines = 5,
    int? maxLength,
    bool showCounter = true,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) =>
      AppTextField(
        key: key,
        label: label,
        hint: hint,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: maxLines,
        minLines: 3,
        maxLength: maxLength,
        showCounter: showCounter,
        validator: validator,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.sentences,
      );

  /// City / Location field
  factory AppTextField.city({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) =>
      AppTextField(
        key: key,
        label: 'Current City',
        hint: 'e.g. Delhi, Mumbai, Bangalore',
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.text,
        prefixIcon: Icons.location_on_outlined,
        validator: validator,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
        required: true,
      );

  /// Name field
  factory AppTextField.name({
    Key? key,
    String? label,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) =>
      AppTextField(
        key: key,
        label: label ?? 'Full Name',
        hint: 'e.g. Priya Sharma',
        controller: controller,
        focusNode: focusNode,
        prefixIcon: Icons.person_outline_rounded,
        validator: validator,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s']")),
          LengthLimitingTextInputFormatter(60),
        ],
        required: true,
      );

  /// Read-only info field
  factory AppTextField.readOnly({
    Key? key,
    required String label,
    required String value,
    IconData? prefixIcon,
    VoidCallback? onTap,
  }) =>
      AppTextField(
        key: key,
        label: label,
        controller: TextEditingController(text: value),
        prefixIcon: prefixIcon,
        readOnly: true,
        onTap: onTap,
        suffixIcon: onTap != null
            ? Icons.arrow_forward_ios_rounded
            : null,
        onSuffixTap: onTap,
      );

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  Color get _borderColor {
    if (_errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.crimson;
    return AppColors.border;
  }

  double get _borderWidth {
    if (_isFocused || _errorText != null) return 2;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── LABEL ───────────────────────────────
        if (widget.label != null) ...[
          Row(children: [
            Text(
              widget.label!,
              style: AppTextStyles.inputLabel,
            ),
            if (widget.required)
              Text(
                ' *',
                style: AppTextStyles.inputLabel.copyWith(
                    color: AppColors.crimson),
              ),
          ]),
          const SizedBox(height: 7),
        ],

        // ── INPUT ───────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _borderColor,
              width: _borderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: ColoredBox(
              color: widget.enabled
                  ? (widget.fillColor ?? AppColors.white)
                  : AppColors.ivoryDark,
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                initialValue: widget.initialValue,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                inputFormatters: widget.inputFormatters,
                maxLength: widget.maxLength,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                minLines: widget.minLines,
                obscureText: widget.obscureText,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                textCapitalization: widget.textCapitalization,
                style: AppTextStyles.inputText,
                cursorColor: AppColors.crimson,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                validator: (v) {
                  final err = widget.validator?.call(v);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _errorText = err);
                    }
                  });
                  return null; // We handle error display
                },
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.inputHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counterText: '',
                  contentPadding: _contentPadding(),
                  prefixIcon: _buildPrefixIcon(),
                  suffixIcon: _buildSuffixIcon(),
                ),
              ),
            ),
          ),
        ),

        // ── COUNTER (optional) ──────────────────
        if (widget.showCounter &&
            widget.maxLength != null &&
            widget.controller != null)
          _CounterText(
            controller: widget.controller!,
            maxLength: widget.maxLength!,
          ),

        // ── ERROR ───────────────────────────────
        if (_errorText != null)
          _ErrorText(message: _errorText!),

        // ── HELPER ──────────────────────────────
        if (widget.helperText != null && _errorText == null)
          _HelperText(message: widget.helperText!),
      ],
    );
  }

  EdgeInsetsGeometry _contentPadding() {
    final hasPrefixIcon =
        widget.prefixIcon != null || widget.prefixWidget != null;
    final hasSuffixIcon =
        widget.suffixIcon != null || widget.suffixWidget != null;

    return EdgeInsets.only(
      left: hasPrefixIcon ? 4 : 16,
      right: hasSuffixIcon ? 4 : 16,
      top: 14,
      bottom: 14,
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixWidget != null) {
      return widget.prefixWidget;
    }
    if (widget.prefixIcon != null) {
      return Icon(
        widget.prefixIcon,
        size: 18,
        color: _isFocused ? AppColors.crimson : AppColors.muted,
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixWidget != null) {
      return widget.suffixWidget;
    }
    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: Icon(
          widget.suffixIcon,
          size: 18,
          color: AppColors.muted,
        ),
      );
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────
// PASSWORD TEXT FIELD
// ─────────────────────────────────────────────────────────

class _PasswordTextField extends AppTextField {
  const _PasswordTextField({
    super.key,
    required String label,
    super.controller,
    super.focusNode,
    super.validator,
    super.onChanged,
    super.textInputAction,
  }) : super(
    label: label,
    hint: '••••••••',
    keyboardType: TextInputType.visiblePassword,
    obscureText: true,
    prefixIcon: Icons.lock_outline_rounded,
    required: true,
  );
}

// ─────────────────────────────────────────────────────────
// APP DROPDOWN FIELD
// ─────────────────────────────────────────────────────────

/// Branded dropdown field.
///
/// ```dart
/// AppDropdownField<String>(
///   label: 'Religion',
///   hint: 'Select religion',
///   value: _religion,
///   items: ['Hindu', 'Muslim', 'Christian'],
///   onChanged: (v) => setState(() => _religion = v),
///   validator: Validators.religion,
/// )
/// ```
class AppDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<T> items;
  final String Function(T)? itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool required;
  final bool enabled;
  final IconData? prefixIcon;
  final String? helperText;

  const AppDropdownField({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value,
    this.itemLabel,
    this.onChanged,
    this.validator,
    this.required = false,
    this.enabled = true,
    this.prefixIcon,
    this.helperText,
  });

  @override
  State<AppDropdownField<T>> createState() =>
      _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T>
    extends State<AppDropdownField<T>> {
  String? _errorText;
  bool _isFocused = false;

  Color get _borderColor {
    if (_errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.crimson;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(children: [
            Text(widget.label!,
                style: AppTextStyles.inputLabel),
            if (widget.required)
              Text(' *',
                  style: AppTextStyles.inputLabel
                      .copyWith(color: AppColors.crimson)),
          ]),
          const SizedBox(height: 7),
        ],

        // Dropdown
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _borderColor,
              width: _isFocused ? 2 : 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: ColoredBox(
              color: widget.enabled
                  ? AppColors.white
                  : AppColors.ivoryDark,
              child: DropdownButtonFormField<T>(
                value: widget.value,
                isExpanded: true,
                dropdownColor: AppColors.white,
                icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.muted),
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.inputHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                    widget.prefixIcon,
                    size: 18,
                    color: AppColors.muted,
                  )
                      : null,
                  counterText: '',
                ),
                onTap: () => setState(() => _isFocused = true),
                onChanged: widget.enabled
                    ? (v) {
                  setState(() => _isFocused = false);
                  widget.onChanged?.call(v);
                }
                    : null,
                validator: (v) {
                  final err = widget.validator?.call(v);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _errorText = err);
                    }
                  });
                  return null;
                },
                items: widget.items
                    .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    widget.itemLabel?.call(item) ??
                        item.toString(),
                    style: AppTextStyles.inputText,
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
        ),

        if (_errorText != null)
          _ErrorText(message: _errorText!),

        if (widget.helperText != null && _errorText == null)
          _HelperText(message: widget.helperText!),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// OTP INPUT FIELD
// ─────────────────────────────────────────────────────────

/// Individual OTP digit box.
class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool hasError;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasError
                  ? AppColors.error
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasError
                  ? AppColors.error
                  : AppColors.crimson,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          fillColor: hasError
              ? AppColors.errorSurface
              : AppColors.white,
          filled: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE HELPER WIDGETS
// ─────────────────────────────────────────────────────────

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.error),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.inputError,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelperText extends StatelessWidget {
  final String message;
  const _HelperText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 4),
      child: Text(
        message,
        style: AppTextStyles.inputError.copyWith(
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _CounterText extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  const _CounterText(
      {required this.controller, required this.maxLength});

  @override
  State<_CounterText> createState() => _CounterTextState();
}

class _CounterTextState extends State<_CounterText> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.controller.text.length;
    final isNearLimit = count >= widget.maxLength * 0.9;
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$count / ${widget.maxLength}',
          style: AppTextStyles.inputError.copyWith(
            color: isNearLimit ? AppColors.error : AppColors.muted,
          ),
        ),
      ),
    );
  }
}