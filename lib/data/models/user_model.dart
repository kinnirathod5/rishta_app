// lib/data/models/user_model.dart
// Core user authentication model

class UserModel {
  final String uid;
  final String phoneNumber;
  final String? email;
  final String? googleId;
  final bool isAnonymous;
  final bool isPhoneVerified;
  final bool isIdVerified;
  final bool isPremium;
  final String? premiumPlan; // 'silver' | 'gold' | 'platinum'
  final DateTime? premiumExpiry;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isActive; // false = deactivated
  final bool isDeleted;
  final String profileId; // linked ProfileModel id

  const UserModel({
    required this.uid,
    required this.phoneNumber,
    this.email,
    this.googleId,
    this.isAnonymous = false,
    this.isPhoneVerified = false,
    this.isIdVerified = false,
    this.isPremium = false,
    this.premiumPlan,
    this.premiumExpiry,
    required this.createdAt,
    required this.lastActiveAt,
    this.isActive = true,
    this.isDeleted = false,
    required this.profileId,
  });

  // ── FROM FIRESTORE ──────────────────────────────────
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'],
      googleId: data['googleId'],
      isAnonymous: data['isAnonymous'] ?? false,
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      isIdVerified: data['isIdVerified'] ?? false,
      isPremium: data['isPremium'] ?? false,
      premiumPlan: data['premiumPlan'],
      premiumExpiry: data['premiumExpiry'] != null
          ? DateTime.parse(data['premiumExpiry'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      lastActiveAt: data['lastActiveAt'] != null
          ? DateTime.parse(data['lastActiveAt'])
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
      isDeleted: data['isDeleted'] ?? false,
      profileId: data['profileId'] ?? '',
    );
  }

  // ── TO FIRESTORE ────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'googleId': googleId,
      'isAnonymous': isAnonymous,
      'isPhoneVerified': isPhoneVerified,
      'isIdVerified': isIdVerified,
      'isPremium': isPremium,
      'premiumPlan': premiumPlan,
      'premiumExpiry': premiumExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'isActive': isActive,
      'isDeleted': isDeleted,
      'profileId': profileId,
    };
  }

  // ── COPY WITH ───────────────────────────────────────
  UserModel copyWith({
    String? phoneNumber,
    String? email,
    String? googleId,
    bool? isAnonymous,
    bool? isPhoneVerified,
    bool? isIdVerified,
    bool? isPremium,
    String? premiumPlan,
    DateTime? premiumExpiry,
    DateTime? lastActiveAt,
    bool? isActive,
    bool? isDeleted,
    String? profileId,
  }) {
    return UserModel(
      uid: uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      googleId: googleId ?? this.googleId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isIdVerified: isIdVerified ?? this.isIdVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      profileId: profileId ?? this.profileId,
    );
  }

  // ── HELPERS ─────────────────────────────────────────
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiry == null) return false;
    return premiumExpiry!.isAfter(DateTime.now());
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, phone: $phoneNumber, premium: $isPremium)';
}