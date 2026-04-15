// lib/data/models/profile_model.dart
//
// NOTE: Firebase (cloud_firestore) Phase 3 mein add hoga.
// Tab fromFirestore() / toFirestore() uncomment karna hai.
// Abhi Map<String, dynamic> se kaam chalega.

// ─────────────────────────────────────────────────────────
// SUPPORTING ENUMS
// ─────────────────────────────────────────────────────────

enum MaritalStatus {
  neverMarried,
  divorced,
  widowed,
  separated,
}

extension MaritalStatusX on MaritalStatus {
  String get value {
    switch (this) {
      case MaritalStatus.neverMarried:
        return 'never_married';
      case MaritalStatus.divorced:
        return 'divorced';
      case MaritalStatus.widowed:
        return 'widowed';
      case MaritalStatus.separated:
        return 'separated';
    }
  }

  String get label {
    switch (this) {
      case MaritalStatus.neverMarried:
        return 'Never Married';
      case MaritalStatus.divorced:
        return 'Divorced';
      case MaritalStatus.widowed:
        return 'Widowed';
      case MaritalStatus.separated:
        return 'Separated';
    }
  }

  static MaritalStatus fromString(String? v) {
    switch (v) {
      case 'divorced':   return MaritalStatus.divorced;
      case 'widowed':    return MaritalStatus.widowed;
      case 'separated':  return MaritalStatus.separated;
      default:           return MaritalStatus.neverMarried;
    }
  }
}

// ─────────────────────────────────────────────────────────

enum EmploymentType {
  privateJob,
  governmentJob,
  business,
  selfEmployed,
  notWorking,
}

extension EmploymentTypeX on EmploymentType {
  String get value {
    switch (this) {
      case EmploymentType.privateJob:
        return 'private';
      case EmploymentType.governmentJob:
        return 'govt';
      case EmploymentType.business:
        return 'business';
      case EmploymentType.selfEmployed:
        return 'self_employed';
      case EmploymentType.notWorking:
        return 'not_working';
    }
  }

  String get label {
    switch (this) {
      case EmploymentType.privateJob:
        return 'Private Sector';
      case EmploymentType.governmentJob:
        return 'Government Job';
      case EmploymentType.business:
        return 'Business';
      case EmploymentType.selfEmployed:
        return 'Self Employed';
      case EmploymentType.notWorking:
        return 'Not Working';
    }
  }

  static EmploymentType fromString(String? v) {
    switch (v) {
      case 'govt':          return EmploymentType.governmentJob;
      case 'business':      return EmploymentType.business;
      case 'self_employed': return EmploymentType.selfEmployed;
      case 'not_working':   return EmploymentType.notWorking;
      default:              return EmploymentType.privateJob;
    }
  }
}

// ─────────────────────────────────────────────────────────

enum FamilyType {
  joint,
  nuclear,
  other,
}

extension FamilyTypeX on FamilyType {
  String get value {
    switch (this) {
      case FamilyType.joint:   return 'joint';
      case FamilyType.nuclear: return 'nuclear';
      case FamilyType.other:   return 'other';
    }
  }

  String get label {
    switch (this) {
      case FamilyType.joint:   return 'Joint Family';
      case FamilyType.nuclear: return 'Nuclear Family';
      case FamilyType.other:   return 'Other';
    }
  }

  static FamilyType fromString(String? v) {
    switch (v) {
      case 'nuclear': return FamilyType.nuclear;
      case 'other':   return FamilyType.other;
      default:        return FamilyType.joint;
    }
  }
}

// ─────────────────────────────────────────────────────────

enum FamilyValues {
  traditional,
  moderate,
  liberal,
}

extension FamilyValuesX on FamilyValues {
  String get value {
    switch (this) {
      case FamilyValues.traditional: return 'traditional';
      case FamilyValues.moderate:    return 'moderate';
      case FamilyValues.liberal:     return 'liberal';
    }
  }

  String get label {
    switch (this) {
      case FamilyValues.traditional: return 'Traditional';
      case FamilyValues.moderate:    return 'Moderate';
      case FamilyValues.liberal:     return 'Liberal';
    }
  }

  static FamilyValues fromString(String? v) {
    switch (v) {
      case 'moderate': return FamilyValues.moderate;
      case 'liberal':  return FamilyValues.liberal;
      default:         return FamilyValues.traditional;
    }
  }
}

