// lib/core/utils/formatters.dart

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────
// TEXT INPUT FORMATTERS
// (Use in TextFormField inputFormatters: [])
// ─────────────────────────────────────────────────────────

/// Only digits allowed — 0-9
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final filtered = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '');
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(
          offset: filtered.length),
    );
  }
}

/// Only letters and spaces allowed
class LettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final filtered = newValue.text
        .replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(
          offset: filtered.length),
    );
  }
}

/// Letters, digits and spaces only
class AlphaNumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final filtered = newValue.text
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(
          offset: filtered.length),
    );
  }
}

/// Auto capitalize first letter of each word
class TitleCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final words = newValue.text.split(' ');
    final formatted = words
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() +
        word.substring(1))
        .join(' ');
    return newValue.copyWith(
      text: formatted,
      selection: newValue.selection,
    );
  }
}

/// Limit max characters
class MaxLengthFormatter extends TextInputFormatter {
  final int maxLength;
  MaxLengthFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.length > maxLength) {
      return oldValue;
    }
    return newValue;
  }
}

/// Indian phone number formatter
/// Input: 9876543210
/// Output: 98765 43210
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Only allow digits
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '');

    // Max 10 digits
    final limited = digits.length > 10
        ? digits.substring(0, 10)
        : digits;

    // Format as: 98765 43210
    String formatted = limited;
    if (limited.length > 5) {
      formatted =
      '${limited.substring(0, 5)} ${limited.substring(5)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
          offset: formatted.length),
    );
  }
}

/// OTP input — digits only, max 1 char per field
class OtpFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '');
    final limited =
    digits.isEmpty ? '' : digits[0];
    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(
          offset: limited.length),
    );
  }
}

/// No leading/trailing spaces, single space between words
class NoExtraSpacesFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Allow typing but prevent double spaces
    if (newValue.text.contains('  ')) {
      return oldValue;
    }
    // Prevent leading space
    if (newValue.text.startsWith(' ') &&
        oldValue.text.isEmpty) {
      return oldValue;
    }
    return newValue;
  }
}

// ─────────────────────────────────────────────────────────
// VALUE FORMATTERS
// (Pure functions — input value → formatted string)
// ─────────────────────────────────────────────────────────

abstract class AppFormatter {
  AppFormatter._();

  // ── PHONE ─────────────────────────────────────────────

