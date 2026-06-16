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

  // ── Wallpaper Detail / Actions ───────────────────────────────
  sl.registerLazySingleton<WallpaperService>(() => const WallpaperService());
  // Factory — one cubit per detail/preview screen instance.
  sl.registerFactory(
    () => WallpaperActionsCubit(service: sl<WallpaperService>()),
  );
}
