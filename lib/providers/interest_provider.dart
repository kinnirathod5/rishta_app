// lib/providers/interest_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/interest_model.dart';
import '../data/models/connection_model.dart';
import '../data/repositories/interest_repository.dart';
import 'auth_provider.dart';

// ── REPOSITORY PROVIDER ───────────────────────────────────
final interestRepositoryProvider =
Provider<InterestRepository>(
      (ref) => InterestRepository(),
);

// ── INTERESTS STATE ───────────────────────────────────────
class InterestsState {
  final List<InterestModel> received;
  final List<InterestModel> sent;
  final List<ConnectionModel> connections;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final String? successMessage;

  const InterestsState({
    this.received = const [],
    this.sent = const [],
    this.connections = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.successMessage,
  });

  InterestsState copyWith({
    List<InterestModel>? received,
    List<InterestModel>? sent,
    List<ConnectionModel>? connections,
    bool? isLoading,
    bool? isSending,
    String? error,
    String? successMessage,
  }) {
    return InterestsState(
      received: received ?? this.received,
      sent: sent ?? this.sent,
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      successMessage: successMessage,
    );
  }

  // ── COMPUTED PROPERTIES ───────────────────────────
  List<InterestModel> get pendingReceived => received
      .where((i) => i.status == InterestStatus.pending)
      .toList();

  List<InterestModel> get pendingSent => sent
      .where((i) => i.status == InterestStatus.pending)
      .toList();

  List<InterestModel> get acceptedSent => sent
      .where((i) => i.status == InterestStatus.accepted)
      .toList();

  List<InterestModel> get declinedSent => sent
      .where((i) => i.status == InterestStatus.declined)
      .toList();

  int get pendingReceivedCount => pendingReceived.length;
  int get connectionsCount => connections.length;

  bool get hasActivity =>
      received.isNotEmpty ||
          sent.isNotEmpty ||
          connections.isNotEmpty;
}

// ── INTERESTS NOTIFIER ────────────────────────────────────
class InterestsNotifier extends StateNotifier<InterestsState> {
  final InterestRepository _repo;
  final String? _userId;

  InterestsNotifier(this._repo, this._userId)
      : super(const InterestsState()) {
    if (_userId != null) loadAll();
  }

  // ── LOAD ALL ──────────────────────────────────────
  Future<void> loadAll() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final received =
      await _repo.getReceivedInterests(_userId!);
      final sent =
      await _repo.getSentInterests(_userId!);
      final connections =
      await _repo.getConnections(_userId!);

      state = state.copyWith(
        received: received,
        sent: sent,
        connections: connections,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ── SEND INTEREST ─────────────────────────────────
  Future<bool> sendInterest({
    required String fromProfileId,
    required String toUserId,
    required String toProfileId,
  }) async {
    if (_userId == null) return false;

    state = state.copyWith(isSending: true, error: null);

    try {
      // Pehle check karo already bheja toh nahi
      final alreadySent =
      await _repo.hasAlreadySentInterest(
        fromUserId: _userId!,
        toUserId: toUserId,
      );

      if (alreadySent) {
        state = state.copyWith(
          isSending: false,
          error: 'Pehle se interest bheja hua hai',
        );
        return false;
      }

      final interestId = await _repo.sendInterest(
        fromUserId: _userId!,
        fromProfileId: fromProfileId,
        toUserId: toUserId,
        toProfileId: toProfileId,
      );

      // Local state update
      final newInterest = InterestModel(
        id: interestId,
        fromUserId: _userId!,
        fromProfileId: fromProfileId,
        toUserId: toUserId,
        toProfileId: toProfileId,
        sentAt: DateTime.now(),
      );

      state = state.copyWith(
        sent: [...state.sent, newInterest],
        isSending: false,
        successMessage: 'Interest bhej diya! 💌',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // ── ACCEPT INTEREST ───────────────────────────────
  Future<void> acceptInterest(
      String interestId, InterestModel interest) async {
    try {
      await _repo.respondToInterest(
        interestId,
        InterestStatus.accepted,
        currentUserId: _userId ?? '',
        interest: interest,
      );

      // Local: received se hata ke connections mein daalo
      final accepted = state.received
          .firstWhere((i) => i.id == interestId);

      // Mock connection banao
      final connection = ConnectionModel(
        id: 'conn_${DateTime.now().millisecondsSinceEpoch}',
        user1Id: accepted.fromUserId,
        profile1Id: accepted.fromProfileId,
        user2Id: accepted.toUserId,
        profile2Id: accepted.toProfileId,
        interestId: interestId,
        connectedAt: DateTime.now(),
      );

      state = state.copyWith(
        received: state.received
            .where((i) => i.id != interestId)
            .toList(),
        connections: [...state.connections, connection],
        successMessage: 'Interest accept kar liya! 🎉',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── DECLINE INTEREST ──────────────────────────────
  Future<void> declineInterest(String interestId,
      InterestModel interest) async {
    try {
      await _repo.respondToInterest(
        interestId,
        InterestStatus.declined,
        currentUserId: _userId ?? '',
        interest: interest,
      );

      // Local: received se remove karo
      state = state.copyWith(
        received: state.received
            .where((i) => i.id != interestId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── WITHDRAW INTEREST ─────────────────────────────
  Future<void> withdrawInterest(String interestId) async {
    try {
      await _repo.withdrawInterest(interestId);

      state = state.copyWith(
        sent: state.sent.map((i) {
          if (i.id == interestId) {
            return i.copyWith(
                status: InterestStatus.withdrawn);
          }
          return i;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── CLEAR MESSAGES ────────────────────────────────
  void clearMessages() {
    state = state.copyWith(
      error: null,
      successMessage: null,
    );
  }

  // ── REFRESH ───────────────────────────────────────
  Future<void> refresh() async {
    await loadAll();
  }
}

// ── PROVIDER ─────────────────────────────────────────────
final interestsProvider =
StateNotifierProvider<InterestsNotifier, InterestsState>(
      (ref) {
    final userId = ref.watch(currentUidProvider);
    return InterestsNotifier(
      ref.read(interestRepositoryProvider),
      userId,
    );
  },
);

// ── CONVENIENCE PROVIDERS ─────────────────────────────────

/// Pending interests ki count (badge ke liye)
final pendingInterestsCountProvider = Provider<int>((ref) {
  return ref.watch(interestsProvider).pendingReceivedCount;
});

/// Connections ki count
final connectionsCountProvider = Provider<int>((ref) {
  return ref.watch(interestsProvider).connectionsCount;
});

/// Sent interest ids (home screen mein button state ke liye)
final sentInterestIdsProvider = Provider<Set<String>>((ref) {
  final interests = ref.watch(interestsProvider);
  return interests.sent
      .map((i) => i.toProfileId)
      .toSet();
});