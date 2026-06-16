// // lib/features/wallpaper_detail/presentation/pages/wallpaper_preview_screen.dart

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:feather_icons/feather_icons.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../config/di/injection_container.dart';
// import '../../../../core/constants/colors.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../../../home/domain/entities/wallpaper_entity.dart';
// import '../cubit/wallpaper_actions_cubit.dart';
// import '../cubit/wallpaper_actions_state.dart';
// import '../widgets/set_wallpaper_sheet.dart';

// enum WallpaperTarget { lockScreen, homeScreen }

// enum ImageFilter {
//   original('Original'),
//   vivid('Vivid'),
//   vibrant('Vibrant'),
//   warm('Warm'),
//   cool('Cool'),
//   contrast('Contrast'),
//   soft('Soft'),
//   dramatic('Dramatic'),
//   sepia('Sepia'),
//   noir('Noir');

//   const ImageFilter(this.label);

//   final String label;

//   ColorFilter get colorFilter {
//     switch (this) {
//       case ImageFilter.original:
//         return ColorFilter.matrix([
//           1, 0, 0, 0, 0,
//           0, 1, 0, 0, 0,
//           0, 0, 1, 0, 0,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.vivid:
//         return ColorFilter.matrix([
//           1.2, 0, 0, 0, 0,
//           0, 1.3, 0, 0, 0,
//           0, 0, 1.1, 0, 0,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.vibrant:
//         return ColorFilter.matrix([
//           1.1, 0, 0, 0, 0,
//           0, 1.5, 0, 0, 0,
//           0, 0, 1.0, 0, 0,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.warm:
//         return ColorFilter.matrix([
//           1.1, 0, 0, 0, 30,
//           0, 0.9, 0, 0, 10,
//           0, 0, 0.7, 0, -20,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.cool:
//         return ColorFilter.matrix([
//           0.9, 0, 0, 0, -10,
//           0, 0.95, 0, 0, 5,
//           0, 0, 1.2, 0, 30,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.contrast:
//         return ColorFilter.matrix([
//           1.3, 0, 0, 0, -20,
//           0, 1.3, 0, 0, -20,
//           0, 0, 1.3, 0, -20,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.soft:
//         return ColorFilter.matrix([
//           0.9, 0, 0, 0, 20,
//           0, 0.9, 0, 0, 20,
//           0, 0, 0.9, 0, 20,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.dramatic:
//         return ColorFilter.matrix([
//           1.4, 0, 0, 0, -30,
//           0, 1.3, 0, 0, -30,
//           0, 0, 1.2, 0, -30,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.sepia:
//         return ColorFilter.matrix([
//           0.393, 0.769, 0.189, 0, 0,
//           0.349, 0.686, 0.168, 0, 0,
//           0.272, 0.534, 0.131, 0, 0,
//           0, 0, 0, 1, 0,
//         ]);
//       case ImageFilter.noir:
//         return ColorFilter.matrix([
//           0.2, 0.2, 0.2, 0, 0,
//           0.2, 0.2, 0.2, 0, 0,
//           0.2, 0.2, 0.2, 0, 0,
//           0, 0, 0, 1, 0,
//         ]);
//     }
//   }
// }

// class WallpaperPreviewScreen extends StatelessWidget {
//   final WallpaperEntity wallpaper;

//   const WallpaperPreviewScreen({super.key, required this.wallpaper});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => sl<WallpaperActionsCubit>(),
//       child: _PreviewView(wallpaper: wallpaper),
//     );
//   }
// }

// class _PreviewView extends StatefulWidget {
//   final WallpaperEntity wallpaper;

//   const _PreviewView({required this.wallpaper});

//   @override
//   State<_PreviewView> createState() => _PreviewViewState();
// }

// class _PreviewViewState extends State<_PreviewView> {
//   WallpaperTarget _selectedTarget = WallpaperTarget.lockScreen;
//   ImageFilter _selectedFilter = ImageFilter.original;
//   bool _showControls = true;

//   String get _imageUrl => widget.wallpaper.imageUrl.isNotEmpty
//       ? widget.wallpaper.imageUrl
//       : widget.wallpaper.cardImageUrl;

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   }

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }

//   Future<void> _onSetWallpaper() async {
//     final target = await SetWallpaperSheet.show(context);
//     if (target == null || !mounted) return;

