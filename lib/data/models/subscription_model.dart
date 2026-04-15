// lib/data/models/subscription_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// SUBSCRIPTION PLAN ENUM
// ─────────────────────────────────────────────────────────

enum SubscriptionPlan {
  free,
  silver,
  gold,
  platinum,
}

extension SubscriptionPlanX on SubscriptionPlan {
  String get value {
    switch (this) {
      case SubscriptionPlan.free:     return 'free';
      case SubscriptionPlan.silver:   return 'silver';
      case SubscriptionPlan.gold:     return 'gold';
      case SubscriptionPlan.platinum: return 'platinum';
    }
  }

  String get label {
    switch (this) {
      case SubscriptionPlan.free:     return 'Free';
      case SubscriptionPlan.silver:   return 'Silver';
      case SubscriptionPlan.gold:     return 'Gold';
      case SubscriptionPlan.platinum: return 'Platinum';
    }
  }

  String get emoji {
    switch (this) {
      case SubscriptionPlan.free:     return '🆓';
      case SubscriptionPlan.silver:   return '🥈';
      case SubscriptionPlan.gold:     return '🥇';
      case SubscriptionPlan.platinum: return '💎';
    }
  }

  bool get isPaid => this != SubscriptionPlan.free;

  static SubscriptionPlan fromString(String? v) {
    switch (v) {
      case 'silver':   return SubscriptionPlan.silver;
      case 'gold':     return SubscriptionPlan.gold;
      case 'platinum': return SubscriptionPlan.platinum;
      default:         return SubscriptionPlan.free;
    }
  }
}

// ─────────────────────────────────────────────────────────
// SUBSCRIPTION STATUS ENUM
// ─────────────────────────────────────────────────────────

enum SubscriptionStatus {
  active,    // Currently active
  expired,   // Past expiry date
  cancelled, // Cancelled by user
  pending,   // Payment pending verification
  failed,    // Payment failed
}

extension SubscriptionStatusX on SubscriptionStatus {
  String get value {
    switch (this) {
      case SubscriptionStatus.active:    return 'active';
      case SubscriptionStatus.expired:   return 'expired';
      case SubscriptionStatus.cancelled: return 'cancelled';
      case SubscriptionStatus.pending:   return 'pending';
      case SubscriptionStatus.failed:    return 'failed';
    }
  }

  String get label {
    switch (this) {
      case SubscriptionStatus.active:    return 'Active';
      case SubscriptionStatus.expired:   return 'Expired';
      case SubscriptionStatus.cancelled: return 'Cancelled';
      case SubscriptionStatus.pending:   return 'Pending';
      case SubscriptionStatus.failed:    return 'Failed';
    }
  }

  static SubscriptionStatus fromString(String? v) {
    switch (v) {
      case 'expired':   return SubscriptionStatus.expired;
      case 'cancelled': return SubscriptionStatus.cancelled;
      case 'pending':   return SubscriptionStatus.pending;
      case 'failed':    return SubscriptionStatus.failed;
      default:          return SubscriptionStatus.active;
    }
  }
}

// ─────────────────────────────────────────────────────────
// PLAN FEATURES MODEL
// ─────────────────────────────────────────────────────────

/// Features included in each subscription plan.
class PlanFeatures {
  final int contactViewLimit;     // -1 = unlimited
  final int interestSendLimit;    // -1 = unlimited
  final bool canSeeWhoViewed;
  final bool canSeeContactDetails;
  final bool canSendMessage;
  final bool priorityListing;
  final bool advancedFilters;
  final bool hideAds;
  final bool profileBoost;
  final int photoLimit;
  final bool verifiedBadge;
  final bool dedicatedSupport;

  const PlanFeatures({
    required this.contactViewLimit,
    required this.interestSendLimit,
    required this.canSeeWhoViewed,
    required this.canSeeContactDetails,
    required this.canSendMessage,
    required this.priorityListing,
    required this.advancedFilters,
    required this.hideAds,
    required this.profileBoost,
    required this.photoLimit,
    required this.verifiedBadge,
    required this.dedicatedSupport,
  });

