/// WALLR — All app strings in one place.
/// Usage: Text(AppStrings.appName)
///
/// Convention:
///   - Group by screen / feature
///   - Snake_case after the group prefix
///   - No string interpolation here — use format methods in the feature layer

abstract final class AppStrings {
  // ─── App ────────────────────────────────────────────────────
  static const String appName = 'Wallr';
  static const String appTagline = 'Your canvas. Curated.';

  // ─── Onboarding ─────────────────────────────────────────────
  static const String onboarding1Title = 'Discover Stunning Walls';
  static const String onboarding1Subtitle =
      'Explore thousands of premium wallpapers crafted by artists worldwide.';

  static const String onboarding2Title = 'Curate Your Collection';
  static const String onboarding2Subtitle =
      'Save your favourites and organise them into personal collections.';

  static const String onboarding3Title = 'Set in One Tap';
  static const String onboarding3Subtitle =
      'Crop, preview, and set your wallpaper — home screen or lock screen.';

  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get Started';

  // ─── Auth ────────────────────────────────────────────────────
  static const String authWelcomeBack = 'Welcome back';
  static const String authCreateAccount = 'Create account';
  static const String authSignIn = 'Sign In';
  static const String authSignUp = 'Sign Up';
  static const String authSignOut = 'Sign Out';
  static const String authOrContinueWith = 'or continue with';

  static const String authEmailHint = 'Email address';
  static const String authPasswordHint = 'Password';
  static const String authNameHint = 'Full name';

  static const String authForgotPassword = 'Forgot password?';
  static const String authAlreadyHaveAccount = 'Already have an account? ';
  static const String authDontHaveAccount = "Don't have an account? ";

  static const String authGoogleSignIn = 'Google';
  static const String authAppleSignIn = 'Apple';

  static const String authEmailEmpty = 'Email cannot be empty';
  static const String authEmailInvalid = 'Enter a valid email address';
  static const String authPasswordEmpty = 'Password cannot be empty';
  static const String authPasswordShort =
      'Password must be at least 8 characters';

  // ─── Bottom Nav ──────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navSearch = 'Search';
  static const String navCollections = 'Collections';
  static const String navDownloads = 'Downloads';
  static const String navProfile = 'Profile';

  // ─── Home Feed ───────────────────────────────────────────────
  static const String homeFeatured = 'Featured';
  static const String homeTrending = 'Trending';
  static const String homeNewArrivals = 'New Arrivals';
  static const String homeForYou = 'For You';
  static const String homeCategories = 'Categories';
  static const String homeSeeAll = 'See All';

  // ─── Search ──────────────────────────────────────────────────
  static const String searchHint = 'Search wallpapers, artists…';
  static const String searchNoResults = 'No results found';
  static const String searchTryAnother = 'Try a different keyword';
  static const String searchExplore = 'Explore';
  static const String searchTrending = 'Trending Searches';

  // ─── Wallpaper Detail ────────────────────────────────────────
  static const String detailDownload = 'Download';
  static const String detailSetWallpaper = 'Set Wallpaper';
  static const String detailPreview = 'Preview';
  static const String detailAddToCollection = 'Add to Collection';
  static const String detailShare = 'Share';
  static const String detailResolution = 'Resolution';
  static const String detailCategory = 'Category';
  static const String detailArtist = 'Artist';
  static const String detailViews = 'Views';
  static const String detailDownloads = 'Downloads';

  // ─── Apply / Set Screen ──────────────────────────────────────
  static const String applyHomeScreen = 'Home Screen';
  static const String applyLockScreen = 'Lock Screen';
  static const String applyBothScreens = 'Both';
  static const String applySetNow = 'Set Now';
  static const String applySuccess = 'Wallpaper set successfully!';

  // ─── Collections ─────────────────────────────────────────────
  static const String collectionsTitle = 'Collections';
  static const String collectionsEmpty = 'No collections yet';
  static const String collectionsEmptySub =
      'Save wallpapers to collections to see them here.';
  static const String collectionsCreate = 'Create Collection';
  static const String collectionsNewName = 'Collection name';
  static const String collectionsNameHint = 'e.g. Dark Aesthetic';
  static const String collectionsCreateBtn = 'Create';
  static const String collectionsMoveSuccess = 'Moved to collection';
  static const String collectionsMoveTitle = 'Move to Collection';

  // ─── Favourites ──────────────────────────────────────────────
  static const String favouritesTitle = 'Favourites';
  static const String favouritesEmpty = 'Nothing here yet';
  static const String favouritesEmptySub =
      'Tap the heart on any wallpaper to save it here.';

  // ─── Downloads ───────────────────────────────────────────────
  static const String downloadsTitle = 'Downloads';
  static const String downloadsEmpty = 'No downloads yet';
  static const String downloadsEmptySub =
      'Your downloaded wallpapers will appear here.';
  static const String downloadsSelect = 'Select';
  static const String downloadsSelectAll = 'Select All';
  static const String downloadsDelete = 'Delete';
  static const String downloadsDeleteConfirm = 'Delete selected wallpapers?';
  static const String downloadsDeleteCancel = 'Cancel';
  static const String downloadsDeleteConfirmBtn = 'Delete';

  // ─── Profile ─────────────────────────────────────────────────
  static const String profileTitle = 'Profile';
  static const String profileEditProfile = 'Edit Profile';
  static const String profilePremium = 'Go Premium';
  static const String profileStats = 'Stats';

  // ─── Settings ────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String settingsAppearance = 'Appearance';
  static const String settingsDarkMode = 'Dark Mode';
  static const String settingsNotifications = 'Notifications';
  static const String settingsDownloadQuality = 'Download Quality';
  static const String settingsClearCache = 'Clear Cache';
  static const String settingsAbout = 'About';
  static const String settingsPrivacyPolicy = 'Privacy Policy';
  static const String settingsTerms = 'Terms of Service';
  static const String settingsVersion = 'Version';
  static const String settingsSignOut = 'Sign Out';

  // ─── Premium Paywall ─────────────────────────────────────────
  static const String premiumTitle = 'Wallr Pro';
  static const String premiumSubtitle = 'Unlock the full canvas.';
  static const String premiumUnlimited = 'Unlimited Downloads';
  static const String premiumNoAds = 'Ad-Free Experience';
  static const String premium4K = 'Exclusive 4K & 8K Wallpapers';
  static const String premiumEarlyAccess = 'Early Access to New Drops';
  static const String premiumSubscribe = 'Subscribe Now';
  static const String premiumRestore = 'Restore Purchase';
  static const String premiumMonthly = '/ month';
  static const String premiumYearly = '/ year';
  static const String premiumBestValue = 'Best Value';

  // ─── General / Common ────────────────────────────────────────
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String loading = 'Loading…';
  static const String error = 'Something went wrong';
  static const String errorRetry = 'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection';
  static const String done = 'Done';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String share = 'Share';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String free = 'Free';
  static const String pro = 'Pro';
  static const String new_ = 'New'; // 'new' is a Dart keyword
  static const String trending = 'Trending';
}
