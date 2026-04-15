// lib/core/widgets/custom_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// BUTTON SIZE ENUM
// ─────────────────────────────────────────────────────────

enum ButtonSize {
  small,   // h: 36  — chips, inline actions
  medium,  // h: 44  — secondary actions
  large,   // h: 52  — primary CTA (default)
  xlarge,  // h: 60  — hero CTA
}

extension ButtonSizeValues on ButtonSize {
  double get height {
    switch (this) {
      case ButtonSize.small:  return 36;
      case ButtonSize.medium: return 44;
      case ButtonSize.large:  return 52;
      case ButtonSize.xlarge: return 60;
    }
  }

  double get fontSize {
    switch (this) {
      case ButtonSize.small:  return 13;
      case ButtonSize.medium: return 14;
      case ButtonSize.large:  return 16;
      case ButtonSize.xlarge: return 18;
    }
  }

  double get iconSize {
    switch (this) {
      case ButtonSize.small:  return 14;
      case ButtonSize.medium: return 16;
      case ButtonSize.large:  return 18;
      case ButtonSize.xlarge: return 22;
    }
  }

  double get borderRadius {
    switch (this) {
      case ButtonSize.small:  return 8;
      case ButtonSize.medium: return 10;
      case ButtonSize.large:  return 12;
      case ButtonSize.xlarge: return 14;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
            horizontal: 16);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
            horizontal: 20);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
            horizontal: 24);
      case ButtonSize.xlarge:
        return const EdgeInsets.symmetric(
            horizontal: 28);
    }
  }
}

// ─────────────────────────────────────────────────────────
// PRIMARY BUTTON
// ─────────────────────────────────────────────────────────

/// Full-width crimson primary button.
///
/// Usage:
/// ```dart
/// // Standard:
/// PrimaryButton(
///   label: 'Send OTP',
///   onPressed: _sendOtp,
/// )
///
/// // Loading state:
/// PrimaryButton(
///   label: 'Saving...',
///   isLoading: _isSaving,
///   onPressed: _save,
/// )
///
/// // With icon:
/// PrimaryButton(
///   label: 'Continue',
///   icon: Icons.arrow_forward_rounded,
///   onPressed: _continue,
/// )
/// ```
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;
  final IconData? icon;
  final IconData? leadingIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool haptic;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.icon,
    this.leadingIcon,
    this.backgroundColor,
    this.textColor,
    this.haptic = true,
  });

  // ── VARIANTS ─────────────────────────────────────

  /// Success green button
  const PrimaryButton.success({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.icon,
    this.leadingIcon,
    this.haptic = true,
  })  : backgroundColor = AppColors.success,
        textColor = Colors.white;

  /// Gold premium button
  const PrimaryButton.gold({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.icon,
    this.leadingIcon,
    this.haptic = true,
  })  : backgroundColor = AppColors.gold,
        textColor = Colors.white;

  /// Danger/error red button
  const PrimaryButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.icon,
    this.leadingIcon,
    this.haptic = true,
  })  : backgroundColor = AppColors.error,
        textColor = Colors.white;

  @override
  State<PrimaryButton> createState() =>
      _PrimaryButtonState();
}

class _PrimaryButtonState
    extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDisabled =>
      widget.onPressed == null || widget.isLoading;

  void _onTapDown(_) {
    if (!_isDisabled) _controller.forward();
  }

  void _onTapUp(_) {
    if (!_isDisabled) _controller.reverse();
  }

  void _onTapCancel() => _controller.reverse();

  void _onTap() {
    if (_isDisabled) return;
    if (widget.haptic) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDisabled
        ? AppColors.disabled
        : (widget.backgroundColor ??
        AppColors.crimson);
    final fg = widget.textColor ?? Colors.white;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 200),
          width: widget.isFullWidth
              ? double.infinity
              : null,
          height: widget.size.height,
          padding: widget.isFullWidth
              ? null
              : widget.size.padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(
                widget.size.borderRadius),
            boxShadow: _isDisabled
                ? null
                : [
              BoxShadow(
                color: bg.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? _LoadingContent(
              color: fg,
              label: widget.label,
              size: widget.size,
            )
                : _ButtonContent(
              label: widget.label,
              icon: widget.icon,
              leadingIcon: widget.leadingIcon,
              color: fg,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SECONDARY BUTTON (Outlined)
// ─────────────────────────────────────────────────────────

/// Outlined button — secondary actions.
class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;
  final IconData? icon;
  final IconData? leadingIcon;
  final Color? borderColor;
  final Color? textColor;
  final bool haptic;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.icon,
    this.leadingIcon,
    this.borderColor,
    this.textColor,
    this.haptic = true,
  });

  @override
  State<SecondaryButton> createState() =>
      _SecondaryButtonState();
}

