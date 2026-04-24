// lib/core/constants/app_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ── AUTH ──────────────────────────────────────────────────
import 'package:rishta_app/presentation/auth/splash_screen.dart';
import 'package:rishta_app/presentation/auth/welcome_screen.dart';
import 'package:rishta_app/presentation/auth/phone_entry_screen.dart';
import 'package:rishta_app/presentation/auth/otp_screen.dart';
import 'package:rishta_app/presentation/auth/explore_first_screen.dart';
import 'package:rishta_app/presentation/auth/profile_type_screen.dart';

// ── PROFILE SETUP STEPS ───────────────────────────────────
import 'package:rishta_app/presentation/auth/profile_setup/step1_basic_info.dart';
import 'package:rishta_app/presentation/auth/profile_setup/step2_religion.dart';
import 'package:rishta_app/presentation/auth/profile_setup/step3_education.dart';
import 'package:rishta_app/presentation/auth/profile_setup/step4_family.dart';
import 'package:rishta_app/presentation/auth/profile_setup/step5_photos.dart';

// ── SHELL ─────────────────────────────────────────────────
import 'package:rishta_app/presentation/shell/main_shell.dart';

// ── MAIN APP ──────────────────────────────────────────────
import 'package:rishta_app/presentation/home/home_screen.dart';
import 'package:rishta_app/presentation/home/search_screen.dart';
import 'package:rishta_app/presentation/home/profile_detail_screen.dart';
import 'package:rishta_app/presentation/profile/my_profile_screen.dart';
import 'package:rishta_app/presentation/profile/profile_preview_screen.dart';
import 'package:rishta_app/presentation/profile/edit_profile_screen.dart';
import 'package:rishta_app/presentation/chat/chat_inbox_screen.dart';
import 'package:rishta_app/presentation/chat/chat_window_screen.dart';

// ── PLACEHOLDER SCREENS ───────────────────────────────────
// These will be replaced one by one with full implementations
import 'package:rishta_app/presentation/placeholder_screens.dart';
import 'package:rishta_app/presentation/interests/interests_screen.dart';

// ── PROFILE SCREENS ───────────────────────────────────────
import 'package:rishta_app/presentation/profile/shortlisted_screen.dart';
import 'package:rishta_app/presentation/profile/who_viewed_screen.dart';
import 'package:rishta_app/presentation/profile/partner_preference_screen.dart';
import 'package:rishta_app/presentation/profile/horoscope_screen.dart';
import 'package:rishta_app/presentation/profile/id_verification_screen.dart';
import 'package:rishta_app/presentation/profile/blocked_users_screen.dart';

// ── SETTINGS SCREENS ──────────────────────────────────────
import 'package:rishta_app/presentation/settings/notifications_screen.dart';
import 'package:rishta_app/presentation/settings/premium_screen.dart';
import 'package:rishta_app/presentation/settings/privacy_screen.dart';
import 'package:rishta_app/presentation/settings/help_support_screen.dart';
import 'package:rishta_app/presentation/settings/delete_account_screen.dart';

// ─────────────────────────────────────────────────────────
// ROUTE PATHS
// Single source of truth for all route strings
// ─────────────────────────────────────────────────────────

abstract class AppRoute {
  AppRoute._();

  // ── AUTH ──────────────────────────────────────────
  static const String splash      = '/';
  static const String welcome     = '/welcome';
  static const String phone       = '/phone';
  static const String otp         = '/otp';
  static const String explore     = '/explore';
  static const String profileType = '/profile-type';

  // ── PROFILE SETUP ─────────────────────────────────
  static const String step1 = '/setup/step1';
  static const String step2 = '/setup/step2';
  static const String step3 = '/setup/step3';
  static const String step4 = '/setup/step4';
  static const String step5 = '/setup/step5';

  // ── SHELL TABS ────────────────────────────────────
  static const String home      = '/home';
  static const String search    = '/search';
  static const String interests = '/interests';
  static const String chat      = '/chat';
  static const String myProfile = '/my-profile';

  // ── PROFILE ───────────────────────────────────────
  static const String profileDetail  = '/profile/:uid';
  static const String profilePreview = '/profile-preview';
  static const String editProfile    = '/edit-profile';
  static const String shortlisted    = '/shortlisted';
  static const String whoViewed      = '/who-viewed';
  static const String partnerPref    = '/partner-preference';
  static const String horoscope      = '/horoscope';
  static const String idVerification = '/id-verification';
  static const String blockedUsers   = '/blocked-users';

  // ── CHAT ──────────────────────────────────────────
  static const String chatWindow = '/chat/:chatId';

  // ── SETTINGS ──────────────────────────────────────
  static const String notifications = '/notifications';
  static const String premium       = '/premium';
  static const String privacy       = '/privacy';
  static const String helpSupport   = '/help-support';
  static const String deleteAccount = '/delete-account';

  // ── PATH HELPERS ──────────────────────────────────

  /// '/profile/abc123'
  static String profileDetailPath(String uid) =>
      '/profile/$uid';

