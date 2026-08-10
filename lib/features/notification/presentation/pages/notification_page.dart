import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationsRequested());
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(const NotificationsRefreshed());
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          switch (state) {
            case NotificationInitial():
            case NotificationLoading():
              return const _NotificationLoadingView();

            case NotificationError(message: final message):
              return _NotificationErrorView(
                message: message,
                onRetry: () =>
                    context.read<NotificationBloc>().add(const NotificationsRequested()),
              );

            case NotificationLoaded(
                  notifications: final notifications,
                  isRefreshing: _,
                ):
              if (notifications.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications',
                  subtitle: 'You\'re all caught up!',
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryContainer,
                backgroundColor: AppColors.surface,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        context.read<NotificationBloc>().add(
                              NotificationMarkReadRequested(notification.id),
                            );
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _NotificationLoadingView extends StatelessWidget {
  const _NotificationLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.surfaceHigh,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
                ),
              ),
              SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 0.7.sw,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NotificationErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64.w,
              color: AppColors.navInactive,
            ),
            SizedBox(height: AppDimensions.lg),
            Text(
              'Couldn\'t load notifications',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSm,
            ),
            SizedBox(height: AppDimensions.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMdMuted,
            ),
            SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimary,
                shape: const StadiumBorder(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                  vertical: AppDimensions.sm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
