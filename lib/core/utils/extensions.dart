// lib/core/utils/extensions.dart

import 'package:flutter/material.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────
// STRING EXTENSIONS
// ─────────────────────────────────────────────────────────

extension StringExtensions on String {

  // ── CAPITALIZE ────────────────────────────────────────

  /// 'priya sharma' → 'Priya Sharma'
  String get capitalize {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() +
        word.substring(1).toLowerCase())
        .join(' ');
  }

  /// 'hello world' → 'Hello world'
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  // ── PHONE ─────────────────────────────────────────────

  /// '9876543210' → '98765 43210'
  String get formatPhone {
    if (length != 10) return this;
    return '${substring(0, 5)} ${substring(5)}';
  }

  /// '9876543210' → '98765 *****'
  String get maskPhone {
    if (length != 10) return this;
    return '${substring(0, 5)} *****';
  }

  /// '+919876543210' → '9876543210'
  String get stripCountryCode {
    if (startsWith('+91')) return substring(3);
    if (startsWith('91') && length == 12) {
      return substring(2);
    }
    return this;
  }

  // ── VALIDATION ────────────────────────────────────────

  /// Is valid 10-digit Indian mobile number
  bool get isValidPhone {
    final clean = stripCountryCode;
    return clean.length == 10 &&
        RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
  }

  /// Is valid email
  bool get isValidEmail {
    return RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Is null or empty check
  bool get isNullOrEmpty => trim().isEmpty;

  /// Has minimum length
  bool hasMinLength(int min) => trim().length >= min;

  // ── DISPLAY ───────────────────────────────────────────

  /// Truncate with ellipsis
  /// 'Long text here' → 'Long text...'
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Remove extra whitespace
  String get clean => trim().replaceAll(
      RegExp(r'\s+'), ' ');

  /// Extract initials from name
  /// 'Priya Sharma' → 'PS'
  String get initials {
    final words = trim().split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[words.length - 1][0]}'
        .toUpperCase();
  }

  /// Convert to title for display
  /// 'never_married' → 'Never Married'
  String get fromSnakeCase {
    return split('_').map((w) => w.capitalize).join(' ');
  }

  /// 'Never Married' → 'never_married'
  String get toSnakeCase {
    return toLowerCase().replaceAll(' ', '_');
  }
}

// ─────────────────────────────────────────────────────────
// NULLABLE STRING EXTENSIONS
// ─────────────────────────────────────────────────────────

extension NullableStringExtensions on String? {

  /// Is null or empty
  bool get isNullOrEmpty =>
      this == null || this!.trim().isEmpty;

  /// Returns fallback if null/empty
  String orDefault(String fallback) {
    return isNullOrEmpty ? fallback : this!;
  }

  /// Safe capitalize
  String get safeCapitalize =>
      isNullOrEmpty ? '' : this!.capitalize;
}

// ─────────────────────────────────────────────────────────
// DATETIME EXTENSIONS
// ─────────────────────────────────────────────────────────

extension DateTimeExtensions on DateTime {

  // ── AGE ───────────────────────────────────────────────

  /// Calculate age from date of birth
  /// DateTime(1998, 3, 12).age → 26
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month ||
        (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  // ── TIME AGO ──────────────────────────────────────────

  /// '5 minutes ago', '2 hours ago', 'Yesterday'
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    final years = (diff.inDays / 365).floor();
    return '${years}y ago';
  }

  // ── CHAT TIME FORMAT ──────────────────────────────────

  /// For chat window time — '3:45 PM'
  String get chatTime {
    final h = hour > 12
        ? hour - 12
        : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  /// For chat inbox time — smart format
  /// Today → '3:45 PM'
  /// Yesterday → 'Yesterday'
  /// This week → 'Mon', 'Tue'...
  /// Older → '12/3/24'
  String get inboxTime {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'Just now';
    if (isSameDay(now)) return chatTime;
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      const days = [
        'Mon', 'Tue', 'Wed',
        'Thu', 'Fri', 'Sat', 'Sun',
      ];
      return days[weekday - 1];
    }
    return '$day/${month.toString().padLeft(2, '0')}/${year.toString().substring(2)}';
  }

  // ── DATE LABEL ────────────────────────────────────────

