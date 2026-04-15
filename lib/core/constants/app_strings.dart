// lib/core/constants/app_strings.dart

/// All user-facing strings for RishtaApp.
/// English only — no Hinglish.
/// Use these constants instead of hardcoded strings.
abstract class AppStrings {
  AppStrings._();

  // ── APP ──────────────────────────────────────────────
  static const String appName        = 'RishtaApp';
  static const String appTagline     = 'Find Your Perfect Match';
  static const String appVersion     = 'v1.0.0';

  // ── ONBOARDING ───────────────────────────────────────
  static const String slide1Title    = 'Millions of Profiles';
  static const String slide1Sub      = 'Find your perfect life partner\nwithin your community — completely free';
  static const String slide2Title    = 'Your Community';
  static const String slide2Sub      = 'Filter by religion, caste and gotra\nto find your best match';
  static const String slide3Title    = 'Safe & Verified';
  static const String slide3Sub      = 'Every profile is verified\nYour privacy is our responsibility';
  static const String skip           = 'Skip';
  static const String next           = 'Next';
  static const String getStarted     = 'Get Started 🎉';
  static const String alreadyAccount = 'Already have an account?';
  static const String login          = 'Login';

  // ── AUTH ─────────────────────────────────────────────
  static const String enterPhone     = 'Enter Your\nPhone Number';
  static const String otpWillBeSent  = 'We\'ll send an OTP to verify your number';
  static const String mobileNumber   = 'Mobile Number';
  static const String phonePlaceholder = '98765 43210';
  static const String sendOtp        = 'Send OTP';
  static const String sendingOtp     = 'Sending OTP...';
  static const String continueGoogle = 'Continue with Google';
  static const String orDivider      = 'OR';
  static const String termsPrefix    = 'By continuing, you agree to our ';
  static const String termsLink      = 'Terms & Conditions';
  static const String andText        = ' and ';
  static const String privacyLink    = 'Privacy Policy';

  static const String verifyNumber   = 'Verify Your Number';
  static const String otpSentTo      = 'OTP sent to';
  static const String changeNumber   = 'Change number?';
  static const String enterOtp       = 'Enter 6-digit OTP';
  static const String verify         = 'Verify';
  static const String verifying      = 'Verifying...';
  static const String didntReceive   = "Didn't receive OTP? Resend in (";
  static const String resendOtp      = 'Resend OTP';
  static const String secureOtp      = 'Secure OTP — expires in 10 minutes';
  static const String invalidOtp     = 'Invalid OTP. Please try again.';

  // ── EXPLORE FIRST ────────────────────────────────────
  static const String howToStart     = 'How Would You Like to Start?';
  static const String chooseBestOption = 'Choose the option that suits you best';
  static const String browseFirst    = 'Browse First';
  static const String browseFirstSub = 'Explore profiles without an account';
  static const String createAccount  = 'Create Account';
  static const String createAccountSub = 'Full access — completely free';
  static const String recommended    = '⭐ RECOMMENDED';
  static const String photosBlurred  = '🔒 Photos blurred';
  static const String contactHidden  = '🔒 Contact hidden';
  static const String chatDisabled   = '🔒 Chat disabled';
  static const String viewPhotos     = '✓ View photos';
  static const String sendInterests  = '✓ Send interests';
  static const String chatDirectly   = '✓ Chat directly';
  static const String continueBtn    = 'Continue';

  // ── PROFILE TYPE ─────────────────────────────────────
  static const String profileForWho  = 'Who Is This Profile For?';
  static const String rightChoiceBetter = 'Choosing correctly helps us find better matches';
  static const String forMyself      = 'For Myself';
  static const String forMyselfSub   = 'I am looking for my own life partner';
  static const String ageRange       = 'Age 18–35 • Modern approach';
  static const String forMyChild     = 'For My Son / Daughter';
  static const String forMyChildSub  = 'I am looking for a match for my child';
  static const String familyOriented = 'Family-oriented • Traditional values';
  static const String candidateGender = 'Candidate\'s Gender';
  static const String male           = 'Male';
  static const String female         = 'Female';
  static const String canChangeInSettings = 'You can change this later in Settings';

