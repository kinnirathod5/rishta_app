// lib/data/models/user_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// USER ROLE ENUM
// ─────────────────────────────────────────────────────────

enum UserRole {
  user,   // Normal registered user
  guest,  // Anonymous/explore user
  admin,  // Admin panel access
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.user:  return 'user';
      case UserRole.guest: return 'guest';
      case UserRole.admin: return 'admin';
    }
  }

  bool get isGuest => this == UserRole.guest;
  bool get isAdmin => this == UserRole.admin;
  bool get isUser  => this == UserRole.user;

  static UserRole fromString(String? v) {
    switch (v) {
      case 'guest': return UserRole.guest;
      case 'admin': return UserRole.admin;
      default:      return UserRole.user;
    }
  }
}

// ─────────────────────────────────────────────────────────
// ACCOUNT STATUS ENUM
// ─────────────────────────────────────────────────────────

enum AccountStatus {
  active,      // Normal active account
  suspended,   // Temporarily suspended
  deactivated, // User deactivated account
  banned,      // Permanently banned
  deleted,     // Soft deleted
}

extension AccountStatusX on AccountStatus {
  String get value {
    switch (this) {
      case AccountStatus.active:
        return 'active';
      case AccountStatus.suspended:
        return 'suspended';
      case AccountStatus.deactivated:
        return 'deactivated';
      case AccountStatus.banned:
        return 'banned';
      case AccountStatus.deleted:
        return 'deleted';
    }
  }

  bool get isActive =>
      this == AccountStatus.active;

  bool get isAccessible =>
      this == AccountStatus.active ||
          this == AccountStatus.deactivated;

  static AccountStatus fromString(String? v) {
    switch (v) {
      case 'suspended':   return AccountStatus.suspended;
      case 'deactivated': return AccountStatus.deactivated;
      case 'banned':      return AccountStatus.banned;
      case 'deleted':     return AccountStatus.deleted;
      default:            return AccountStatus.active;
    }
  }
}

// ─────────────────────────────────────────────────────────
// NOTIFICATION PREFERENCES MODEL
// ─────────────────────────────────────────────────────────

/// User's notification preferences.
class NotificationPreferences {
  final bool interests;     // Interest received/accepted
  final bool messages;      // New messages
  final bool profileViews;  // Profile viewed
  final bool matches;       // New match suggestions
  final bool reminders;     // Profile completion reminders
  final bool promotional;   // Offers and promotions
  final bool pushEnabled;   // Master push toggle
  final bool emailEnabled;  // Email notifications

  const NotificationPreferences({
    this.interests = true,
    this.messages = true,
    this.profileViews = true,
    this.matches = true,
    this.reminders = true,
    this.promotional = false,
    this.pushEnabled = true,
    this.emailEnabled = true,
  });

  factory NotificationPreferences.fromMap(
      Map<String, dynamic> data) {
    return NotificationPreferences(
      interests:
      data['interests'] as bool? ?? true,
      messages:
      data['messages'] as bool? ?? true,
      profileViews:
      data['profileViews'] as bool? ?? true,
      matches: data['matches'] as bool? ?? true,
      reminders:
      data['reminders'] as bool? ?? true,
      promotional:
      data['promotional'] as bool? ?? false,
      pushEnabled:
      data['pushEnabled'] as bool? ?? true,
      emailEnabled:
      data['emailEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'interests': interests,
      'messages': messages,
      'profileViews': profileViews,
      'matches': matches,
      'reminders': reminders,
      'promotional': promotional,
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
    };
  }

  NotificationPreferences copyWith({
    bool? interests,
    bool? messages,
    bool? profileViews,
    bool? matches,
    bool? reminders,
    bool? promotional,
    bool? pushEnabled,
    bool? emailEnabled,
  }) {
    return NotificationPreferences(
      interests: interests ?? this.interests,
      messages: messages ?? this.messages,
      profileViews:
      profileViews ?? this.profileViews,
      matches: matches ?? this.matches,
      reminders: reminders ?? this.reminders,
      promotional:
      promotional ?? this.promotional,
      pushEnabled:
      pushEnabled ?? this.pushEnabled,
      emailEnabled:
      emailEnabled ?? this.emailEnabled,
    );
  }

  /// All notifications disabled
  static const NotificationPreferences disabled =
  NotificationPreferences(
    interests: false,
    messages: false,
    profileViews: false,
    matches: false,
    reminders: false,
    promotional: false,
    pushEnabled: false,
    emailEnabled: false,
  );
}

// ─────────────────────────────────────────────────────────
// PRIVACY SETTINGS MODEL
// ─────────────────────────────────────────────────────────

/// User's privacy settings.
class PrivacySettings {
  final bool showOnlineStatus;    // Show green dot
  final bool showLastSeen;        // Show last seen time
  final bool showProfileViews;    // Allow others to see who viewed
  final bool allowMessageFromAll; // Or only connections
  final bool hideFromSearch;      // Hidden from search results
  final bool profileVisible;      // Profile visible to others
  final bool showPhoneNumber;     // Show phone in profile