  /// '/chat/chatId123'
  static String chatWindowPath(String chatId) =>
      '/chat/$chatId';
}

// ─────────────────────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────────────────────

abstract class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.splash,
    debugLogDiagnostics: false,

    // ── REDIRECT ──────────────────────────────────
    // TODO: Phase 3 — Firebase auth redirect
    // redirect: (context, state) {
    //   final container =
    //       ProviderScope.containerOf(context);
    //   final isLoggedIn =
    //       container.read(isLoggedInProvider);
    //   final authRoutes = [
    //     AppRoute.welcome, AppRoute.phone,
    //     AppRoute.otp,     AppRoute.explore,
    //   ];
    //   final isAuthRoute = authRoutes.any(
    //       (r) => state.uri.path.startsWith(r));
    //   if (!isLoggedIn && !isAuthRoute) {
    //     return AppRoute.welcome;
    //   }
    //   return null;
    // },

    routes: [

      // ── SPLASH ──────────────────────────────────
      GoRoute(
        path: AppRoute.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            _fade(state, const SplashScreen()),
      ),

      // ── WELCOME ─────────────────────────────────
      GoRoute(
        path: AppRoute.welcome,
        name: 'welcome',
        pageBuilder: (context, state) =>
            _fade(state, const WelcomeScreen()),
      ),

      // ── PHONE ───────────────────────────────────
      GoRoute(
        path: AppRoute.phone,
        name: 'phone',
        pageBuilder: (context, state) =>
            _slide(state,
                const PhoneEntryScreen()),
      ),

      // ── OTP ─────────────────────────────────────
      GoRoute(
        path: AppRoute.otp,
        name: 'otp',
        pageBuilder: (context, state) {
          final phone =
              state.extra as String? ?? '';
          return _slide(
            state,
            OtpScreen(phoneNumber: phone),
          );
        },
      ),

      // ── EXPLORE FIRST ───────────────────────────
      GoRoute(
        path: AppRoute.explore,
        name: 'explore',
        pageBuilder: (context, state) =>
            _slide(state,
                const ExploreFirstScreen()),
      ),

      // ── PROFILE TYPE ────────────────────────────
      GoRoute(
        path: AppRoute.profileType,
        name: 'profileType',
        pageBuilder: (context, state) =>
            _slide(state,
                const ProfileTypeScreen()),
      ),

      // ── PROFILE SETUP — Step 1 ──────────────────
      GoRoute(
        path: AppRoute.step1,
        name: 'step1',
        pageBuilder: (context, state) {
          final extra = state.extra
          as Map<String, dynamic>?;
          return _slide(
            state,
            Step1BasicInfo(extra: extra),
          );
        },
      ),

      // ── PROFILE SETUP — Step 2 ──────────────────
      GoRoute(
        path: AppRoute.step2,
        name: 'step2',
        pageBuilder: (context, state) =>
            _slide(state,
                const Step2Religion()),
      ),

      // ── PROFILE SETUP — Step 3 ──────────────────
      GoRoute(
        path: AppRoute.step3,
        name: 'step3',
        pageBuilder: (context, state) =>
            _slide(state,
                const Step3Education()),
      ),

      // ── PROFILE SETUP — Step 4 ──────────────────
      GoRoute(
        path: AppRoute.step4,
        name: 'step4',
        pageBuilder: (context, state) =>
            _slide(state,
                const Step4Family()),
      ),

      // ── PROFILE SETUP — Step 5 ──────────────────
      GoRoute(
        path: AppRoute.step5,
        name: 'step5',
        pageBuilder: (context, state) =>
            _slide(state,
                const Step5Photos()),
      ),

      // ── SHELL — Bottom Nav ───────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home,
            name: 'home',
            pageBuilder: (context, state) =>
                _none(state,
                    const HomeScreen()),
          ),
          GoRoute(
            path: AppRoute.search,
            name: 'search',
            pageBuilder: (context, state) =>
                _none(state,
                    const SearchScreen()),
          ),
          GoRoute(
            path: AppRoute.interests,
            name: 'interests',
            pageBuilder: (context, state) =>
                _none(state,
                    const InterestsScreen()),
          ),
          GoRoute(
            path: AppRoute.chat,
            name: 'chat',
            pageBuilder: (context, state) =>
                _none(state,
                    const ChatInboxScreen()),
          ),
          GoRoute(
            path: AppRoute.myProfile,
            name: 'myProfile',
            pageBuilder: (context, state) =>
                _none(state,
                    const MyProfileScreen()),
          ),
        ],
      ),

      // ── PROFILE DETAIL ──────────────────────────
      GoRoute(
        path: AppRoute.profileDetail,
        name: 'profileDetail',
        pageBuilder: (context, state) {
          final uid =
              state.pathParameters['uid'] ?? '';
          final profile =
          state.extra as MockProfile?;
          return _slide(
            state,
            ProfileDetailScreen(
              profileId: uid,
              profile: profile,
            ),
          );
        },
      ),

      // ── PROFILE PREVIEW ─────────────────────────
      GoRoute(
        path: AppRoute.profilePreview,
        name: 'profilePreview',
        pageBuilder: (context, state) =>
            _slide(state,
                const ProfilePreviewScreen()),
      ),

      // ── EDIT PROFILE ────────────────────────────
      GoRoute(
        path: AppRoute.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) =>
            _slide(state,
                const EditProfileScreen()),
      ),

      // ── SHORTLISTED ─────────────────────────────
      GoRoute(
        path: AppRoute.shortlisted,
        name: 'shortlisted',
        pageBuilder: (context, state) =>
            _slide(state,
                const ShortlistedScreen()),
      ),

      // ── WHO VIEWED ──────────────────────────────
      GoRoute(
        path: AppRoute.whoViewed,
        name: 'whoViewed',
        pageBuilder: (context, state) =>
            _slide(state,
                const WhoViewedScreen()),
      ),

      // ── PARTNER PREFERENCE ──────────────────────
      GoRoute(
        path: AppRoute.partnerPref,
        name: 'partnerPref',
        pageBuilder: (context, state) =>
            _slide(state,
                const PartnerPreferenceScreen()),
      ),

      // ── HOROSCOPE ───────────────────────────────
      GoRoute(
        path: AppRoute.horoscope,
        name: 'horoscope',
        pageBuilder: (context, state) =>
            _slide(state,
                const HoroscopeScreen()),
      ),

      // ── ID VERIFICATION ─────────────────────────
      GoRoute(
        path: AppRoute.idVerification,
        name: 'idVerification',
        pageBuilder: (context, state) =>
            _slide(state,
                const IdVerificationScreen()),
      ),

      // ── BLOCKED USERS ───────────────────────────
      GoRoute(
        path: AppRoute.blockedUsers,
        name: 'blockedUsers',
        pageBuilder: (context, state) =>
            _slide(state,
                const BlockedUsersScreen()),
      ),

      // ── CHAT WINDOW ─────────────────────────────
      GoRoute(
        path: AppRoute.chatWindow,
        name: 'chatWindow',
        pageBuilder: (context, state) {
          final chatId =
              state.pathParameters['chatId'] ??
                  '';
          return _slide(
            state,
            ChatWindowScreen(chatId: chatId),
          );
        },
      ),

      // ── NOTIFICATIONS ───────────────────────────
      GoRoute(
        path: AppRoute.notifications,
        name: 'notifications',
        pageBuilder: (context, state) =>
            _slide(state,
                const NotificationsScreen()),
      ),

      // ── PREMIUM ─────────────────────────────────
      GoRoute(
        path: AppRoute.premium,
        name: 'premium',
        pageBuilder: (context, state) =>
            _slide(state,
                const PremiumScreen()),
      ),

      // ── PRIVACY ─────────────────────────────────
      GoRoute(
        path: AppRoute.privacy,
        name: 'privacy',
        pageBuilder: (context, state) =>
            _slide(state,
                const PrivacyScreen()),
      ),

      // ── HELP & SUPPORT ──────────────────────────
      GoRoute(
        path: AppRoute.helpSupport,
        name: 'helpSupport',
        pageBuilder: (context, state) =>
            _slide(state,
                const HelpSupportScreen()),
      ),

      // ── DELETE ACCOUNT ──────────────────────────
      GoRoute(
        path: AppRoute.deleteAccount,
        name: 'deleteAccount',
        pageBuilder: (context, state) =>
            _slide(state,
                const DeleteAccountScreen()),
      ),
    ],

    // ── ERROR PAGE ────────────────────────────────
    errorPageBuilder: (context, state) =>
        _none(state, const _ErrorScreen()),
  );

  // ─────────────────────────────────────────────────
  // PAGE TRANSITIONS
  // ─────────────────────────────────────────────────

  /// Slide from right — standard push
  static CustomTransitionPage<void> _slide(
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration:
      const Duration(milliseconds: 280),
      reverseTransitionDuration:
      const Duration(milliseconds: 220),
      transitionsBuilder: (
          _,
          animation,
          secondaryAnimation,
          child,
          ) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(
                curve: Curves.easeOut)),
          ),
          child: child,
        );
      },
    );
  }

  /// Fade — splash + welcome only
  static CustomTransitionPage<void> _fade(
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration:
      const Duration(milliseconds: 400),
      transitionsBuilder:
          (_, animation, __, child) =>
          FadeTransition(
            opacity: animation,
            child: child,
          ),
    );
  }

  /// No animation — bottom nav tab switches
  static NoTransitionPage<void> _none(
      GoRouterState state,
      Widget child,
      ) {
    return NoTransitionPage<void>(
      key: state.pageKey,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────
// ERROR SCREEN
// ─────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.crimsonSurface,
                  borderRadius:
                  BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text('😕',
                      style: TextStyle(
                          fontSize: 44)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'The page you are looking for\ndoes not exist.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      context.go(AppRoute.home),
                  child:
                  const Text('Go to Home'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context
                    .go(AppRoute.welcome),
                child: Text(
                  'Go to Welcome Screen',
                  style: AppTextStyles
                      .buttonSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}