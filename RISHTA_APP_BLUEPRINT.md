# RishtaApp — Complete Blueprint & Architecture
## Indian Matrimony App | Flutter + Firebase + Riverpod

---

## TECH STACK

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter (Dart) — Android first, iOS later |
| State Management | Riverpod (flutter_riverpod) |
| Navigation | GoRouter |
| Backend | Firebase (Firestore, Auth, Storage, FCM) |
| Payments | Razorpay |
| Local Storage | shared_preferences |
| Image Loading | cached_network_image |
| Image Picker | image_picker |

**Brand Colors:**
- Primary Crimson: `#8B1A1A`
- Gold Accent: `#C9962A`
- Background Ivory: `#FAF6F0`

---

## APP ARCHITECTURE — Clean Architecture

```
UI Layer (Screens + Widgets)
        ↕
State Layer (Riverpod Providers)
        ↕
Domain Layer (Models + Interfaces)
        ↕
Data Layer (Repositories + Firebase)
```

### Pattern: Repository Pattern + Riverpod
- Screens watch providers
- Providers call repositories
- Repositories talk to Firebase
- Models are pure Dart (no Firebase imports in Phase 1-2)

---

## COMPLETE FILE STRUCTURE

```
rishta_app/
├── android/                          # Android project files
│   └── app/
│       ├── build.gradle              # App-level gradle
│       ├── google-services.json      # Firebase config (Phase 3)
│       └── src/main/
│           ├── AndroidManifest.xml   # Permissions
│           └── res/                  # Icons, splash
│
├── ios/                              # iOS project files (Phase 7)
│
├── lib/                              # All Dart source code
│   │
│   ├── main.dart                     # App entry point
│   │
│   ├── core/                         # Shared utilities
│   │   │
│   │   ├── constants/
│   │   │   ├── app_colors.dart       # Color palette (Crimson, Gold, Ivory)
│   │   │   ├── app_strings.dart      # All UI text strings
│   │   │   ├── app_text_styles.dart  # Typography system
│   │   │   ├── app_routes.dart       # GoRouter + all routes
│   │   │   └── app_theme.dart        # MaterialApp theme
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart       # Form validators (name, phone, DOB...)
│   │   │   ├── formatters.dart       # Text formatters + display helpers
│   │   │   └── extensions.dart       # Dart extension methods
│   │   │
│   │   └── widgets/                  # Reusable UI components
│   │       ├── custom_button.dart    # PrimaryButton, SecondaryButton, etc.
│   │       ├── custom_text_field.dart# AppTextField, AppDropdownField, OtpBox
│   │       ├── loading_overlay.dart  # LoadingOverlay, Shimmer, Spinner
│   │       ├── empty_state.dart      # EmptyState factory widgets
│   │       ├── profile_avatar.dart   # ProfileAvatar (6 sizes, badges)
│   │       ├── match_card.dart       # MatchCard (4 styles)
│   │       ├── filter_sheet.dart     # FilterState, FilterSheet, SortSheet
│   │       └── block_report_dialog.dart # Block + Report flow
│   │
│   ├── data/                         # Data layer
│   │   │
│   │   ├── models/                   # Pure Dart models (no Firebase)
│   │   │   ├── user_model.dart       # UserModel, UserRole, AccountStatus
│   │   │   ├── profile_model.dart    # ProfileModel + all enums + extensions
│   │   │   │                         # (MaritalStatus, EmploymentType,
│   │   │   │                         #  FamilyType, ManglikStatus, ProfileFor)
│   │   │   ├── interest_model.dart   # InterestModel, InterestStatus
│   │   │   ├── connection_model.dart # ConnectionModel, ConnectionStatus
│   │   │   ├── chat_model.dart       # ChatModel, ChatStatus
│   │   │   ├── message_model.dart    # MessageModel, MessageType, MessageStatus
│   │   │   ├── notification_model.dart # NotificationModel, NotificationType
│   │   │   └── subscription_model.dart # SubscriptionModel, PlanFeatures,
│   │   │                               # PlanPricing, SubscriptionPlan
│   │   │
│   │   └── repositories/             # Data access layer
│   │       ├── auth_repository.dart       # OTP, Google Sign-in, Sign-out
│   │       ├── profile_repository.dart    # CRUD, photos, shortlist, block
│   │       ├── interest_repository.dart   # Send/Accept/Decline/Withdraw
│   │       ├── chat_repository.dart       # Messages, streams, mute, archive
│   │       ├── notification_repository.dart # CRUD, FCM, push helpers
│   │       └── subscription_repository.dart # Razorpay, plans, promo codes
│   │
│   ├── providers/                    # Riverpod state layer
│   │   ├── auth_provider.dart        # AuthState, AuthNotifier, AuthStep enum
│   │   │                             # Providers: currentUidProvider,
│   │   │                             #   isLoggedInProvider, isGuestProvider
│   │   ├── profile_provider.dart     # MyProfileNotifier, OtherProfileNotifier
│   │   │                             # Providers: currentProfileProvider,
│   │   │                             #   profileScoreProvider, hasProfileProvider
│   │   ├── app_state_provider.dart   # AppSettings, Connectivity,
│   │   │                             # NotificationsNotifier, BottomNavNotifier,
│   │   │                             # LoadingNotifier, SnackNotifier
│   │   ├── home_provider.dart        # HomeNotifier, SearchNotifier,
│   │   │                             # ProfileFilter model
│   │   ├── interest_provider.dart    # InterestsNotifier, connections,
│   │   │                             # sentInterestIdsProvider
│   │   └── chat_provider.dart        # ChatsNotifier, MessagesNotifier
│   │                                 # (optimistic updates)
│   │
│   └── presentation/                 # UI layer
│       │
│       ├── auth/                     # Authentication screens
│       │   ├── splash_screen.dart          # 6-layer animated splash
│       │   ├── welcome_screen.dart         # 3-slide onboarding
│       │   ├── phone_entry_screen.dart     # +91 phone input
│       │   ├── otp_screen.dart             # 6-box OTP (auto-verify)
│       │   ├── explore_first_screen.dart   # Browse vs Register choice
│       │   ├── profile_type_screen.dart    # Who is profile for?
│       │   │
│       │   └── profile_setup/        # 5-step profile creation
│       │       ├── step1_basic_info.dart   # Name, DOB, Height, City
│       │       ├── step2_religion.dart     # Religion, Caste, Gotra, Manglik
│       │       ├── step3_education.dart    # Qualification, Employment, Income
│       │       ├── step4_family.dart       # Family type, Parents, Siblings
│       │       └── step5_photos.dart       # 6-slot photo grid
│       │
│       ├── shell/
│       │   └── main_shell.dart       # Bottom nav (5 tabs + badges)
│       │
│       ├── home/                     # Main discovery screens
│       │   ├── home_screen.dart      # Today matches + New members + MockProfile
│       │   ├── search_screen.dart    # Search + Filter + Sort + Grid/List
│       │   └── profile_detail_screen.dart # Full profile view
│       │
│       ├── interests/
│       │   └── interests_screen.dart # Received/Sent/Connected tabs
│       │
│       ├── chat/
│       │   ├── chat_inbox_screen.dart  # Chat list
│       │   └── chat_window_screen.dart # Chat messages
│       │
│       ├── profile/                  # Profile screens
│       │   ├── my_profile_screen.dart           # Profile dashboard
│       │   ├── edit_profile_screen.dart          # 6-tab edit (Basic/Religion/Edu...)
│       │   ├── profile_preview_screen.dart       # Preview as others see it
│       │   ├── shortlisted_screen.dart           # Shortlisted profiles (Phase 5)
│       │   ├── who_viewed_screen.dart            # Who viewed my profile (Phase 5)
│       │   ├── partner_preference_screen.dart    # Partner filters (Phase 5)
│       │   ├── horoscope_screen.dart             # Horoscope details (Phase 5)
│       │   ├── id_verification_screen.dart       # ID verify flow (Phase 5)
│       │   └── blocked_users_screen.dart         # Blocked users list (Phase 5)
│       │
│       ├── placeholder_screens.dart  # Temporary — will be empty in Phase 5
│       │
│       └── settings/                 # Settings screens (Phase 5 — real UI pending)
│           ├── notifications_screen.dart   # Notification center
│           ├── premium_screen.dart         # Subscription plans
│           ├── privacy_screen.dart         # Privacy settings
│           ├── help_support_screen.dart    # Help & FAQ
│           └── delete_account_screen.dart  # Account deletion flow
│
├── assets/
│   ├── images/                       # App images
│   │   └── logo.png                  # App logo
│   ├── icons/                        # Custom icons
│   └── fonts/                        # Custom fonts (if any)
│
├── test/                             # Tests (Phase 6)
│   ├── unit/
│   │   ├── validators_test.dart
│   │   ├── formatters_test.dart
│   │   └── models_test.dart
│   └── widget/
│       ├── auth_test.dart
│       └── home_test.dart
│
├── pubspec.yaml                      # Dependencies
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

---

## ALL ROUTES (app_routes.dart)

```
/                    → SplashScreen
/welcome             → WelcomeScreen
/phone               → PhoneEntryScreen
/otp                 → OtpScreen(phoneNumber)
/explore             → ExploreFirstScreen
/profile-type        → ProfileTypeScreen

