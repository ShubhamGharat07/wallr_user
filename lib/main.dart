import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallr/config/di/injection_container.dart';

import 'config/routes/app_router.dart';
import 'config/routes/route_names.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/domain/usecases/get_wallpaper_by_id_usecase.dart';
import 'features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'features/onboarding/presentation/bloc/onboarding_cubit.dart';

final fcmService = FcmService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '853044061342-467iq899rtpjn4mfu24sejcipbh0dmqf.apps.googleusercontent.com',
  );

  await initDependencies();

  await fcmService.initialize();

  // Deep links must be registered before the first frame can carry a
  // cold-start link — the initial link is cached and consumed by MyApp.
  await sl<DeepLinkService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  StreamSubscription<String>? _deepLinkSubscription;
  String? _lastOpenedWallpaperId;
  DateTime? _lastOpenedAt;

  @override
  void initState() {
    super.initState();
    final deepLinkService = sl<DeepLinkService>();

    // Cold start: the id is ready before the router exists — navigate
    // only after the first frame so go_router is attached.
    final pendingId = deepLinkService.consumePendingWallpaperId();
    if (pendingId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openWallpaper(pendingId),
      );
    }

    // Warm start: any future link navigates immediately.
    _deepLinkSubscription = deepLinkService.wallpaperLinks.listen(
      _openWallpaper,
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openWallpaper(String wallpaperId) async {
    // Dedupe: the same id arriving twice within 3s (rare platform
    // double-delivery of the same link) must not stack screens.
    final now = DateTime.now();
    if (wallpaperId == _lastOpenedWallpaperId &&
        _lastOpenedAt != null &&
        now.difference(_lastOpenedAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastOpenedWallpaperId = wallpaperId;
    _lastOpenedAt = now;

    final result = await sl<GetWallpaperByIdUseCase>()(wallpaperId);
    result.fold(
      (failure) {
        _messengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Couldn't open wallpaper: ${failure.message}"),
              backgroundColor: Colors.red.shade900,
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      (wallpaper) {
        if (!mounted) return;
        appRouter.push(
          RouteNames.wallpaperDetail,
          extra: WallpaperDetailExtras(wallpaper: wallpaper),
        );
      },
    );
  }

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
            scaffoldMessengerKey: _messengerKey,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}
