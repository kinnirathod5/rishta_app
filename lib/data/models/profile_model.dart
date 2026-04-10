// lib/data/models/profile_model.dart
// Complete matrimony profile model

class ProfileModel {
  final String id;
  final String userId;

  // ── BASIC INFO ──────────────────────────────────────
  final String fullName;
  final DateTime dateOfBirth;
  final String gender; // 'male' | 'female'
  final int heightInInches;
  final String currentCity;
  final String motherTongue;
  final String maritalStatus; // 'never_married' | 'divorced' | 'widowed'
  final String about;
  final String profileFor; // 'self' | 'parent'

  // ── RELIGION ────────────────────────────────────────
  final String religion;
  final String caste;
  final String? subCaste;
  final String? gotra;
  final String manglik; // 'yes' | 'no' | 'partial'
  final String? nakshatra;
  final String? rashi;

  // ── EDUCATION ───────────────────────────────────────
  final String qualification;
  final String? college;
  final String employmentType; // 'govt' | 'private' | 'business' | 'not_working'
  final String? company;
  final String? designation;
  final String annualIncome;
  final String? workingCity;
  final bool isNri;
  final String? nriCountry;

  // ── FAMILY ──────────────────────────────────────────
  final String familyType; // 'joint' | 'nuclear' | 'other'
  final String familyValues; // 'traditional' | 'moderate' | 'liberal'
  final String familyStatus; // 'middle' | 'upper_middle' | 'rich'
  final String? fatherOccupation;
  final String? motherOccupation;
  final int brothers;
  final int sisters;
  final String? familyCity;

  // ── PHOTOS ──────────────────────────────────────────
  final List<String> photoUrls; // Firebase Storage URLs
  final String? mainPhotoUrl;

  // ── PARTNER PREFERENCE ──────────────────────────────
  final int minAge;
  final int maxAge;
  final int minHeightInInches;
  final int maxHeightInInches;
  final List<String> preferredReligions;
  final List<String> preferredCastes;
  final String minEducation;
  final String minIncome;
  final bool anyCity;
  final List<String> preferredCities;
  final String manglikPreference; // 'yes' | 'no' | 'any'
  final List<String> preferredMaritalStatus;
  final String? aboutPartner;

  // ── HOROSCOPE ───────────────────────────────────────
  final String? birthTime;
  final String? birthPlace;
  final String? kundaliUrl;

  // ── VERIFICATION ────────────────────────────────────
  final bool isVerified;
  final String? verificationStatus; // 'pending' | 'approved' | 'rejected'