// ─────────────────────────────────────────────────────────

enum ManglikStatus {
  yes,
  no,
  partial,
  dontKnow,
}

extension ManglikStatusX on ManglikStatus {
  String get value {
    switch (this) {
      case ManglikStatus.yes:       return 'yes';
      case ManglikStatus.no:        return 'no';
      case ManglikStatus.partial:   return 'partial';
      case ManglikStatus.dontKnow:  return 'dont_know';
    }
  }

  String get label {
    switch (this) {
      case ManglikStatus.yes:       return 'Manglik';
      case ManglikStatus.no:        return 'Non-Manglik';
      case ManglikStatus.partial:   return 'Partial Manglik';
      case ManglikStatus.dontKnow:  return "Don't Know";
    }
  }

  static ManglikStatus fromString(String? v) {
    switch (v) {
      case 'yes':       return ManglikStatus.yes;
      case 'partial':   return ManglikStatus.partial;
      case 'dont_know': return ManglikStatus.dontKnow;
      default:          return ManglikStatus.no;
    }
  }
}

// ─────────────────────────────────────────────────────────

enum ProfileFor {
  self,
  son,
  daughter,
  brother,
  sister,
  relative,
  friend,
}

extension ProfileForX on ProfileFor {
  String get value {
    switch (this) {
      case ProfileFor.self:     return 'self';
      case ProfileFor.son:      return 'son';
      case ProfileFor.daughter: return 'daughter';
      case ProfileFor.brother:  return 'brother';
      case ProfileFor.sister:   return 'sister';
      case ProfileFor.relative: return 'relative';
      case ProfileFor.friend:   return 'friend';
    }
  }

  String get label {
    switch (this) {
      case ProfileFor.self:     return 'Myself';
      case ProfileFor.son:      return 'My Son';
      case ProfileFor.daughter: return 'My Daughter';
      case ProfileFor.brother:  return 'My Brother';
      case ProfileFor.sister:   return 'My Sister';
      case ProfileFor.relative: return 'My Relative';
      case ProfileFor.friend:   return 'My Friend';
    }
  }

  static ProfileFor fromString(String? v) {
    switch (v) {
      case 'son':      return ProfileFor.son;
      case 'daughter': return ProfileFor.daughter;
      case 'brother':  return ProfileFor.brother;
      case 'sister':   return ProfileFor.sister;
      case 'relative': return ProfileFor.relative;
      case 'friend':   return ProfileFor.friend;
      default:         return ProfileFor.self;
    }
  }
}

// ─────────────────────────────────────────────────────────
// PARTNER PREFERENCE MODEL
// ─────────────────────────────────────────────────────────

class PartnerPreference {
  final int minAge;
  final int maxAge;
  final int? minHeightInches;
  final int? maxHeightInches;
  final List<String> religions;
  final List<String> castes;
  final List<String> cities;
  final List<String> educations;
  final String? minIncome;
  final List<MaritalStatus> maritalStatuses;
  final bool verifiedOnly;

  const PartnerPreference({
    this.minAge = 22,
    this.maxAge = 35,
    this.minHeightInches,
    this.maxHeightInches,
    this.religions = const [],
    this.castes = const [],
    this.cities = const [],
    this.educations = const [],
    this.minIncome,
    this.maritalStatuses = const [],
    this.verifiedOnly = false,
  });

