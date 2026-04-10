// lib/providers/app_state_provider.dart
// Global app state — theme, language, connectivity, notifications

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import 'auth_provider.dart';

// ── NOTIFICATION REPOSITORY PROVIDER ─────────────────────
final notificationRepositoryProvider =
Provider<NotificationRepository>(
      (ref) => NotificationRepository(),
);

// ─────────────────────────────────────────────────────────
// APP SETTINGS STATE
// ─────────────────────────────────────────────────────────

class AppSettings {
  final bool isDarkMode;
  final String language; // 'hindi' | 'english'
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showOnlineStatus;
  final bool autoPlayVideos;

  const AppSettings({
    this.isDarkMode = false,
    this.language = 'hindi',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showOnlineStatus = true,
    this.autoPlayVideos = false,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showOnlineStatus,
    bool? autoPlayVideos,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled:
      notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled:
      vibrationEnabled ?? this.vibrationEnabled,
      showOnlineStatus:
      showOnlineStatus ?? this.showOnlineStatus,
      autoPlayVideos:
      autoPlayVideos ?? this.autoPlayVideos,
    );
  }
}

// ── APP SETTINGS NOTIFIER ─────────────────────────────────
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    // TODO: SharedPreferences se load karo
    // final prefs = await SharedPreferences.getInstance();
    // state = AppSettings(
    //   isDarkMode: prefs.getBool('isDarkMode') ?? false,
    //   language: prefs.getString('language') ?? 'hindi',
    //   notificationsEnabled:
    //     prefs.getBool('notificationsEnabled') ?? true,
    //   soundEnabled: prefs.getBool('soundEnabled') ?? true,
    //   vibrationEnabled:
    //     prefs.getBool('vibrationEnabled') ?? true,
    //   showOnlineStatus:
    //     prefs.getBool('showOnlineStatus') ?? true,
    // );
  }

  Future<void> _saveToStorage() async {
    // TODO: SharedPreferences mein save karo
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool('isDarkMode', state.isDarkMode);
    // prefs.setString('language', state.language);
    // prefs.setBool('notificationsEnabled',
    //   state.notificationsEnabled);
    // prefs.setBool('soundEnabled', state.soundEnabled);
    // prefs.setBool('vibrationEnabled',
    //   state.vibrationEnabled);
    // prefs.setBool('showOnlineStatus',
    //   state.showOnlineStatus);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _saveToStorage();
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
    _saveToStorage();
  }

  void toggleNotifications() {
    state = state.copyWith(
        notificationsEnabled: !state.notificationsEnabled);
    _saveToStorage();
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    _saveToStorage();
  }

  void toggleVibration() {
    state = state.copyWith(
        vibrationEnabled: !state.vibrationEnabled);
    _saveToStorage();
  }

  void toggleOnlineStatus() {
    state = state.copyWith(
        showOnlineStatus: !state.showOnlineStatus);
    _saveToStorage();
  }

  void reset() {
    state = const AppSettings();
    _saveToStorage();
  }
}

// ── APP SETTINGS PROVIDER ─────────────────────────────────
final appSettingsProvider =
StateNotifierProvider<AppSettingsNotifier, AppSettings>(
      (ref) => AppSettingsNotifier(),
);

// ─────────────────────────────────────────────────────────
// CONNECTIVITY STATE
// ─────────────────────────────────────────────────────────

enum ConnectivityStatus { online, offline, unknown }

class ConnectivityState {
  final ConnectivityStatus status;
  final bool wasOffline; // offline tha aur wapas online aaya

  const ConnectivityState({
    this.status = ConnectivityStatus.unknown,
    this.wasOffline = false,
  });

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    bool? wasOffline,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      wasOffline: wasOffline ?? this.wasOffline,
    );
  }

  bool get isOnline =>
      status == ConnectivityStatus.online;
  bool get isOffline =>
      status == ConnectivityStatus.offline;
}