  // ── PLAN DEFINITIONS ──────────────────────────────────

  static const PlanFeatures free = PlanFeatures(
    contactViewLimit: 5,
    interestSendLimit: 5,
    canSeeWhoViewed: false,
    canSeeContactDetails: false,
    canSendMessage: false,
    priorityListing: false,
    advancedFilters: false,
    hideAds: false,
    profileBoost: false,
    photoLimit: 3,
    verifiedBadge: false,
    dedicatedSupport: false,
  );

  static const PlanFeatures silver = PlanFeatures(
    contactViewLimit: 30,
    interestSendLimit: 20,
    canSeeWhoViewed: true,
    canSeeContactDetails: true,
    canSendMessage: true,
    priorityListing: false,
    advancedFilters: true,
    hideAds: true,
    profileBoost: false,
    photoLimit: 10,
    verifiedBadge: false,
    dedicatedSupport: false,
  );

  static const PlanFeatures gold = PlanFeatures(
    contactViewLimit: -1,
    interestSendLimit: -1,
    canSeeWhoViewed: true,
    canSeeContactDetails: true,
    canSendMessage: true,
    priorityListing: true,
    advancedFilters: true,
    hideAds: true,
    profileBoost: true,
    photoLimit: 20,
    verifiedBadge: true,
    dedicatedSupport: false,
  );

  static const PlanFeatures platinum = PlanFeatures(
    contactViewLimit: -1,
    interestSendLimit: -1,
    canSeeWhoViewed: true,
    canSeeContactDetails: true,
    canSendMessage: true,
    priorityListing: true,
    advancedFilters: true,
    hideAds: true,
    profileBoost: true,
    photoLimit: -1,
    verifiedBadge: true,
    dedicatedSupport: true,
  );

  /// Get features for a plan
  static PlanFeatures forPlan(
      SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.silver:
        return silver;
      case SubscriptionPlan.gold:
        return gold;
      case SubscriptionPlan.platinum:
        return platinum;
      default:
        return free;
    }
  }

  bool get hasUnlimitedContacts =>
      contactViewLimit == -1;

  bool get hasUnlimitedInterests =>
      interestSendLimit == -1;

  bool get hasUnlimitedPhotos => photoLimit == -1;
}

// ─────────────────────────────────────────────────────────
// PLAN PRICING MODEL
// ─────────────────────────────────────────────────────────

/// Pricing details for a subscription plan.
class PlanPricing {
  final SubscriptionPlan plan;
  final int months;
  final int priceInPaise; // Razorpay uses paise
  final int? originalPriceInPaise;
  final String? badge; // e.g. 'Most Popular'

  const PlanPricing({
    required this.plan,
    required this.months,
    required this.priceInPaise,
    this.originalPriceInPaise,
    this.badge,
  });

  // ── PRICE HELPERS ─────────────────────────────────────

  /// Price in rupees
  int get priceInRupees => priceInPaise ~/ 100;

  /// Original price in rupees
  int? get originalPriceInRupees =>
      originalPriceInPaise != null
          ? originalPriceInPaise! ~/ 100
          : null;

  /// Display price '₹499'
  String get displayPrice =>
      '₹$priceInRupees';

  /// Price per month
  int get pricePerMonth => priceInRupees ~/ months;

  /// Display price per month '₹166/mo'
  String get displayPricePerMonth =>
      '₹$pricePerMonth/mo';

  /// Discount percentage
  int? get discountPercent {
    if (originalPriceInPaise == null) return null;
    final orig = originalPriceInPaise!;
    final curr = priceInPaise;
    return (((orig - curr) / orig) * 100).round();
  }

  /// Has discount
  bool get hasDiscount =>
      originalPriceInPaise != null &&
          originalPriceInPaise! > priceInPaise;

  /// Duration label '1 Month' / '3 Months'
  String get durationLabel =>
      months == 1 ? '1 Month' : '$months Months';

  // ── PREDEFINED PRICING ────────────────────────────────

