// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';

// ── REPOSITORY PROVIDER ───────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepository(),
);

// ── AUTH STATE ────────────────────────────────────────────
class AuthState {
  final String? uid;
  final String? phoneNumber;
  final String? verificationId;
  final bool isLoading;
  final bool isLoggedIn;
  final bool isAnonymous;
  final bool isNewUser;
  final String? error;

  const AuthState({
    this.uid,
    this.phoneNumber,
    this.verificationId,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.isAnonymous = false,
    this.isNewUser = false,
    this.error,
  });

  AuthState copyWith({
    String? uid,
    String? phoneNumber,
    String? verificationId,
    bool? isLoading,
    bool? isLoggedIn,
    bool? isAnonymous,
    bool? isNewUser,
    String? error,
  }) {
    return AuthState(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isNewUser: isNewUser ?? this.isNewUser,
      error: error,
    );
  }

  bool get hasError => error != null;
  bool get canVerifyOtp => verificationId != null;
}

// ── AUTH NOTIFIER ─────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  // ── SEND OTP ──────────────────────────────────────
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      phoneNumber: phoneNumber,
    );

    try {
      await _repo.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
          );
          onCodeSent(verificationId);
        },
        onError: (err) {
          state = state.copyWith(
            isLoading: false,
            error: err,
          );
          onError(err);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      onError(e.toString());
    }
  }

  // ── VERIFY OTP ────────────────────────────────────
  Future<bool> verifyOtp(String otp) async {
    if (state.verificationId == null) {
      state = state.copyWith(error: 'Verification ID nahi mila');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final uid = await _repo.verifyOtp(
        verificationId: state.verificationId!,
        otp: otp,
      );

      if (uid != null) {
        state = state.copyWith(
          isLoading: false,
          uid: uid,
          isLoggedIn: true,
          isAnonymous: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Galat OTP hai, dobara try karo',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // ── GOOGLE SIGN IN ────────────────────────────────
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uid = await _repo.signInWithGoogle();

      if (uid != null) {
        state = state.copyWith(
          isLoading: false,
          uid: uid,
          isLoggedIn: true,
          isAnonymous: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Google login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // ── ANONYMOUS SIGN IN (Guest Mode) ────────────────
  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uid = await _repo.signInAnonymously();
      state = state.copyWith(
        isLoading: false,
        uid: uid,
        isLoggedIn: uid != null,
        isAnonymous: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ── SIGN OUT ──────────────────────────────────────
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repo.signOut();
    state = const AuthState();
  }

  // ── CLEAR ERROR ───────────────────────────────────
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ── RESET ─────────────────────────────────────────
  void reset() {
    state = const AuthState();
  }
}

// ── PROVIDER ─────────────────────────────────────────────
final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

// ── CONVENIENCE PROVIDERS ─────────────────────────────────

/// Sirf uid chahiye
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).uid;
});

/// Login hai ya nahi
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

/// Guest mode hai ya nahi
final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAnonymous;
});

/// Premium hai ya nahi (baad mein UserModel se aayega)
final isPremiumProvider = Provider<bool>((ref) {
  // TODO: UserModel se check karo
  return false;
});