// ── CONNECTIVITY NOTIFIER ─────────────────────────────────
class ConnectivityNotifier
    extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier()
      : super(const ConnectivityState(
      status: ConnectivityStatus.online)) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // TODO: connectivity_plus package use karo
    // final connectivity = Connectivity();
    // final result = await connectivity.checkConnectivity();
    // _updateStatus(result);
    //
    // connectivity.onConnectivityChanged.listen((result) {
    //   _updateStatus(result);
    // });

    // Mock: online status
    state = const ConnectivityState(
        status: ConnectivityStatus.online);
  }

  void _updateStatus(dynamic result) {
    // TODO: ConnectivityResult se status update karo
    // final isOnline = result != ConnectivityResult.none;
    // final wasOffline = state.isOffline;
    //
    // state = state.copyWith(
    //   status: isOnline
    //     ? ConnectivityStatus.online
    //     : ConnectivityStatus.offline,
    //   wasOffline: !isOnline ? false : wasOffline,
    // );
  }

  void setOnline() {
    state = state.copyWith(
      status: ConnectivityStatus.online,
      wasOffline: state.isOffline,
    );
  }

  void setOffline() {
    state = state.copyWith(
      status: ConnectivityStatus.offline,
    );
  }
}

// ── CONNECTIVITY PROVIDER ─────────────────────────────────
final connectivityProvider = StateNotifierProvider<
    ConnectivityNotifier, ConnectivityState>(
      (ref) => ConnectivityNotifier(),
);

// ─────────────────────────────────────────────────────────
// NOTIFICATIONS STATE
// ─────────────────────────────────────────────────────────

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // ── COMPUTED ──────────────────────────────────────
  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  List<NotificationModel> get todayNotifications {
    return notifications
        .where((n) => n.dateGroup == 'Aaj')
        .toList();
  }

  List<NotificationModel> get yesterdayNotifications {
    return notifications
        .where((n) => n.dateGroup == 'Kal')
        .toList();
  }

  List<NotificationModel> get olderNotifications {
    return notifications
        .where((n) =>
    n.dateGroup != 'Aaj' && n.dateGroup != 'Kal')
        .toList();
  }
}

// ── NOTIFICATIONS NOTIFIER ────────────────────────────────
class NotificationsNotifier
    extends StateNotifier<NotificationsState> {
  final NotificationRepository _repo;
  final String? _userId;

  NotificationsNotifier(this._repo, this._userId)
      : super(const NotificationsState()) {
    if (_userId != null) loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notifications =
      await _repo.getUserNotifications(_userId!);
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _repo.markAsRead(notificationId);
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList(),
    );
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    await _repo.markAllAsRead(_userId!);
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList(),
    );
  }

  Future<void> deleteNotification(
      String notificationId) async {
    await _repo.deleteNotification(notificationId);
    state = state.copyWith(
      notifications: state.notifications
          .where((n) => n.id != notificationId)
          .toList(),
    );
  }

  Future<void> clearAll() async {
    if (_userId == null) return;
    await _repo.clearAll(_userId!);
    state = state.copyWith(notifications: []);
  }

  // Naya notification add karo (realtime ke liye)
  void addNotification(NotificationModel notification) {
    state = state.copyWith(
      notifications: [
        notification,
        ...state.notifications,
      ],
    );
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}

// ── NOTIFICATIONS PROVIDER ────────────────────────────────
final notificationsProvider = StateNotifierProvider<
    NotificationsNotifier, NotificationsState>(
      (ref) {
    final userId = ref.watch(currentUidProvider);
    return NotificationsNotifier(
      ref.read(notificationRepositoryProvider),
      userId,
    );
  },
);

// ── UNREAD COUNT PROVIDER (badge ke liye) ─────────────────
final unreadNotificationsCountProvider =
Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

// ─────────────────────────────────────────────────────────
// BOTTOM NAV STATE
// ─────────────────────────────────────────────────────────

class BottomNavState {
  final int currentIndex;

  const BottomNavState({this.currentIndex = 0});

