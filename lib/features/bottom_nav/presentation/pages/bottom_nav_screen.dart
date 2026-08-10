import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../notification/presentation/bloc/notification_state.dart';

class BottomNavScreen extends StatefulWidget {
  final Widget child;
  final String location;

  const BottomNavScreen({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationsRequested());
  }

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
    final selectedIndex = _navIndex(widget.location);

    // Hide AppBar on search, downloads and notifications pages
    final isSearchPage = widget.location.contains(RouteNames.search);
    final isDownloadsPage = widget.location.contains(RouteNames.downloads);
    final isNotificationsPage =
        widget.location.contains(RouteNames.notifications);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (!isSearchPage && !isDownloadsPage && !isNotificationsPage)
            SafeArea(
              bottom: false,
              child: CustomAppBar(
                actions: [
                  IconButton(
                    onPressed: () => context.go(RouteNames.search),
                    icon: const Icon(Icons.search, color: AppColors.onSurface),
                  ),
                  BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      final unreadCount = switch (state) {
                        NotificationLoaded(notifications: final items) =>
                          items.where((n) => !n.isRead).length,
                        _ => 0,
                      };
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () =>
                                context.go(RouteNames.notifications),
                            icon: const Icon(
                              Icons.notifications_none,
                              color: AppColors.onSurface,
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.surface, width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => _onTap(context, index),
            backgroundColor: AppColors.background,
            selectedItemColor: AppColors.primaryContainer,
            unselectedItemColor: AppColors.navInactive,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            enableFeedback: false,
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
      ),
    );
  }
}
