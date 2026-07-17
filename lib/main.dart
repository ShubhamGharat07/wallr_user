import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallr/config/di/injection_container.dart';

import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'features/onboarding/presentation/bloc/onboarding_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await GoogleSignIn.instance.initialize();

  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => OnboardingCubit(
                CompleteOnboardingUseCase(
                  OnboardingRepositoryImpl(
                    OnboardingLocalDataSourceImpl(sl<SharedPreferences>()),
                  ),
                ),
              ),
            ),
          ],
          child: MaterialApp.router(
            title: 'Wallr',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}
