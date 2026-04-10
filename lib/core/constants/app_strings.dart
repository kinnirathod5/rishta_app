class AppStrings {
  AppStrings._();

  // ── APP ───────────────────────────────────────────────
  static const String appName = 'RishtaApp';
  static const String appTagline = 'Apna Rishta, Apni Pasand';
  static const String appVersion = 'v1.0.0';

  // ── ONBOARDING SLIDES ─────────────────────────────────
  static const String slide1Title = 'Lakho Rishte';
  static const String slide1Subtitle =
      'Apni community mein apna perfect\nlife partner dhundho — bilkul free';
  static const String slide2Title = 'Apni Community Mein';
  static const String slide2Subtitle =
      'Religion, caste aur gotra ke hisaab se\nfilter karke best match pao';
  static const String slide3Title = 'Safe & Verified';
  static const String slide3Subtitle =
      'Har profile verify hoti hai\nAapki privacy hamari zimmedari hai';

  // ── BUTTONS ───────────────────────────────────────────
  static const String btnNext = 'Aage';
  static const String btnGetStarted = 'Shuru Karein 🎉';
  static const String btnSkip = 'Skip';
  static const String btnContinue = 'Aage Badho';
  static const String btnSendOtp = 'OTP Bhejo';
  static const String btnVerify = 'Verify Karo';
  static const String btnResendOtp = 'OTP Dobara Bhejo';
  static const String btnGoogleLogin = 'Google se Login';
  static const String btnCreateProfile = 'Profile Banao ✓';
  static const String btnSave = 'Save Karo';
  static const String btnEdit = 'Edit Karo';

  // ── AUTH ──────────────────────────────────────────────
  static const String phoneTitle = 'Apna Number Daalo';
  static const String phoneSubtitle = 'OTP bheja jayega verify karne ke liye';
  static const String phoneHint = 'Mobile Number';
  static const String phoneAlreadyAccount = 'Pehle se account hai? ';
  static const String phoneLoginLink = 'Login Karo';

  static const String otpTitle = 'Verify Karo';
  static const String otpSubtitle = 'OTP bheja gaya';
  static const String otpResendPrefix = 'OTP nahi aaya? ';
  static const String otpResendLink = 'Dobara Bhejo';
  static const String otpChangeNumber = 'Number change karo';
  static const String otpTimerPrefix = 'Resend (';
  static const String otpTimerSuffix = 's)';

  // ── EXPLORE FIRST ─────────────────────────────────────
  static const String exploreTitle = 'Kaise Shuru Karein?';
  static const String guestCardTitle = 'Pehle Browse Karo';
  static const String guestCardSubtitle = 'Bina account ke profiles dekhein';
  static const String registerCardTitle = 'Account Banao';
  static const String registerCardSubtitle = 'Full access — bilkul free';
  static const String recommendedBadge = '⭐ RECOMMENDED';
  static const String guestFeature1 = '🔒 Photos blurred';
  static const String guestFeature2 = '🔒 Contact hidden';
  static const String guestFeature3 = '🔒 No chat';
  static const String registerFeature1 = '✓ Photos dekhein';
  static const String registerFeature2 = '✓ Interest bhejein';
  static const String registerFeature3 = '✓ Chat karein';

  // ── PROFILE TYPE ──────────────────────────────────────
  static const String profileTypeTitle = 'Profile Kiske Liye Hai?';
  static const String selfCardTitle = 'Apne Liye';
  static const String selfCardSubtitle =
      'Main khud life partner dhundh raha/rahi hoon';
  static const String parentCardTitle = 'Bete / Beti Ke Liye';
  static const String parentCardSubtitle =
      'Main apne bachche ke liye rishta dhundh raha hoon';
  static const String genderLabel = 'Candidate ka gender:';
  static const String genderMale = '👨 Male';
  static const String genderFemale = '👩 Female';

  // ── PROFILE SETUP ─────────────────────────────────────
  static const String step1Title = 'Basic Info';
  static const String step2Title = 'Religion & Caste';
  static const String step3Title = 'Education & Career';
  static const String step4Title = 'Family Info';
  static const String step5Title = 'Photos Add Karo';

  // Step 1 fields
  static const String fullName = 'Poora Naam';
  static const String dob = 'Janam Tithi';
  static const String height = 'Lambai (Height)';
  static const String currentCity = 'Abhi Kahan Rehte Ho';
  static const String motherTongue = 'Matrubhasha';
  static const String aboutMe = 'Apne Baare Mein';
  static const String aboutMeHint =
      'Thoda apne baare mein likho... (max 300 akshar)';

  // Step 2 fields
  static const String religion = 'Dharm (Religion)';
  static const String caste = 'Jaati (Caste)';
  static const String subCaste = 'Upjaati (Sub-caste)';
  static const String gotra = 'Gotra';
  static const String manglik = 'Manglik';
  static const String manglikYes = 'Haan';
  static const String manglikNo = 'Nahi';
  static const String manglikPartial = 'Anshik';

  // Step 3 fields
  static const String qualification = 'Shiksha (Qualification)';
  static const String college = 'College / University';
  static const String employmentType = 'Naukri ka Prakar';
  static const String company = 'Company / Kahan Kaam';
  static const String income = 'Saalana Aay (Income)';
  static const String nri = 'Kya aap NRI hain?';

  // Step 4 fields
  static const String familyType = 'Parivar ka Prakar';
  static const String familyValues = 'Parivar ki Soch';
  static const String fatherOccupation = 'Pita ka Kaam';
  static const String motherOccupation = 'Mata ka Kaam';
  static const String brothers = 'Bhai (Brothers)';
  static const String sisters = 'Behen (Sisters)';

  // Step 5
  static const String photoMainBadge = '⭐ Main';
  static const String photoAddHint = 'Tap karo photo add karne ke liye';
  static const String photoGallery = 'Gallery se';
  static const String photoCamera = 'Camera se';
  static const String photoMinRequired = 'Kam se kam 1 photo zaroori hai';

  // ── VALIDATION ERRORS ─────────────────────────────────
  static const String errorRequired = 'Yeh field zaroori hai';
  static const String errorPhoneInvalid =
      'Sahi mobile number daalo (10 digits)';
  static const String errorPhoneShort = '10 digit ka number chahiye';
  static const String errorOtpInvalid = 'Galat OTP, dobara try karo';
  static const String errorOtpExpired =
      'OTP expire ho gaya, dobara bhejo';
  static const String errorNameInvalid =
      'Sirf alphabets aur spaces allowed hain';
  static const String errorAgeInvalid = 'Umar 18 saal se zyada honi chahiye';
  static const String errorAboutMaxLength =
      'Maximum 300 akshar hi likh sakte ho';

  // ── SNACKBAR MESSAGES ─────────────────────────────────
  static const String otpSent = 'OTP bhej diya gaya ✓';
  static const String otpResent = 'OTP dobara bhej diya ✓';
  static const String profileSaved = 'Profile save ho gayi ✓';
  static const String noInternet =
      'Internet nahi hai, connection check karo';
  static const String somethingWentWrong =
      'Kuch gadbad ho gayi, dobara try karo';

  // ── HOME ──────────────────────────────────────────────
  static const String homeGreeting = 'Namaste';
  static const String homeTodayMatches = "Aaj ke Matches";
  static const String homeRecentlyJoined = 'Naaye Members';
  static const String homeNearMe = 'Aas Paas';
  static const String homeFeatured = 'Featured Profiles';
  static const String homeNewInterests = 'Naye Interests';
  static const String homeProfileViews = 'Profile Views';

  // ── BOTTOM NAV ────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navSearch = 'Search';
  static const String navInterests = 'Interests';
  static const String navChat = 'Chat';
  static const String navProfile = 'Profile';

  // ── INTERESTS ─────────────────────────────────────────
  static const String interestsSent = 'Bheje';
  static const String interestsReceived = 'Aaye';
  static const String interestsConnected = 'Connected';
  static const String btnAccept = '✓ Accept';
  static const String btnDecline = '✕ Decline';

  // ── PREMIUM ───────────────────────────────────────────
  static const String premiumTitle = 'Premium Baniye 👑';
  static const String premiumSubtitle =
      'Rishta dhundhna aur aasaan karo';
  static const String silverPlan = 'Silver';
  static const String goldPlan = 'Gold';
  static const String platinumPlan = 'Platinum';
  static const String mostPopular = '⭐ MOST POPULAR';

  // ── EMPTY STATES ──────────────────────────────────────
  static const String emptyMatches =
      'Abhi koi match nahi mila\nFilters thoda relax karo';
  static const String emptyInterests =
      'Abhi koi interest nahi aaya\nProfile complete karo';
  static const String emptyChats =
      'Abhi koi chat nahi hai\nPehle interest bhejo';
  static const String emptyNotifications = 'Abhi koi notification nahi';
}