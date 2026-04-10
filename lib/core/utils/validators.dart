class Validators {
  Validators._();

  // ── PHONE NUMBER ──────────────────────────────────────
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number daalna zaroori hai';
    }
    final cleaned = value.trim().replaceAll(' ', '');
    if (cleaned.length != 10) {
      return '10 digit ka number chahiye';
    }
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(cleaned)) {
      return 'Sahi mobile number daalo (6/7/8/9 se shuru hona chahiye)';
    }
    return null;
  }

  // ── OTP ───────────────────────────────────────────────
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP daalna zaroori hai';
    }
    if (value.trim().length != 6) {
      return '6 digit ka OTP daalo';
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Sirf numbers allowed hain';
    }
    return null;
  }

  // ── NAME ──────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Naam daalna zaroori hai';
    }
    if (value.trim().length < 2) {
      return 'Naam bahut chota hai';
    }
    if (value.trim().length > 50) {
      return 'Naam bahut lamba hai (max 50 akshar)';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Sirf alphabets aur spaces allowed hain';
    }
    return null;
  }

  // ── DATE OF BIRTH ─────────────────────────────────────
  static String? dob(DateTime? value) {
    if (value == null) {
      return 'Janam tithi daalni zaroori hai';
    }
    final today = DateTime.now();
    final age = today.year -
        value.year -
        ((today.month < value.month ||
            (today.month == value.month && today.day < value.day))
            ? 1
            : 0);
    if (age < 18) {
      return 'Umar 18 saal se zyada honi chahiye';
    }
    if (age > 70) {
      return 'Sahi janam tithi daalo';
    }
    return null;
  }

  // ── ABOUT ME ──────────────────────────────────────────
  static String? about(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional field
    }
    if (value.trim().length > 300) {
      return 'Maximum 300 akshar hi likh sakte ho';
    }
    return null;
  }

  // ── REQUIRED FIELD ────────────────────────────────────
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Yeh field'} zaroori hai';
    }
    return null;
  }

  // ── CITY ──────────────────────────────────────────────
  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sheher ka naam daalna zaroori hai';
    }
    if (value.trim().length < 2) {
      return 'Sahi sheher ka naam daalo';
    }
    return null;
  }

  // ── DROPDOWN ──────────────────────────────────────────
  static String? dropdown(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Koi ek'} select karo';
    }
    return null;
  }
}