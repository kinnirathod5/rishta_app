// lib/data/models/subscription_model.dart

enum SubscriptionPlan {
  silver,
  gold,
  platinum,
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
}

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final int durationMonths; // 1 | 3 | 6
  final double amountPaid;
  final String currency;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.durationMonths,
    required this.amountPaid,
    this.currency = 'INR',
    this.status = SubscriptionStatus.active,
    required this.startDate,
    required this.endDate,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.createdAt,
  });

  // ── FROM FIRESTORE ──────────────────────────────────
  factory SubscriptionModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return SubscriptionModel(
      id: id,
      userId: data['userId'] ?? '',
      plan: SubscriptionPlan.values.firstWhere(
            (e) => e.name == (data['plan'] ?? 'silver'),
        orElse: () => SubscriptionPlan.silver,
      ),
      durationMonths: data['durationMonths'] ?? 1,
      amountPaid: (data['amountPaid'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      status: SubscriptionStatus.values.firstWhere(
            (e) => e.name == (data['status'] ?? 'active'),
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : DateTime.now(),
      endDate: data['endDate'] != null
          ? DateTime.parse(data['endDate'])
          : DateTime.now(),
      razorpayOrderId: data['razorpayOrderId'],
      razorpayPaymentId: data['razorpayPaymentId'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  // ── TO FIRESTORE ────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'plan': plan.name,
      'durationMonths': durationMonths,
      'amountPaid': amountPaid,
      'currency': currency,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ── COPY WITH ───────────────────────────────────────
  SubscriptionModel copyWith({
    SubscriptionStatus? status,
    String? razorpayPaymentId,
  }) {
    return SubscriptionModel(
      id: id,
      userId: userId,
      plan: plan,
      durationMonths: durationMonths,
      amountPaid: amountPaid,
      currency: currency,
      status: status ?? this.status,
      startDate: startDate,
      endDate: endDate,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId:
      razorpayPaymentId ?? this.razorpayPaymentId,
      createdAt: createdAt,
    );
  }

  // ── PLAN FEATURES ───────────────────────────────────
  static const Map<SubscriptionPlan, Map<String, dynamic>>
  planFeatures = {
    SubscriptionPlan.silver: {
      'contactsLimit': 50,
      'chatEnabled': true,
      'videoCallLimit': 0,
      'profileBoosts': 1,
      'whoViewedMe': false,
      'relationshipManager': false,
      'featuredProfile': false,
      'adsRemoved': true,
    },
    SubscriptionPlan.gold: {
      'contactsLimit': 200,
      'chatEnabled': true,
      'videoCallLimit': 10,
      'profileBoosts': 5,
      'whoViewedMe': true,
      'relationshipManager': false,
      'featuredProfile': false,
      'adsRemoved': true,
    },
    SubscriptionPlan.platinum: {
      'contactsLimit': -1, // unlimited
      'chatEnabled': true,
      'videoCallLimit': -1, // unlimited
      'profileBoosts': -1, // unlimited
      'whoViewedMe': true,
      'relationshipManager': true,
      'featuredProfile': true,
      'adsRemoved': true,
    },
  };

  // ── PLAN PRICES (INR) ───────────────────────────────
  static const Map<SubscriptionPlan, Map<int, int>>
  planPrices = {
    SubscriptionPlan.silver: {1: 499, 3: 1299, 6: 2199},
    SubscriptionPlan.gold: {1: 999, 3: 2599, 6: 4499},
    SubscriptionPlan.platinum: {1: 1999, 3: 4999, 6: 8999},
  };

  // ── HELPERS ─────────────────────────────────────────
  bool get isActive =>
      status == SubscriptionStatus.active &&
          endDate.isAfter(DateTime.now());

  bool get isExpired =>
      status == SubscriptionStatus.expired ||
          endDate.isBefore(DateTime.now());

  bool get isCancelled =>
      status == SubscriptionStatus.cancelled;

  int get daysRemaining {
    if (!isActive) return 0;
    final diff = endDate.difference(DateTime.now());
    return diff.inDays.clamp(0, 999);
  }

  Map<String, dynamic> get features =>
      planFeatures[plan] ?? {};

  bool getFeature(String key) {
    final value = features[key];
    if (value is bool) return value;
    if (value is int) return value != 0;
    return false;
  }

  int getFeatureLimit(String key) {
    final value = features[key];
    if (value is int) return value;
    return 0;
  }

  static int getPrice(SubscriptionPlan plan, int months) {
    return planPrices[plan]?[months] ?? 0;
  }

  static String getPriceText(
      SubscriptionPlan plan, int months) {
    final price = getPrice(plan, months);
    final label = months == 1
        ? 'mahina'
        : '$months mahine';
    return '₹$price / $label';
  }

  String get planName {
    switch (plan) {
      case SubscriptionPlan.silver:
        return 'Silver';
      case SubscriptionPlan.gold:
        return 'Gold';
      case SubscriptionPlan.platinum:
        return 'Platinum';
    }
  }

  String get planEmoji {
    switch (plan) {
      case SubscriptionPlan.silver:
        return '🥈';
      case SubscriptionPlan.gold:
        return '🥇';
      case SubscriptionPlan.platinum:
        return '💎';
    }
  }

  String get statusText {
    switch (status) {
      case SubscriptionStatus.active:
        return isExpired ? 'Expire Ho Gaya' : 'Active';
      case SubscriptionStatus.expired:
        return 'Expire Ho Gaya';
      case SubscriptionStatus.cancelled:
        return 'Cancel Ho Gaya';
    }
  }

  @override
  String toString() =>
      'SubscriptionModel(id: $id, plan: ${plan.name}, '
          'status: ${status.name}, daysLeft: $daysRemaining)';
}