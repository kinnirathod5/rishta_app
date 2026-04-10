// lib/data/repositories/auth_repository.dart
// Firebase Auth operations

// NOTE: Firebase packages abhi commented out hain pubspec mein
// Jab Firebase connect karein tab uncomment karna
// import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  // Singleton
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  // ── PHONE AUTH ──────────────────────────────────────

  /// Phone number se OTP bhejo
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    // TODO: Firebase Phase mein uncomment karo
    // await FirebaseAuth.instance.verifyPhoneNumber(
    //   phoneNumber: phoneNumber,
    //   verificationCompleted: (credential) async {
    //     await FirebaseAuth.instance.signInWithCredential(credential);
    //   },
    //   verificationFailed: (e) => onError(e.message ?? 'Error'),
    //   codeSent: (verificationId, _) => onCodeSent(verificationId),
    //   codeAutoRetrievalTimeout: (_) {},
    // );

    // MOCK implementation (testing ke liye)
    await Future.delayed(const Duration(seconds: 2));
    onCodeSent('mock_verification_id_123');
  }

  /// OTP verify karo aur sign in
  Future<String?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    // TODO: Firebase Phase mein uncomment karo
    // final credential = PhoneAuthProvider.credential(
    //   verificationId: verificationId,
    //   smsCode: otp,
    // );
    // final result = await FirebaseAuth.instance
    //   .signInWithCredential(credential);
    // return result.user?.uid;

    // MOCK implementation
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      return 'mock_user_uid_${DateTime.now().millisecondsSinceEpoch}';
    }
    return null;
  }

  /// Google Sign In
  Future<String?> signInWithGoogle() async {
    // TODO: Firebase Phase mein implement karo
    // final googleUser = await GoogleSignIn().signIn();
    // final googleAuth = await googleUser?.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );
    // final result = await FirebaseAuth.instance
    //   .signInWithCredential(credential);
    // return result.user?.uid;

    await Future.delayed(const Duration(seconds: 1));
    return null; // Not implemented yet
  }

  /// Anonymous sign in (guest mode)
  Future<String?> signInAnonymously() async {
    // TODO: Firebase Phase mein uncomment karo
    // final result = await FirebaseAuth.instance.signInAnonymously();
    // return result.user?.uid;

    await Future.delayed(const Duration(milliseconds: 500));
    return 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Logout
  Future<void> signOut() async {
    // TODO: await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Current user uid
  String? get currentUid {
    // TODO: return FirebaseAuth.instance.currentUser?.uid;
    return null;
  }

  /// Is logged in
  bool get isLoggedIn => currentUid != null;
}