  factory PartnerPreference.fromMap(
      Map<String, dynamic> data) {
    return PartnerPreference(
      minAge: data['minAge'] as int? ?? 22,
      maxAge: data['maxAge'] as int? ?? 35,
      minHeightInches:
      data['minHeightInches'] as int?,
      maxHeightInches:
      data['maxHeightInches'] as int?,
      religions: List<String>.from(
          data['religions'] ?? []),
      castes: List<String>.from(
          data['castes'] ?? []),
      cities: List<String>.from(
          data['cities'] ?? []),
      educations: List<String>.from(
          data['educations'] ?? []),
      minIncome: data['minIncome'] as String?,
      maritalStatuses:
      (data['maritalStatuses'] as List? ?? [])
          .map((s) =>
          MaritalStatusX.fromString(s))
          .toList(),
      verifiedOnly:
      data['verifiedOnly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minAge': minAge,
      'maxAge': maxAge,
      'minHeightInches': minHeightInches,
      'maxHeightInches': maxHeightInches,
      'religions': religions,
      'castes': castes,
      'cities': cities,
      'educations': educations,
      'minIncome': minIncome,
      'maritalStatuses': maritalStatuses
          .map((s) => s.value)
          .toList(),
      'verifiedOnly': verifiedOnly,
    };
  }

  PartnerPreference copyWith({
    int? minAge,
    int? maxAge,
    int? minHeightInches,
    int? maxHeightInches,
    List<String>? religions,
    List<String>? castes,
    List<String>? cities,
    List<String>? educations,
    String? minIncome,
    List<MaritalStatus>? maritalStatuses,
    bool? verifiedOnly,
  }) {
    return PartnerPreference(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      minHeightInches:
      minHeightInches ?? this.minHeightInches,
      maxHeightInches:
      maxHeightInches ?? this.maxHeightInches,
      religions: religions ?? this.religions,
      castes: castes ?? this.castes,
      cities: cities ?? this.cities,
      educations: educations ?? this.educations,
      minIncome: minIncome ?? this.minIncome,
      maritalStatuses:
      maritalStatuses ?? this.maritalStatuses,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }

  /// Display age range text
  String get ageRangeText =>
      '$minAge – $maxAge yrs';
}

// ─────────────────────────────────────────────────────────
// PROFILE MODEL
// ─────────────────────────────────────────────────────────

/// Complete profile of a user.
///
/// Firestore path: /profiles/{profileId}
class ProfileModel {
  // ── IDENTITY ──────────────────────────────────────────
  final String id;
  final String userId;
  final ProfileFor profileFor;

  // ── BASIC INFO ────────────────────────────────────────
  final String fullName;
  final DateTime dateOfBirth;
  final int heightInInches;
  final String currentCity;
  final String nativeCity;
  final String motherTongue;
  final String about;
  final MaritalStatus maritalStatus;

  // ── RELIGION ──────────────────────────────────────────
  final String religion;
  final String caste;
  final String? subCaste;
  final String? gotra;
  final ManglikStatus manglik;

  // ── EDUCATION ─────────────────────────────────────────
  final String qualification;
  final String? collegeName;
  final EmploymentType employmentType;
  final String? companyName;
  final String? designation;
  final String annualIncome;

  // ── FAMILY ────────────────────────────────────────────
  final FamilyType familyType;
  final FamilyValues familyValues;
  final String? fatherOccupation;
  final String? motherOccupation;
  final int brotherCount;
  final int sisterCount;
  final int marriedBrotherCount;
  final int marriedSisterCount;
  final String? familyCity;

  // ── HOROSCOPE ─────────────────────────────────────────
  final String? rashi;
  final String? nakshatra;
  final String? birthPlace;
  final String? kundaliUrl;

  // ── PHOTOS ────────────────────────────────────────────
  final List<String> photoUrls;
  final String? mainPhotoUrl;

  // ── PARTNER PREFERENCE ────────────────────────────────
  final PartnerPreference partnerPreference;

  // ── STATUS ────────────────────────────────────────────
  final bool isVerified;
  final bool isActive;
  final bool isPremium;
  final String? verificationDocUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    this.profileFor = ProfileFor.self,
    required this.fullName,
    required this.dateOfBirth,
    required this.heightInInches,
    required this.currentCity,
    this.nativeCity = '',
    this.motherTongue = '',
    this.about = '',
    this.maritalStatus = MaritalStatus.neverMarried,
    required this.religion,
    required this.caste,
    this.subCaste,
    this.gotra,
    this.manglik = ManglikStatus.no,
    required this.qualification,
    this.collegeName,
    this.employmentType = EmploymentType.privateJob,
    this.companyName,
    this.designation,
    this.annualIncome = '',
    this.familyType = FamilyType.joint,
    this.familyValues = FamilyValues.traditional,
    this.fatherOccupation,
    this.motherOccupation,
    this.brotherCount = 0,
    this.sisterCount = 0,
    this.marriedBrotherCount = 0,
    this.marriedSisterCount = 0,
    this.familyCity,
    this.rashi,
    this.nakshatra,
    this.birthPlace,
    this.kundaliUrl,
    this.photoUrls = const [],
    this.mainPhotoUrl,
    this.partnerPreference = const PartnerPreference(),
    this.isVerified = false,
    this.isActive = true,
    this.isPremium = false,
    this.verificationDocUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  // ── COMPUTED ──────────────────────────────────────────

  /// Current age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month &&
            now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// First name only
  String get firstName =>
      fullName.split(' ').first;

  /// Display name with age
  String get displayName => '$fullName, $age';

  /// Height in feet/inches
  String get heightText {
    final feet = heightInInches ~/ 12;
    final inches = heightInInches % 12;
    return "$feet'$inches\"";
  }

  /// Full height with cm
  String get heightFullText {
    final cm = (heightInInches * 2.54).round();
    return '$heightText ($cm cm)';
  }

  /// Primary photo URL
  String? get primaryPhoto =>
      mainPhotoUrl ??
          (photoUrls.isNotEmpty ? photoUrls.first : null);

  /// Has profile photo
  bool get hasPhoto => photoUrls.isNotEmpty;

  /// Initials for avatar
  String get initials {
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

  /// Location + caste string
  String get locationCaste =>
      '$currentCity • $caste';

  /// Profession display
  String get professionDisplay {
    if (companyName != null &&
        companyName!.isNotEmpty) {
      return '$designation • $companyName';
    }
    return designation ??
        employmentType.label;
  }

  /// Has horoscope details
  bool get hasHoroscope =>
      rashi != null ||
          nakshatra != null ||
          kundaliUrl != null;

  /// Brother info text
  String get brotherText {
    if (brotherCount == 0) return 'None';
    final married = marriedBrotherCount > 0
        ? ' ($marriedBrotherCount Married)'
        : '';
    return '$brotherCount$married';
  }

  /// Sister info text
  String get sisterText {
    if (sisterCount == 0) return 'None';
    final married = marriedSisterCount > 0
        ? ' ($marriedSisterCount Married)'
        : '';
    return '$sisterCount$married';
  }

  /// Profile completeness score (0-100)
  int get profileScore {
    int score = 0;

    // Basic info — 20 pts
    if (fullName.isNotEmpty) score += 5;
    if (currentCity.isNotEmpty) score += 5;
    if (about.isNotEmpty) score += 5;
    if (heightInInches > 0) score += 5;

    // Religion — 15 pts
    if (religion.isNotEmpty) score += 8;
    if (caste.isNotEmpty) score += 7;

    // Education — 15 pts
    if (qualification.isNotEmpty) score += 8;
    if (annualIncome.isNotEmpty) score += 7;

    // Family — 15 pts
    if (fatherOccupation != null) score += 8;
    if (motherOccupation != null) score += 7;

    // Photos — 20 pts
    if (photoUrls.isNotEmpty) score += 10;
    if (photoUrls.length >= 3) score += 5;
    if (photoUrls.length >= 5) score += 5;

    // Horoscope — 15 pts
    if (rashi != null) score += 5;
    if (nakshatra != null) score += 5;
    if (kundaliUrl != null) score += 5;

    return score.clamp(0, 100);
  }

  /// Incomplete sections with score gain
  List<Map<String, String>> get incompleteSections {
    final sections = <Map<String, String>>[];

    if (kundaliUrl == null) {
      sections.add({
        'emoji': '⭐',
        'label': 'Add Horoscope',
        'score': '+15%',
        'route': '/horoscope',
      });
    }
    if (photoUrls.length < 3) {
      sections.add({
        'emoji': '📸',
        'label': 'Add more photos',
        'score': '+7%',
        'route': '/setup/step5',
      });
    }
    if (!isVerified) {
      sections.add({
        'emoji': '🔐',
        'label': 'Verify ID',
        'score': '+10%',
        'route': '/id-verification',
      });
    }
    if (about.isEmpty) {
      sections.add({
        'emoji': '✍️',
        'label': 'Write about yourself',
        'score': '+5%',
        'route': '/setup/step1',
      });
    }
    return sections;
  }

  // ── FROM MAP ──────────────────────────────────────────

  factory ProfileModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return ProfileModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      profileFor: ProfileForX.fromString(
          data['profileFor'] as String?),

      // Basic
      fullName:
      data['fullName'] as String? ?? '',
      dateOfBirth:
      _parseDateTime(data['dateOfBirth']) ??
          DateTime(2000),
      heightInInches:
      data['heightInInches'] as int? ?? 0,
      currentCity:
      data['currentCity'] as String? ?? '',
      nativeCity:
      data['nativeCity'] as String? ?? '',
      motherTongue:
      data['motherTongue'] as String? ?? '',
      about: data['about'] as String? ?? '',
      maritalStatus: MaritalStatusX.fromString(
          data['maritalStatus'] as String?),

      // Religion
      religion:
      data['religion'] as String? ?? '',
      caste: data['caste'] as String? ?? '',
      subCaste: data['subCaste'] as String?,
      gotra: data['gotra'] as String?,
      manglik: ManglikStatusX.fromString(
          data['manglik'] as String?),

      // Education
      qualification:
      data['qualification'] as String? ?? '',
      collegeName:
      data['collegeName'] as String?,
      employmentType: EmploymentTypeX.fromString(
          data['employmentType'] as String?),
      companyName:
      data['companyName'] as String?,
      designation:
      data['designation'] as String?,
      annualIncome:
      data['annualIncome'] as String? ?? '',

      // Family
      familyType: FamilyTypeX.fromString(
          data['familyType'] as String?),
      familyValues: FamilyValuesX.fromString(
          data['familyValues'] as String?),
      fatherOccupation:
      data['fatherOccupation'] as String?,
      motherOccupation:
      data['motherOccupation'] as String?,
      brotherCount:
      data['brotherCount'] as int? ?? 0,
      sisterCount:
      data['sisterCount'] as int? ?? 0,
      marriedBrotherCount:
      data['marriedBrotherCount'] as int? ??
          0,
      marriedSisterCount:
      data['marriedSisterCount'] as int? ??
          0,
      familyCity: data['familyCity'] as String?,

      // Horoscope
      rashi: data['rashi'] as String?,
      nakshatra: data['nakshatra'] as String?,
      birthPlace: data['birthPlace'] as String?,
      kundaliUrl: data['kundaliUrl'] as String?,

      // Photos
      photoUrls: List<String>.from(
          data['photoUrls'] ?? []),
      mainPhotoUrl:
      data['mainPhotoUrl'] as String?,

      // Partner Preference
      partnerPreference: data['partnerPreference'] != null
          ? PartnerPreference.fromMap(
          Map<String, dynamic>.from(
              data['partnerPreference']))
          : const PartnerPreference(),

      // Status
      isVerified:
      data['isVerified'] as bool? ?? false,
      isActive:
      data['isActive'] as bool? ?? true,
      isPremium:
      data['isPremium'] as bool? ?? false,
      verificationDocUrl:
      data['verificationDocUrl'] as String?,
      createdAt:
      _parseDateTime(data['createdAt']) ??
          DateTime.now(),
      updatedAt:
      _parseDateTime(data['updatedAt']) ??
          DateTime.now(),
      lastActiveAt:
      _parseDateTime(data['lastActiveAt']),
    );
  }

  // ── TO MAP ────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'profileFor': profileFor.value,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'heightInInches': heightInInches,
      'currentCity': currentCity,
      'nativeCity': nativeCity,
      'motherTongue': motherTongue,
      'about': about,
      'maritalStatus': maritalStatus.value,
      'religion': religion,
      'caste': caste,
      'subCaste': subCaste,
      'gotra': gotra,
      'manglik': manglik.value,
      'qualification': qualification,
      'collegeName': collegeName,
      'employmentType': employmentType.value,
      'companyName': companyName,
      'designation': designation,
      'annualIncome': annualIncome,
      'familyType': familyType.value,
      'familyValues': familyValues.value,
      'fatherOccupation': fatherOccupation,
      'motherOccupation': motherOccupation,
      'brotherCount': brotherCount,
      'sisterCount': sisterCount,
      'marriedBrotherCount': marriedBrotherCount,
      'marriedSisterCount': marriedSisterCount,
      'familyCity': familyCity,
      'rashi': rashi,
      'nakshatra': nakshatra,
      'birthPlace': birthPlace,
      'kundaliUrl': kundaliUrl,
      'photoUrls': photoUrls,
      'mainPhotoUrl': mainPhotoUrl,
      'partnerPreference':
      partnerPreference.toMap(),
      'isVerified': isVerified,
      'isActive': isActive,
      'isPremium': isPremium,
      'verificationDocUrl': verificationDocUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastActiveAt':
      lastActiveAt?.toIso8601String(),
    };
  }

  // ── COPY WITH ─────────────────────────────────────────

  ProfileModel copyWith({
    String? id,
    String? userId,
    ProfileFor? profileFor,
    String? fullName,
    DateTime? dateOfBirth,
    int? heightInInches,
    String? currentCity,
    String? nativeCity,
    String? motherTongue,
    String? about,
    MaritalStatus? maritalStatus,
    String? religion,
    String? caste,
    String? subCaste,
    String? gotra,
    ManglikStatus? manglik,
    String? qualification,
    String? collegeName,
    EmploymentType? employmentType,
    String? companyName,
    String? designation,
    String? annualIncome,
    FamilyType? familyType,
    FamilyValues? familyValues,
    String? fatherOccupation,
    String? motherOccupation,
    int? brotherCount,
    int? sisterCount,
    int? marriedBrotherCount,
    int? marriedSisterCount,
    String? familyCity,
    String? rashi,
    String? nakshatra,
    String? birthPlace,
    String? kundaliUrl,
    List<String>? photoUrls,
    String? mainPhotoUrl,
    PartnerPreference? partnerPreference,
    bool? isVerified,
    bool? isActive,
    bool? isPremium,
    String? verificationDocUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileFor: profileFor ?? this.profileFor,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightInInches:
      heightInInches ?? this.heightInInches,
      currentCity: currentCity ?? this.currentCity,
      nativeCity: nativeCity ?? this.nativeCity,
      motherTongue:
      motherTongue ?? this.motherTongue,
      about: about ?? this.about,
      maritalStatus:
      maritalStatus ?? this.maritalStatus,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      subCaste: subCaste ?? this.subCaste,
      gotra: gotra ?? this.gotra,
      manglik: manglik ?? this.manglik,
      qualification:
      qualification ?? this.qualification,
      collegeName: collegeName ?? this.collegeName,
      employmentType:
      employmentType ?? this.employmentType,
      companyName: companyName ?? this.companyName,
      designation: designation ?? this.designation,
      annualIncome:
      annualIncome ?? this.annualIncome,
      familyType: familyType ?? this.familyType,
      familyValues:
      familyValues ?? this.familyValues,
      fatherOccupation:
      fatherOccupation ?? this.fatherOccupation,
      motherOccupation:
      motherOccupation ?? this.motherOccupation,
      brotherCount:
      brotherCount ?? this.brotherCount,
      sisterCount: sisterCount ?? this.sisterCount,
      marriedBrotherCount: marriedBrotherCount ??
          this.marriedBrotherCount,
      marriedSisterCount: marriedSisterCount ??
          this.marriedSisterCount,
      familyCity: familyCity ?? this.familyCity,
      rashi: rashi ?? this.rashi,
      nakshatra: nakshatra ?? this.nakshatra,
      birthPlace: birthPlace ?? this.birthPlace,
      kundaliUrl: kundaliUrl ?? this.kundaliUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      mainPhotoUrl:
      mainPhotoUrl ?? this.mainPhotoUrl,
      partnerPreference:
      partnerPreference ?? this.partnerPreference,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      verificationDocUrl: verificationDocUrl ??
          this.verificationDocUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt:
      lastActiveAt ?? this.lastActiveAt,
    );
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // ── EQUALITY ──────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is ProfileModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProfileModel(id: $id, '
          'name: $fullName, '
          'age: $age, '
          'city: $currentCity)';
}

// ─────────────────────────────────────────────────────────
// PHASE 3 — FIREBASE INTEGRATION
// Uncomment when cloud_firestore is added to pubspec.yaml
// ─────────────────────────────────────────────────────────
/*
import 'package:cloud_firestore/cloud_firestore.dart';

extension ProfileModelFirestore on ProfileModel {
  static ProfileModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ProfileModel.fromMap(doc.id, {
      ...data,
      'dateOfBirth':
          (data['dateOfBirth'] as Timestamp?)
              ?.toDate(),
      'createdAt':
          (data['createdAt'] as Timestamp?)
              ?.toDate(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)
              ?.toDate(),
      'lastActiveAt':
          (data['lastActiveAt'] as Timestamp?)
              ?.toDate(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    return {
      ...map,
      'dateOfBirth':
          Timestamp.fromDate(dateOfBirth),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActiveAt': lastActiveAt != null
          ? Timestamp.fromDate(lastActiveAt!)
          : null,
    };
  }
}
*/