  static const List<PlanPricing> allPlans = [
    // Silver
    PlanPricing(
      plan: SubscriptionPlan.silver,
      months: 1,
      priceInPaise: 49900,
      badge: null,
    ),
    PlanPricing(
      plan: SubscriptionPlan.silver,
      months: 3,
      priceInPaise: 129900,
      originalPriceInPaise: 149700,
    ),

    // Gold
    PlanPricing(
      plan: SubscriptionPlan.gold,
      months: 1,
      priceInPaise: 99900,
      badge: 'Most Popular',
    ),
    PlanPricing(
      plan: SubscriptionPlan.gold,
      months: 3,
      priceInPaise: 249900,
      originalPriceInPaise: 299700,
      badge: 'Best Value',
    ),
    PlanPricing(
      plan: SubscriptionPlan.gold,
      months: 6,
      priceInPaise: 449900,
      originalPriceInPaise: 599400,
    ),

    // Platinum
    PlanPricing(
      plan: SubscriptionPlan.platinum,
      months: 1,
      priceInPaise: 199900,
    ),
    PlanPricing(
      plan: SubscriptionPlan.platinum,
      months: 3,
      priceInPaise: 499900,
      originalPriceInPaise: 599700,
    ),
    PlanPricing(
      plan: SubscriptionPlan.platinum,
      months: 6,
      priceInPaise: 899900,
      originalPriceInPaise: 1199400,
    ),
  ];

  /// Get pricing options for a plan
  static List<PlanPricing> forPlan(
      SubscriptionPlan plan) {
    return allPlans
        .where((p) => p.plan == plan)
        .toList();
  }
}

// ─────────────────────────────────────────────────────────
// SUBSCRIPTION MODEL
// ─────────────────────────────────────────────────────────

