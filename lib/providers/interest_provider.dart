// lib/providers/interest_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rishta_app/data/models/interest_model.dart';
import 'package:rishta_app/data/models/connection_model.dart';
import 'package:rishta_app/data/repositories/interest_repository.dart';
import 'package:rishta_app/providers/auth_provider.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────

final interestRepositoryProvider =
Provider<InterestRepository>(
      (ref) => InterestRepository(),
);

// ─────────────────────────────────────────────────────────
// INTERESTS STATE
// ─────────────────────────────────────────────────────────

class InterestsState {
  final List<InterestModel> received;
  final List<InterestModel> sent;
  final List<ConnectionModel> connections;
  final bool isLoading;
  final bool isActing;   // Accept/Decline ho raha
  final String? error;
  final String? successMessage;

  const InterestsState({
    this.received = const [],
    this.sent = const [],
    this.connections = const [],
    this.isLoading = false,
    this.isActing = false,
    this.error,
    this.successMessage,
  });

  InterestsState copyWith({
    List<InterestModel>? received,
    List<InterestModel>? sent,
    List<ConnectionModel>? connections,
    bool? isLoading,
    bool? isActing,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return InterestsState(
      received: received ?? this.received,
      sent: sent ?? this.sent,
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      isActing: isActing ?? this.isActing,
      error: clearError
          ? null
          : error ?? this.error,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  // ── COMPUTED ──────────────────────────────────────────

  /// Pending received interests
  List<InterestModel> get pendingReceived =>
      received
          .where((i) => i.isPending)
          .toList();

  /// Accepted received interests
  List<InterestModel> get acceptedReceived =>
      received
          .where((i) => i.isAccepted)
          .toList();

  /// Pending sent interests
  List<InterestModel> get pendingSent =>
      sent.where((i) => i.isPending).toList();

  /// Accepted sent interests
  List<InterestModel> get acceptedSent =>
      sent.where((i) => i.isAccepted).toList();

  /// Declined sent interests
  List<InterestModel> get declinedSent =>
      sent.where((i) => i.isDeclined).toList();

  /// Total pending count (for tab badge)
  int get pendingCount => pendingReceived.length;

  /// Total connections count
  int get connectionCount => connections.length;

  bool get hasError =>
      error != null && error!.isNotEmpty;

  bool get hasSuccess =>
      successMessage != null &&
          successMessage!.isNotEmpty;

  bool get isEmpty =>
      received.isEmpty &&
          sent.isEmpty &&
          connections.isEmpty;

  bool get hasConnections => connections.isNotEmpty;

  /// Check if already sent interest to a profile
  bool hasSentTo(String receiverProfileId) =>
      sent.any((i) =>
      i.receiverProfileId == receiverProfileId &&
          i.isPending);

  /// Check if connected with a user
  bool isConnectedWith(String uid) =>
      connections.any((c) =>
      c.userIds.contains(uid) && c.isConnected);

  /// Get interest received from a user
  InterestModel? getReceivedFrom(
      String senderUid) {
    try {
      return received.firstWhere(
              (i) => i.senderId == senderUid);
    } catch (_) {
      return null;
    }
  }

  /// Get connection with a user
  ConnectionModel? getConnectionWith(
      String uid) {
    try {
      return connections.firstWhere(
              (c) => c.userIds.contains(uid));
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────
// INTERESTS NOTIFIER
// ─────────────────────────────────────────────────────────

class InterestsNotifier
    extends StateNotifier<InterestsState> {
  final InterestRepository _repo;
  final String? _uid;
  final String? _profileId;

  InterestsNotifier(
      this._repo,
      this._uid,
      this._profileId,
      ) : super(const InterestsState()) {
    if (_uid != null) _load();
  }

  // ── LOAD ──────────────────────────────────────────────

  Future<void> _load() async {
    if (_uid == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      // Load all in parallel
      final results = await Future.wait([
        _repo.getReceivedInterests(uid: _uid!),
        _repo.getSentInterests(uid: _uid!),
        _repo.getConnections(_uid!),
      ]);

      state = state.copyWith(
        received: results[0] as List<InterestModel>,
        sent: results[1] as List<InterestModel>,
        connections:
        results[2] as List<ConnectionModel>,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load interests.',
      );
    }
  }

  // ── SEND INTEREST ─────────────────────────────────────

  Future<bool> sendInterest({
    required String receiverId,
    required String receiverProfileId,
    String? message,
  }) async {
    if (_uid == null || _profileId == null) {
      return false;
    }

    state = state.copyWith(
      isActing: true,
      clearError: true,
    );

    try {
      final interest = await _repo.sendInterest(
        senderId: _uid!,
        receiverId: receiverId,
        senderProfileId: _profileId!,
        receiverProfileId: receiverProfileId,
        message: message,
      );

      // Add to sent list
      state = state.copyWith(
        sent: [interest, ...state.sent],
        isActing: false,
        successMessage: 'Interest sent! 💌',
        clearError: true,
      );
      return true;
    } on InterestException catch (e) {
      state = state.copyWith(
        isActing: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActing: false,
        error: 'Failed to send interest.',
      );
      return false;
    }
  }

  // ── ACCEPT INTEREST ───────────────────────────────────

  Future<bool> acceptInterest(
      String interestId) async {
    if (_uid == null) return false;

    state = state.copyWith(
      isActing: true,
      clearError: true,
    );

    try {
      final result = await _repo.respondToInterest(
        interestId: interestId,
        accept: true,
        responderUid: _uid!,
      );

      // Update received list
      final updatedReceived =
      state.received.map((i) =>
      i.id == interestId
          ? result.interest
          : i).toList();

      // Add new connection if created
      final updatedConnections =
      List<ConnectionModel>.from(
          state.connections);
      if (result.connection != null) {
        updatedConnections
            .insert(0, result.connection!);
      }

      state = state.copyWith(
        received: updatedReceived,
        connections: updatedConnections,
        isActing: false,
        successMessage:
        'Interest accepted! You are now connected 🎉',
        clearError: true,
      );
      return true;
    } on InterestException catch (e) {
      state = state.copyWith(
        isActing: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActing: false,
        error: 'Failed to accept interest.',
      );
      return false;
    }
  }

  // ── DECLINE INTEREST ──────────────────────────────────

  Future<bool> declineInterest(
      String interestId) async {
    if (_uid == null) return false;

    state = state.copyWith(
      isActing: true,
      clearError: true,
    );

    try {
      final result = await _repo.respondToInterest(
        interestId: interestId,
        accept: false,
        responderUid: _uid!,
      );

      final updatedReceived =
      state.received.map((i) =>
      i.id == interestId
          ? result.interest
          : i).toList();

      state = state.copyWith(
        received: updatedReceived,
        isActing: false,
        clearError: true,
      );
      return true;
    } on InterestException catch (e) {
      state = state.copyWith(
        isActing: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActing: false,
        error: 'Failed to decline interest.',
      );
      return false;
    }
  }

  // ── WITHDRAW INTEREST ─────────────────────────────────

  Future<bool> withdrawInterest(
      String interestId) async {
    if (_uid == null) return false;

    state = state.copyWith(
      isActing: true,
      clearError: true,
    );

    try {
      final withdrawn =
      await _repo.withdrawInterest(
        interestId: interestId,
        senderUid: _uid!,
      );

      // Remove from sent list
      final updatedSent = state.sent
          .where((i) => i.id != interestId)
          .toList();

      state = state.copyWith(
        sent: updatedSent,
        isActing: false,
        successMessage: 'Interest withdrawn',
        clearError: true,
      );
      return true;
    } on InterestException catch (e) {
      state = state.copyWith(
        isActing: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActing: false,
        error: 'Failed to withdraw interest.',
      );
      return false;
    }
  }

  // ── CLEAR MESSAGES ────────────────────────────────────

  void clearError() =>
      state = state.copyWith(clearError: true);

  void clearSuccess() =>
      state = state.copyWith(clearSuccess: true);

  void clearMessages() => state = state.copyWith(
      clearError: true, clearSuccess: true);

  // ── REFRESH ───────────────────────────────────────────

  Future<void> refresh() => _load();
}

// ─────────────────────────────────────────────────────────
// INTERESTS PROVIDER
// ─────────────────────────────────────────────────────────

final interestsProvider = StateNotifierProvider<
    InterestsNotifier, InterestsState>((ref) {
  final uid = ref.watch(currentUidProvider);
  final profileId =
      ref.watch(currentProfileProvider)?.id;
  return InterestsNotifier(
    ref.read(interestRepositoryProvider),
    uid,
    profileId,
  );
});

// ─────────────────────────────────────────────────────────
// CONVENIENCE PROVIDERS
// ─────────────────────────────────────────────────────────

/// Pending received interests count (tab badge)
final pendingInterestsCountProvider =
Provider<int>((ref) {
  return ref
      .watch(interestsProvider)
      .pendingCount;
});

/// All pending received interests
final pendingReceivedProvider =
Provider<List<InterestModel>>((ref) {
  return ref
      .watch(interestsProvider)
      .pendingReceived;
});

/// All sent interests
final sentInterestsProvider =
Provider<List<InterestModel>>((ref) {
  return ref.watch(interestsProvider).sent;
});

/// All connections
final connectionsProvider =
Provider<List<ConnectionModel>>((ref) {
  return ref
      .watch(interestsProvider)
      .connections;
});

/// Set of profile IDs user has sent interest to
/// Used to show "Interest Sent" state on cards
final sentInterestIdsProvider =
Provider<Set<String>>((ref) {
  return ref
      .watch(interestsProvider)
      .sent
      .where((i) => i.isPending)
      .map((i) => i.receiverProfileId)
      .toSet();
});

/// Is user connected with a specific uid
final isConnectedWithProvider =
Provider.family<bool, String>((ref, uid) {
  return ref
      .watch(interestsProvider)
      .isConnectedWith(uid);
});

/// Has user sent interest to a specific profile
final hasSentInterestProvider =
Provider.family<bool, String>(
        (ref, profileId) {
      return ref
          .watch(interestsProvider)
          .hasSentTo(profileId);
    });

/// Total connections count
final connectionCountProvider =
Provider<int>((ref) {
  return ref
      .watch(interestsProvider)
      .connectionCount;
});

/// Is interests section loading
final interestsLoadingProvider =
Provider<bool>((ref) {
  return ref.watch(interestsProvider).isLoading;
});

/// Is an action (accept/decline) in progress
final interestActingProvider =
Provider<bool>((ref) {
  return ref.watch(interestsProvider).isActing;
});