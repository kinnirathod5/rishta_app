import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';

// ─────────────────────────────────────────────────────────────
// NOTE: Firebase initialization yahan baad mein aayegi
// Abhi bina Firebase ke app chalega (mock data ke saath)
// ─────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar transparent rakho
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    // ProviderScope — Riverpod ke liye zaroor
    const ProviderScope(
      child: RishtaApp(),
    ),
  );
}

class RishtaApp extends StatelessWidget {
  const RishtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ── APP INFO ──────────────────────────────────
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // ── THEME ─────────────────────────────────────
      theme: AppTheme.lightTheme,

      // ── ROUTER ────────────────────────────────────
      routerConfig: AppRoutes.router,
    );
  }
}