/// Represents an active/past subscription of a user.
///
/// Firestore path: /subscriptions/{subscriptionId}
///
/// Fields:
/// - [id]              Firestore document ID
/// - [userId]          Owner user UID
/// - [plan]            silver/gold/platinum
/// - [status]          active/expired/cancelled/pending
/// - [months]          Duration in months
/// - [priceInPaise]    Amount paid (Razorpay paise)
/// - [razorpayOrderId] Razorpay order ID
/// - [razorpayPaymentId] Razorpay payment ID
/// - [startDate]       Subscription start date
/// - [endDate]         Subscription end date
/// - [autoRenew]       Auto-renewal enabled
/// - [cancelledAt]     When user cancelled
/// - [createdAt]       When subscription was created
class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final int months;
  final int priceInPaise;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final DateTime? cancelledAt;
  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    this.status = SubscriptionStatus.active,
    required this.months,
    required this.priceInPaise,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.startDate,
    required this.endDate,
    this.autoRenew = false,
    this.cancelledAt,
    required this.createdAt,
  });

  // ── COMPUTED ──────────────────────────────────────────

  bool get isActive =>
      status == SubscriptionStatus.active &&
          !isExpiredNow;

  bool get isExpiredNow =>
      DateTime.now().isAfter(endDate);

  bool get isPaid =>
      plan != SubscriptionPlan.free;

  bool get isSilver =>
      plan == SubscriptionPlan.silver;

  bool get isGold =>
      plan == SubscriptionPlan.gold;

  bool get isPlatinum =>
      plan == SubscriptionPlan.platinum;

  /// Days remaining in subscription
  int get daysRemaining {
    final diff = endDate.difference(DateTime.now());
    return diff.inDays.clamp(0, 9999);
  }

  /// Hours remaining today
  int get hoursRemaining {
    final diff = endDate.difference(DateTime.now());
    return diff.inHours.clamp(0, 9999);
  }

  /// Is expiring within 7 days
  bool get isExpiringSoon =>
      isActive && daysRemaining <= 7;

  /// Is expiring today
  bool get isExpiringToday =>
      isActive && daysRemaining == 0;

  /// Expiry display text
  String get expiryText {
    if (isExpiredNow) return 'Expired';
    if (daysRemaining == 0) return 'Expires today';
    if (daysRemaining == 1) return '1 day left';
    if (daysRemaining < 30) {
      return '$daysRemaining days left';
    }
    final months = (daysRemaining / 30).floor();
    return '$months month${months > 1 ? 's' : ''} left';
  }

  /// Price in rupees
  int get priceInRupees => priceInPaise ~/ 100;

  /// Display price
  String get displayPrice =>
      '₹$priceInRupees';

  /// Plan features
  PlanFeatures get features =>
      PlanFeatures.forPlan(plan);

  /// Plan label with duration
  String get planLabel =>
      '${plan.label} • $months Month${months > 1 ? 's' : ''}';

  // ── FROM MAP ──────────────────────────────────────────

  factory SubscriptionModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return SubscriptionModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      plan: SubscriptionPlanX.fromString(
          data['plan'] as String?),
      status: SubscriptionStatusX.fromString(
          data['status'] as String?),
      months: data['months'] as int? ?? 1,
      priceInPaise:
      data['priceInPaise'] as int? ?? 0,
      razorpayOrderId:
      data['razorpayOrderId'] as String?,
      razorpayPaymentId:
      data['razorpayPaymentId'] as String?,
      startDate:
      _parseDateTime(data['startDate']) ??
          DateTime.now(),
      endDate:
      _parseDateTime(data['endDate']) ??
          DateTime.now().add(
              const Duration(days: 30)),
      autoRenew:
      data['autoRenew'] as bool? ?? false,
      cancelledAt:
      _parseDateTime(data['cancelledAt']),
      createdAt:
      _parseDateTime(data['createdAt']) ??
          DateTime.now(),
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'plan': plan.value,
      'status': status.value,
      'months': months,
      'priceInPaise': priceInPaise,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'autoRenew': autoRenew,
      'cancelledAt':
      cancelledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    int? months,
    int? priceInPaise,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoRenew,
    DateTime? cancelledAt,
    DateTime? createdAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      months: months ?? this.months,
      priceInPaise:
      priceInPaise ?? this.priceInPaise,
      razorpayOrderId:
      razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ??
          this.razorpayPaymentId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoRenew: autoRenew ?? this.autoRenew,
      cancelledAt:
      cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── STATUS TRANSITIONS ────────────────────────────────

  SubscriptionModel markActive() =>
      copyWith(status: SubscriptionStatus.active);

  SubscriptionModel markExpired() =>
      copyWith(status: SubscriptionStatus.expired);

  SubscriptionModel cancel() => copyWith(
    status: SubscriptionStatus.cancelled,
    cancelledAt: DateTime.now(),
  );

  // ── FACTORY CONSTRUCTORS ──────────────────────────────

  /// Create a new subscription after payment
  factory SubscriptionModel.create({
    required String userId,
    required SubscriptionPlan plan,
    required int months,
    required int priceInPaise,
    required String razorpayOrderId,
    required String razorpayPaymentId,
  }) {
    final now = DateTime.now();
    return SubscriptionModel(
      id: 'sub_${now.millisecondsSinceEpoch}',
      userId: userId,
      plan: plan,
      status: SubscriptionStatus.active,
      months: months,
      priceInPaise: priceInPaise,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      startDate: now,
      endDate: now.add(
          Duration(days: months * 30)),
      autoRenew: false,
      createdAt: now,
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
      other is SubscriptionModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SubscriptionModel(id: $id, '
          'plan: ${plan.value}, '
          'status: ${status.value}, '
          'daysRemaining: $daysRemaining)';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension SubscriptionModelFirestore
    on SubscriptionModel {
  static SubscriptionModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SubscriptionModel.fromMap(doc.id, {
      ...data,
      'startDate':
          (data['startDate'] as Timestamp?)
              ?.toDate(),
      'endDate':
          (data['endDate'] as Timestamp?)
              ?.toDate(),
      'cancelledAt':
          (data['cancelledAt'] as Timestamp?)
              ?.toDate(),
      'createdAt':
          (data['createdAt'] as Timestamp?)
              ?.toDate(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    return {
      ...map,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
*/