class _SecondaryButtonState
    extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scale = Tween<double>(
      begin: 1.0, end: 0.97,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDisabled =>
      widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final color = widget.textColor ??
        widget.borderColor ??
        AppColors.crimson;
    final border =
        widget.borderColor ?? AppColors.crimson;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: () {
          if (_isDisabled) return;
          if (widget.haptic) {
            HapticFeedback.lightImpact();
          }
          widget.onPressed?.call();
        },
        onTapDown: (_) {
          if (!_isDisabled) {
            _controller.forward();
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) {
          _controller.reverse();
          setState(() => _isPressed = false);
        },
        onTapCancel: () {
          _controller.reverse();
          setState(() => _isPressed = false);
        },
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 150),
          width: widget.isFullWidth
              ? double.infinity
              : null,
          height: widget.size.height,
          padding: widget.isFullWidth
              ? null
              : widget.size.padding,
          decoration: BoxDecoration(
            color: _isPressed
                ? border.withOpacity(0.06)
                : AppColors.white,
            borderRadius: BorderRadius.circular(
                widget.size.borderRadius),
            border: Border.all(
              color: _isDisabled
                  ? AppColors.border
                  : border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? _LoadingContent(
              color: color,
              label: widget.label,
              size: widget.size,
            )
                : _ButtonContent(
              label: widget.label,
              icon: widget.icon,
              leadingIcon: widget.leadingIcon,
              color: _isDisabled
                  ? AppColors.disabled
                  : color,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TEXT BUTTON
// ─────────────────────────────────────────────────────────

/// Minimal text-only button.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final ButtonSize size;
  final IconData? icon;
  final bool underline;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.size = ButtonSize.medium,
    this.icon,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.crimson;
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: size.iconSize, color: c),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: size.fontSize,
                fontWeight: FontWeight.w600,
                color: onPressed == null
                    ? AppColors.disabled
                    : c,
                decoration: underline
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ICON BUTTON
// ─────────────────────────────────────────────────────────

/// Square icon button with optional badge.
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? bgColor;
  final double size;
  final double iconSize;
  final double borderRadius;
  final int badgeCount;
  final Color? badgeColor;
  final bool hasBorder;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.bgColor,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius = 12,
    this.badgeCount = 0,
    this.badgeColor,
    this.hasBorder = false,
  });

  /// Circle variant
  const AppIconButton.circle({
    super.key,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.bgColor,
    this.size = 40,
    this.iconSize = 20,
    this.badgeCount = 0,
    this.badgeColor,
    this.hasBorder = false,
  }) : borderRadius = 100;

  /// On dark background (white icons)
  const AppIconButton.onDark({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 36,
    this.iconSize = 20,
    this.borderRadius = 10,
    this.badgeCount = 0,
    this.hasBorder = false,
  })  : iconColor = Colors.white,
        bgColor =
        const Color(0x1FFFFFFF),
        badgeColor = null;

  @override
  State<AppIconButton> createState() =>
      _AppIconButtonState();
}