  BottomNavState copyWith({int? currentIndex}) {
    return BottomNavState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class BottomNavNotifier
    extends StateNotifier<BottomNavState> {
  BottomNavNotifier() : super(const BottomNavState());

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void goHome() => setIndex(0);
  void goSearch() => setIndex(1);
  void goInterests() => setIndex(2);
  void goChat() => setIndex(3);
  void goProfile() => setIndex(4);
}

// ── BOTTOM NAV PROVIDER ───────────────────────────────────
final bottomNavProvider =
StateNotifierProvider<BottomNavNotifier, BottomNavState>(
      (ref) => BottomNavNotifier(),
);

// ─────────────────────────────────────────────────────────
// APP INIT STATE
// ─────────────────────────────────────────────────────────

enum AppInitStatus {
  initializing,
  unauthenticated,
  authenticated,
  profileSetupRequired,
  ready,
  error,
}

class AppInitState {
  final AppInitStatus status;
  final String? error;
  final String? uid;

  const AppInitState({
    this.status = AppInitStatus.initializing,
    this.error,
    this.uid,
  });

  AppInitState copyWith({
    AppInitStatus? status,
    String? error,
    String? uid,
  }) {
    return AppInitState(
      status: status ?? this.status,
      error: error,
      uid: uid ?? this.uid,
    );
  }

  bool get isReady => status == AppInitStatus.ready;
  bool get isLoading =>
      status == AppInitStatus.initializing;
  bool get needsAuth =>
      status == AppInitStatus.unauthenticated;
  bool get needsProfileSetup =>
      status == AppInitStatus.profileSetupRequired;
}

// ── APP INIT NOTIFIER ─────────────────────────────────────
class AppInitNotifier extends StateNotifier<AppInitState> {
  AppInitNotifier() : super(const AppInitState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(
        status: AppInitStatus.initializing);

    try {
      // TODO: Firebase Auth state check karo
      // final user = FirebaseAuth.instance.currentUser;
      //
      // if (user == null) {
      //   state = state.copyWith(
      //     status: AppInitStatus.unauthenticated);
      //   return;
      // }
      //
      // state = state.copyWith(uid: user.uid);
      //
      // Check karo profile banaya hai ya nahi
      // final profile = await ProfileRepository()
      //   .getProfileByUserId(user.uid);
      //
      // if (profile == null) {
      //   state = state.copyWith(
      //     status: AppInitStatus.profileSetupRequired);
      //   return;
      // }
      //
      // state = state.copyWith(
      //   status: AppInitStatus.ready);

      // Mock: Direct ready
      await Future.delayed(
          const Duration(milliseconds: 500));
      state = state.copyWith(
          status: AppInitStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AppInitStatus.error,
        error: e.toString(),
      );
    }
  }

  void setAuthenticated(String uid) {
    state = state.copyWith(
      status: AppInitStatus.authenticated,
      uid: uid,
    );
  }

  void setProfileSetupRequired() {
    state = state.copyWith(
        status: AppInitStatus.profileSetupRequired);
  }

  void setReady() {
    state =
        state.copyWith(status: AppInitStatus.ready);
  }

  void setUnauthenticated() {
    state = state.copyWith(
      status: AppInitStatus.unauthenticated,
      uid: null,
    );
  }

  Future<void> retry() async {
    await _initialize();
  }
}

// ── APP INIT PROVIDER ─────────────────────────────────────
final appInitProvider =
StateNotifierProvider<AppInitNotifier, AppInitState>(
      (ref) => AppInitNotifier(),
);

// ─────────────────────────────────────────────────────────
// GLOBAL CONVENIENCE PROVIDERS
// ─────────────────────────────────────────────────────────

/// Dark mode hai ya nahi
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).isDarkMode;
});

/// App language
final appLanguageProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).language;
});

/// Internet connection hai ya nahi
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isOnline;
});

/// App theme
final appThemeProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(isDarkModeProvider);
  // TODO: Dark theme implement karo
  return ThemeData.light();
});