// lib/providers/app_state_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rishta_app/data/models/notification_model.dart';
import 'package:rishta_app/data/repositories/notification_repository.dart';
import 'package:rishta_app/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────

final notificationRepositoryProvider =
Provider<NotificationRepository>(
      (ref) => NotificationRepository(),
);

// ─────────────────────────────────────────────────────────
// APP SETTINGS STATE
// ─────────────────────────────────────────────────────────

class AppSettings {
  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool biometricEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.biometricEnabled = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? biometricEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled:
      notificationsEnabled ??
          this.notificationsEnabled,
      soundEnabled:
      soundEnabled ?? this.soundEnabled,
      vibrationEnabled:
      vibrationEnabled ?? this.vibrationEnabled,
      biometricEnabled:
      biometricEnabled ?? this.biometricEnabled,
    );
  }

  bool get isDarkMode =>
      themeMode == ThemeMode.dark;
}

// ─────────────────────────────────────────────────────────
// APP SETTINGS NOTIFIER
// ─────────────────────────────────────────────────────────

class AppSettingsNotifier
    extends StateNotifier<AppSettings> {
  AppSettingsNotifier()
      : super(const AppSettings());

  void setThemeMode(ThemeMode mode) =>
      state = state.copyWith(themeMode: mode);

  void toggleTheme() {
    final next = state.isDarkMode
        ? ThemeMode.light
        : ThemeMode.dark;
    state = state.copyWith(themeMode: next);
  }

  void setLanguage(String lang) =>
      state = state.copyWith(language: lang);

  void setNotifications(bool enabled) =>
      state = state.copyWith(
          notificationsEnabled: enabled);

  void setSound(bool enabled) =>
      state = state.copyWith(soundEnabled: enabled);

  void setVibration(bool enabled) =>
      state = state.copyWith(
          vibrationEnabled: enabled);

  void setBiometric(bool enabled) =>
      state = state.copyWith(
          biometricEnabled: enabled);
}

final appSettingsProvider = StateNotifierProvider<
    AppSettingsNotifier, AppSettings>(
      (ref) => AppSettingsNotifier(),
);

// ─────────────────────────────────────────────────────────
// CONNECTIVITY STATE
// ─────────────────────────────────────────────────────────

class ConnectivityState {
  final bool isConnected;
  final bool isWifi;
  final bool isMobile;

  const ConnectivityState({
    this.isConnected = true,
    this.isWifi = true,
    this.isMobile = false,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? isWifi,
    bool? isMobile,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isWifi: isWifi ?? this.isWifi,
      isMobile: isMobile ?? this.isMobile,
    );
  }

  String get statusLabel {
    if (!isConnected) return 'No Internet';
    if (isWifi) return 'WiFi';
    if (isMobile) return 'Mobile Data';
    return 'Connected';
  }
}

// ─────────────────────────────────────────────────────────
// CONNECTIVITY NOTIFIER
// ─────────────────────────────────────────────────────────

class ConnectivityNotifier
    extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier()
      : super(const ConnectivityState());

  // Phase 3: connectivity_plus package use karo
  // void _init() {
  //   Connectivity().onConnectivityChanged
  //       .listen(_handleChange);
  // }

  void setConnected(bool connected) {
    state = state.copyWith(
        isConnected: connected);
  }

  void setWifi(bool wifi) {
    state = state.copyWith(
      isConnected: true,
      isWifi: wifi,
      isMobile: !wifi,
    );
  }

  void setDisconnected() {
    state = state.copyWith(
      isConnected: false,
      isWifi: false,
      isMobile: false,
    );
  }
}

final connectivityProvider = StateNotifierProvider<
    ConnectivityNotifier, ConnectivityState>(
      (ref) => ConnectivityNotifier(),
);

// Simple bool provider
final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isConnected;
});

// ─────────────────────────────────────────────────────────
// NOTIFICATIONS STATE
// ─────────────────────────────────────────────────────────

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications:
      notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  // ── COMPUTED ────────────────────────────────────────

  bool get hasUnread => unreadCount > 0;

  bool get isEmpty => notifications.isEmpty;

  /// Grouped by dateGroup
  Map<String, List<NotificationModel>>
  get grouped {
    final map =
    <String, List<NotificationModel>>{};
    for (final n in notifications) {
      map[n.dateGroup] ??= [];
      map[n.dateGroup]!.add(n);
    }
    return map;
  }

  List<NotificationModel> get unread =>
      notifications.where((n) => n.isUnread).toList();
}

// ─────────────────────────────────────────────────────────
// NOTIFICATIONS NOTIFIER
// ─────────────────────────────────────────────────────────

