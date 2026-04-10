import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/placeholder_screens.dart';
import '../../presentation/auth/welcome_screen.dart';
import '../../presentation/profile/my_profile_screen.dart';
import '../../presentation/settings/notifications_screen.dart';
import '../../presentation/settings/premium_screen.dart';
import '../../presentation/settings/privacy_screen.dart';
import '../../presentation/auth/phone_entry_screen.dart';
import '../../presentation/auth/otp_screen.dart';
import '../../presentation/auth/explore_first_screen.dart';
import '../../presentation/auth/profile_type_screen.dart';
import '../../presentation/auth/profile_setup/step1_basic_info.dart';
import '../../presentation/auth/profile_setup/step2_religion.dart';
import '../../presentation/auth/profile_setup/step3_education.dart';
import '../../presentation/auth/profile_setup/step4_family.dart';
import '../../presentation/auth/profile_setup/step5_photos.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/home/search_screen.dart';
import '../../presentation/home/profile_detail_screen.dart';
import '../../presentation/interests/interests_screen.dart';
import '../../presentation/chat/chat_inbox_screen.dart';
import '../../presentation/chat/chat_window_screen.dart';
import '../../presentation/profile/shortlisted_screen.dart';
import '../../presentation/profile/who_viewed_screen.dart';
import '../../presentation/profile/partner_preference_screen.dart';
import '../../presentation/profile/horoscope_screen.dart';
import '../../presentation/profile/id_verification_screen.dart';
import '../../presentation/profile/blocked_users_screen.dart';
import '../../presentation/profile/profile_preview_screen.dart';
import '../../presentation/settings/help_support_screen.dart';
import '../../presentation/settings/delete_account_screen.dart';
import '../../presentation/shell/main_shell.dart';

// ── ROUTE PATHS ───────────────────────────────────────────
class AppRoutePaths {
  AppRoutePaths._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String phone = '/phone';
  static const String otp = '/otp';
  static const String explore = '/explore';
  static const String profileType = '/profile-type';

  // Profile Setup
  static const String setupStep1 = '/setup/step1';
  static const String setupStep2 = '/setup/step2';
  static const String setupStep3 = '/setup/step3';
  static const String setupStep4 = '/setup/step4';
  static const String setupStep5 = '/setup/step5';

  // Main App
  static const String home = '/home';
  static const String search = '/search';
  static const String profileDetail = '/profile/:uid';
  static const String interests = '/interests';
  static const String chatInbox = '/chat';
  static const String chatWindow = '/chat/:chatId';
  static const String myProfile = '/my-profile';
  static const String notifications = '/notifications';
  static const String premium = '/premium';
  static const String privacy = '/privacy';
  static const String shortlisted = '/shortlisted';
  static const String whoViewed = '/who-viewed';
  static const String partnerPreference = '/partner-preference';
  static const String horoscope = '/horoscope';
  static const String idVerification = '/id-verification';
  static const String blockedUsers = '/blocked-users';
  static const String helpSupport = '/help-support';
  static const String deleteAccount = '/delete-account';
  static const String profilePreview = '/profile-preview';
}

