import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor — instantiate mat karo

  // ── PRIMARY BRAND COLORS ──────────────────────────────
  static const Color crimson = Color(0xFF8B1A1A);
  static const Color crimsonLight = Color(0xFFB22222);
  static const Color crimsonDark = Color(0xFF6B0F0F);
  static const Color crimsonSurface = Color(0xFFFEF2F2);

  // ── GOLD / ACCENT ─────────────────────────────────────
  static const Color gold = Color(0xFFC9962A);
  static const Color goldLight = Color(0xFFE8B84B);
  static const Color goldSurface = Color(0xFFFFF8E7);

  // ── BACKGROUND COLORS ─────────────────────────────────
  static const Color ivory = Color(0xFFFAF6F0);
  static const Color ivoryDark = Color(0xFFF0E8DC);
  static const Color white = Color(0xFFFFFFFF);

  // ── TEXT COLORS ───────────────────────────────────────
  static const Color ink = Color(0xFF1A1209);
  static const Color inkSoft = Color(0xFF3D2B1A);
  static const Color muted = Color(0xFF8A7560);
  static const Color disabled = Color(0xFFD1C4B8);

  // ── BORDER COLORS ─────────────────────────────────────
  static const Color border = Color(0xFFE8DDD4);
  static const Color borderDark = Color(0xFFD4C4B4);

  // ── STATUS COLORS ─────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color error = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // ── OVERLAY ───────────────────────────────────────────
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x33000000);

  // ── SHIMMER ───────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFEDE8E3);
  static const Color shimmerHighlight = Color(0xFFF5F1ED);

  // ── GRADIENTS ─────────────────────────────────────────
  static const LinearGradient crimsonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B0F0F), Color(0xFF8B1A1A), Color(0xFF4A0808)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9962A), Color(0xFFE8B84B)],
  );

  // ── SHADOWS ───────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF8B1A1A).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}