class _AppIconButtonState
    extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0, end: 0.90,
    ).animate(CurvedAnimation(
      parent: _ctrl, curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.bgColor ??
                    AppColors.ivoryDark,
                borderRadius:
                BorderRadius.circular(
                    widget.borderRadius),
                border: widget.hasBorder
                    ? Border.all(
                    color: AppColors.border,
                    width: 1.5)
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.iconColor ??
                      AppColors.inkSoft,
                ),
              ),
            ),
            // Badge
            if (widget.badgeCount > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.badgeColor ??
                        AppColors.crimson,
                    borderRadius:
                    BorderRadius.circular(
                        100),
                    border: Border.all(
                        color: AppColors.white,
                        width: 1.5),
                  ),
                  child: Text(
                    widget.badgeCount > 99
                        ? '99+'
                        : '${widget.badgeCount}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
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

// ─────────────────────────────────────────────────────────
// INTEREST BUTTON
// ─────────────────────────────────────────────────────────

/// Animated interest send/sent button.
class InterestButton extends StatelessWidget {
  final bool isInterested;
  final VoidCallback? onTap;
  final bool isCompact;
  final bool isFullWidth;

  const InterestButton({
    super.key,
    required this.isInterested,
    this.onTap,
    this.isCompact = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: isInterested
              ? AppColors.crimson
              : AppColors.crimsonSurface,
          borderRadius: BorderRadius.circular(
              isCompact ? 8 : 10),
          border: isInterested
              ? null
              : Border.all(
              color: AppColors.crimson
                  .withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: isFullWidth
              ? MainAxisSize.max
              : MainAxisSize.min,
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(
                  milliseconds: 200),
              transitionBuilder:
                  (child, anim) => ScaleTransition(
                scale: anim,
                child: child,
              ),
              child: Icon(
                isInterested
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isInterested),
                size: isCompact ? 13 : 16,
                color: isInterested
                    ? Colors.white
                    : AppColors.crimson,
              ),
            ),
            SizedBox(width: isCompact ? 4 : 6),
            AnimatedSwitcher(
              duration: const Duration(
                  milliseconds: 200),
              child: Text(
                isInterested
                    ? 'Sent ✓'
                    : 'Send Interest',
                key: ValueKey(isInterested),
                style: TextStyle(
                  fontSize: isCompact ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: isInterested
                      ? Colors.white
                      : AppColors.crimson,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SHORTLIST BUTTON
// ─────────────────────────────────────────────────────────

/// Animated bookmark shortlist button.
class ShortlistButton extends StatelessWidget {
  final bool isShortlisted;
  final VoidCallback? onTap;
  final bool isCircle;
  final double size;

  const ShortlistButton({
    super.key,
    required this.isShortlisted,
    this.onTap,
    this.isCircle = false,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isShortlisted
              ? AppColors.goldSurface
              : AppColors.ivoryDark,
          shape: isCircle
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: isCircle
              ? null
              : BorderRadius.circular(10),
          border: Border.all(
            color: isShortlisted
                ? AppColors.gold
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration:
            const Duration(milliseconds: 200),
            transitionBuilder:
                (child, anim) =>
                ScaleTransition(
                  scale: anim,
                  child: child,
                ),
            child: Icon(
              isShortlisted
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              key: ValueKey(isShortlisted),
              size: size * 0.45,
              color: isShortlisted
                  ? AppColors.gold
                  : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BACK BUTTON
// ─────────────────────────────────────────────────────────

/// Standard back button for all screens.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? iconColor;

  const AppBackButton({
    super.key,
    this.onTap,
    this.bgColor,
    this.iconColor,
  });

  /// White variant — for dark backgrounds
  const AppBackButton.white({
    super.key,
    this.onTap,
  })  : bgColor = const Color(0x26FFFFFF),
        iconColor = Colors.white;

  /// Circle variant
  const AppBackButton.circle({
    super.key,
    this.onTap,
    this.bgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.softShadow,
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: iconColor ?? AppColors.ink,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// GRADIENT BUTTON
// ─────────────────────────────────────────────────────────

/// Gradient CTA button — for premium/featured sections.
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;
  final IconData? icon;
  final IconData? leadingIcon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient = AppColors.crimsonGradient,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.icon,
    this.leadingIcon,
  });

  const GradientButton.gold({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
    this.icon,
    this.leadingIcon,
  }) : gradient = AppColors.goldGradient;

  @override
  State<GradientButton> createState() =>
      _GradientButtonState();
}

class _GradientButtonState
    extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0, end: 0.96,
    ).animate(CurvedAnimation(
      parent: _ctrl, curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isDisabled =>
      widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: () {
          if (_isDisabled) return;
          HapticFeedback.lightImpact();
          widget.onPressed?.call();
        },
        onTapDown: (_) {
          if (!_isDisabled) _ctrl.forward();
        },
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: widget.isFullWidth
              ? double.infinity
              : null,
          height: widget.size.height,
          padding: widget.isFullWidth
              ? null
              : widget.size.padding,
          decoration: BoxDecoration(
            gradient: _isDisabled
                ? null
                : widget.gradient,
            color: _isDisabled
                ? AppColors.disabled
                : null,
            borderRadius: BorderRadius.circular(
                widget.size.borderRadius),
            boxShadow: _isDisabled
                ? null
                : AppColors.cardShadow,
          ),
          child: Center(
            child: widget.isLoading
                ? _LoadingContent(
              color: Colors.white,
              label: widget.label,
              size: widget.size,
            )
                : _ButtonContent(
              label: widget.label,
              icon: widget.icon,
              leadingIcon: widget.leadingIcon,
              color: Colors.white,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE SHARED WIDGETS
// ─────────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? leadingIcon;
  final Color color;
  final ButtonSize size;

  const _ButtonContent({
    required this.label,
    this.icon,
    this.leadingIcon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon,
              size: size.iconSize, color: color),
          SizedBox(
              width:
              size == ButtonSize.small ? 5 : 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: size.fontSize,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
        if (icon != null) ...[
          SizedBox(
              width:
              size == ButtonSize.small ? 5 : 8),
          Icon(icon,
              size: size.iconSize, color: color),
        ],
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  final Color color;
  final String label;
  final ButtonSize size;

  const _LoadingContent({
    required this.color,
    required this.label,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size.iconSize,
          height: size.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: color,
          ),
        ),
        SizedBox(
            width: size == ButtonSize.small
                ? 6
                : 10),
        Text(
          label,
          style: TextStyle(
            fontSize: size.fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}