  const PrivacySettings({
    this.showOnlineStatus = true,
    this.showLastSeen = true,
    this.showProfileViews = true,
    this.allowMessageFromAll = false,
    this.hideFromSearch = false,
    this.profileVisible = true,
    this.showPhoneNumber = false,
  });

  factory PrivacySettings.fromMap(
      Map<String, dynamic> data) {
    return PrivacySettings(
      showOnlineStatus:
      data['showOnlineStatus'] as bool? ??
          true,
      showLastSeen:
      data['showLastSeen'] as bool? ?? true,
      showProfileViews:
      data['showProfileViews'] as bool? ??
          true,
      allowMessageFromAll:
      data['allowMessageFromAll'] as bool? ??
          false,
      hideFromSearch:
      data['hideFromSearch'] as bool? ??
          false,
      profileVisible:
      data['profileVisible'] as bool? ?? true,
      showPhoneNumber:
      data['showPhoneNumber'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showOnlineStatus': showOnlineStatus,
      'showLastSeen': showLastSeen,
      'showProfileViews': showProfileViews,
      'allowMessageFromAll': allowMessageFromAll,
      'hideFromSearch': hideFromSearch,
      'profileVisible': profileVisible,
      'showPhoneNumber': showPhoneNumber,
    };
  }

  PrivacySettings copyWith({
    bool? showOnlineStatus,
    bool? showLastSeen,
    bool? showProfileViews,
    bool? allowMessageFromAll,
    bool? hideFromSearch,
    bool? profileVisible,
    bool? showPhoneNumber,
  }) {
    return PrivacySettings(
      showOnlineStatus:
      showOnlineStatus ?? this.showOnlineStatus,
      showLastSeen:
      showLastSeen ?? this.showLastSeen,
      showProfileViews:
      showProfileViews ?? this.showProfileViews,
      allowMessageFromAll: allowMessageFromAll ??
          this.allowMessageFromAll,
      hideFromSearch:
      hideFromSearch ?? this.hideFromSearch,
      profileVisible:
      profileVisible ?? this.profileVisible,
      showPhoneNumber:
      showPhoneNumber ?? this.showPhoneNumber,
    );
  }
}

// ─────────────────────────────────────────────────────────
// USER MODEL
// ─────────────────────────────────────────────────────────

/// Core user account — authentication & settings.
/// Separate from ProfileModel which holds matrimony data.
///
/// Firestore path: /users/{uid}
///
/// UserModel  → Auth data, settings, preferences
/// ProfileModel → Matrimony profile data
class UserModel {
  // ── IDENTITY ──────────────────────────────────────────
  final String uid;
  final String phoneNumber;
  final String? email;
  final UserRole role;
  final AccountStatus accountStatus;

  // ── PROFILE LINK ──────────────────────────────────────
  final String? profileId;       // Link to ProfileModel
  final bool hasCompletedSetup;  // Profile setup done

  // ── FCM ───────────────────────────────────────────────
  final List<String> fcmTokens;  // Push notification tokens

  // ── PREFERENCES ───────────────────────────────────────
  final NotificationPreferences notificationPrefs;
  final PrivacySettings privacySettings;

  // ── ACTIVITY ──────────────────────────────────────────
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── REFERRAL ──────────────────────────────────────────
  final String? referralCode;      // This user's code
  final String? referredByCode;    // Code used to join
  final int referralCount;         // How many referred