  // ── STATUS ──────────────────────────────────────────
  final bool isActive;
  final bool isHidden;
  final int profileScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOnlineAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.heightInInches,
    required this.currentCity,
    required this.motherTongue,
    required this.maritalStatus,
    this.about = '',
    required this.profileFor,
    required this.religion,
    required this.caste,
    this.subCaste,
    this.gotra,
    this.manglik = 'no',
    this.nakshatra,
    this.rashi,
    required this.qualification,
    this.college,
    required this.employmentType,
    this.company,
    this.designation,
    required this.annualIncome,
    this.workingCity,
    this.isNri = false,
    this.nriCountry,
    required this.familyType,
    required this.familyValues,
    required this.familyStatus,
    this.fatherOccupation,
    this.motherOccupation,
    this.brothers = 0,
    this.sisters = 0,
    this.familyCity,
    this.photoUrls = const [],
    this.mainPhotoUrl,
    this.minAge = 22,
    this.maxAge = 35,
    this.minHeightInInches = 60,
    this.maxHeightInInches = 78,
    this.preferredReligions = const [],
    this.preferredCastes = const [],
    this.minEducation = 'Graduate',
    this.minIncome = 'Koi bhi',
    this.anyCity = true,
    this.preferredCities = const [],
    this.manglikPreference = 'any',
    this.preferredMaritalStatus = const ['never_married'],
    this.aboutPartner,
    this.birthTime,
    this.birthPlace,
    this.kundaliUrl,
    this.isVerified = false,
    this.verificationStatus,
    this.isActive = true,
    this.isHidden = false,
    this.profileScore = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastOnlineAt,
  });

  // ── FROM FIRESTORE ──────────────────────────────────
  factory ProfileModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return ProfileModel(
      id: id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.parse(data['dateOfBirth'])
          : DateTime.now(),
      gender: data['gender'] ?? 'male',
      heightInInches: data['heightInInches'] ?? 65,
      currentCity: data['currentCity'] ?? '',
      motherTongue: data['motherTongue'] ?? '',
      maritalStatus: data['maritalStatus'] ?? 'never_married',
      about: data['about'] ?? '',
      profileFor: data['profileFor'] ?? 'self',
      religion: data['religion'] ?? '',
      caste: data['caste'] ?? '',
      subCaste: data['subCaste'],
      gotra: data['gotra'],
      manglik: data['manglik'] ?? 'no',
      nakshatra: data['nakshatra'],
      rashi: data['rashi'],
      qualification: data['qualification'] ?? '',
      college: data['college'],
      employmentType: data['employmentType'] ?? 'private',
      company: data['company'],
      designation: data['designation'],
      annualIncome: data['annualIncome'] ?? '',
      workingCity: data['workingCity'],
      isNri: data['isNri'] ?? false,
      nriCountry: data['nriCountry'],
      familyType: data['familyType'] ?? 'joint',
      familyValues: data['familyValues'] ?? 'moderate',
      familyStatus: data['familyStatus'] ?? 'middle',
      fatherOccupation: data['fatherOccupation'],
      motherOccupation: data['motherOccupation'],
      brothers: data['brothers'] ?? 0,
      sisters: data['sisters'] ?? 0,
      familyCity: data['familyCity'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      mainPhotoUrl: data['mainPhotoUrl'],
      minAge: data['minAge'] ?? 22,
      maxAge: data['maxAge'] ?? 35,
      minHeightInInches: data['minHeightInInches'] ?? 60,
      maxHeightInInches: data['maxHeightInInches'] ?? 78,
      preferredReligions:
      List<String>.from(data['preferredReligions'] ?? []),
      preferredCastes:
      List<String>.from(data['preferredCastes'] ?? []),
      minEducation: data['minEducation'] ?? 'Graduate',
      minIncome: data['minIncome'] ?? 'Koi bhi',
      anyCity: data['anyCity'] ?? true,
      preferredCities:
      List<String>.from(data['preferredCities'] ?? []),
      manglikPreference: data['manglikPreference'] ?? 'any',
      preferredMaritalStatus: List<String>.from(
          data['preferredMaritalStatus'] ?? ['never_married']),
      aboutPartner: data['aboutPartner'],
      birthTime: data['birthTime'],
      birthPlace: data['birthPlace'],
      kundaliUrl: data['kundaliUrl'],
      isVerified: data['isVerified'] ?? false,
      verificationStatus: data['verificationStatus'],
      isActive: data['isActive'] ?? true,
      isHidden: data['isHidden'] ?? false,
      profileScore: data['profileScore'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
      lastOnlineAt: data['lastOnlineAt'] != null
          ? DateTime.parse(data['lastOnlineAt'])
          : null,
    );
  }

  // ── TO FIRESTORE ────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'heightInInches': heightInInches,
      'currentCity': currentCity,
      'motherTongue': motherTongue,
      'maritalStatus': maritalStatus,
      'about': about,
      'profileFor': profileFor,
      'religion': religion,
      'caste': caste,
      'subCaste': subCaste,
      'gotra': gotra,
      'manglik': manglik,
      'nakshatra': nakshatra,
      'rashi': rashi,
      'qualification': qualification,
      'college': college,
      'employmentType': employmentType,
      'company': company,
      'designation': designation,
      'annualIncome': annualIncome,
      'workingCity': workingCity,
      'isNri': isNri,
      'nriCountry': nriCountry,
      'familyType': familyType,
      'familyValues': familyValues,
      'familyStatus': familyStatus,
      'fatherOccupation': fatherOccupation,
      'motherOccupation': motherOccupation,
      'brothers': brothers,
      'sisters': sisters,
      'familyCity': familyCity,
      'photoUrls': photoUrls,
      'mainPhotoUrl': mainPhotoUrl,
      'minAge': minAge,
      'maxAge': maxAge,
      'minHeightInInches': minHeightInInches,
      'maxHeightInInches': maxHeightInInches,
      'preferredReligions': preferredReligions,
      'preferredCastes': preferredCastes,
      'minEducation': minEducation,
      'minIncome': minIncome,
      'anyCity': anyCity,
      'preferredCities': preferredCities,
      'manglikPreference': manglikPreference,
      'preferredMaritalStatus': preferredMaritalStatus,
      'aboutPartner': aboutPartner,
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'kundaliUrl': kundaliUrl,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'isActive': isActive,
      'isHidden': isHidden,
      'profileScore': profileScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastOnlineAt': lastOnlineAt?.toIso8601String(),
    };
  }

  // ── COPY WITH ───────────────────────────────────────
  ProfileModel copyWith({
    String? fullName,
    String? about,
    List<String>? photoUrls,
    String? mainPhotoUrl,
    bool? isVerified,
    String? verificationStatus,
    bool? isActive,
    bool? isHidden,
    int? profileScore,
    DateTime? updatedAt,
    DateTime? lastOnlineAt,
  }) {
    return ProfileModel(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      heightInInches: heightInInches,
      currentCity: currentCity,
      motherTongue: motherTongue,
      maritalStatus: maritalStatus,
      about: about ?? this.about,
      profileFor: profileFor,
      religion: religion,
      caste: caste,
      subCaste: subCaste,
      gotra: gotra,
      manglik: manglik,
      nakshatra: nakshatra,
      rashi: rashi,
      qualification: qualification,
      college: college,
      employmentType: employmentType,
      company: company,
      designation: designation,
      annualIncome: annualIncome,
      workingCity: workingCity,
      isNri: isNri,
      nriCountry: nriCountry,
      familyType: familyType,
      familyValues: familyValues,
      familyStatus: familyStatus,
      fatherOccupation: fatherOccupation,
      motherOccupation: motherOccupation,
      brothers: brothers,
      sisters: sisters,
      familyCity: familyCity,
      photoUrls: photoUrls ?? this.photoUrls,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      minAge: minAge,
      maxAge: maxAge,
      minHeightInInches: minHeightInInches,
      maxHeightInInches: maxHeightInInches,
      preferredReligions: preferredReligions,
      preferredCastes: preferredCastes,
      minEducation: minEducation,
      minIncome: minIncome,
      anyCity: anyCity,
      preferredCities: preferredCities,
      manglikPreference: manglikPreference,
      preferredMaritalStatus: preferredMaritalStatus,
      aboutPartner: aboutPartner,
      birthTime: birthTime,
      birthPlace: birthPlace,
      kundaliUrl: kundaliUrl,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus:
      verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      isHidden: isHidden ?? this.isHidden,
      profileScore: profileScore ?? this.profileScore,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
    );
  }

  // ── HELPERS ─────────────────────────────────────────
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

  String get heightText {
    final feet = heightInInches ~/ 12;
    final inches = heightInInches % 12;
    return "$feet'$inches\"";
  }

  String get firstPhotoUrl =>
      mainPhotoUrl ?? (photoUrls.isNotEmpty ? photoUrls.first : '');

  bool get hasPhotos => photoUrls.isNotEmpty;

  @override
  String toString() =>
      'ProfileModel(id: $id, name: $fullName, age: $age)';
}