  // ── PROFILE SETUP ────────────────────────────────────
  static const String stepOf5        = 'Step {n} of 5';
  static const String basicInfo      = 'Basic Info';
  static const String basicInfoSub   = 'Tell us about yourself';
  static const String fullName       = 'Full Name';
  static const String fullNameHint   = 'e.g. Priya Sharma';
  static const String dateOfBirth    = 'Date of Birth';
  static const String dobHint        = 'DD / MM / YYYY';
  static const String height         = 'Height';
  static const String heightHint     = 'Select your height';
  static const String currentCity    = 'Current City';
  static const String cityHint       = 'e.g. Delhi, Mumbai, Bangalore';
  static const String motherTongue   = 'Mother Tongue';
  static const String motherTongueHint = 'Select your language';
  static const String aboutMe        = 'About Me';
  static const String aboutMeHint    = 'Tell something about yourself — hobbies, values, interests...';
  static const String optional       = '(Optional)';
  static const String maxChars       = 'max 300 characters';
  static const String continueSetup  = 'Continue';

  // ── BUTTONS / ACTIONS ────────────────────────────────
  static const String save           = 'Save';
  static const String saving         = 'Saving...';
  static const String submit         = 'Submit';
  static const String submitting     = 'Submitting...';
  static const String cancel         = 'Cancel';
  static const String confirm        = 'Confirm';
  static const String delete         = 'Delete';
  static const String remove         = 'Remove';
  static const String close          = 'Close';
  static const String back           = 'Back';
  static const String done           = 'Done';
  static const String edit           = 'Edit';
  static const String view           = 'View';
  static const String viewAll        = 'View All →';
  static const String viewProfile    = 'View Profile';
  static const String sendInterest   = 'Send Interest';
  static const String interestSent   = 'Sent ✓';
  static const String accept         = 'Accept';
  static const String decline        = 'Decline';
  static const String block          = 'Block';
  static const String report         = 'Report';
  static const String unblock        = 'Unblock';
  static const String withdraw       = 'Withdraw';
  static const String maybeLater     = 'Maybe Later';

  // ── HOME ─────────────────────────────────────────────
  static const String hello          = 'Hello,';
  static const String todayMatches   = "Today's Matches";
  static const String newMembers     = 'New Members';
  static const String featuredProfiles = 'Featured Profiles';
  static const String newMatchesCount = 'new matches today';
  static const String profileComplete = '% Complete';
  static const String newInterests   = 'New Interests';
  static const String profileViews   = 'Profile Views';
  static const String connected      = 'Connected';
  static const String premiumMembers = 'Premium Members';
  static const String premiumSubtext = 'Verified and premium profiles just for you';
  static const String viewNow        = 'View Now →';

  // ── PROFILE ──────────────────────────────────────────
  static const String myProfile      = 'My Profile';
  static const String profileScore   = 'Profile Score';
  static const String profileComplete2 = 'Complete';
  static const String editProfile    = 'Edit Profile';
  static const String preview        = 'Preview';
  static const String autoSaved      = 'Auto Saved ✓';
  static const String addHoroscope   = 'Add Horoscope';
  static const String addPhotos      = 'Add more photos';
  static const String verified       = 'Verified';
  static const String premium        = 'Premium';

  // ── INTERESTS ────────────────────────────────────────
  static const String interests      = 'Interests';
  static const String received       = 'Received';
  static const String sent           = 'Sent';
  static const String connections    = 'Connected';
  static const String pendingCount   = 'Pending';
  static const String accepted       = 'Accepted';
  static const String declined       = 'Declined';
  static const String waitingForReply = 'Awaiting Reply';

  // ── CHAT ─────────────────────────────────────────────
  static const String messages       = 'Messages';
  static const String yourConversations = 'Your conversations';
  static const String typeMessage    = 'Type a message...';
  static const String send           = 'Send';
  static const String online         = 'Online';
  static const String delivered      = 'Delivered';
  static const String read           = 'Read';
  static const String messageDeleted = 'This message was deleted';
  static const String noChats        = 'No Conversations Yet';
  static const String noChatsSubtext = 'Connect with profiles and start chatting';

