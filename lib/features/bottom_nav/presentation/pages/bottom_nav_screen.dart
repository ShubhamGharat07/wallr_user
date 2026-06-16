import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../config/routes/route_names.dart';

class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int _navIndex(String location) {
    if (location.startsWith(RouteNames.profile)) return 4;
    if (location.startsWith(RouteNames.favourites)) return 3;
    if (location.startsWith(RouteNames.categories)) return 2;
    if (location.startsWith(RouteNames.search)) return 1;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go(RouteNames.search);
        break;
      case 2:
        context.go(RouteNames.categories);
        break;
      case 3:
        context.go(RouteNames.favourites);
        break;
      case 4:
        context.go(RouteNames.profile);
        break;
      default:
        context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _navIndex(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: AppColors.onSurface),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.black,
          border: Border(top: BorderSide(color: AppColors.surface, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onTap(context, index),
          backgroundColor: AppColors.black,
          selectedItemColor: AppColors.primaryContainer,
          unselectedItemColor: AppColors.navInactive,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