  /// For notification grouping
  /// 'Today', 'Yesterday', 'This Week', 'Earlier'
  String get dateGroup {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays == 0 && isSameDay(now)) {
      return 'Today';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return 'This Week';
    return 'Earlier';
  }

  /// For chat window date separator
  /// 'Today', 'Yesterday', '12 Mar 2024'
  String get chatDateLabel {
    final now = DateTime.now();
    if (isSameDay(now)) return 'Today';
    if (isSameDay(
        now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return '$day ${_monthName(month)} $year';
  }

  // ── FORMATTED DATES ───────────────────────────────────

  /// '12 Mar 1998'
  String get displayDate {
    return '$day ${_monthName(month)} $year';
  }

  /// '12 Mar 1998 • 26 yrs'
  String get dobDisplay {
    return '$displayDate • $age yrs';
  }

  /// '12/03/1998'
  String get shortDate {
    return '${day.toString().padLeft(2, '0')}/'
        '${month.toString().padLeft(2, '0')}/$year';
  }

  // ── SAME DAY CHECK ────────────────────────────────────

  bool isSameDay(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }

  // ── HELPER ────────────────────────────────────────────

  String _monthName(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }
}

// ─────────────────────────────────────────────────────────
// INT EXTENSIONS
// ─────────────────────────────────────────────────────────

extension IntExtensions on int {

  // ── HEIGHT ────────────────────────────────────────────

  /// Inches to feet/inches text
  /// 163 → "5'4\""
  String get toHeightText {
    final feet = this ~/ 12;
    final inches = this % 12;
    return "$feet'$inches\"";
  }

  /// Inches to cm
  /// 64 → '163 cm'
  String get toCmText {
    final cm = (this * 2.54).round();
    return '$cm cm';
  }

  /// Full height text
  /// 64 → "5'4\" (163 cm)"
  String get toFullHeightText {
    return '$toHeightText (${toCmText})';
  }

  // ── INCOME ────────────────────────────────────────────

  /// Rupees to LPA short
  /// 1200000 → '12 LPA'
  String get toIncomeText {
    if (this >= 10000000) {
      final cr = (this / 10000000).toStringAsFixed(1);
      return '$cr Cr';
    }
    if (this >= 100000) {
      final lpa = (this / 100000).round();
      return '$lpa LPA';
    }
    if (this >= 1000) {
      final k = (this / 1000).round();
      return '${k}K';
    }
    return toString();
  }

  // ── COUNT ─────────────────────────────────────────────

  /// Smart count display
  /// 1200 → '1.2K', 1500000 → '1.5M'
  String get toCompactCount {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    }
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// Badge count — max 99+
  String get toBadgeCount {
    if (this > 99) return '99+';
    return toString();
  }

  // ── SCORE ─────────────────────────────────────────────

  /// Profile score to stars (out of 5)
  /// 78 → 4 (out of 5)
  int get scoreToStars {
    return (this / 20).round().clamp(0, 5);
  }

  // ── PLURALIZE ─────────────────────────────────────────

  /// 1 → '1 photo', 3 → '3 photos'
  String pluralize(String singular,
      [String? plural]) {
    final pluralForm = plural ?? '${singular}s';
    return '$this ${this == 1 ? singular : pluralForm}';
  }
}

// ─────────────────────────────────────────────────────────
// DOUBLE EXTENSIONS
// ─────────────────────────────────────────────────────────

extension DoubleExtensions on double {

  /// Round to 1 decimal place
  double get round1 =>
      double.parse(toStringAsFixed(1));

  /// Height in inches to feet string
  String get toHeightText =>
      toInt().toHeightText;
}

// ─────────────────────────────────────────────────────────
// LIST EXTENSIONS
// ─────────────────────────────────────────────────────────

extension ListExtensions<T> on List<T> {

  /// Is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Safe get — returns null if index out of bounds
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Paginate list
  /// profiles.paginate(page: 0, size: 10)
  List<T> paginate({
    required int page,
    required int size,
  }) {
    final start = page * size;
    if (start >= length) return [];
    final end = (start + size).clamp(0, length);
    return sublist(start, end);
  }

  /// Split into chunks
  /// [1,2,3,4,5].chunks(2) → [[1,2],[3,4],[5]]
  List<List<T>> chunks(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(
          i, (i + size).clamp(0, length)));
    }
    return result;
  }

  /// Unique items only
  List<T> get unique => toSet().toList();

