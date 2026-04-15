// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rishta_app/data/models/user_model.dart';
import 'package:rishta_app/data/repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────

final authRepositoryProvider =
Provider<AuthRepository>(
      (ref) => AuthRepository(),
);

// ─────────────────────────────────────────────────────────
// AUTH STATE
// ─────────────────────────────────────────────────────────

enum AuthStep {
  idle,         // Initial state
  sendingOtp,   // OTP bhej raha
  otpSent,      // OTP bheja, verify karo
  verifying,    // OTP verify ho raha
  signingIn,    // Sign in ho raha
  success,      // Auth complete
  error,        // Error state
}

class AuthState {
  final UserModel? user;
  final AuthStep step;
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final String? phoneNumber;

  const AuthState({
    this.user,
    this.step = AuthStep.idle,
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.phoneNumber,
  });

  AuthState copyWith({
    UserModel? user,
    AuthStep? step,
    bool? isLoading,
    String? error,
    String? verificationId,
    String? phoneNumber,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      verificationId:
      verificationId ?? this.verificationId,
      phoneNumber:
      phoneNumber ?? this.phoneNumber,
    );
  }

  // ── COMPUTED ──────────────────────────────────────────

  bool get isLoggedIn =>
      user != null && !isAnonymous;

  bool get isAnonymous =>
      user?.role == UserRole.guest;

  bool get isGuest => isAnonymous;

  bool get hasUser => user != null;

  bool get hasError =>
      error != null && error!.isNotEmpty;

  bool get isOtpSent =>
      step == AuthStep.otpSent;

  bool get isIdle => step == AuthStep.idle;

  bool get isSuccess =>
      step == AuthStep.success;

  bool get hasCompletedSetup =>
      user?.hasCompletedSetup ?? false;

  String get displayPhone =>
      user?.formattedPhone ?? '';

  String get maskedPhone =>
      phoneNumber != null
          ? '${phoneNumber!.substring(0, 5).replaceAll(
          RegExp(r'\d'), '*')} ${phoneNumber!.length > 5 ? phoneNumber!.substring(5) : ''}'
          : '';
}

// ─────────────────────────────────────────────────────────
// AUTH NOTIFIER
// ─────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo)
      : super(const AuthState());

  // ── SEND OTP ──────────────────────────────────────────

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  }) async {
    state = state.copyWith(
      step: AuthStep.sendingOtp,
      isLoading: true,
      clearError: true,
      phoneNumber: phoneNumber,
    );

    await _repo.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        state = state.copyWith(
          step: AuthStep.otpSent,
          isLoading: false,
          verificationId: verificationId,
        );
        onCodeSent(verificationId);
      },
      onError: (error) {
        state = state.copyWith(
          step: AuthStep.error,
          isLoading: false,
          error: error,
        );
        onError(error);
      },
    );
  }

  // ── VERIFY OTP ────────────────────────────────────────

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(
      step: AuthStep.verifying,
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _repo.verifyOtp(
        otp: otp,
        verificationId: state.verificationId,
      );

      state = state.copyWith(
        user: user,
        step: AuthStep.success,
        isLoading: false,
        clearError: true,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        step: AuthStep.otpSent,
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        step: AuthStep.error,
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  // ── RESEND OTP ────────────────────────────────────────

  Future<void> resendOtp({
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  }) async {
    if (state.phoneNumber == null) return;

    await sendOtp(
      phoneNumber: state.phoneNumber!,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  // ── SIGN IN ANONYMOUSLY ───────────────────────────────

  Future<bool> signInAnonymously() async {
    state = state.copyWith(
      step: AuthStep.signingIn,
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _repo.signInAnonymously();

      state = state.copyWith(
        user: user,
        step: AuthStep.success,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        step: AuthStep.error,
        isLoading: false,
        error: 'Could not sign in as guest.',
      );
      return false;
    }
  }

  // ── SIGN IN WITH GOOGLE ───────────────────────────────

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(
      step: AuthStep.signingIn,
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _repo.signInWithGoogle();

      state = state.copyWith(
        user: user,
        step: AuthStep.success,
        isLoading: false,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        step: AuthStep.idle,
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        step: AuthStep.error,
        isLoading: false,
        error: 'Google sign in failed.',
      );
      return false;
    }
  }

  // ── SIGN OUT ──────────────────────────────────────────

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repo.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign out failed. Please try again.',
      );
    }
  }

  // ── DELETE ACCOUNT ────────────────────────────────────

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repo.deleteAccount();
      state = const AuthState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Account deletion failed.',
      );
      return false;
    }
  }

  // ── UPDATE USER ───────────────────────────────────────

  /// Update local user state after profile changes.
  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);
  }

  /// Mark profile setup as complete.
  void markSetupComplete(String profileId) {
    if (state.user == null) return;
    final updated =
    state.user!.linkProfile(profileId);
    state = state.copyWith(user: updated);
  }

  // ── CLEAR ERROR ───────────────────────────────────────

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ── RESET ─────────────────────────────────────────────

  void reset() {
    state = const AuthState();
  }

  /// Reset back to OTP entry screen.
  void resetToOtp() {
    state = state.copyWith(
      step: AuthStep.otpSent,
      clearError: true,
    );
  }
}

// ─────────────────────────────────────────────────────────
// MAIN AUTH PROVIDER
// ─────────────────────────────────────────────────────────

final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(
    ref.read(authRepositoryProvider),
  ),
);

// ─────────────────────────────────────────────────────────
// CONVENIENCE PROVIDERS
// ─────────────────────────────────────────────────────────

/// Currently signed-in user UID (nullable)
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.uid;
});

/// Currently signed-in user model (nullable)
final currentUserProvider =
Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is user fully signed in (not guest)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

/// Is user anonymous/guest
final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAnonymous;
});

/// Has user completed profile setup
final hasCompletedSetupProvider =
Provider<bool>((ref) {
  return ref
      .watch(authProvider)
      .hasCompletedSetup;
});

/// Is auth loading
final isAuthLoadingProvider =
Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Current auth error message
final authErrorProvider =
Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

/// Current auth step
final authStepProvider =
Provider<AuthStep>((ref) {
  return ref.watch(authProvider).step;
});

/// Phone number being verified
final authPhoneProvider =
Provider<String?>((ref) {
  return ref.watch(authProvider).phoneNumber;
});