/setup/step1         → Step1BasicInfo(extra: {profileFor})
/setup/step2         → Step2Religion
/setup/step3         → Step3Education
/setup/step4         → Step4Family
/setup/step5         → Step5Photos

ShellRoute (MainShell — bottom nav):
  /home              → HomeScreen
  /search            → SearchScreen
  /interests         → InterestsScreen
  /chat              → ChatInboxScreen
  /my-profile        → MyProfileScreen

/profile/:uid        → ProfileDetailScreen
/profile-preview     → ProfilePreviewScreen
/edit-profile        → EditProfileScreen

/shortlisted         → ShortlistedScreen
/who-viewed          → WhoViewedScreen
/partner-preference  → PartnerPreferenceScreen
/horoscope           → HoroscopeScreen
/id-verification     → IdVerificationScreen
/blocked-users       → BlockedUsersScreen

/chat/:chatId        → ChatWindowScreen

/notifications       → NotificationsScreen
/premium             → PremiumScreen
/privacy             → PrivacyScreen
/help-support        → HelpSupportScreen
/delete-account      → DeleteAccountScreen
```

---

## ALL PROVIDERS

```dart
// ── AUTH ──────────────────────────────────────
authProvider              → AuthState (user, step, isLoading, error)
currentUidProvider        → String?
currentUserProvider       → UserModel?
isLoggedInProvider        → bool
isGuestProvider           → bool
hasCompletedSetupProvider → bool
authStepProvider          → AuthStep
authErrorProvider         → String?