//     await context.read<WallpaperActionsCubit>().setWallpaper(
//           imageUrl: _imageUrl,
//           wallpaperId: widget.wallpaper.id,
//           target: target,
//         );
//   }

//   Widget _buildFilteredImage() {
//     final filter = _selectedFilter;
//     return ColorFiltered(
//       colorFilter: filter.colorFilter,
//       child: CachedNetworkImage(
//         imageUrl: _imageUrl,
//         fit: BoxFit.cover,
//         placeholder: (_, __) => const ColoredBox(
//           color: Colors.black,
//           child: Center(
//             child: CircularProgressIndicator(
//               color: AppColors.primaryContainer,
//               strokeWidth: 2,
//             ),
//           ),
//         ),
//         errorWidget: (_, __, ___) => const ColoredBox(
//           color: Colors.black,
//           child: Icon(
//             Icons.broken_image_outlined,
//             color: Colors.white54,
//             size: 48,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final topPad = MediaQuery.of(context).padding.top;
//     final bottomPad = MediaQuery.of(context).padding.bottom;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: BlocConsumer<WallpaperActionsCubit, WallpaperActionsState>(
//         listenWhen: (prev, curr) =>
//             curr.message != null && prev.message != curr.message,
//         listener: (context, state) {
//           ScaffoldMessenger.of(context)
//             ..hideCurrentSnackBar()
//             ..showSnackBar(
//               SnackBar(
//                 content: Text(state.message!),
//                 backgroundColor: state.status == WallpaperActionStatus.failure
//                     ? AppColors.errorContainer
//                     : AppColors.surfaceHigh,
//                 behavior: SnackBarBehavior.floating,
//               ),
//             );
//         },
//         builder: (context, state) {
//           return GestureDetector(
//             onTap: () => setState(() => _showControls = !_showControls),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 _buildFilteredImage(),
//                 AnimatedOpacity(
//                   opacity: _showControls ? 1 : 0,
//                   duration: const Duration(milliseconds: 200),
//                   child: IgnorePointer(
//                     ignoring: !_showControls,
//                     child: _PreviewControls(
//                       topPad: topPad,
//                       bottomPad: bottomPad,
//                       selectedTarget: _selectedTarget,
//                       selectedFilter: _selectedFilter,
//                       isBusy: state.isBusy,
//                       onTargetChanged: (target) =>
//                           setState(() => _selectedTarget = target),
//                       onFilterChanged: (filter) =>
//                           setState(() => _selectedFilter = filter),
//                       onBack: () => context.pop(),
//                       onSetWallpaper: _onSetWallpaper,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _PreviewControls extends StatelessWidget {
//   final double topPad;
//   final double bottomPad;
//   final WallpaperTarget selectedTarget;
//   final ImageFilter selectedFilter;
//   final bool isBusy;
//   final ValueChanged<WallpaperTarget> onTargetChanged;
//   final ValueChanged<ImageFilter> onFilterChanged;
//   final VoidCallback onBack;
//   final VoidCallback onSetWallpaper;

