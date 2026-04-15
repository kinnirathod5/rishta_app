// lib/core/utils/validators.dart

import 'package:rishta_app/core/constants/app_strings.dart';

// ─────────────────────────────────────────────────────────
// VALIDATORS
// All validators return:
//   null    → valid
//   String  → error message
// ─────────────────────────────────────────────────────────

abstract class Validators {
  Validators._();

  // ─────────────────────────────────────────────────
  // AUTH VALIDATORS
  // ─────────────────────────────────────────────────

  /// Indian mobile number — 10 digits, starts 6/7/8/9
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.phoneRequired;
    }
    final clean = value
        .trim()
        .replaceAll(' ', '')
        .replaceAll('+91', '')
        .replaceAll('-', '');

    if (clean.length != 10) {
      return AppStrings.phoneInvalid;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
      return AppStrings.phoneInvalid;
    }
    return null;
  }

  /// 6-digit OTP
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.otpRequired;
    }
    if (value.trim().length != 6) {
      return AppStrings.otpInvalid;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return AppStrings.otpInvalid;
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // PERSONAL INFO VALIDATORS
  // ─────────────────────────────────────────────────

  /// Full name — min 2 chars, letters and spaces only
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    final clean = value.trim();
    if (clean.length < 2) {
      return AppStrings.nameMin;
    }
    if (clean.length > 60) {
      return 'Name must be less than 60 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'.]+$").hasMatch(clean)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Date of birth — must be 18+
  static String? dateOfBirth(DateTime? dob) {
    if (dob == null) {
      return AppStrings.dobRequired;
    }
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month &&
            today.day < dob.day)) {
      age--;
    }
    if (age < 18) {
      return AppStrings.mustBe18;
    }
    if (age > 80) {
      return 'Please enter a valid date of birth';
    }
    // Future date check
    if (dob.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }
    return null;
  }

  /// Age range — min 18, max 80
  static String? age(int? value) {
    if (value == null) {
      return AppStrings.dobRequired;
    }
    if (value < 18) {
      return AppStrings.mustBe18;
    }
    if (value > 80) {
      return 'Please enter a valid age';
    }
    return null;
  }

  /// City — required, min 2 chars
  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.cityRequired;
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid city name';
    }
    return null;
  }

  /// Height in inches — 4ft to 7ft
  static String? height(int? inches) {
    if (inches == null || inches == 0) {
      return AppStrings.heightRequired;
    }
    if (inches < 48) {
      // Less than 4'0"
      return 'Height seems too short';
    }
    if (inches > 84) {
      // More than 7'0"
      return 'Height seems too tall';
    }
    return null;
  }

  /// About me — optional, max 300 chars
  static String? about(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.length > 300) {
      return 'About me must be under 300 characters';
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // RELIGION VALIDATORS
  // ─────────────────────────────────────────────────

  /// Religion — required dropdown
  static String? religion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.religionRequired;
    }
    return null;
  }

  /// Caste — required dropdown
  static String? caste(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.casteRequired;
    }
    return null;
  }

  /// Sub caste — optional text field
  static String? subCaste(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid sub-caste';
    }
    return null;
  }

  /// Gotra — optional text field
  static String? gotra(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid gotra';
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // EDUCATION VALIDATORS
  // ─────────────────────────────────────────────────

  /// Qualification — required dropdown
  static String? qualification(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.qualRequired;
    }
    return null;
  }

  /// College name — optional text
  static String? college(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid college name';
    }
    return null;
  }

  /// Employment type — required dropdown
  static String? employmentType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select employment type';
    }
    return null;
  }

  /// Company name — optional
  static String? company(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid company name';
    }
    return null;
  }

  /// Annual income — required dropdown
  static String? annualIncome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.incomeRequired;
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // FAMILY VALIDATORS
  // ─────────────────────────────────────────────────

  /// Family type — required
  static String? familyType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select family type';
    }
    return null;
  }

  /// Family values — required
  static String? familyValues(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select family values';
    }
    return null;
  }

  /// Father occupation — optional
  static String? fatherOccupation(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid occupation';
    }
    return null;
  }

  /// Mother occupation — optional
  static String? motherOccupation(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid occupation';
    }
    return null;
  }

  /// Siblings count — 0 to 10
  static String? siblingCount(int? value) {
    if (value == null) return null;
    if (value < 0 || value > 10) {
      return 'Please enter a valid number (0-10)';
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // PARTNER PREFERENCE VALIDATORS
  // ─────────────────────────────────────────────────

  /// Age range — min must be < max, both 18-80
  static String? ageRange(
      int? minAge, int? maxAge) {
    if (minAge == null || maxAge == null) {
      return 'Please set age range';
    }
    if (minAge < 18) {
      return 'Minimum age must be at least 18';
    }
    if (maxAge > 80) {
      return 'Maximum age cannot exceed 80';
    }
    if (minAge >= maxAge) {
      return 'Minimum age must be less than maximum age';
    }
    if (maxAge - minAge < 2) {
      return 'Age range must be at least 2 years';
    }
    return null;
  }

  /// Height range — min < max
  static String? heightRange(
      int? minInches, int? maxInches) {
    if (minInches == null || maxInches == null) {
      return null; // Optional
    }
    if (minInches >= maxInches) {
      return 'Minimum height must be less than maximum';
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // PHOTO VALIDATORS
  // ─────────────────────────────────────────────────

  /// At least 1 photo required
  static String? photos(List<String> photoUrls) {
    if (photoUrls.isEmpty) {
      return 'Please upload at least 1 photo';
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // GENERAL PURPOSE VALIDATORS
  // ─────────────────────────────────────────────────

  /// Required field — any type
  static String? required(
      String? value, {
        String? fieldName,
      }) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : AppStrings.required;
    }
    return null;
  }

  /// Required dropdown
  static String? dropdown(
      String? value, {
        String? errorMessage,
      }) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? AppStrings.required;
    }
    return null;
  }

  /// Email — optional but must be valid if provided
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    final clean = value.trim();
    if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(clean)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Min length check
  static String? minLength(
      String? value,
      int min, {
        String? fieldName,
      }) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.required;
    }
    if (value.trim().length < min) {
      final name = fieldName ?? 'This field';
      return '$name must be at least $min characters';
    }
    return null;
  }

  /// Max length check
  static String? maxLength(
      String? value,
      int max, {
        String? fieldName,
      }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > max) {
      final name = fieldName ?? 'This field';
      return '$name must be less than $max characters';
    }
    return null;
  }

  /// URL — optional but valid if provided
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    final clean = value.trim();
    if (!RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b')
        .hasMatch(clean)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // ─────────────────────────────────────────────────
  // COMBINED VALIDATORS
  // (Run multiple validators at once)
  // ─────────────────────────────────────────────────

  /// Run multiple validators — returns first error
  static String? combine(
      String? value,
      List<String? Function(String?)> validators,
      ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Validate full profile Step 1
  static Map<String, String?> validateStep1({
    required String name,
    required DateTime? dob,
    required int? height,
    required String city,
    required String? motherTongue,
  }) {
    return {
      'name': Validators.name(name),
      'dob': Validators.dateOfBirth(dob),
      'height': Validators.height(height),
      'city': Validators.city(city),
      'motherTongue':
      Validators.dropdown(motherTongue,
          errorMessage:
          'Please select mother tongue'),
    };
  }

  /// Validate full profile Step 2
  static Map<String, String?> validateStep2({
    required String religion,
    required String caste,
  }) {
    return {
      'religion': Validators.religion(religion),
      'caste': Validators.caste(caste),
    };
  }

  /// Validate full profile Step 3
  static Map<String, String?> validateStep3({
    required String qualification,
    required String? employmentType,
    required String? annualIncome,
  }) {
    return {
      'qualification':
      Validators.qualification(qualification),
      'employmentType':
      Validators.employmentType(employmentType),
      'annualIncome':
      Validators.annualIncome(annualIncome),
    };
  }

  /// Validate full profile Step 4
  static Map<String, String?> validateStep4({
    required String? familyType,
    required String? familyValues,
  }) {
    return {
      'familyType':
      Validators.familyType(familyType),
      'familyValues':
      Validators.familyValues(familyValues),
    };
  }

  // ─────────────────────────────────────────────────
  // HELPER
  // ─────────────────────────────────────────────────

  /// Check if a Map of errors has any non-null values
  static bool hasErrors(Map<String, String?> errors) {
    return errors.values.any((e) => e != null);
  }

  /// Get first error from a map
  static String? firstError(
      Map<String, String?> errors) {
    for (final entry in errors.entries) {
      if (entry.value != null) return entry.value;
    }
    return null;
  }
}