// ── PROFILE ───────────────────────────────────
myProfileProvider         → MyProfileState
currentProfileProvider    → ProfileModel?
profileScoreProvider      → int
hasProfileProvider        → bool
isPremiumProvider         → bool

// ── APP STATE ─────────────────────────────────
appSettingsProvider       → AppSettings
connectivityProvider      → ConnectivityState
isConnectedProvider       → bool
notificationsProvider     → NotificationsState
unreadNotificationsCount  → int
bottomNavProvider         → int
globalLoadingProvider     → bool
snackProvider             → SnackMessage?
appInitProvider           → AppInitState

// ── HOME / SEARCH ─────────────────────────────
homeProvider              → HomeState
searchProvider            → SearchState
todayMatchesProvider      → List<ProfileModel>
newMembersProvider        → List<ProfileModel>
searchResultsProvider     → List<ProfileModel>
activeFilterCountProvider → int

// ── INTERESTS ─────────────────────────────────
interestsProvider         → InterestsState
pendingInterestsCount     → int
sentInterestIdsProvider   → Set<String>
connectionsProvider       → List<ConnectionModel>
connectionCountProvider   → int
isConnectedWithProvider   → bool (family: uid)
hasSentInterestProvider   → bool (family: profileId)

// ── CHAT ──────────────────────────────────────
chatsProvider             → ChatsState
messagesProvider          → MessagesState (family: chatId)
totalUnreadProvider       → int
visibleMessagesProvider   → List<MessageModel> (family: chatId)
isChatMutedProvider       → bool (family: chatId)
```

---

## ALL MODELS

```dart
// user_model.dart
UserModel { uid, phone, email, displayName, photoUrl,
            profileId, role, accountStatus,
            hasCompletedSetup, fcmTokens,
            notificationPreferences, privacySettings }

