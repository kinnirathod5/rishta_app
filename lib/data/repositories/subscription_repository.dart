// lib/data/repositories/subscription_repository.dart
//
// NOTE: Firebase (cloud_firestore) + Razorpay Phase 3/4 mein add hoga.
// Tab actual Firestore + Razorpay calls uncomment karna hai.
// Abhi mock implementation se kaam chalega.

import 'package:rishta_app/data/models/subscription_model.dart';

// ─────────────────────────────────────────────────────────
// SUBSCRIPTION EXCEPTIONS
// ─────────────────────────────────────────────────────────

class SubscriptionException implements Exception {
  final String code;
  final String message;

  const SubscriptionException({
    required this.code,
    required this.message,
  });

  factory SubscriptionException.fromCode(
      String code) {
    switch (code) {
      case 'subscription-not-found':
        return const SubscriptionException(
          code: 'subscription-not-found',
          message: 'No active subscription found.',
        );
      case 'payment-failed':
        return const SubscriptionException(
          code: 'payment-failed',
          message: 'Payment failed. Please try again.',
        );
      case 'payment-cancelled':
        return const SubscriptionException(
          code: 'payment-cancelled',
          message: 'Payment was cancelled.',
        );
      case 'order-creation-failed':
        return const SubscriptionException(
          code: 'order-creation-failed',
          message: 'Could not create payment order. Please try again.',
        );
      case 'verification-failed':
        return const SubscriptionException(
          code: 'verification-failed',
          message: 'Payment verification failed. Contact support.',
        );
      case 'already-active':
        return const SubscriptionException(
          code: 'already-active',
          message: 'You already have an active subscription.',
        );
      case 'network-error':
        return const SubscriptionException(
          code: 'network-error',
          message: 'No internet connection. Please try again.',
        );
      default:
        return const SubscriptionException(
          code: 'unknown',
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  @override
  String toString() =>
      'SubscriptionException('
          'code: $code, message: $message)';
}

// ─────────────────────────────────────────────────────────
// RAZORPAY ORDER MODEL
// ─────────────────────────────────────────────────────────

/// Razorpay order details for payment initiation.
class RazorpayOrder {
  final String orderId;
  final int amountInPaise;
  final String currency;
  final String receipt;
  final SubscriptionPlan plan;
  final int months;

  const RazorpayOrder({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    required this.receipt,
    required this.plan,
    required this.months,
  });

  /// Amount in rupees
  int get amountInRupees => amountInPaise ~/ 100;

  /// Display amount '₹999'
  String get displayAmount =>
      '₹$amountInRupees';

  /// Razorpay options map
  Map<String, dynamic> toRazorpayOptions({
    required String userName,
    required String userPhone,
    String? userEmail,
    String? appName,
  }) {
    return {
      'key': 'rzp_test_XXXXXXXXXXXXXXX',
      // Phase 4: Replace with actual key
      'amount': amountInPaise,
      'currency': currency,
      'order_id': orderId,
      'name': appName ?? 'RishtaApp',
      'description':
      '${plan.label} Plan • $months Month${months > 1 ? 's' : ''}',
      'prefill': {
        'name': userName,
        'contact': userPhone,
        if (userEmail != null)
          'email': userEmail,
      },
      'theme': {'color': '#8B1A1A'},
    };
  }
}

// ─────────────────────────────────────────────────────────
// MOCK DATA STORE
// ─────────────────────────────────────────────────────────

final Map<String, SubscriptionModel>
_mockSubscriptions = {};

// ─────────────────────────────────────────────────────────
// SUBSCRIPTION REPOSITORY
// ─────────────────────────────────────────────────────────

class SubscriptionRepository {

  // ── CREATE RAZORPAY ORDER ─────────────────────────────

  /// Create a Razorpay payment order.
  ///
  /// Returns [RazorpayOrder] with orderId to
  /// initiate payment.
  Future<RazorpayOrder> createRazorpayOrder({
    required String userId,
    required SubscriptionPlan plan,
    required int months,
    required int priceInPaise,
  }) async {
    try {
      await _delay(ms: 800);

      // Mock order ID
      final orderId =
          'order_mock_${DateTime.now().millisecondsSinceEpoch}';
      final receipt =
          'receipt_${userId}_${plan.value}_${months}mo';

      return RazorpayOrder(
        orderId: orderId,
        amountInPaise: priceInPaise,
        currency: 'INR',
        receipt: receipt,
        plan: plan,
        months: months,
      );

      // ── PHASE 4 — RAZORPAY ──────────────────────
      // Use Firebase Cloud Functions to create
      // Razorpay order server-side:
      //
      // final callable = FirebaseFunctions
      //     .instance
      //     .httpsCallable('createRazorpayOrder');
      // final result = await callable.call({
      //   'userId': userId,
      //   'plan': plan.value,
      //   'months': months,
      //   'amount': priceInPaise,
      //   'currency': 'INR',
      // });
      // return RazorpayOrder(
      //   orderId: result.data['orderId'],
      //   amountInPaise: priceInPaise,
      //   currency: 'INR',
      //   receipt: result.data['receipt'],
      //   plan: plan,
      //   months: months,
      // );
    } catch (e) {
      throw SubscriptionException.fromCode(
          'order-creation-failed');
    }
  }

  // ── VERIFY AND ACTIVATE ───────────────────────────────

  /// Verify Razorpay payment and activate subscription.
  ///
  /// Call this after successful Razorpay payment.
  ///
  /// [razorpayOrderId]   — from createRazorpayOrder
  /// [razorpayPaymentId] — from Razorpay success callback
  /// [razorpaySignature] — from Razorpay success callback
  ///
  /// Returns activated [SubscriptionModel].
  Future<SubscriptionModel> verifyAndActivate({
    required String userId,
    required SubscriptionPlan plan,
    required int months,
    required int priceInPaise,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    try {
      await _delay(ms: 1000);

      // Mock: always succeeds
      // Phase 4: Verify signature server-side

      final subscription =
      SubscriptionModel.create(
        userId: userId,
        plan: plan,
        months: months,
        priceInPaise: priceInPaise,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
      );

      _mockSubscriptions[userId] = subscription;

      return subscription;

      // ── PHASE 4 — RAZORPAY + FIRESTORE ──────────
      // Verify signature via Cloud Functions:
      //
      // final callable = FirebaseFunctions
      //     .instance
      //     .httpsCallable('verifyRazorpayPayment');
      // final result = await callable.call({
      //   'orderId': razorpayOrderId,
      //   'paymentId': razorpayPaymentId,
      //   'signature': razorpaySignature,
      // });
      // if (result.data['verified'] != true) {
      //   throw SubscriptionException.fromCode(
      //       'verification-failed');
      // }
      // final sub = SubscriptionModel.create(
      //   userId: userId,
      //   plan: plan,
      //   months: months,
      //   priceInPaise: priceInPaise,
      //   razorpayOrderId: razorpayOrderId,
      //   razorpayPaymentId: razorpayPaymentId,
      // );
      // final batch =
      //     FirebaseFirestore.instance.batch();
      // batch.set(
      //   FirebaseFirestore.instance
      //       .collection('subscriptions')
      //       .doc(sub.id),
      //   sub.toMap(),
      // );
      // batch.update(
      //   FirebaseFirestore.instance
      //       .collection('profiles')
      //       .doc(userId),
      //   {'isPremium': true},
      // );
      // await batch.commit();
      // return sub;
    } on SubscriptionException {
      rethrow;
    } catch (e) {
      throw SubscriptionException.fromCode(
          'payment-failed');
    }
  }

  // ── GET ACTIVE SUBSCRIPTION ───────────────────────────

  /// Get the currently active subscription for a user.
  ///
  /// Returns null if no active subscription.
  Future<SubscriptionModel?> getActiveSubscription(
      String userId) async {
    try {
      await _delay(ms: 400);

      final sub = _mockSubscriptions[userId];
      if (sub == null) return null;

      // Check if expired
      if (sub.isExpiredNow) {
        await _handleExpiry(userId, sub);
        return null;
      }

      return sub.isActive ? sub : null;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('subscriptions')
      //     .where('userId', isEqualTo: userId)
      //     .where('status', isEqualTo: 'active')
      //     .orderBy('createdAt',
      //         descending: true)
      //     .limit(1)
      //     .get();
      // if (snap.docs.isEmpty) return null;
      // final sub = SubscriptionModel.fromMap(
      //     snap.docs.first.id,
      //     snap.docs.first.data());
      // if (sub.isExpiredNow) {
      //   await _markExpired(sub.id);
      //   return null;
      // }
      // return sub;
    } catch (e) {
      return null;
    }
  }

  // ── GET SUBSCRIPTION HISTORY ──────────────────────────

  /// Get full subscription history for a user.
  Future<List<SubscriptionModel>>
  getSubscriptionHistory(String userId) async {
    try {
      await _delay(ms: 500);

      // Mock: return current sub if exists
      final sub = _mockSubscriptions[userId];
      return sub != null ? [sub] : [];

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('subscriptions')
      //     .where('userId', isEqualTo: userId)
      //     .orderBy('createdAt',
      //         descending: true)
      //     .get();
      // return snap.docs
      //     .map((d) => SubscriptionModel.fromMap(
      //         d.id, d.data()))
      //     .toList();
    } catch (e) {
      return [];
    }
  }

  // ── CANCEL SUBSCRIPTION ───────────────────────────────

  /// Cancel an active subscription.
  ///
  /// Note: Access continues until end date.
  Future<SubscriptionModel> cancelSubscription({
    required String userId,
    required String subscriptionId,
  }) async {
    try {
      await _delay(ms: 600);

      final sub = _mockSubscriptions[userId];
      if (sub == null ||
          sub.id != subscriptionId) {
        throw SubscriptionException.fromCode(
            'subscription-not-found');
      }

      if (!sub.isActive) {
        throw SubscriptionException.fromCode(
            'subscription-not-found');
      }

      final cancelled = sub.cancel();
      _mockSubscriptions[userId] = cancelled;
      return cancelled;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // await FirebaseFirestore.instance
      //     .collection('subscriptions')
      //     .doc(subscriptionId)
      //     .update({
      //   'status': 'cancelled',
      //   'cancelledAt':
      //       FieldValue.serverTimestamp(),
      //   'updatedAt':
      //       FieldValue.serverTimestamp(),
      // });
      // return await getSubscriptionById(
      //     subscriptionId) ??
      //     (throw SubscriptionException.fromCode(
      //         'subscription-not-found'));
    } on SubscriptionException {
      rethrow;
    } catch (e) {
      throw SubscriptionException.fromCode(
          'unknown');
    }
  }

  // ── GET SUBSCRIPTION BY ID ────────────────────────────

  /// Get a subscription by its ID.
  Future<SubscriptionModel?> getSubscriptionById(
      String subscriptionId) async {
    try {
      await _delay(ms: 300);

      try {
        return _mockSubscriptions.values
            .firstWhere(
                (s) => s.id == subscriptionId);
      } catch (_) {
        return null;
      }

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('subscriptions')
      //     .doc(subscriptionId)
      //     .get();
      // if (!snap.exists) return null;
      // return SubscriptionModel.fromMap(
      //     snap.id, snap.data()!);
    } catch (e) {
      return null;
    }
  }

  // ── CHECK IS PREMIUM ──────────────────────────────────

  /// Check if user currently has premium access.
  Future<bool> isPremium(String userId) async {
    try {
      final sub =
      await getActiveSubscription(userId);
      return sub?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  // ── GET PLAN FEATURES ─────────────────────────────────

  /// Get features for user's current plan.
  Future<PlanFeatures> getCurrentFeatures(
      String userId) async {
    try {
      final sub =
      await getActiveSubscription(userId);
      if (sub == null) {
        return PlanFeatures.free;
      }
      return sub.features;
    } catch (e) {
      return PlanFeatures.free;
    }
  }

  // ── GET ALL PRICING ───────────────────────────────────

  /// Get all available plan pricing options.
  List<PlanPricing> getAllPricing() {
    return PlanPricing.allPlans;
  }

  /// Get pricing for a specific plan.
  List<PlanPricing> getPricingForPlan(
      SubscriptionPlan plan) {
    return PlanPricing.forPlan(plan);
  }

  // ── SUBSCRIPTION STREAM ───────────────────────────────

  /// Real-time stream of active subscription.
  Stream<SubscriptionModel?> subscriptionStream(
      String userId) async* {
    yield await getActiveSubscription(userId);

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // yield* FirebaseFirestore.instance
    //     .collection('subscriptions')
    //     .where('userId', isEqualTo: userId)
    //     .where('status', isEqualTo: 'active')
    //     .snapshots()
    //     .map((snap) {
    //   if (snap.docs.isEmpty) return null;
    //   final sub = SubscriptionModel.fromMap(
    //       snap.docs.first.id,
    //       snap.docs.first.data());
    //   return sub.isExpiredNow ? null : sub;
    // });
  }

  // ── CHECK EXPIRY SOON ─────────────────────────────────

  /// Check if subscription expires within [days].
  Future<bool> isExpiringSoon(
      String userId, {
        int days = 7,
      }) async {
    try {
      final sub =
      await getActiveSubscription(userId);
      if (sub == null) return false;
      return sub.daysRemaining <= days;
    } catch (e) {
      return false;
    }
  }

  // ── APPLY PROMO CODE ──────────────────────────────────

  /// Validate and apply a promo/coupon code.
  ///
  /// Returns discount percentage (0-100).
  Future<int> applyPromoCode({
    required String userId,
    required String code,
    required SubscriptionPlan plan,
  }) async {
    try {
      await _delay(ms: 600);

      // Mock promo codes
      final mockCodes = {
        'RISHTA10': 10,
        'WELCOME20': 20,
        'PREMIUM50': 50,
      };

      final discount = mockCodes[
      code.toUpperCase()];
      if (discount == null) {
        throw const SubscriptionException(
          code: 'invalid-promo',
          message: 'Invalid promo code.',
        );
      }

      return discount;

      // ── PHASE 3 — FIRESTORE ─────────────────────
      // final snap = await FirebaseFirestore
      //     .instance
      //     .collection('promoCodes')
      //     .doc(code.toUpperCase())
      //     .get();
      // if (!snap.exists) {
      //   throw SubscriptionException(
      //     code: 'invalid-promo',
      //     message: 'Invalid promo code.',
      //   );
      // }
      // final data = snap.data()!;
      // final expiry = _parseDateTime(
      //     data['expiresAt']);
      // if (expiry != null &&
      //     DateTime.now().isAfter(expiry)) {
      //   throw SubscriptionException(
      //     code: 'expired-promo',
      //     message: 'Promo code has expired.',
      //   );
      // }
      // return data['discountPercent'] as int;
    } on SubscriptionException {
      rethrow;
    } catch (e) {
      throw SubscriptionException.fromCode(
          'unknown');
    }
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  Future<void> _delay({int ms = 400}) async {
    await Future.delayed(
        Duration(milliseconds: ms));
  }

  Future<void> _handleExpiry(
      String userId,
      SubscriptionModel sub,
      ) async {
    // Mark subscription as expired
    _mockSubscriptions[userId] =
        sub.markExpired();

    // ── PHASE 3 — FIRESTORE ─────────────────────
    // await FirebaseFirestore.instance
    //     .collection('subscriptions')
    //     .doc(sub.id)
    //     .update({
    //   'status': 'expired',
    //   'updatedAt':
    //       FieldValue.serverTimestamp(),
    // });
    // // Remove premium flag from profile
    // await FirebaseFirestore.instance
    //     .collection('profiles')
    //     .where('userId', isEqualTo: userId)
    //     .get()
    //     .then((snap) {
    //   for (final doc in snap.docs) {
    //     doc.reference.update(
    //         {'isPremium': false});
    //   }
    // });
  }
}