// lib/core/constants/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:rishta_app/core/constants/app_colors.dart';

/// Central typography system for RishtaApp.
///
/// RULES:
/// 1. Never use hardcoded TextStyle anywhere
/// 2. Always use AppTextStyles.xyz
/// 3. Never instantiate — all members are static
abstract class AppTextStyles {
  AppTextStyles._();

  // ─────────────────────────────────────────────────
  // HEADINGS
  // ─────────────────────────────────────────────────

  /// Screen title — 32px bold
  /// Usage: Main page headers
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Section title — 26px bold
  /// Usage: Card headers, section titles
  static const TextStyle h2 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.25,
    letterSpacing: -0.3,
  );

  /// Sub heading — 22px semibold
  /// Usage: Dialog titles, sheet headers
  static const TextStyle h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.3,
  );

  /// Card heading — 18px semibold
  /// Usage: Card titles, list headers
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.35,
  );

  /// Small heading — 16px semibold
  /// Usage: Section labels, tab titles
  static const TextStyle h5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────
  // BODY TEXT
  // ─────────────────────────────────────────────────

  /// Body large — 16px regular
  /// Usage: Long form text, about sections
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
    height: 1.6,
  );

  /// Body medium — 14px regular
  /// Usage: Standard body text, descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
    height: 1.55,
  );

  /// Body small — 12px regular
  /// Usage: Secondary info, captions
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.5,
  );

  // ─────────────────────────────────────────────────
  // LABELS
  // ─────────────────────────────────────────────────

  /// Label large — 14px semibold
  /// Usage: Form field labels, category names
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
    height: 1.4,
  );

  /// Label medium — 13px semibold
  /// Usage: Chips, tags, badges
  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
    height: 1.4,
  );

  /// Label small — 11px medium
  /// Usage: Meta info, timestamps
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // ─────────────────────────────────────────────────
  // BUTTONS
  // ─────────────────────────────────────────────────

  /// Primary button text — 16px semibold white
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  /// Secondary button text — 15px semibold crimson
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.crimson,
    letterSpacing: 0.2,
  );

  /// Small button text — 13px semibold
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ─────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────

  /// App bar title — 18px semibold white
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  /// App bar subtitle — 12px regular white70
  static const TextStyle appBarSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xB3FFFFFF),
  );

  // ─────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────

  /// Bottom nav selected — 11px semibold
  static const TextStyle navSelected = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.crimson,
  );

  /// Bottom nav unselected — 11px regular
  static const TextStyle navUnselected = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  // ─────────────────────────────────────────────────
  // FORM FIELDS
  // ─────────────────────────────────────────────────

  /// Input field text — 15px regular
  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  /// Input hint — 14px regular disabled
  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.disabled,
  );

  /// Input label — 13px semibold
  static const TextStyle inputLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSoft,
  );

  /// Input error — 12px regular error
  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
  );

  // ─────────────────────────────────────────────────
  // PROFILE CARD
  // ─────────────────────────────────────────────────

  /// Profile name large — 24px bold
  static const TextStyle profileNameLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Profile name medium — 15px bold
  static const TextStyle profileNameMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Profile name small — 13px bold
  static const TextStyle profileNameSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Profile detail — 14px regular inkSoft
  static const TextStyle profileDetail = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSoft,
  );

  /// Profile meta — 12px regular muted
  static const TextStyle profileMeta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  // ─────────────────────────────────────────────────
  // CHAT
  // ─────────────────────────────────────────────────

  /// Chat message — 14px regular
  static const TextStyle chatMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.45,
  );

  /// Chat message mine (on crimson bg)
  static const TextStyle chatMessageMine = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.45,
  );

  /// Chat time stamp — 10px regular
  static const TextStyle chatTime = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// Chat name in inbox — 15px semibold
  static const TextStyle chatName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// Chat preview message — 13px regular
  static const TextStyle chatPreview = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// Chat preview unread — 13px medium
  static const TextStyle chatPreviewUnread = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.inkSoft,
  );

  // ─────────────────────────────────────────────────
  // STATUS / BADGES
  // ─────────────────────────────────────────────────

  /// Verified badge — 9px bold white
  static const TextStyle badgeVerified = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// Premium badge — 10px bold white
  static const TextStyle badgePremium = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// Status chip — 11px semibold
  static const TextStyle statusChip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  /// Unread count badge — 11px bold white
  static const TextStyle unreadBadge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ─────────────────────────────────────────────────
  // TABS
  // ─────────────────────────────────────────────────

  /// Tab selected — 13px semibold
  static const TextStyle tabSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Tab unselected — 13px regular
  static const TextStyle tabUnselected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // ─────────────────────────────────────────────────
  // SPECIAL
  // ─────────────────────────────────────────────────

  /// Splash app name — 34px bold white
  static const TextStyle splashTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 1.5,
  );

  /// Splash tagline — 13px light white60
  static const TextStyle splashTagline = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: Color(0x99FFFFFF),
    letterSpacing: 0.8,
  );

  /// Onboarding title — 28px bold ink
  static const TextStyle onboardTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  /// Onboarding subtitle — 15px regular muted
  static const TextStyle onboardSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.65,
  );

  /// Empty state title — 20px bold ink
  static const TextStyle emptyTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Empty state subtitle — 14px regular muted
  static const TextStyle emptySubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.6,
  );

  /// Score percentage — 22px extrabold crimson
  static const TextStyle scorePercent = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.crimson,
  );

  /// Stat value — 20px extrabold ink
  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  /// Stat label — 11px regular muted
  static const TextStyle statLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.3,
  );

  /// Section "View All" link — 13px semibold crimson
  static const TextStyle viewAll = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.crimson,
  );

  /// Filter section title — 14px bold ink
  static const TextStyle filterTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Info row label — 13px regular muted
  static const TextStyle infoLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// Info row value — 13px semibold ink
  static const TextStyle infoValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// Version text — 11px regular white30
  static const TextStyle versionText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Colors.white30,
    letterSpacing: 1.5,
  );

  // ─────────────────────────────────────────────────
  // UTILITY METHODS
  // ─────────────────────────────────────────────────

  /// Returns a style with custom color
  static TextStyle withColor(
      TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Returns a style with custom font size
  static TextStyle withSize(
      TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Returns a crimson colored style
  static TextStyle crimson(TextStyle style) {
    return style.copyWith(color: AppColors.crimson);
  }

  /// Returns a white colored style
  static TextStyle white(TextStyle style) {
    return style.copyWith(color: Colors.white);
  }

  /// Returns a muted colored style
  static TextStyle muted(TextStyle style) {
    return style.copyWith(color: AppColors.muted);
  }

  /// Returns a gold colored style
  static TextStyle gold(TextStyle style) {
    return style.copyWith(color: AppColors.gold);
  }
}