// ── ROUTER ────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutePaths.splash,
    debugLogDiagnostics: true,

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Page nahi mila: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutePaths.splash),
              child: const Text('Home pe jaao'),
            ),
          ],
        ),
      ),
    ),

    routes: [
      // ── AUTH ─────────────────────────────────────
      GoRoute(
        path: AppRoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashPlaceholder(),
      ),
      GoRoute(
        path: AppRoutePaths.welcome,
        name: 'welcome',
        pageBuilder: (context, state) => _fade(
          state, const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.phone,
        name: 'phone',
        pageBuilder: (context, state) => _slide(
          state, const PhoneEntryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.otp,
        name: 'otp',
        pageBuilder: (context, state) {
          final phone = state.extra as String? ?? '';
          return _slide(state, OtpScreen(phoneNumber: phone));
        },
      ),
      GoRoute(
        path: AppRoutePaths.explore,
        name: 'explore',
        pageBuilder: (context, state) => _slide(
          state, const ExploreFirstScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.profileType,
        name: 'profileType',
        pageBuilder: (context, state) => _slide(
          state, const ProfileTypeScreen(),
        ),
      ),

      // ── PROFILE SETUP ────────────────────────────
      GoRoute(
        path: AppRoutePaths.setupStep1,
        name: 'setupStep1',
        pageBuilder: (context, state) => _slide(
          state, const Step1BasicInfo(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.setupStep2,
        name: 'setupStep2',
        pageBuilder: (context, state) => _slide(
          state, const Step2Religion(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.setupStep3,
        name: 'setupStep3',
        pageBuilder: (context, state) => _slide(
          state, const Step3Education(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.setupStep4,
        name: 'setupStep4',
        pageBuilder: (context, state) => _slide(
          state, const Step4Family(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.setupStep5,
        name: 'setupStep5',
        pageBuilder: (context, state) => _slide(
          state, const Step5Photos(),
        ),
      ),

      // ── MAIN APP (Shell — persistent bottom nav) ──
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutePaths.home,
            name: 'home',
            pageBuilder: (context, state) => _fade(
              state, const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutePaths.search,
            name: 'search',
            pageBuilder: (context, state) => _fade(
              state, const SearchScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutePaths.interests,
            name: 'interests',
            pageBuilder: (context, state) => _fade(
              state, const InterestsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutePaths.chatInbox,
            name: 'chatInbox',
            pageBuilder: (context, state) => _fade(
              state, const ChatInboxScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutePaths.myProfile,
            name: 'myProfile',
            pageBuilder: (context, state) => _fade(
              state, const MyProfileScreen(),
            ),
          ),
        ],
      ),

      // ── DETAIL / SECONDARY SCREENS ────────────────
      GoRoute(
        path: AppRoutePaths.profileDetail,
        name: 'profileDetail',
        pageBuilder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          final extra = state.extra as MockProfile?;
          return _slide(
              state, ProfileDetailScreen(uid: uid, profile: extra));
        },
      ),
      GoRoute(
        path: AppRoutePaths.chatWindow,
        name: 'chatWindow',
        pageBuilder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return _slide(
              state,
              ChatWindowScreen(
                chatId: chatId,
                otherUserName: extra?['name'] ?? '',
                otherUserEmoji: extra?['emoji'] ?? '👤',
                otherUserCaste: extra?['caste'] ?? '',
                otherUserCity: extra?['city'] ?? '',
              ));
        },
      ),
      GoRoute(
        path: AppRoutePaths.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => _slide(
          state, const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.premium,
        name: 'premium',
        pageBuilder: (context, state) => _slide(
          state, const PremiumScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.privacy,
        name: 'privacy',
        pageBuilder: (context, state) => _slide(
          state, const PrivacyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.shortlisted,
        name: 'shortlisted',
        pageBuilder: (context, state) => _slide(
          state, const ShortlistedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.whoViewed,
        name: 'whoViewed',
        pageBuilder: (context, state) => _slide(
          state, const WhoViewedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.partnerPreference,
        name: 'partnerPreference',
        pageBuilder: (context, state) => _slide(
          state, const PartnerPreferenceScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.horoscope,
        name: 'horoscope',
        pageBuilder: (context, state) => _slide(
          state, const HoroscopeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.idVerification,
        name: 'idVerification',
        pageBuilder: (context, state) => _slide(
          state, const IdVerificationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.blockedUsers,
        name: 'blockedUsers',
        pageBuilder: (context, state) => _slide(
          state, const BlockedUsersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.helpSupport,
        name: 'helpSupport',
        pageBuilder: (context, state) => _slide(
          state, const HelpSupportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.deleteAccount,
        name: 'deleteAccount',
        pageBuilder: (context, state) => _slide(
          state, const DeleteAccountScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.profilePreview,
        name: 'profilePreview',
        pageBuilder: (context, state) => _slide(
          state, const ProfilePreviewScreen(),
        ),
      ),
    ],
  );

  // ── TRANSITIONS ──────────────────────────────────────
  static CustomTransitionPage _fade(
      GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondary, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  static CustomTransitionPage _slide(
      GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondary, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}