  const UserModel({
    required this.uid,
    required this.phoneNumber,
    this.email,
    this.role = UserRole.user,
    this.accountStatus = AccountStatus.active,
    this.profileId,
    this.hasCompletedSetup = false,
    this.fcmTokens = const [],
    this.notificationPrefs =
    const NotificationPreferences(),
    this.privacySettings = const PrivacySettings(),
    this.isOnline = false,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
    this.referralCode,
    this.referredByCode,
    this.referralCount = 0,
  });

  // ── COMPUTED ──────────────────────────────────────────

  bool get isGuest   => role == UserRole.guest;
  bool get isAdmin   => role == UserRole.admin;
  bool get isActive  => accountStatus.isActive;

  bool get hasProfile =>
      profileId != null && profileId!.isNotEmpty;

  bool get hasEmail =>
      email != null && email!.isNotEmpty;

  bool get hasFcmToken => fcmTokens.isNotEmpty;

  /// Formatted phone number '98765 43210'
  String get formattedPhone {
    final clean = phoneNumber.replaceAll(
        RegExp(r'[^0-9]'), '');
    final digits = clean.length > 10
        ? clean.substring(clean.length - 10)
        : clean;
    if (digits.length != 10) return phoneNumber;
    return '${digits.substring(0, 5)} '
        '${digits.substring(5)}';
  }

  /// Masked phone number '98765 *****'
  String get maskedPhone {
    final clean = phoneNumber.replaceAll(
        RegExp(r'[^0-9]'), '');
    final digits = clean.length > 10
        ? clean.substring(clean.length - 10)
        : clean;
    if (digits.length != 10) return phoneNumber;
    return '${digits.substring(0, 5)} *****';
  }

  /// Phone with country code '+91 98765 43210'
  String get phoneWithCode =>
      '+91 $formattedPhone';

  /// Last seen display text
  String get lastSeenText {
    if (isOnline) return 'Online';
    if (lastSeenAt == null) return 'Last seen recently';
    final diff =
    DateTime.now().difference(lastSeenAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return 'Last seen ${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return 'Last seen ${diff.inHours}h ago';
    }
    if (diff.inDays == 1) {
      return 'Last seen yesterday';
    }
    return 'Last seen ${diff.inDays}d ago';
  }

  /// Member since display
  String get memberSinceText {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Member since '
        '${months[createdAt.month - 1]} '
        '${createdAt.year}';
  }

  // ── FROM MAP ──────────────────────────────────────────

  factory UserModel.fromMap(
      String uid,
      Map<String, dynamic> data,
      ) {
    return UserModel(
      uid: uid,
      phoneNumber:
      data['phoneNumber'] as String? ?? '',
      email: data['email'] as String?,
      role: UserRoleX.fromString(
          data['role'] as String?),
      accountStatus: AccountStatusX.fromString(
          data['accountStatus'] as String?),
      profileId: data['profileId'] as String?,
      hasCompletedSetup:
      data['hasCompletedSetup'] as bool? ??
          false,
      fcmTokens: List<String>.from(
          data['fcmTokens'] ?? []),
      notificationPrefs:
      data['notificationPrefs'] != null
          ? NotificationPreferences.fromMap(
          Map<String, dynamic>.from(
              data['notificationPrefs']))
          : const NotificationPreferences(),
      privacySettings:
      data['privacySettings'] != null
          ? PrivacySettings.fromMap(
          Map<String, dynamic>.from(
              data['privacySettings']))
          : const PrivacySettings(),
      isOnline:
      data['isOnline'] as bool? ?? false,
      lastSeenAt:
      _parseDateTime(data['lastSeenAt']),
      createdAt:
      _parseDateTime(data['createdAt']) ??
          DateTime.now(),
      updatedAt:
      _parseDateTime(data['updatedAt']) ??
          DateTime.now(),
      referralCode:
      data['referralCode'] as String?,
      referredByCode:
      data['referredByCode'] as String?,
      referralCount:
      data['referralCount'] as int? ?? 0,
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role.value,
      'accountStatus': accountStatus.value,
      'profileId': profileId,
      'hasCompletedSetup': hasCompletedSetup,
      'fcmTokens': fcmTokens,
      'notificationPrefs':
      notificationPrefs.toMap(),
      'privacySettings': privacySettings.toMap(),
      'isOnline': isOnline,
      'lastSeenAt':
      lastSeenAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'referralCode': referralCode,
      'referredByCode': referredByCode,
      'referralCount': referralCount,
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? email,
    UserRole? role,
    AccountStatus? accountStatus,
    String? profileId,
    bool? hasCompletedSetup,
    List<String>? fcmTokens,
    NotificationPreferences? notificationPrefs,
    PrivacySettings? privacySettings,
    bool? isOnline,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? referralCode,
    String? referredByCode,
    int? referralCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      accountStatus:
      accountStatus ?? this.accountStatus,
      profileId: profileId ?? this.profileId,
      hasCompletedSetup:
      hasCompletedSetup ?? this.hasCompletedSetup,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      notificationPrefs:
      notificationPrefs ?? this.notificationPrefs,
      privacySettings:
      privacySettings ?? this.privacySettings,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      referralCode:
      referralCode ?? this.referralCode,
      referredByCode:
      referredByCode ?? this.referredByCode,
      referralCount:
      referralCount ?? this.referralCount,
    );
  }