// profile_model.dart  (40+ fields)
ProfileModel { id, userId, profileFor, fullName, dateOfBirth,
               gender, heightInInches, currentCity, nativeCity,
               motherTongue, maritalStatus, about, photoUrls,
               religion, caste, subCaste, gotra, manglik,
               qualification, collegeName, employmentType,
               companyName, designation, annualIncome,
               familyType, familyValues, fatherOccupation,
               motherOccupation, brotherCount, sisterCount,
               familyCity, isVerified, isPremium, isActive,
               profileScore, lastActiveAt, shortlistedIds }

Enums: MaritalStatus, EmploymentType, FamilyType,
       FamilyValues, ManglikStatus, ProfileFor

// interest_model.dart
InterestModel { id, senderId, receiverId,
                senderProfileId, receiverProfileId,
                status, message, sentAt, respondedAt }
InterestStatus: pending, accepted, declined,
                withdrawn, expired

// connection_model.dart
ConnectionModel { id, userIds, initiatedBy,
                  status, connectedAt }

// chat_model.dart
ChatModel { id, participantIds, lastMessage,
            lastMessageTime, unreadCount, mutedBy, status }

// message_model.dart
MessageModel { id, chatId, senderId, type, text,
               mediaUrl, status, sentAt, readAt }
MessageType: text, image, system, deleted
MessageStatus: sending, sent, delivered, read, failed

// notification_model.dart
NotificationModel { id, userId, type, title, body,
                    senderId, referenceId, route,
                    isRead, createdAt }
NotificationType: 14 types (interestReceived,
                  interestAccepted, newMessage,
                  profileViewed, premiumExpiring...)

// subscription_model.dart
SubscriptionModel { id, userId, plan, months,
                    priceInPaise, status,
                    startDate, endDate }
SubscriptionPlan: free, silver, gold, diamond
```

---

## FIREBASE STRUCTURE (Phase 3)

```
Firestore Collections:
├── users/{uid}
│   ├── uid, phone, email, role
│   ├── profileId, hasCompletedSetup
│   ├── fcmTokens[], blockedUsers[]
│   └── notificationPreferences{}
│
├── profiles/{profileId}
│   ├── userId, fullName, dateOfBirth
│   ├── religion, caste, gotra
│   ├── qualification, employmentType
│   ├── familyType, familyValues
│   ├── photoUrls[], mainPhotoUrl
│   ├── isVerified, isPremium, isActive
│   └── shortlistedIds[], lastActiveAt
│
├── interests/{interestId}
│   ├── senderId, receiverId
│   ├── senderProfileId, receiverProfileId
│   ├── status, message
│   └── sentAt, respondedAt
│
├── connections/{connectionId}
│   ├── userIds[], initiatedBy
│   ├── status, connectedAt
│   └── chatId
│
├── chats/{chatId}
│   ├── participantIds[]
│   ├── lastMessage, lastMessageTime
│   ├── unreadCount{uid: count}
│   ├── mutedBy[], status
│   └── messages/ (subcollection)
│       └── {messageId}
│           ├── senderId, type, text
│           ├── mediaUrl, status
│           └── sentAt, readAt
│
├── notifications/{notificationId}
│   ├── userId, type, title, body
│   ├── senderId, referenceId, route
│   └── isRead, createdAt
│
├── subscriptions/{subscriptionId}
│   ├── userId, plan, months
│   ├── priceInPaise, status
│   └── startDate, endDate
│
├── reports/{reportId}
│   ├── reporterUserId, targetUserId
│   ├── reason, additionalInfo
│   └── status, createdAt
│
└── promoCodes/{code}
    ├── discountPercent
    └── expiresAt