  // ── NOTIFICATIONS ────────────────────────────────────
  static const String notifications  = 'Notifications';
  static const String markAllRead    = 'Mark All Read ✓';
  static const String noNotifications = 'No Notifications Yet';
  static const String activitiesHere = 'Your matches and activities will appear here';
  static const String today          = 'Today';
  static const String yesterday      = 'Yesterday';
  static const String thisWeek       = 'This Week';
  static const String earlier        = 'Earlier';

  // ── SETTINGS ─────────────────────────────────────────
  static const String settings       = 'Settings';
  static const String notificationSettings = 'Notifications';
  static const String privacySettings = 'Privacy Settings';
  static const String premiumPlans   = 'Premium Plans';
  static const String helpSupport    = 'Help & Support';
  static const String aboutApp       = 'About App';
  static const String logout         = 'Logout';
  static const String deactivate     = 'Deactivate Account';
  static const String deleteAccount  = 'Delete Account';
  static const String manageAlerts   = 'Manage your alerts';
  static const String whoCanSee      = 'Control who can see your profile';
  static const String unlockFeatures = 'Unlock all features';
  static const String faqContact     = 'FAQ and contact us';
  static const String versionInfo    = 'Version 1.0.0';

  // ── ERRORS ───────────────────────────────────────────
  static const String required       = 'This field is required';
  static const String phoneRequired  = 'Phone number is required';
  static const String phoneInvalid   = 'Enter a valid 10-digit number starting with 6, 7, 8 or 9';
  static const String nameRequired   = 'Name is required';
  static const String nameMin        = 'Name must be at least 2 characters';
  static const String dobRequired    = 'Date of birth is required';
  static const String mustBe18       = 'You must be at least 18 years old';
  static const String heightRequired = 'Height is required';
  static const String cityRequired   = 'City is required';
  static const String religionRequired = 'Religion is required';
  static const String casteRequired  = 'Caste is required';
  static const String qualRequired   = 'Qualification is required';
  static const String incomeRequired = 'Income range is required';
  static const String otpRequired    = 'Please enter the OTP';
  static const String otpInvalid     = 'Invalid OTP. Please try again.';
  static const String somethingWrong = 'Something went wrong. Please try again.';
  static const String noInternet     = 'No internet connection. Please check your network.';

  // ── EMPTY STATES ─────────────────────────────────────
  static const String noProfiles     = 'No Profiles Found';
  static const String noProfilesSub  = 'Try adjusting your filters or search query';
  static const String resetFilters   = 'Reset Filters';
  static const String noInterests    = 'No Interests Yet';
  static const String noInterestsSub = 'Browse profiles and send interests';
  static const String noConnections  = 'No Connections Yet';
  static const String noConnectionsSub = 'Accept interests to build connections';
  static const String browseProfiles = 'Browse Profiles 💑';
  static const String viewConnections = 'View Connections';

  // ── GUEST ────────────────────────────────────────────
  static const String limitedAccess  = '🔒 Limited Access';
  static const String registerUnlock = 'Register to unlock all features';
  static const String registerFree   = "Register — It's Free 🎉";
  static const String createFreeAccount = 'Create a Free Account!';
  static const String needAccountFor = 'You need an account to send and receive interests';
  static const String viewUnlimited  = 'View unlimited photos';
  static const String sendReceive    = 'Send and receive interests';
  static const String chatDirectlyFull = 'Chat directly with matches';

  // ── PREMIUM ──────────────────────────────────────────
  static const String goPremium      = 'Go Premium';
  static const String premiumTagline = 'Make finding your match easier';
  static const String silver         = 'Silver';
  static const String goldPlan       = 'Gold';
  static const String platinumPlan   = 'Platinum';
  static const String mostPopular    = '⭐ MOST POPULAR';
  static const String buyNow         = 'Buy Now';
  static const String perMonth       = '/ month';
  static const String months3        = '3 months';
  static const String months6        = '6 months';

  // ── DIALOGS ──────────────────────────────────────────
  static const String logoutTitle    = 'Logout?';
  static const String logoutMsg      = 'Are you sure you want to logout?';
  static const String deleteTitle    = '⚠️ Delete Account?';
  static const String deleteMsg      = 'This action is permanent. All your data will be deleted within 30 days. Are you sure?';
  static const String yesDelete      = 'Yes, Delete';
  static const String yesLogout      = 'Yes, Logout';
  static const String blockTitle     = 'Block User?';
  static const String reportTitle    = 'Report User';
}