  /// '9876543210' → '98765 43210'
  static String phone(String value) {
    final digits =
    value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) return value;
    return '${digits.substring(0, 5)} ${digits.substring(5)}';
  }

  /// '9876543210' → '+91 98765 43210'
  static String phoneWithCode(String value) {
    final formatted = phone(value);
    return '+91 $formatted';
  }

  /// '9876543210' → '98765 *****'
  static String phoneMasked(String value) {
    final digits =
    value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) return value;
    return '${digits.substring(0, 5)} *****';
  }

  // ── HEIGHT ────────────────────────────────────────────

  /// 64 inches → "5'4\""
  static String height(int inches) {
    final feet = inches ~/ 12;
    final inch = inches % 12;
    return "$feet'$inch\"";
  }

  /// 64 → "5'4\" (163 cm)"
  static String heightFull(int inches) {
    final cm = (inches * 2.54).round();
    return "${height(inches)} ($cm cm)";
  }

  /// "5'4\"" → 64 (inches)
  static int heightToInches(String text) {
    final match =
    RegExp(r"(\d+)'(\d+)").firstMatch(text);
    if (match == null) return 0;
    final feet = int.tryParse(match.group(1) ?? '0') ?? 0;
    final inch = int.tryParse(match.group(2) ?? '0') ?? 0;
    return (feet * 12) + inch;
  }

  // ── INCOME ────────────────────────────────────────────

  /// 1200000 → '12 LPA'
  static String income(int amount) {
    if (amount >= 10000000) {
      final cr =
      (amount / 10000000).toStringAsFixed(1);
      return '$cr Cr/yr';
    }
    if (amount >= 100000) {
      final lpa = (amount / 100000).round();
      return '$lpa LPA';
    }
    if (amount >= 1000) {
      final k = (amount / 1000).round();
      return '${k}K/yr';
    }
    return '₹$amount';
  }

  /// '8-12 LPA' → display as is
  static String incomeRange(
      String minLpa, String maxLpa) {
    return '$minLpa – $maxLpa LPA';
  }

  // ── CURRENCY ──────────────────────────────────────────

  /// 49900 → '₹499'
  static String currency(int paisa) {
    final rupees = paisa ~/ 100;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(rupees);
  }

  /// 49900 → '₹499.00'
  static String currencyDecimal(int paisa) {
    final rupees = paisa / 100;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(rupees);
  }

  /// 499 → '₹499 / month'
  static String subscriptionPrice(
      int amount, int months) {
    final label = months == 1
        ? 'month'
        : '$months months';
    return '₹$amount / $label';
  }

  // ── DATE & TIME ───────────────────────────────────────

  /// DateTime → '12 Mar 1998'
  static String date(DateTime dt) {
    return DateFormat('d MMM yyyy').format(dt);
  }

  /// DateTime → '12/03/1998'
  static String dateShort(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  /// DateTime → '3:45 PM'
  static String time(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  /// DateTime → '12 Mar 1998, 3:45 PM'
  static String dateTime(DateTime dt) {
    return DateFormat('d MMM yyyy, h:mm a').format(dt);
  }

  /// DateTime → 'Mar 1998'
  static String monthYear(DateTime dt) {
    return DateFormat('MMM yyyy').format(dt);
  }

  // ── AGE ───────────────────────────────────────────────

  /// DateTime dob → '26 years'
  static String ageText(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month &&
            now.day < dob.day)) {
      age--;
    }
    return '$age years';
  }

  /// DateTime dob → '12 Mar 1998 • 26 yrs'
  static String dobFull(DateTime dob) {
    return '${date(dob)} • ${ageText(dob)}';
  }

  // ── NAME ──────────────────────────────────────────────

  /// 'priya sharma' → 'Priya Sharma'
  static String name(String value) {
    return value
        .trim()
        .split(' ')
        .map((w) => w.isEmpty
        ? w
        : w[0].toUpperCase() +
        w.substring(1).toLowerCase())
        .join(' ');
  }

  /// 'Priya Sharma' → 'PS'
  static String initials(String fullName) {
    final words = fullName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[words.length - 1][0]}'
        .toUpperCase();
  }

  // ── PROFILE INFO ──────────────────────────────────────

  /// Profile location + caste
  /// 'Delhi • Brahmin'
  static String locationCaste(
      String city, String caste) {
    return '$city • $caste';
  }

  /// Profession + company
  /// 'Software Engineer • TCS'
  static String professionCompany(
      String profession, String? company) {
    if (company == null || company.isEmpty) {
      return profession;
    }
    return '$profession • $company';
  }

  /// Education + income
  /// 'B.Tech • 8-12 LPA'
  static String educationIncome(
      String education, String incomeRange) {
    return '$education • $incomeRange';
  }

  /// Age + height
  /// '26 yrs • 5\'4"'
  static String ageHeight(
      int age, int heightInches) {
    return '$age yrs • ${height(heightInches)}';
  }

  // ── MANGLIK ───────────────────────────────────────────

  /// 'yes' → 'Manglik'
  /// 'no' → 'Non-Manglik'
  /// 'partial' → 'Partial Manglik'
  static String manglik(String value) {
    switch (value.toLowerCase()) {
      case 'yes':
        return 'Manglik';
      case 'no':
        return 'Non-Manglik';
      case 'partial':
        return 'Partial Manglik';
      default:
        return value;
    }
  }

  // ── MARITAL STATUS ────────────────────────────────────

  /// 'never_married' → 'Never Married'
  static String maritalStatus(String value) {
    switch (value.toLowerCase()) {
      case 'never_married':
        return 'Never Married';
      case 'divorced':
        return 'Divorced';
      case 'widowed':
        return 'Widowed';
      case 'separated':
        return 'Separated';
      default:
        return value
            .split('_')
            .map((w) => w[0].toUpperCase() +
            w.substring(1))
            .join(' ');
    }
  }

  // ── EMPLOYMENT TYPE ───────────────────────────────────

  /// 'govt' → 'Government Job'
  static String employmentType(String value) {
    switch (value.toLowerCase()) {
      case 'govt':
        return 'Government Job';
      case 'private':
        return 'Private Sector';
      case 'business':
        return 'Business / Self Employed';
      case 'not_working':
        return 'Not Working';
      default:
        return value;
    }
  }

  // ── FAMILY TYPE ───────────────────────────────────────

  /// 'joint' → 'Joint Family'
  static String familyType(String value) {
    switch (value.toLowerCase()) {
      case 'joint':
        return 'Joint Family';
      case 'nuclear':
        return 'Nuclear Family';
      case 'other':
        return 'Other';
      default:
        return value;
    }
  }

  // ── FAMILY VALUES ─────────────────────────────────────

  /// 'traditional' → 'Traditional'
  static String familyValues(String value) {
    switch (value.toLowerCase()) {
      case 'traditional':
        return 'Traditional';
      case 'moderate':
        return 'Moderate';
      case 'liberal':
        return 'Liberal';
      default:
        return value;
    }
  }

  // ── SIBLINGS ──────────────────────────────────────────

  /// 2, true → '2 Brothers (1 Married)'
  static String siblings(
      int count, String gender) {
    if (count == 0) return 'None';
    final label = gender.toLowerCase() == 'brother'
        ? count == 1 ? 'Brother' : 'Brothers'
        : count == 1 ? 'Sister' : 'Sisters';
    return '$count $label';
  }

  // ── PROFILE SCORE ─────────────────────────────────────

  /// 78 → '78%'
  static String score(int value) => '$value%';

  /// 78 → 'Good'
  static String scoreLabel(int value) {
    if (value >= 90) return 'Excellent';
    if (value >= 75) return 'Good';
    if (value >= 50) return 'Average';
    return 'Incomplete';
  }

  // ── COUNT ─────────────────────────────────────────────

  /// 1200 → '1.2K'
  static String compactCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// 105 → '99+'
  static String badgeCount(int count) {
    if (count > 99) return '99+';
    return count.toString();
  }

  // ── SUBSCRIPTION ──────────────────────────────────────

  /// 'gold', 1 → 'Gold • 1 Month'
  static String subscriptionLabel(
      String plan, int months) {
    final planName =
        plan[0].toUpperCase() + plan.substring(1);
    final duration =
    months == 1 ? '1 Month' : '$months Months';
    return '$planName • $duration';
  }

  /// DateTime → '15 days left'
  static String subscriptionExpiry(DateTime expiry) {
    final diff =
    expiry.difference(DateTime.now());
    if (diff.inDays <= 0) return 'Expired';
    if (diff.inDays == 1) return '1 day left';
    if (diff.inDays < 30) {
      return '${diff.inDays} days left';
    }
    final months = (diff.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} left';
  }

  // ── VERIFICATION STATUS ───────────────────────────────

  /// 'pending' → 'Verification Pending'
  static String verificationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Verification Pending';
      case 'approved':
        return 'Verified ✓';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return status;
    }
  }
}