Firebase Storage:
└── profiles/{userId}/
    └── photo_{timestamp}.jpg
```

---

## pubspec.yaml DEPENDENCIES

```yaml
name: rishta_app
description: Indian Matrimony App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^13.2.0

  # Firebase (uncomment in Phase 3)
  # firebase_core: ^3.3.0
  # firebase_auth: ^5.2.0
  # cloud_firestore: ^5.2.0
  # firebase_storage: ^12.1.0
  # firebase_messaging: ^15.1.0
  # google_sign_in: ^6.2.1

  # Payments (Phase 4)
  # razorpay_flutter: ^1.3.6

  # UI
  cached_network_image: ^3.3.1
  image_picker: ^1.1.2
  pin_code_fields: ^8.0.1

  # Storage
  shared_preferences: ^2.3.2

  # Utils
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## KEY DECISIONS

| Decision | Choice | Reason |
|----------|--------|--------|
| State | Riverpod | Type-safe, testable, no BuildContext |
| Navigation | GoRouter | Deep links, ShellRoute for bottom nav |
| Imports | Package imports only | `package:rishta_app/...` always |
| Mock OTP | "123456" | Phase 1-2 development |
| Firebase | Phase 3 | Mock first, integrate later |
| Profile images | Emoji for Phase 1-2 | Real upload in Phase 3 |
| Gender | Male/Female/Other | Inclusive |
| Language | English only | No Hinglish in code |

---

## DEVELOPMENT PHASES

| Phase | Status | What |
|-------|--------|------|
| Phase 1 | ✅ Done | All UI screens with mock data |
| Phase 2 | ✅ Done | Models, Repositories, Providers |
| Phase 3 | ⏳ Next | Firebase — real data |
| Phase 4 | ⏳ | Razorpay payments |
| Phase 5 | ⏳ | Remaining screens (placeholder → real) |
| Phase 6 | ⏳ | Testing + Play Store release |

---

## SCREEN INVENTORY

### ✅ COMPLETE SCREENS (Real UI)
| Screen | File | Route |
|--------|------|-------|
| Splash | splash_screen.dart | / |
| Welcome | welcome_screen.dart | /welcome |
| Phone Entry | phone_entry_screen.dart | /phone |
| OTP | otp_screen.dart | /otp |
| Explore First | explore_first_screen.dart | /explore |
| Profile Type | profile_type_screen.dart | /profile-type |
| Step 1 Basic Info | step1_basic_info.dart | /setup/step1 |
| Step 2 Religion | step2_religion.dart | /setup/step2 |
| Step 3 Education | step3_education.dart | /setup/step3 |
| Step 4 Family | step4_family.dart | /setup/step4 |
| Step 5 Photos | step5_photos.dart | /setup/step5 |
| Home | home_screen.dart | /home |
| Search | search_screen.dart | /search |
| Interests | interests_screen.dart | /interests |
| Chat Inbox | chat_inbox_screen.dart | /chat |
| Chat Window | chat_window_screen.dart | /chat/:chatId |
| My Profile | my_profile_screen.dart | /my-profile |
| Edit Profile | edit_profile_screen.dart | /edit-profile |
| Profile Preview | profile_preview_screen.dart | /profile-preview |
| Profile Detail | profile_detail_screen.dart | /profile/:uid |
| Main Shell | main_shell.dart | (shell) |

### ⏳ PHASE 5 — Build Real UI for these screens
Files already created — need real UI code written.
See 🟡 tables above for full list.

---

*Generated: April 2026 | RishtaApp v1.0 | Flutter 3.x*