  /// First or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Last or null
  T? get lastOrNull => isEmpty ? null : last;
}

// ─────────────────────────────────────────────────────────
// BUILD CONTEXT EXTENSIONS
// ─────────────────────────────────────────────────────────

extension ContextExtensions on BuildContext {

  // ── SCREEN SIZE ───────────────────────────────────────

  double get screenWidth =>
      MediaQuery.of(this).size.width;

  double get screenHeight =>
      MediaQuery.of(this).size.height;

  double get topPadding =>
      MediaQuery.of(this).padding.top;

  double get bottomPadding =>
      MediaQuery.of(this).padding.bottom;

  EdgeInsets get safeAreaPadding =>
      MediaQuery.of(this).padding;

  bool get isSmallScreen => screenWidth < 360;

  bool get isMediumScreen =>
      screenWidth >= 360 && screenWidth < 414;

  bool get isLargeScreen => screenWidth >= 414;

  // ── KEYBOARD ──────────────────────────────────────────

  bool get isKeyboardOpen =>
      MediaQuery.of(this).viewInsets.bottom > 0;

  double get keyboardHeight =>
      MediaQuery.of(this).viewInsets.bottom;

  void hideKeyboard() =>
      FocusScope.of(this).unfocus();

  // ── THEME ─────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);

  bool get isDarkMode =>
      Theme.of(this).brightness == Brightness.dark;

  // ── SNACKBARS ─────────────────────────────────────────

  /// Show a standard info snackbar
  void showSnackBar(
      String message, {
        Color? backgroundColor,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium
              .copyWith(color: Colors.white),
        ),
        backgroundColor:
        backgroundColor ?? AppColors.ink,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show an error snackbar
  void showErrorSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white),
            ),
          ),
        ]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show a success snackbar
  void showSuccessSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white),
            ),
          ),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show a warning snackbar
  void showWarningSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white),
            ),
          ),
        ]),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ── NAVIGATION ────────────────────────────────────────

  void pop<T>([T? result]) =>
      Navigator.of(this).pop(result);

  bool canPop() => Navigator.of(this).canPop();

  // ── DIALOG ────────────────────────────────────────────

  /// Show confirm dialog
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: AppTextStyles.h4),
        content: Text(message,
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, false),
            child: Text(cancelLabel,
                style: AppTextStyles.buttonSecondary),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? AppColors.error
                  : AppColors.crimson,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10)),
            ),
            onPressed: () =>
                Navigator.pop(ctx, true),
            child: Text(confirmLabel,
                style: AppTextStyles.buttonPrimary),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ─────────────────────────────────────────────────────────
// COLOR EXTENSIONS
// ─────────────────────────────────────────────────────────

extension ColorExtensions on Color {

  /// Returns true if color is dark
  bool get isDark {
    final luminance = computeLuminance();
    return luminance < 0.5;
  }

  /// Returns appropriate text color
  Color get textColor =>
      isDark ? Colors.white : AppColors.ink;

  /// Returns with given opacity (0.0 to 1.0)
  Color withValue(double opacity) =>
      withOpacity(opacity.clamp(0.0, 1.0));

  /// Lighten color by amount
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(
        (hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Darken color by amount
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(
        (hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// ─────────────────────────────────────────────────────────
// WIDGET EXTENSIONS
// ─────────────────────────────────────────────────────────

extension WidgetExtensions on Widget {

  /// Add padding to any widget
  Widget paddingAll(double value) =>
      Padding(
          padding: EdgeInsets.all(value),
          child: this);

  Widget paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: vertical),
        child: this,
      );

  Widget paddingOnly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
            left: left,
            right: right,
            top: top,
            bottom: bottom),
        child: this,
      );

  /// Wrap in Center
  Widget get centered =>
      Center(child: this);

  /// Wrap in Expanded
  Widget get expanded =>
      Expanded(child: this);

  /// Wrap in Flexible
  Widget get flexible =>
      Flexible(child: this);

  /// Wrap in SafeArea
  Widget get safeArea =>
      SafeArea(child: this);

  /// Add tap gesture
  Widget onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);

  /// Add visibility
  Widget visible(bool isVisible) =>
      Visibility(visible: isVisible, child: this);

  /// Wrap in SingleChildScrollView
  Widget get scrollable =>
      SingleChildScrollView(child: this);
}