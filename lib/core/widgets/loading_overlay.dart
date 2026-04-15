// lib/core/widgets/loading_overlay.dart

import 'package:flutter/material.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// LOADING OVERLAY WIDGET
// Blocks UI interaction while async operation runs
// ─────────────────────────────────────────────────────────

/// Full-screen loading overlay.
///
/// Usage:
/// ```dart
/// // 1. Wrap screen in Stack:
/// Stack(children: [
///   YourScreen(),
///   if (_isLoading) const LoadingOverlay(),
/// ])
///
/// // 2. With message:
/// LoadingOverlay(message: 'Saving profile...')
///
/// // 3. Show programmatically:
/// LoadingOverlay.show(context, message: 'Please wait...');
/// LoadingOverlay.hide(context);
/// ```
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool dismissible;
  final Color? barrierColor;
  final LoadingStyle style;

  const LoadingOverlay({
    super.key,
    this.message,
    this.dismissible = false,
    this.barrierColor,
    this.style = LoadingStyle.card,
  });

  // ── STATIC SHOW / HIDE ────────────────────────────────

  static OverlayEntry? _overlayEntry;

  /// Show loading overlay on top of everything
  static void show(
      BuildContext context, {
        String? message,
        LoadingStyle style = LoadingStyle.card,
      }) {
    hide(context); // Remove existing if any

    _overlayEntry = OverlayEntry(
      builder: (_) => LoadingOverlay(
        message: message,
        style: style,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: dismissible
              ? () => Navigator.of(context).pop()
              : null,
          child: Container(
            color: barrierColor ??
                AppColors.scrim,
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (style) {
      case LoadingStyle.card:
        return _CardLoader(message: message);
      case LoadingStyle.minimal:
        return _MinimalLoader(message: message);
      case LoadingStyle.dots:
        return _DotsLoader(message: message);
      case LoadingStyle.logo:
        return _LogoLoader(message: message);
    }
  }
}

// ─────────────────────────────────────────────────────────
// LOADING STYLE ENUM
// ─────────────────────────────────────────────────────────

enum LoadingStyle {
  card,     // White card with spinner
  minimal,  // Just spinner, no card
  dots,     // Animated dots
  logo,     // App logo with spinner
}

// ─────────────────────────────────────────────────────────
// CARD LOADER (Default)
// ─────────────────────────────────────────────────────────

class _CardLoader extends StatelessWidget {
  final String? message;
  const _CardLoader({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.modalShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CrimsonSpinner(),
          if (message != null) ...[
            const SizedBox(height: 18),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// MINIMAL LOADER
// ─────────────────────────────────────────────────────────

class _MinimalLoader extends StatelessWidget {
  final String? message;
  const _MinimalLoader({this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 14),
          Text(
            message!,
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// DOTS LOADER
// ─────────────────────────────────────────────────────────

class _DotsLoader extends StatefulWidget {
  final String? message;
  const _DotsLoader({this.message});

  @override
  State<_DotsLoader> createState() =>
      _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.modalShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Three animated dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  // Stagger each dot
                  final delay = i * 0.2;
                  final progress =
                  ((_controller.value - delay) %
                      1.0)
                      .clamp(0.0, 1.0);
                  final scale = progress < 0.5
                      ? 1.0 + (progress * 2 * 0.4)
                      : 1.4 -
                      ((progress - 0.5) *
                          2 *
                          0.4);
                  return Container(
                    margin:
                    const EdgeInsets.symmetric(
                        horizontal: 4),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.crimson
                              .withOpacity(
                              0.4 + progress * 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 18),
            Text(
              widget.message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LOGO LOADER
// ─────────────────────────────────────────────────────────

class _LogoLoader extends StatefulWidget {
  final String? message;
  const _LogoLoader({this.message});

  @override
  State<_LogoLoader> createState() =>
      _LogoLoaderState();
}

class _LogoLoaderState extends State<_LogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulse,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.crimsonGradient,
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold
                    .withOpacity(0.5),
                width: 2,
              ),
              boxShadow: AppColors.crimsonShadow,
            ),
            child: const Center(
              child: Text('💍',
                  style: TextStyle(fontSize: 36)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _CrimsonSpinnerWhite(),
        if (widget.message != null) ...[
          const SizedBox(height: 14),
          Text(
            widget.message!,
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// INLINE LOADING WIDGETS
// Use inside cards, buttons, lists
// ─────────────────────────────────────────────────────────

/// Small crimson spinner — for inline use
class AppSpinner extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const AppSpinner({
    super.key,
    this.size = 20,
    this.color = AppColors.crimson,
    this.strokeWidth = 2.5,
  });

  /// White variant — for use on dark backgrounds
  const AppSpinner.white({
    super.key,
    this.size = 20,
    this.strokeWidth = 2.5,
  }) : color = Colors.white;

  /// Small variant
  const AppSpinner.small({
    super.key,
    this.color = AppColors.crimson,
  })  : size = 16,
        strokeWidth = 2;

  /// Large variant
  const AppSpinner.large({
    super.key,
    this.color = AppColors.crimson,
  })  : size = 36,
        strokeWidth = 3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

/// Button loading state — spinner + label
class ButtonLoader extends StatelessWidget {
  final String label;
  final Color textColor;

  const ButtonLoader({
    super.key,
    required this.label,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: textColor,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.buttonPrimary
              .copyWith(color: textColor),
        ),
      ],
    );
  }
}

/// Center page loading indicator
class PageLoader extends StatelessWidget {
  final String? message;

  const PageLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSpinner.large(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading for list items
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Full card shimmer
  const ShimmerLoader.card({super.key})
      : width = double.infinity,
        height = 120,
        borderRadius = 14;

  /// Text line shimmer
  const ShimmerLoader.text({
    super.key,
    this.width = 200,
  })  : height = 14,
        borderRadius = 7;

  /// Avatar shimmer
  const ShimmerLoader.avatar({super.key})
      : width = 48,
        height = 48,
        borderRadius = 100;

  @override
  State<ShimmerLoader> createState() =>
      _ShimmerLoaderState();
}

class _ShimmerLoaderState
    extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_animation.value - 1).clamp(0.0, 1.0),
              _animation.value.clamp(0.0, 1.0),
              (_animation.value + 1).clamp(0.0, 1.0),
            ],
            colors: const [
              Color(0xFFEEE8E0),
              Color(0xFFF8F4EE),
              Color(0xFFEEE8E0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full profile card shimmer
class ProfileCardShimmer extends StatelessWidget {
  const ProfileCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar shimmer
          const ShimmerLoader.avatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const ShimmerLoader.text(width: 160),
                const SizedBox(height: 8),
                const ShimmerLoader.text(width: 120),
                const SizedBox(height: 8),
                ShimmerLoader.text(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal match card shimmer
class MatchCardShimmer extends StatelessWidget {
  const MatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // Photo shimmer
          const ShimmerLoader(
            height: 112,
            borderRadius: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const ShimmerLoader.text(
                    width: 100),
                const SizedBox(height: 6),
                const ShimmerLoader.text(
                    width: 80),
                const SizedBox(height: 6),
                const ShimmerLoader.text(
                    width: 90),
                const SizedBox(height: 10),
                const ShimmerLoader(
                    height: 28,
                    borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────────────────

class _CrimsonSpinner extends StatelessWidget {
  const _CrimsonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 42,
      height: 42,
      child: CircularProgressIndicator(
        strokeWidth: 3.5,
        color: AppColors.crimson,
      ),
    );
  }
}

class _CrimsonSpinnerWhite extends StatelessWidget {
  const _CrimsonSpinnerWhite();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }
}