//   const _PreviewControls({
//     required this.topPad,
//     required this.bottomPad,
//     required this.selectedTarget,
//     required this.selectedFilter,
//     required this.isBusy,
//     required this.onTargetChanged,
//     required this.onFilterChanged,
//     required this.onBack,
//     required this.onSetWallpaper,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Top chrome with back button and target toggle
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: EdgeInsets.only(
//               top: topPad + 8.h,
//               left: 16.w,
//               right: 16.w,
//               bottom: 24.h,
//             ),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xCC000000), Colors.transparent],
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 AppButton.glass(
//                   icon: const Icon(
//                     FeatherIcons.arrowLeft,
//                     color: Colors.white,
//                     size: 22,
//                   ),
//                   onTap: onBack,
//                 ),
//                 _TargetToggle(
//                   selected: selectedTarget,
//                   onChanged: onTargetChanged,
//                 ),
//                 AppButton.glass(
//                   icon: const Icon(
//                     FeatherIcons.zoomIn,
//                     color: Colors.white,
//                     size: 22,
//                   ),
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Middle action buttons (Adjust, Crop, Filter)
//         Positioned(
//           left: 0,
//           right: 0,
//           top: 0,
//           bottom: 0,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _ActionButton(
//                       icon: FeatherIcons.sliders,
//                       label: 'Adjust',
//                       onTap: () {},
//                     ),
//                     SizedBox(width: 48.w),
//                     _ActionButton(
//                       icon: FeatherIcons.crop,
//                       label: 'Crop',
//                       onTap: () {},
//                     ),
//                     SizedBox(width: 48.w),
//                     _ActionButton(
//                       icon: FeatherIcons.star,
//                       label: 'Filter',
//                       onTap: () => _showFilterBottomSheet(context),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Bottom chrome with Set wallpaper button
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: EdgeInsets.only(
//               top: 48.h,
//               left: 16.w,
//               right: 16.w,
//               bottom: bottomPad + 24.h,
//             ),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [Color(0xCC000000), Colors.transparent],
//               ),
//             ),
//             child: AppButton.primary(
//               label: 'Set wallpaper',
//               icon: const Icon(FeatherIcons.image),
//               isLoading: isBusy,
//               onTap: onSetWallpaper,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showFilterBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.surfaceLow,
//       barrierColor: Colors.black.withOpacity(0.4),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       builder: (_) => _FilterBottomSheet(
//         selectedFilter: selectedFilter,
//         onFilterSelected: onFilterChanged,
//       ),
//     );
//   }
// }

// class _TargetToggle extends StatelessWidget {
//   final WallpaperTarget selected;
//   final ValueChanged<WallpaperTarget> onChanged;

//   const _TargetToggle({
//     required this.selected,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(24.r),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.2),
//           width: 1.0,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _TargetSegment(
//             label: 'Lock\nscreen',
//             isSelected: selected == WallpaperTarget.lockScreen,
//             onTap: () => onChanged(WallpaperTarget.lockScreen),
//           ),
//           _TargetSegment(
//             label: 'Home\nscreen',
//             isSelected: selected == WallpaperTarget.homeScreen,
//             onTap: () => onChanged(WallpaperTarget.homeScreen),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TargetSegment extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _TargetSegment({
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: 16.w,
//           vertical: 8.h,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.primaryContainer
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         child: Text(
//           label,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 11.sp,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//             color: isSelected
//                 ? AppColors.onPrimary
//                 : Colors.white.withOpacity(0.7),
//             height: 1.3,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _ActionButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 56.w,
//             height: 56.w,
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.4),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 1.0,
//               ),
//             ),
//             child: Center(
//               child: Icon(
//                 icon,
//                 color: Colors.white,
//                 size: 24.w,
//               ),
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.white.withOpacity(0.8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FilterBottomSheet extends StatelessWidget {
//   final ImageFilter selectedFilter;
//   final ValueChanged<ImageFilter> onFilterSelected;

//   const _FilterBottomSheet({
//     required this.selectedFilter,
//     required this.onFilterSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(bottom: 16.h),
//               child: Text(
//                 'Filters',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.onSurface,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 200.h,
//               child: GridView.count(
//                 crossAxisCount: 5,
//                 crossAxisSpacing: 12.w,
//                 mainAxisSpacing: 12.h,
//                 children: ImageFilter.values.map((filter) {
//                   return _FilterTile(
//                     filter: filter,
//                     isSelected: selectedFilter == filter,
//                     onSelected: () {
//                       onFilterSelected(filter);
//                       Navigator.pop(context);
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),
//             SizedBox(height: 16.h),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _FilterTile extends StatelessWidget {
//   final ImageFilter filter;
//   final bool isSelected;
//   final VoidCallback onSelected;

//   const _FilterTile({
//     required this.filter,
//     required this.isSelected,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onSelected,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: double.infinity,
//             height: 56.w,
//             decoration: BoxDecoration(
//               color: AppColors.surfaceHigh.withOpacity(0.5),
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(
//                 color: isSelected
//                     ? AppColors.primaryContainer
//                     : AppColors.cardBorder,
//                 width: isSelected ? 2.0 : 1.0,
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 filter.label,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                   color: isSelected
//                       ? AppColors.primaryContainer
//                       : AppColors.onSurfaceVariant,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/features/wallpaper_detail/presentation/pages/wallpaper_preview_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/domain/entities/wallpaper_entity.dart';
import '../cubit/wallpaper_actions_cubit.dart';
import '../cubit/wallpaper_actions_state.dart';
import '../widgets/set_wallpaper_sheet.dart';

enum WallpaperTarget { lockScreen, homeScreen }

enum ImageFilter {
  original('Original'),
  vivid('Vivid'),
  vibrant('Vibrant'),
  warm('Warm'),
  cool('Cool'),
  contrast('Contrast'),
  soft('Soft'),
  dramatic('Dramatic'),
  sepia('Sepia'),
  noir('Noir');

  const ImageFilter(this.label);
  final String label;

  ColorFilter get colorFilter {
    switch (this) {
      case ImageFilter.original:
        return const ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.vivid:
        return const ColorFilter.matrix([
          1.2,
          0,
          0,
          0,
          0,
          0,
          1.3,
          0,
          0,
          0,
          0,
          0,
          1.1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.vibrant:
        return const ColorFilter.matrix([
          1.1,
          0,
          0,
          0,
          0,
          0,
          1.5,
          0,
          0,
          0,
          0,
          0,
          1.0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.warm:
        return const ColorFilter.matrix([
          1.1,
          0,
          0,
          0,
          30,
          0,
          0.9,
          0,
          0,
          10,
          0,
          0,
          0.7,
          0,
          -20,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.cool:
        return const ColorFilter.matrix([
          0.9,
          0,
          0,
          0,
          -10,
          0,
          0.95,
          0,
          0,
          5,
          0,
          0,
          1.2,
          0,
          30,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.contrast:
        return const ColorFilter.matrix([
          1.3,
          0,
          0,
          0,
          -20,
          0,
          1.3,
          0,
          0,
          -20,
          0,
          0,
          1.3,
          0,
          -20,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.soft:
        return const ColorFilter.matrix([
          0.9,
          0,
          0,
          0,
          20,
          0,
          0.9,
          0,
          0,
          20,
          0,
          0,
          0.9,
          0,
          20,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.dramatic:
        return const ColorFilter.matrix([
          1.4,
          0,
          0,
          0,
          -30,
          0,
          1.3,
          0,
          0,
          -30,
          0,
          0,
          1.2,
          0,
          -30,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.sepia:
        return const ColorFilter.matrix([
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilter.noir:
        return const ColorFilter.matrix([
          0.2,
          0.2,
          0.2,
          0,
          0,
          0.2,
          0.2,
          0.2,
          0,
          0,
          0.2,
          0.2,
          0.2,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Root screen
// ─────────────────────────────────────────────────────────────────────────────
class WallpaperPreviewScreen extends StatelessWidget {
  final WallpaperEntity wallpaper;

  const WallpaperPreviewScreen({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WallpaperActionsCubit>(),
      child: _PreviewView(wallpaper: wallpaper),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stateful view
// ─────────────────────────────────────────────────────────────────────────────
class _PreviewView extends StatefulWidget {
  final WallpaperEntity wallpaper;

  const _PreviewView({required this.wallpaper});

  @override
  State<_PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<_PreviewView> {
  WallpaperTarget _selectedTarget = WallpaperTarget.lockScreen;
  ImageFilter _selectedFilter = ImageFilter.original;
  bool _showControls = true;
  bool _isFavourited = false;

  String get _imageUrl => widget.wallpaper.imageUrl.isNotEmpty
      ? widget.wallpaper.imageUrl
      : widget.wallpaper.cardImageUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _onSetWallpaper() async {
    final target = await SetWallpaperSheet.show(context);
    if (target == null || !mounted) return;

    await context.read<WallpaperActionsCubit>().setWallpaper(
      imageUrl: _imageUrl,
      wallpaperId: widget.wallpaper.id,
      target: target,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<WallpaperActionsCubit, WallpaperActionsState>(
        listenWhen: (prev, curr) =>
            curr.message != null && prev.message != curr.message,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.status == WallpaperActionStatus.failure
                    ? AppColors.errorContainer
                    : AppColors.surfaceHigh,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            );
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Full-screen filtered image ──
                ColorFiltered(
                  colorFilter: _selectedFilter.colorFilter,
                  child: CachedNetworkImage(
                    imageUrl: _imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryContainer,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: Colors.black,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),

                // ── Controls overlay ──
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Stack(
                      children: [
                        // Top bar
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _TopBar(
                            topPad: topPad,
                            selectedTarget: _selectedTarget,
                            isFavourited: _isFavourited,
                            onBack: () => context.pop(),
                            onTargetChanged: (t) =>
                                setState(() => _selectedTarget = t),
                            onFavourite: () =>
                                setState(() => _isFavourited = !_isFavourited),
                          ),
                        ),

                        // Bottom section
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _BottomSection(
                            bottomPad: bottomPad,
                            imageUrl: _imageUrl,
                            selectedFilter: _selectedFilter,
                            isBusy: state.isBusy,
                            onFilterChanged: (f) =>
                                setState(() => _selectedFilter = f),
                            onSetWallpaper: _onSetWallpaper,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar — back | Lock/Home toggle | Heart
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final double topPad;
  final WallpaperTarget selectedTarget;
  final bool isFavourited;
  final VoidCallback onBack;
  final ValueChanged<WallpaperTarget> onTargetChanged;
  final VoidCallback onFavourite;

  const _TopBar({
    required this.topPad,
    required this.selectedTarget,
    required this.isFavourited,
    required this.onBack,
    required this.onTargetChanged,
    required this.onFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: topPad + 8.h,
        left: 16.w,
        right: 16.w,
        bottom: 40.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          _GlassIconButton(icon: FeatherIcons.arrowLeft, onTap: onBack),
          const Spacer(),
          _TargetToggle(selected: selectedTarget, onChanged: onTargetChanged),
          const Spacer(),
          _GlassIconButton(
            icon: isFavourited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            onTap: onFavourite,
            activeColor: isFavourited ? const Color(0xFFFF4D6D) : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom section — filter label + strip + set button
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSection extends StatelessWidget {
  final double bottomPad;
  final String imageUrl;
  final ImageFilter selectedFilter;
  final bool isBusy;
  final ValueChanged<ImageFilter> onFilterChanged;
  final VoidCallback onSetWallpaper;

  const _BottomSection({
    required this.bottomPad,
    required this.imageUrl,
    required this.selectedFilter,
    required this.isBusy,
    required this.onFilterChanged,
    required this.onSetWallpaper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 56.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xF0000000), Color(0x88000000), Colors.transparent],
          stops: [0.0, 0.65, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active filter name pill
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Container(
              key: ValueKey(selectedFilter),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  width: 1.0,
                ),
              ),
              child: Text(
                selectedFilter.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Horizontal filter strip with image thumbnails
          SizedBox(
            height: 82.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: ImageFilter.values.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, i) {
                final filter = ImageFilter.values[i];
                return _FilterThumbnail(
                  filter: filter,
                  imageUrl: imageUrl,
                  isSelected: filter == selectedFilter,
                  onTap: () => onFilterChanged(filter),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),

          // Divider line
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            color: Colors.white.withOpacity(0.08),
          ),
          SizedBox(height: 20.h),

          // Set wallpaper button
          Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: bottomPad + 16.h,
            ),
            child: AppButton.primary(
              label: 'Set Wallpaper',
              icon: const Icon(FeatherIcons.image, size: 18),
              isLoading: isBusy,
              onTap: onSetWallpaper,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter thumbnail — image preview with filter applied
// ─────────────────────────────────────────────────────────────────────────────
class _FilterThumbnail extends StatelessWidget {
  final ImageFilter filter;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterThumbnail({
    required this.filter,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 54.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : Colors.white.withOpacity(0.12),
                  width: isSelected ? 2.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryContainer.withOpacity(0.35),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSelected ? 9.5.r : 11.r),
                child: ColorFiltered(
                  colorFilter: filter.colorFilter,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceHigh),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceHigh,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white24,
                        size: 18.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),

            // Label
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primaryContainer
                    : Colors.white.withOpacity(0.5),
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lock / Home toggle
// ─────────────────────────────────────────────────────────────────────────────
class _TargetToggle extends StatelessWidget {
  final WallpaperTarget selected;
  final ValueChanged<WallpaperTarget> onChanged;

  const _TargetToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: WallpaperTarget.values.map((target) {
          final isSelected = target == selected;
          final label = target == WallpaperTarget.lockScreen ? 'Lock' : 'Home';
          return GestureDetector(
            onTap: () => onChanged(target),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.onPrimary
                      : Colors.white.withOpacity(0.65),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass icon button
// ─────────────────────────────────────────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? activeColor;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.38),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Center(
          child: Icon(icon, color: activeColor ?? Colors.white, size: 20.w),
        ),
      ),
    );
  }
}
