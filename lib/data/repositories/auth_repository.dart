// lib/data/repositories/auth_repository.dart
//
// NOTE: Firebase Auth Phase 3 mein add hoga.
// Tab actual Firebase calls uncomment karna hai.
// Abhi mock implementation se kaam chalega.

import 'package:rishta_app/data/models/user_model.dart';

// ─────────────────────────────────────────────────────────
// AUTH EXCEPTIONS
// ─────────────────────────────────────────────────────────

class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({
    required this.code,
    required this.message,
  });

  factory AuthException.fromCode(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return const AuthException(
          code: 'invalid-phone-number',
          message: 'Please enter a valid phone number.',
        );
      case 'too-many-requests':
        return const AuthException(
          code: 'too-many-requests',
          message: 'Too many attempts. Please try again later.',
        );
      case 'invalid-verification-code':
        return const AuthException(
          code: 'invalid-verification-code',
          message: 'Incorrect OTP. Please try again.',
        );
      case 'session-expired':
        return const AuthException(
          code: 'session-expired',
          message: 'OTP has expired. Please request a new one.',
        );
      case 'user-disabled':
        return const AuthException(
          code: 'user-disabled',
          message: 'Your account has been disabled. Please contact support.',
        );
      case 'network-request-failed':
        return const AuthException(
          code: 'network-request-failed',
          message: 'No internet connection. Please try again.',
        );
      default:
        return AuthException(
          code: code,
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  @override
  String toString() =>
      'AuthException(code: $code, message: $message)';
}

// ─────────────────────────────────────────────────────────
// AUTH REPOSITORY
// ─────────────────────────────────────────────────────────

class AuthRepository {

  // ── MOCK STATE ────────────────────────────────────────
  // Phase 3 mein Firebase se replace hoga
  String? _mockVerificationId;
  String? _currentUid;
  bool _isAnonymous = false;

  // Mock OTP — always '123456' in dev
  static const String _mockOtp = '123456';

  // ── CURRENT USER ──────────────────────────────────────

  /// Currently signed in user UID
  String? get currentUid => _currentUid;

  /// Is user signed in
  bool get isSignedIn => _currentUid != null;

  /// Is user anonymous / guest
  bool get isAnonymous => _isAnonymous;

  /// Is user signed in with phone
  bool get isPhoneVerified =>
      isSignedIn && !_isAnonymous;

  // ── SEND OTP ──────────────────────────────────────────

  /// Send OTP to phone number.
  ///
  /// [phoneNumber] — 10 digit number (without +91)
  /// [onCodeSent] — Called with verificationId
  /// [onError]    — Called with error message
  ///
  /// Mock: Always succeeds. OTP = '123456'
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId)
    onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      // Validate phone number
      final clean = phoneNumber
          .replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length != 10) {
        throw AuthException.fromCode(
            'invalid-phone-number');
      }

      // Simulate network delay
      await Future.delayed(
          const Duration(milliseconds: 1200));

      // Mock verificationId
      _mockVerificationId =
      'mock_verification_${clean}_${DateTime.now().millisecondsSinceEpoch}';

      onCodeSent(_mockVerificationId!);

      // ── PHASE 3 — FIREBASE ──────────────────────
      // await FirebaseAuth.instance.verifyPhoneNumber(
      //   phoneNumber: '+91$clean',
      //   timeout: const Duration(seconds: 60),
      //   verificationCompleted: (credential) async {
      //     // Auto-verify on Android
      //     await _signInWithCredential(credential);
      //   },
      //   verificationFailed: (e) {
      //     onError(AuthException
      //         .fromCode(e.code).message);
      //   },
      //   codeSent: (vId, resendToken) {
      //     _mockVerificationId = vId;
      //     onCodeSent(vId);
      //   },
      //   codeAutoRetrievalTimeout: (vId) {
      //     _mockVerificationId = vId;
      //   },
      // );
    } on AuthException catch (e) {
      onError(e.message);
    } catch (e) {
      onError('Failed to send OTP. Please try again.');
    }
  }

  // ── VERIFY OTP ────────────────────────────────────────

  /// Verify OTP and sign in.
  ///
  /// Returns [UserModel] on success.
  /// Throws [AuthException] on failure.
  ///
  /// Mock: '123456' always succeeds.
  Future<UserModel> verifyOtp({
    required String otp,
    String? verificationId,
  }) async {
    try {
      final vId =
          verificationId ?? _mockVerificationId;

      if (vId == null) {
        throw const AuthException(
          code: 'session-expired',
          message: 'Session expired. Please request a new OTP.',
        );
      }

      // Simulate network delay
      await Future.delayed(
          const Duration(milliseconds: 1000));

      // Mock OTP check
      if (otp != _mockOtp) {
        throw AuthException.fromCode(
            'invalid-verification-code');
      }

      // Extract phone from mock verificationId
      final phonePart = vId
          .split('_')
          .elementAtOrNull(2) ?? '9999999999';

      // Create/return mock user
      final uid =
          'uid_${phonePart}_mock';
      _currentUid = uid;
      _isAnonymous = false;

      return UserModel.create(
        uid: uid,
        phoneNumber: phonePart,
      );

      // ── PHASE 3 — FIREBASE ──────────────────────
      // final credential =
      //     PhoneAuthProvider.credential(
      //   verificationId: vId,
      //   smsCode: otp,
      // );
      // final userCredential = await
      //     FirebaseAuth.instance
      //         .signInWithCredential(credential);
      // final fbUser = userCredential.user!;
      // _currentUid = fbUser.uid;
      // return _getOrCreateUser(fbUser);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException.fromCode('unknown');
    }
  }

  // ── SIGN IN ANONYMOUSLY ───────────────────────────────

  /// Sign in as guest (anonymous).
  ///
  /// Returns guest [UserModel].
  Future<UserModel> signInAnonymously() async {
    try {
      await Future.delayed(
          const Duration(milliseconds: 600));

      final uid =
          'guest_${DateTime.now().millisecondsSinceEpoch}';
      _currentUid = uid;
      _isAnonymous = true;

      return UserModel.guest(uid: uid);

      // ── PHASE 3 — FIREBASE ──────────────────────
      // final userCredential = await
      //     FirebaseAuth.instance
      //         .signInAnonymously();
      // _currentUid = userCredential.user!.uid;
      // _isAnonymous = true;
      // return UserModel.guest(
      //     uid: _currentUid!);
    } catch (e) {
      throw AuthException.fromCode('unknown');
    }
  }

  // ── SIGN IN WITH GOOGLE ───────────────────────────────

  /// Sign in with Google (optional OAuth).
  ///
  /// Phase 3 mein implement hoga.
  Future<UserModel> signInWithGoogle() async {
    throw const AuthException(
      code: 'not-implemented',
      message: 'Google sign in coming soon.',
    );

    // ── PHASE 3 — FIREBASE ──────────────────────
    // final googleUser =
    //     await GoogleSignIn().signIn();
    // if (googleUser == null) {
    //   throw const AuthException(
    //     code: 'sign-in-cancelled',
    //     message: 'Sign in cancelled.',
    //   );
    // }
    // final googleAuth =
    //     await googleUser.authentication;
    // final credential =
    //     GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // final userCredential = await
    //     FirebaseAuth.instance
    //         .signInWithCredential(credential);
    // return _getOrCreateUser(
    //     userCredential.user!);
  }

  // ── SIGN OUT ──────────────────────────────────────────

  /// Sign out current user.
  Future<void> signOut() async {
    try {
      await Future.delayed(
          const Duration(milliseconds: 300));

      _currentUid = null;
      _isAnonymous = false;
      _mockVerificationId = null;

      // ── PHASE 3 — FIREBASE ──────────────────────
      // await FirebaseAuth.instance.signOut();
      // await GoogleSignIn().signOut();
    } catch (e) {
      throw AuthException.fromCode('unknown');
    }
  }

  // ── DELETE ACCOUNT ────────────────────────────────────

  /// Permanently delete user account.
  Future<void> deleteAccount() async {
    try {
      if (_currentUid == null) {
        throw const AuthException(
          code: 'not-signed-in',
          message: 'No user is signed in.',
        );
      }

      await Future.delayed(
          const Duration(milliseconds: 500));

      _currentUid = null;
      _isAnonymous = false;

      // ── PHASE 3 — FIREBASE ──────────────────────
      // await FirebaseAuth.instance
      //     .currentUser?.delete();
    } catch (e) {
      throw AuthException.fromCode('unknown');
    }
  }

  // ── UPDATE EMAIL ──────────────────────────────────────

  /// Update user's email address.
  Future<void> updateEmail(String email) async {
    if (_currentUid == null) {
      throw const AuthException(
        code: 'not-signed-in',
        message: 'No user is signed in.',
      );
    }

    await Future.delayed(
        const Duration(milliseconds: 400));

    // ── PHASE 3 — FIREBASE ──────────────────────
    // await FirebaseAuth.instance
    //     .currentUser?.verifyBeforeUpdateEmail(email);
  }

  // ── AUTH STATE STREAM ─────────────────────────────────

  /// Stream of auth state changes.
  /// Emits uid on sign in, null on sign out.
  Stream<String?> get authStateChanges async* {
    // Mock: emit current state immediately
    yield _currentUid;

    // ── PHASE 3 — FIREBASE ──────────────────────
    // yield* FirebaseAuth.instance
    //     .authStateChanges()
    //     .map((user) => user?.uid);
  }

  // ── RELOAD USER ───────────────────────────────────────

  /// Reload current user data from server.
  Future<void> reloadUser() async {
    await Future.delayed(
        const Duration(milliseconds: 300));

    // ── PHASE 3 — FIREBASE ──────────────────────
    // await FirebaseAuth.instance
    //     .currentUser?.reload();
  }

  // ── GET ID TOKEN ─────────────────────────────────────

  /// Get current user's Firebase ID token.
  /// Used for API authentication.
  Future<String?> getIdToken({
    bool forceRefresh = false,
  }) async {
    if (_currentUid == null) return null;

    // Mock token
    return 'mock_id_token_$_currentUid';

    // ── PHASE 3 — FIREBASE ──────────────────────
    // return await FirebaseAuth.instance
    //     .currentUser
    //     ?.getIdToken(forceRefresh);
  }

// ── PRIVATE HELPERS ───────────────────────────────────

// Phase 3 mein use hoga:
// Future<UserModel> _getOrCreateUser(
//     fb.User fbUser) async {
//   final doc = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(fbUser.uid)
//       .get();
//   if (doc.exists) {
//     return UserModel.fromMap(
//         fbUser.uid, doc.data()!);
//   }
//   final newUser = UserModel.create(
//     uid: fbUser.uid,
//     phoneNumber: fbUser.phoneNumber ?? '',
//   );
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(fbUser.uid)
//       .set(newUser.toMap());
//   return newUser;
// }
}