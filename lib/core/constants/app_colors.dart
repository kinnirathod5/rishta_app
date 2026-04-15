// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Central color palette for RishtaApp.
///
/// RULES:
/// 1. Never use hardcoded hex anywhere in the codebase
/// 2. Always use AppColors.xyz
/// 3. Never instantiate — all members are static
abstract class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────
  // BRAND COLORS
  // ─────────────────────────────────────────────────

  /// Primary brand — deep crimson red
  static const Color crimson      = Color(0xFF8B1A1A);

  /// Darker crimson — used in gradients
  static const Color crimsonDark  = Color(0xFF6B0F0F);

  /// Lighter crimson — for hover / lighter accents
  static const Color crimsonLight = Color(0xFFB22222);

  /// Secondary brand — gold
  static const Color gold         = Color(0xFFC9962A);

  /// Lighter gold — for text on dark bg
  static const Color goldLight    = Color(0xFFE8B84B);

  /// Darker gold — for borders / shadows
  static const Color goldDark     = Color(0xFFA07820);

  // ─────────────────────────────────────────────────
  // BACKGROUND COLORS
  // ─────────────────────────────────────────────────

  /// Main app background — warm ivory
  static const Color ivory        = Color(0xFFFAF6F0);

  /// Slightly darker ivory — for cards, inputs
  static const Color ivoryDark    = Color(0xFFF0E8DC);

  /// Pure white
  static const Color white        = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────
  // TEXT COLORS
  // ─────────────────────────────────────────────────

  /// Primary text — near black with warm tone
  static const Color ink          = Color(0xFF1A1209);

  /// Secondary text — soft dark brown
  static const Color inkSoft      = Color(0xFF3D2B1A);

  /// Tertiary text — muted brown
  static const Color muted        = Color(0xFF8A7560);

  /// Disabled / placeholder text
  static const Color disabled     = Color(0xFFD1C4B8);

  // ─────────────────────────────────────────────────
  // BORDER COLORS
  // ─────────────────────────────────────────────────

  /// Default border — light warm grey
  static const Color border       = Color(0xFFE8DDD4);

  // ─────────────────────────────────────────────────
  // SEMANTIC COLORS
  // ─────────────────────────────────────────────────

  /// Success — green
  static const Color success      = Color(0xFF16A34A);

  /// Error — red
  static const Color error        = Color(0xFFDC2626);

  /// Warning — amber
  static const Color warning      = Color(0xFFD97706);

  /// Info — blue
  static const Color info         = Color(0xFF2563EB);

  // ─────────────────────────────────────────────────
  // SURFACE / TINTED BACKGROUNDS
  // ─────────────────────────────────────────────────

  /// Light crimson surface — for error states, interest chips
  static const Color crimsonSurface  = Color(0xFFFEF2F2);

  /// Light gold surface — for premium, tips
  static const Color goldSurface     = Color(0xFFFFF8E7);

  /// Light green surface — for success states
  static const Color successSurface  = Color(0xFFECFDF5);

  /// Light red surface — for error states
  static const Color errorSurface    = Color(0xFFFEF2F2);

  /// Light blue surface — for info states
  static const Color infoSurface     = Color(0xFFEFF6FF);

  /// Light amber surface — for warning states
  static const Color warningSurface  = Color(0xFFFFFBEB);

  // ─────────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────────

  /// Primary crimson gradient — for app bar, buttons
  static const LinearGradient crimsonGradient =
  LinearGradient(
    colors: [crimsonDark, crimson],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Full splash gradient — for splash screen
  static const LinearGradient splashGradient =
  LinearGradient(
    colors: [
      crimsonDark,
      crimson,
      Color(0xFF4A0808),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold gradient — for premium badges, buttons
  static const LinearGradient goldGradient =
  LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gold vertical gradient — for badges
  static const LinearGradient goldVerticalGradient =
  LinearGradient(
    colors: [goldLight, gold],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Success gradient — for connected state
  static const LinearGradient successGradient =
  LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark overlay — for photo overlays
  static const LinearGradient darkOverlay =
  LinearGradient(
    colors: [
      Colors.transparent,
      Color(0xCC000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Ivory fade — for bottom of photo
  static const LinearGradient ivoryFade =
  LinearGradient(
    colors: [
      Colors.transparent,
      ivory,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─────────────────────────────────────────────────
  // SHADOWS
  // ─────────────────────────────────────────────────

  /// Subtle shadow — for cards, tiles
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow — for elevated cards
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Strong shadow — for modals, floating elements
  static const List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];

  /// Crimson glow — for active/focused state
  static const List<BoxShadow> crimsonShadow = [
    BoxShadow(
      color: Color(0x298B1A1A),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Gold glow — for premium elements
  static const List<BoxShadow> goldShadow = [
    BoxShadow(
      color: Color(0x29C9962A),
      blurRadius: 12,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  // ─────────────────────────────────────────────────
  // OPACITY HELPERS
  // ─────────────────────────────────────────────────

  /// Scrim / overlay for modals
  static const Color scrim        = Color(0x80000000);

  /// Light scrim
  static const Color scrimLight   = Color(0x40000000);

  /// White overlay — for locked photos
  static const Color whiteOverlay = Color(0xA6FFFFFF);

  // ─────────────────────────────────────────────────
  // CHAT COLORS
  // ─────────────────────────────────────────────────

  /// Sent message bubble
  static const Color chatBubbleMine  = crimson;

  /// Received message bubble
  static const Color chatBubbleOther = white;

  /// Sent message text
  static const Color chatTextMine    = white;

  /// Received message text
  static const Color chatTextOther   = ink;

  // ─────────────────────────────────────────────────
  // STATUS INDICATOR COLORS
  // ─────────────────────────────────────────────────

  /// Online status dot
  static const Color online          = success;

  /// Offline status dot
  static const Color offline         = Color(0xFFD1D5DB);

  /// Away status dot
  static const Color away            = warning;

  // ─────────────────────────────────────────────────
  // NAMED COLOR HELPERS
  // — For use when opacity not needed (const contexts)
  // ─────────────────────────────────────────────────

  static const Color transparent  = Colors.transparent;
  static const Color black        = Color(0xFF000000);

  // ─────────────────────────────────────────────────
  // UTILITY METHODS
  // ─────────────────────────────────────────────────

  /// Returns surface color for a semantic color
  static Color surfaceFor(Color color) {
    if (color == crimson) return crimsonSurface;
    if (color == gold)    return goldSurface;
    if (color == success) return successSurface;
    if (color == error)   return errorSurface;
    if (color == info)    return infoSurface;
    if (color == warning) return warningSurface;
    return ivoryDark;
  }

  /// Returns text color for a surface color
  static Color textFor(Color surface) {
    if (surface == crimsonSurface) return crimson;
    if (surface == goldSurface)    return gold;
    if (surface == successSurface) return success;
    if (surface == errorSurface)   return error;
    if (surface == infoSurface)    return info;
    if (surface == warningSurface) return warning;
    return inkSoft;
  }

  /// Returns gradient for a plan
  static LinearGradient gradientForPlan(
      String plan) {
    switch (plan.toLowerCase()) {
      case 'silver':
        return const LinearGradient(
          colors: [
            Color(0xFF9E9E9E),
            Color(0xFFBDBDBD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'gold':
        return goldGradient;
      case 'platinum':
        return const LinearGradient(
          colors: [
            Color(0xFF546E7A),
            Color(0xFF78909C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return crimsonGradient;
    }
  }
}