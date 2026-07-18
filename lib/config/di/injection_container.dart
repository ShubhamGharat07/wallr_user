// // lib/config/di/injection_container.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get_it/get_it.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../core/network/network_info.dart';
// import '../../features/auth/data/datasources/auth_remote_datasource.dart';
// import '../../features/auth/data/repositories/auth_repository_impl.dart';
// import '../../features/auth/domain/repositories/auth_repository.dart';
// import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
// import '../../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
// import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
// import '../../features/auth/domain/usecases/sign_out_usecase.dart';
// import '../../features/auth/domain/usecases/sign_up_with_email_usecase.dart';
// import '../../features/auth/presentation/bloc/auth_bloc.dart';
// import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
// import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
// import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
// import '../../features/onboarding/presentation/bloc/onboarding_cubit.dart';

// final sl = GetIt.instance;

// Future<void> initDependencies() async {
//   // ── External ─────────────────────────────────────────────────
//   final prefs = await SharedPreferences.getInstance();
//   sl.registerSingleton<SharedPreferences>(prefs);
//   sl.registerLazySingleton<Connectivity>(() => Connectivity());
//   sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
//   sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

//   // ── Core ─────────────────────────────────────────────────────
//   sl.registerLazySingleton<NetworkInfo>(
//     () => NetworkInfoImpl(sl<Connectivity>()),
//   );

//   // ── Onboarding ───────────────────────────────────────────────
//   sl.registerLazySingleton<OnboardingLocalDataSource>(
//     () => OnboardingLocalDataSourceImpl(sl<SharedPreferences>()),
//   );
//   sl.registerLazySingleton<OnboardingRepository>(
//     () => OnboardingRepositoryImpl(sl<OnboardingLocalDataSource>()),
//   );
//   sl.registerLazySingleton(
//     () => CompleteOnboardingUseCase(sl<OnboardingRepository>()),
//   );
//   sl.registerFactory(() => OnboardingCubit(sl<CompleteOnboardingUseCase>()));

//   // ── Auth ─────────────────────────────────────────────────────
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(
//       auth: sl<FirebaseAuth>(),
//       firestore: sl<FirebaseFirestore>(),
//     ),
//   );
//   sl.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remote: sl<AuthRemoteDataSource>(),
//       networkInfo: sl<NetworkInfo>(),
//     ),
//   );

//   // Auth UseCases
//   sl.registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()));
//   sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl<AuthRepository>()));
//   sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthRepository>()));
//   sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
//   sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));

//   // Auth BLoC — registerFactory kyunki har baar naya instance chahiye
//   sl.registerFactory(
//     () => AuthBloc(
//       signInWithEmail: sl<SignInWithEmailUseCase>(),
//       signUpWithEmail: sl<SignUpWithEmailUseCase>(),
//       signInWithGoogle: sl<SignInWithGoogleUseCase>(),
//       forgotPassword: sl<ForgotPasswordUseCase>(),
//       signOut: sl<SignOutUseCase>(),
//     ),
//   );
// }

// lib/config/di/injection_container.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/network_info.dart';
import '../../core/services/wallpaper_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/categories/data/datasources/categories_remote_datasource.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/presentation/bloc/categories_bloc.dart';
import '../../features/category_detail/data/datasources/category_detail_remote_datasource.dart';
import '../../features/category_detail/data/repositories/category_detail_repository_impl.dart';
import '../../features/category_detail/domain/repositories/category_detail_repository.dart';
import '../../features/category_detail/domain/usecases/get_wallpapers_by_category_usecase.dart';
import '../../features/category_detail/presentation/bloc/category_detail_bloc.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_feed_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/presentation/bloc/onboarding_cubit.dart';
import '../../features/wallpaper_detail/presentation/cubit/wallpaper_actions_cubit.dart';
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_usecase.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/wallpaper_download/data/datasources/local_download_datasource.dart';
import '../../features/wallpaper_download/data/repositories/download_repository_impl.dart';
import '../../features/wallpaper_download/domain/repositories/download_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ─────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ── Core ─────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // ── Onboarding ───────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl<OnboardingLocalDataSource>()),
  );
  sl.registerLazySingleton(
    () => CompleteOnboardingUseCase(sl<OnboardingRepository>()),
  );
  sl.registerFactory(() => OnboardingCubit(sl<CompleteOnboardingUseCase>()));

  // ── Auth ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Auth UseCases
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));

  // Auth BLoC — registerFactory kyunki har baar naya instance chahiye
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl<SignInWithEmailUseCase>(),
      signUpWithEmail: sl<SignUpWithEmailUseCase>(),
      signInWithGoogle: sl<SignInWithGoogleUseCase>(),
      forgotPassword: sl<ForgotPasswordUseCase>(),
      signOut: sl<SignOutUseCase>(),
      prefs: sl<SharedPreferences>(),
    ),
  );

  // ── Home ─────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remote: sl<HomeRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetHomeFeedUseCase(sl<HomeRepository>()));

  // Home BLoC — registerFactory kyunki har baar naya instance chahiye
  sl.registerFactory(() => HomeBloc(getHomeFeed: sl<GetHomeFeedUseCase>()));

  // ── Categories ───────────────────────────────────────────────
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      remote: sl<CategoriesRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<CategoriesRepository>()));

  // Categories BLoC — registerFactory kyunki har baar naya instance chahiye
  sl.registerFactory(() => CategoriesBloc(getCategories: sl<GetCategoriesUseCase>()));

  // ── Category Detail ──────────────────────────────────────────
  sl.registerLazySingleton<CategoryDetailRemoteDataSource>(
    () => CategoryDetailRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<CategoryDetailRepository>(
    () => CategoryDetailRepositoryImpl(
      remote: sl<CategoryDetailRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetWallpapersByCategoryUseCase(sl<CategoryDetailRepository>()));

  // Category Detail BLoC — registerFactory kyunki har baar naya instance chahiye
  sl.registerFactory(() => CategoryDetailBloc(getWallpapers: sl<GetWallpapersByCategoryUseCase>()));

  // ── Search ───────────────────────────────────────────────────
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remote: sl<SearchRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => SearchUseCase(repository: sl<SearchRepository>()));

  // Search BLoC — registerFactory kyunki har baar naya instance chahiye
  sl.registerFactory(() => SearchBloc(searchUseCase: sl<SearchUseCase>()));

  // ── Wallpaper Detail / Actions ───────────────────────────────
  sl.registerLazySingleton<WallpaperService>(() => WallpaperService());

  // Download Repository
  sl.registerLazySingleton<LocalDownloadDataSource>(
    () => LocalDownloadDataSourceImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(
      localDataSource: sl<LocalDownloadDataSource>(),
      dio: Dio(),
    ),
  );

  // Factory — one cubit per detail/preview screen instance.
  sl.registerFactory(
    () => WallpaperActionsCubit(
      service: sl<WallpaperService>(),
      downloadRepository: sl<DownloadRepository>(),
    ),
  );
}
