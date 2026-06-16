// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import '../../config/di/injection_container.dart';
// import '../../features/auth/presentation/bloc/auth_bloc.dart';
// import '../../features/auth/presentation/pages/auth_screen.dart';
// import '../../features/bottom_nav/presentation/pages/bottom_nav_screen.dart';
// import '../../features/categories/presentation/pages/categories.dart';
// import '../../features/favourites/presentation/pages/favourites.dart';
// import '../../features/home/presentation/pages/home_screen.dart';
// import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
// import '../../features/profile/presentation/pages/profile.dart';
// import '../../features/search/presentation/pages/search.dart';
// import 'route_names.dart';

// /// WALLR — GoRouter config
// /// Routes are added here as each screen is built.
// final GoRouter appRouter = GoRouter(
//   initialLocation: RouteNames.onboarding,
//   debugLogDiagnostics: true,
//   routes: [
//     GoRoute(
//       path: RouteNames.onboarding,
//       builder: (context, state) => const OnboardingScreen(),
//     ),
//     GoRoute(
//       path: RouteNames.auth,
//       builder: (context, state) {
//         final selectedTab =
//             state.uri.queryParameters['tab']?.toLowerCase() ?? 'signin';
//         return BlocProvider<AuthBloc>(
//           create: (_) => sl<AuthBloc>(),
//           child: AuthScreen(initialTabIndex: selectedTab == 'signup' ? 1 : 0),
//         );
//       },
//     ),
//     ShellRoute(
//       builder: (context, state, child) =>
//           BottomNavScreen(child: child, location: state.uri.toString()),
//       routes: [
//         GoRoute(
//           path: RouteNames.home,
//           builder: (context, state) => const HomeScreen(),
//           routes: [
//             GoRoute(
//               path: 'search',
//               builder: (context, state) => const Search(),
//             ),
//             GoRoute(
//               path: 'categories',
//               builder: (context, state) => const Categories(),
//             ),
//             GoRoute(
//               path: 'favourites',
//               builder: (context, state) => const Favourites(),
//             ),
//             GoRoute(
//               path: 'profile',
//               builder: (context, state) => const Profile(),
//             ),
//           ],
//         ),
//       ],
//     ),
//   ],
// );

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/bottom_nav/presentation/pages/bottom_nav_screen.dart';
import '../../features/categories/presentation/pages/categories.dart';
import '../../features/favourites/presentation/pages/favourites.dart';
import '../../features/home/domain/entities/wallpaper_entity.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/profile/presentation/pages/profile.dart';
import '../../features/search/presentation/pages/search.dart';
import '../../features/wallpaper_detail/presentation/pages/wallpaper_detail_screen.dart';
import '../../features/wallpaper_detail/presentation/pages/wallpaper_preview_screen.dart';
import 'route_names.dart';

/// WALLR — GoRouter config
/// Routes are added here as each screen is built.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.onboarding,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteNames.auth,
      builder: (context, state) {
        final selectedTab =
            state.uri.queryParameters['tab']?.toLowerCase() ?? 'signin';
        return BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: AuthScreen(initialTabIndex: selectedTab == 'signup' ? 1 : 0),
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) =>
          BottomNavScreen(child: child, location: state.uri.toString()),
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => BlocProvider<HomeBloc>(
            create: (_) => sl<HomeBloc>(),
            child: const HomeScreen(),
          ),
          routes: [
            GoRoute(
              path: 'search',
              builder: (context, state) => const Search(),
            ),
            GoRoute(
              path: 'categories',
              builder: (context, state) => const Categories(),
            ),
            GoRoute(
              path: 'favourites',
              builder: (context, state) => const Favourites(),
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const Profile(),
            ),
          ],
        ),
      ],
    ),

    // ── Wallpaper detail + preview (fullscreen, outside the nav shell) ──
    GoRoute(
      path: RouteNames.wallpaperDetail,
      builder: (context, state) {
        final wallpaper = state.extra as WallpaperEntity;
        return WallpaperDetailScreen(wallpaper: wallpaper);
      },
    ),
    GoRoute(
      path: RouteNames.wallpaperPreview,
      builder: (context, state) {
        final wallpaper = state.extra as WallpaperEntity;
        return WallpaperPreviewScreen(wallpaper: wallpaper);
      },
    ),
  ],
);