class NotificationsNotifier
    extends StateNotifier<NotificationsState> {
  final NotificationRepository _repo;
  final String? _userId;

  NotificationsNotifier(this._repo, this._userId)
      : super(const NotificationsState()) {
    if (_userId != null) _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;

    state = state.copyWith(
        isLoading: true, error: null);

    try {
      final notifications =
      await _repo.getNotifications(
          userId: _userId!);
      final unread =
      await _repo.getUnreadCount(_userId!);

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unread,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAsRead(
      String notificationId) async {
    if (_userId == null) return;

    try {
      await _repo.markAsRead(
        userId: _userId!,
        notificationId: notificationId,
      );

      final updated = state.notifications
          .map((n) => n.id == notificationId
          ? n.markRead()
          : n)
          .toList();

      state = state.copyWith(
        notifications: updated,
        unreadCount:
        (state.unreadCount - 1).clamp(0, 999),
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    try {
      await _repo.markAllAsRead(_userId!);

      final updated = state.notifications
          .map((n) => n.isUnread ? n.markRead() : n)
          .toList();

      state = state.copyWith(
        notifications: updated,
        unreadCount: 0,
      );
    } catch (_) {}
  }

  Future<void> deleteNotification(
      String notificationId) async {
    if (_userId == null) return;

    try {
      await _repo.deleteNotification(
        userId: _userId!,
        notificationId: notificationId,
      );

      final updated = state.notifications
          .where((n) => n.id != notificationId)
          .toList();

      final wasUnread = state.notifications
          .any((n) =>
      n.id == notificationId && n.isUnread);

      state = state.copyWith(
        notifications: updated,
        unreadCount: wasUnread
            ? (state.unreadCount - 1).clamp(0, 999)
            : state.unreadCount,
      );
    } catch (_) {}
  }

  Future<void> clearAll() async {
    if (_userId == null) return;

    try {
      await _repo.clearAll(_userId!);
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
    } catch (_) {}
  }

  Future<void> refresh() => _load();
}

final notificationsProvider =
StateNotifierProvider<NotificationsNotifier,
    NotificationsState>((ref) {
  final userId = ref.watch(currentUidProvider);
  return NotificationsNotifier(
    ref.read(notificationRepositoryProvider),
    userId,
  );
});

// Convenience — unread count only
final unreadNotificationsCountProvider =
Provider<int>((ref) {
  return ref
      .watch(notificationsProvider)
      .unreadCount;
});

// ─────────────────────────────────────────────────────────
// BOTTOM NAV STATE
// ─────────────────────────────────────────────────────────

class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0);

  void goTo(int index) {
    if (index < 0 || index > 4) return;
    state = index;
  }

  void goHome()      => state = 0;
  void goSearch()    => state = 1;
  void goInterests() => state = 2;
  void goChat()      => state = 3;
  void goProfile()   => state = 4;
}

final bottomNavProvider =
StateNotifierProvider<BottomNavNotifier, int>(
      (ref) => BottomNavNotifier(),
);

// ─────────────────────────────────────────────────────────
// APP INIT STATE
// ─────────────────────────────────────────────────────────

enum AppInitStatus {
  initializing,
  ready,
  error,
}

class AppInitState {
  final AppInitStatus status;
  final String? errorMessage;

  const AppInitState({
    this.status = AppInitStatus.initializing,
    this.errorMessage,
  });

  bool get isInitializing =>
      status == AppInitStatus.initializing;
  bool get isReady =>
      status == AppInitStatus.ready;
  bool get hasError =>
      status == AppInitStatus.error;
}

// ─────────────────────────────────────────────────────────
// APP INIT NOTIFIER
// ─────────────────────────────────────────────────────────

class AppInitNotifier
    extends StateNotifier<AppInitState> {
  AppInitNotifier()
      : super(const AppInitState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Simulate initialization tasks
      await Future.delayed(
          const Duration(milliseconds: 1500));

      // Phase 3: Firebase initialize karo
      // await Firebase.initializeApp();

      state = const AppInitState(
          status: AppInitStatus.ready);
    } catch (e) {
      state = AppInitState(
        status: AppInitStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> retry() async {
    state = const AppInitState(
        status: AppInitStatus.initializing);
    await _init();
  }
}

final appInitProvider = StateNotifierProvider<
    AppInitNotifier, AppInitState>(
      (ref) => AppInitNotifier(),
);

// ─────────────────────────────────────────────────────────
// LOADING STATE PROVIDER
// Global loading overlay ke liye
// ─────────────────────────────────────────────────────────

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

final globalLoadingProvider =
StateNotifierProvider<LoadingNotifier, bool>(
      (ref) => LoadingNotifier(),
);

// ─────────────────────────────────────────────────────────
// SNACKBAR / TOAST STATE
// ─────────────────────────────────────────────────────────

enum SnackType { info, success, error, warning }

class SnackMessage {
  final String message;
  final SnackType type;
  final DateTime timestamp;

  SnackMessage({
    required this.message,
    required this.type,
  }) : timestamp = DateTime.now();
}

class SnackNotifier
    extends StateNotifier<SnackMessage?> {
  SnackNotifier() : super(null);

  void show(String message,
      {SnackType type = SnackType.info}) {
    state = SnackMessage(
        message: message, type: type);
  }

  void showSuccess(String message) =>
      show(message, type: SnackType.success);

  void showError(String message) =>
      show(message, type: SnackType.error);

  void showWarning(String message) =>
      show(message, type: SnackType.warning);

  void dismiss() => state = null;
}

final snackProvider =
StateNotifierProvider<SnackNotifier,
    SnackMessage?>(
      (ref) => SnackNotifier(),
);

// ─────────────────────────────────────────────────────────
// SEARCH QUERY STATE
// ─────────────────────────────────────────────────────────

final searchQueryProvider =
StateProvider<String>((ref) => '');

// ─────────────────────────────────────────────────────────
// CONVENIENCE COMPUTED PROVIDERS
// ─────────────────────────────────────────────────────────

/// Is app fully initialized and ready
final isAppReadyProvider = Provider<bool>((ref) {
  return ref
      .watch(appInitProvider)
      .isReady;
});

/// Is dark mode enabled
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).isDarkMode;
});

/// Current theme mode
final themeModeProvider =
Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider).themeMode;
});

/// Current bottom nav index
final currentNavIndexProvider =
Provider<int>((ref) {
  return ref.watch(bottomNavProvider);
});