  // ── ACTIONS ───────────────────────────────────────────

  /// Mark user as online
  UserModel goOnline() => copyWith(
    isOnline: true,
    updatedAt: DateTime.now(),
  );

  /// Mark user as offline
  UserModel goOffline() => copyWith(
    isOnline: false,
    lastSeenAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// Add FCM token
  UserModel addFcmToken(String token) {
    if (fcmTokens.contains(token)) return this;
    return copyWith(
      fcmTokens: [...fcmTokens, token],
    );
  }

  /// Remove FCM token
  UserModel removeFcmToken(String token) {
    return copyWith(
      fcmTokens: fcmTokens
          .where((t) => t != token)
          .toList(),
    );
  }

  /// Link profile after setup
  UserModel linkProfile(String profileId) =>
      copyWith(
        profileId: profileId,
        hasCompletedSetup: true,
        updatedAt: DateTime.now(),
      );

  /// Deactivate account
  UserModel deactivate() => copyWith(
    accountStatus: AccountStatus.deactivated,
    isOnline: false,
    updatedAt: DateTime.now(),
  );

  // ── STATIC HELPERS ────────────────────────────────────

  /// Generate a unique referral code
  static String generateReferralCode(String uid) {
    final suffix = uid.length >= 6
        ? uid.substring(0, 6).toUpperCase()
        : uid.toUpperCase();
    return 'RA$suffix';
  }

  /// Create a new user after phone auth
  factory UserModel.create({
    required String uid,
    required String phoneNumber,
    String? referredByCode,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
      role: UserRole.user,
      accountStatus: AccountStatus.active,
      hasCompletedSetup: false,
      fcmTokens: const [],
      notificationPrefs:
      const NotificationPreferences(),
      privacySettings:
      const PrivacySettings(),
      isOnline: true,
      createdAt: now,
      updatedAt: now,
      referralCode:
      UserModel.generateReferralCode(uid),
      referredByCode: referredByCode,
      referralCount: 0,
    );
  }

  /// Create a guest/anonymous user
  factory UserModel.guest({required String uid}) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      phoneNumber: '',
      role: UserRole.guest,
      accountStatus: AccountStatus.active,
      hasCompletedSetup: false,
      fcmTokens: const [],
      notificationPrefs:
      NotificationPreferences.disabled,
      privacySettings:
      const PrivacySettings(),
      isOnline: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    // Phase 3: Timestamp.toDate() handled here
    // if (value is Timestamp) return value.toDate();
    return null;
  }

  // ── EQUALITY ──────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is UserModel && other.uid == uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() =>
      'UserModel(uid: $uid, '
          'phone: $maskedPhone, '
          'role: ${role.value}, '
          'status: ${accountStatus.value})';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension UserModelFirestore on UserModel {
  static UserModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserModel.fromMap(doc.id, {
      ...data,
      'lastSeenAt':
          (data['lastSeenAt'] as Timestamp?)
              ?.toDate(),
      'createdAt':
          (data['createdAt'] as Timestamp?)
              ?.toDate(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)
              ?.toDate(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    return {
      ...map,
      'lastSeenAt': lastSeenAt != null
          ? Timestamp.fromDate(lastSeenAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
*/