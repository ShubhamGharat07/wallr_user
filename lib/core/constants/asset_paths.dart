// /// WALLR — Asset Path Constants
// ///
// /// All local asset paths resolved relative to project root.
// /// Prefer using [AppAssets] over raw strings to catch rename-regressions
// /// at compile time.
// ///
// /// Usage: Image.asset(AppAssets.logo)
// ///        Lottie.asset(AppAssets.lottieCrown)
// abstract final class AppAssets {
//   // ─── Root Directories ─────────────────────────────────────────
//   static const String _images = 'assets/images';
//   static const String _icons = 'assets/icons';
//   static const String _lottie = 'assets/lottie';
//   static const String _fonts = 'assets/fonts';

//   // ─── App Logo ─────────────────────────────────────────────────
//   /// Primary WALLR logo (SVG / PNG) shown on splash & auth
//   static const String logo = '$_images/wallr_logo.png';

//   /// Small logo mark (icon-only variant) for top-app-bar crown icon
//   static const String logoMark = '$_images/wallr_logomark.png';

//   // ─── Onboarding ───────────────────────────────────────────────
//   /// Slide 1 — Discover Stunning Walls background wallpaper
//   static const String onboarding1Bg = '$_images/onboarding_1.jpg';

//   /// Slide 2 — Curate Your Collection background wallpaper
//   static const String onboarding2Bg = '$_images/onboarding_2.jpg';

//   /// Slide 3 — Set in One Tap background wallpaper
//   static const String onboarding3Bg = '$_images/onboarding_3.jpg';

//   // ─── Placeholder / Error Images ───────────────────────────────
//   /// Used as CachedNetworkImage errorWidget
//   static const String placeholderError = '$_images/placeholder_error.png';

//   /// Blurred low-quality image placeholder (LQIP) for wallpaper cards
//   static const String placeholderBlur = '$_images/placeholder_blur.png';

//   // ─── Empty State Illustrations ────────────────────────────────
//   static const String emptyFavourites = '$_images/empty_favourites.png';
//   static const String emptyDownloads = '$_images/empty_downloads.png';
//   static const String emptyCollections = '$_images/empty_collections.png';
//   static const String emptySearch = '$_images/empty_search.png';
//   static const String emptyGeneral = '$_images/empty_general.png';

//   // ─── Category Cover Images ────────────────────────────────────
//   static const String categoryAbstract = '$_images/cat_abstract.jpg';
//   static const String categoryNature = '$_images/cat_nature.jpg';
//   static const String categoryArchitecture = '$_images/cat_architecture.jpg';
//   static const String categoryMinimal = '$_images/cat_minimal.jpg';
//   static const String categoryDark = '$_images/cat_dark.jpg';
//   static const String categoryNeon = '$_images/cat_neon.jpg';
//   static const String categorySpace = '$_images/cat_space.jpg';
//   static const String categoryAnimals = '$_images/cat_animals.jpg';
//   static const String categoryCars = '$_images/cat_cars.jpg';
//   static const String categoryArt = '$_images/cat_art.jpg';
//   static const String categoryPatterns = '$_images/cat_patterns.jpg';

//   // ─── Icons (SVG) ──────────────────────────────────────────────
//   static const String iconCrown = '$_icons/ic_crown.svg';
//   static const String iconHome = '$_icons/ic_home.svg';
//   static const String iconSearch = '$_icons/ic_search.svg';
//   static const String iconCollections = '$_icons/ic_collections.svg';
//   static const String iconDownload = '$_icons/ic_download.svg';
//   static const String iconProfile = '$_icons/ic_profile.svg';
//   static const String iconHeart = '$_icons/ic_heart.svg';
//   static const String iconHeartFilled = '$_icons/ic_heart_filled.svg';
//   static const String iconGoogle = '$_icons/ic_google.svg';
//   static const String iconApple = '$_icons/ic_apple.svg';
//   static const String iconNotification = '$_icons/ic_notification.svg';
//   static const String iconShare = '$_icons/ic_share.svg';
//   static const String iconAdd = '$_icons/ic_add.svg';
//   static const String iconCheck = '$_icons/ic_check.svg';
//   static const String iconClose = '$_icons/ic_close.svg';
//   static const String iconBack = '$_icons/ic_back.svg';
//   static const String iconEdit = '$_icons/ic_edit.svg';
//   static const String iconDelete = '$_icons/ic_delete.svg';
//   static const String iconSettings = '$_icons/ic_settings.svg';

//   // ─── Lottie Animations ────────────────────────────────────────
//   /// Crown animation on Premium paywall
//   static const String lottieCrown = '$_lottie/crown_anim.json';

//   /// Success tick — "Wallpaper set successfully!"
//   static const String lottieSuccess = '$_lottie/success_anim.json';

//   /// Loading / spinner fallback
//   static const String lottieLoading = '$_lottie/loading_anim.json';

//   /// Confetti burst — collection creation success
//   static const String lottieConfetti = '$_lottie/confetti_anim.json';

//   // ─── Fonts (reference only — declared in pubspec.yaml) ────────
//   /// Inter Regular 400
//   static const String fontInterRegular = '$_fonts/Inter-Regular.ttf';

//   /// Inter Medium 500
//   static const String fontInterMedium = '$_fonts/Inter-Medium.ttf';

//   /// Inter SemiBold 600
//   static const String fontInterSemiBold = '$_fonts/Inter-SemiBold.ttf';

//   /// Inter Bold 700
//   static const String fontInterBold = '$_fonts/Inter-Bold.ttf';
// }
