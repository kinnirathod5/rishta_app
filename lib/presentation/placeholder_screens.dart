// lib/presentation/placeholder_screens.dart
// Temporary placeholder screens — will be replaced
// one by one with full implementations.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────
// BASE PLACEHOLDER WIDGET
// ─────────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool showBack;
  final List<_QuickLink>? quickLinks;

  const _PlaceholderScreen({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.showBack = true,
    this.quickLinks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ─────────────────────────
            if (showBack)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16, 12, 16, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.ivoryDark,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ]),
              ),

            // ── CONTENT ─────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                  const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji icon
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color:
                          AppColors.crimsonSurface,
                          borderRadius:
                          BorderRadius.circular(
                              22),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(
                                fontSize: 44),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.6,
                        ),
                      ),

                      // ── COMING SOON BADGE ──────
                      const SizedBox(height: 20),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.goldSurface,
                          borderRadius:
                          BorderRadius.circular(
                              100),
                          border: Border.all(
                            color: AppColors.gold
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons
                                  .construction_rounded,
                              size: 14,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Coming Soon',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── QUICK LINKS ───────────
                      if (quickLinks != null &&
                          quickLinks!.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Divider(
                            color: AppColors.border),
                        const SizedBox(height: 16),
                        const Text(
                          'Quick Navigation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w600,
                            color: AppColors.muted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment:
                          WrapAlignment.center,
                          children: quickLinks!
                              .map((link) =>
                              _QuickLinkChip(
                                  link: link))
                              .toList(),
                        ),
                      ],
                    ],
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
// QUICK LINK MODEL
// ─────────────────────────────────────────────────────────

class _QuickLink {
  final String label;
  final String route;
  final String emoji;

  const _QuickLink({
    required this.label,
    required this.route,
    required this.emoji,
  });
}

class _QuickLinkChip extends StatelessWidget {
  final _QuickLink link;
  const _QuickLinkChip({required this.link});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(link.route),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border:
          Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(link.emoji,
                style:
                const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              link.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PROFILE SETUP PLACEHOLDERS
// ─────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────
// REMAINING PLACEHOLDER SCREENS
// Will be replaced with full implementations
// ─────────────────────────────────────────────────────────