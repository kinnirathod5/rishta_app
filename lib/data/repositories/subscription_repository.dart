// lib/data/repositories/subscription_repository.dart

import '../models/subscription_model.dart';

class SubscriptionRepository {
  // Singleton
  static final SubscriptionRepository _instance =
  SubscriptionRepository._internal();
  factory SubscriptionRepository() => _instance;
  SubscriptionRepository._internal();

  // ── CREATE SUBSCRIPTION ─────────────────────────────

  /// Naya subscription banao (payment ke baad)
  Future<String> createSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required int durationMonths,
    required double amountPaid,
    required String razorpayOrderId,
    required String razorpayPaymentId,
  }) async {
    // TODO: Firebase Phase mein uncomment karo
    // final startDate = DateTime.now();
    // final endDate = DateTime(
    //   startDate.year,
    //   startDate.month + durationMonths,
    //   startDate.day,
    // );
    //
    // Batch write: subscription + user update
    // final batch = FirebaseFirestore.instance.batch();
    //
    // 1. Subscription document banao
    // final subRef = FirebaseFirestore.instance
    //   .collection('subscriptions')
    //   .doc();
    //
    // final subscription = SubscriptionModel(
    //   id: subRef.id,
    //   userId: userId,
    //   plan: plan,
    //   durationMonths: durationMonths,
    //   amountPaid: amountPaid,
    //   startDate: startDate,
    //   endDate: endDate,
    //   razorpayOrderId: razorpayOrderId,
    //   razorpayPaymentId: razorpayPaymentId,
    //   createdAt: DateTime.now(),
    // );
    // batch.set(subRef, subscription.toFirestore());
    //
    // 2. User ka premium status update karo
    // final userRef = FirebaseFirestore.instance
    //   .collection('users')
    //   .doc(userId);
    // batch.update(userRef, {
    //   'isPremium': true,
    //   'premiumPlan': plan.name,
    //   'premiumExpiry': endDate.toIso8601String(),
    // });
    //
    // await batch.commit();
    // return subRef.id;

    await Future.delayed(const Duration(milliseconds: 500));
    return 'mock_sub_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ── GET ACTIVE SUBSCRIPTION ─────────────────────────

  /// User ka active subscription fetch karo
  Future<SubscriptionModel?> getActiveSubscription(
      String userId) async {
    // TODO: Firebase
    // final snap = await FirebaseFirestore.instance
    //   .collection('subscriptions')
    //   .where('userId', isEqualTo: userId)
    //   .where('status', isEqualTo: 'active')
    //   .where('endDate',
    //     isGreaterThan: DateTime.now().toIso8601String())
    //   .orderBy('endDate', descending: true)
    //   .limit(1)
    //   .get();
    //
    // if (snap.docs.isEmpty) return null;
    // return SubscriptionModel.fromFirestore(
    //   snap.docs.first.data(), snap.docs.first.id);

    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  // ── GET SUBSCRIPTION HISTORY ────────────────────────

  /// User ki subscription history
  Future<List<SubscriptionModel>> getSubscriptionHistory(
      String userId) async {
    // TODO: Firebase
    // final snap = await FirebaseFirestore.instance
    //   .collection('subscriptions')
    //   .where('userId', isEqualTo: userId)
    //   .orderBy('createdAt', descending: true)
    //   .get();
    // return snap.docs.map((doc) =>
    //   SubscriptionModel.fromFirestore(doc.data(), doc.id)).toList();

    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  // ── CANCEL SUBSCRIPTION ─────────────────────────────

  /// Subscription cancel karo
  Future<void> cancelSubscription(
      String subscriptionId, String userId) async {
    // TODO: Firebase
    // final batch = FirebaseFirestore.instance.batch();
    //
    // 1. Subscription status update karo
    // final subRef = FirebaseFirestore.instance
    //   .collection('subscriptions')
    //   .doc(subscriptionId);
    // batch.update(subRef, {
    //   'status': SubscriptionStatus.cancelled.name,
    // });
    //
    // Note: Premium features till endDate rahenge
    // User ka isPremium expiry tak true rahega
    //
    // await batch.commit();

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── CHECK PREMIUM STATUS ────────────────────────────

  /// User premium hai ya nahi check karo
  Future<bool> isPremiumActive(String userId) async {
    final subscription = await getActiveSubscription(userId);
    return subscription?.isActive ?? false;
  }

  // ── RAZORPAY ORDER CREATE ───────────────────────────

  /// Razorpay order banao (payment ke pehle)
  Future<Map<String, dynamic>> createRazorpayOrder({
    required SubscriptionPlan plan,
    required int durationMonths,
  }) async {
    // TODO: Cloud Function ya Backend se call karo
    // final callable = FirebaseFunctions.instance
    //   .httpsCallable('createRazorpayOrder');
    // final result = await callable.call({
    //   'plan': plan.name,
    //   'months': durationMonths,
    //   'amount': SubscriptionModel.getPrice(plan, durationMonths),
    // });
    // return Map<String, dynamic>.from(result.data);

    final amount =
    SubscriptionModel.getPrice(plan, durationMonths);

    await Future.delayed(const Duration(milliseconds: 500));

    // Mock response
    return {
      'orderId':
      'order_mock_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount * 100, // Razorpay paise mein chahiye
      'currency': 'INR',
      'keyId': 'rzp_test_mock_key',
    };
  }

  // ── VERIFY PAYMENT ──────────────────────────────────

  /// Payment verify karo aur subscription activate karo
  Future<bool> verifyAndActivate({
    required String userId,
    required SubscriptionPlan plan,
    required int durationMonths,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    // TODO: Cloud Function se verify karo
    // Signature verification server-side hoti hai
    // final callable = FirebaseFunctions.instance
    //   .httpsCallable('verifyRazorpayPayment');
    // final result = await callable.call({
    //   'orderId': razorpayOrderId,
    //   'paymentId': razorpayPaymentId,
    //   'signature': razorpaySignature,
    // });
    //
    // if (result.data['verified'] == true) {
    //   await createSubscription(
    //     userId: userId,
    //     plan: plan,
    //     durationMonths: durationMonths,
    //     amountPaid: SubscriptionModel.getPrice(plan, durationMonths).toDouble(),
    //     razorpayOrderId: razorpayOrderId,
    //     razorpayPaymentId: razorpayPaymentId,
    //   );
    //   return true;
    // }
    // return false;

    await Future.delayed(const Duration(seconds: 1));
    // Mock: always success
    await createSubscription(
      userId: userId,
      plan: plan,
      durationMonths: durationMonths,
      amountPaid: SubscriptionModel.getPrice(
          plan, durationMonths)
          .toDouble(),
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
    );
    return true;
  }

  // ── GET PLAN DETAILS ────────────────────────────────

  /// Plan ki details return karo
  Map<String, dynamic> getPlanDetails(
      SubscriptionPlan plan) {
    return SubscriptionModel.planFeatures[plan] ?? {};
  }

  /// Plan ki price return karo
  int getPlanPrice(SubscriptionPlan plan, int months) {
    return SubscriptionModel.getPrice(plan, months);
  }

  /// Sabse popular plan return karo
  SubscriptionPlan get recommendedPlan =>
      SubscriptionPlan.gold;

  // ── AUTO RENEWAL CHECK ──────────────────────────────

  /// Expiring subscriptions check karo (Cloud Function use karta hai)
  /// Yeh local reminder ke liye hai
  Future<bool> isExpiringSoon(String userId) async {
    final subscription = await getActiveSubscription(userId);
    if (subscription == null) return false;
    return subscription.daysRemaining <= 3;
  }
}