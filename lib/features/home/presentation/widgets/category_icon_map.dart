// lib/features/home/presentation/widgets/category_icon_map.dart

import 'package:flutter/material.dart';

/// Maps the `iconName` string stored on a category document (admin panel
/// uses Material icon names, e.g. "auto_awesome", "landscape") to a
/// Flutter [IconData]. Falls back to [Icons.category] for anything
/// unmapped so a new icon added in the admin never crashes the app.
IconData categoryIconFromName(String iconName) {
  switch (iconName) {
    case 'auto_awesome':
      return Icons.auto_awesome;
    case 'landscape':
    case 'nature':
      return Icons.landscape;
    case 'location_city':
    case 'cityscape':
      return Icons.location_city;
    case 'memory':
    case 'tech':
      return Icons.memory;
    case 'rocket_launch':
    case 'space':
      return Icons.rocket_launch;
    case 'palette':
    case 'art':
      return Icons.palette;
    case 'pets':
      return Icons.pets;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'directions_car':
      return Icons.directions_car;
    case 'movie':
      return Icons.movie;
    case 'favorite':
      return Icons.favorite;
    case 'wb_sunny':
      return Icons.wb_sunny;
    case 'forest':
      return Icons.forest;
    case 'waves':
      return Icons.waves;
    default:
      return Icons.category;
  }
}

/// Parses a hex color string ("#F5C518" or "F5C518") to a [Color].
/// Falls back to [fallback] on any parse failure.
Color hexToColor(String hex, {required Color fallback}) {
  try {
    var value = hex.replaceAll('#', '').trim();
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  } catch (_) {
    return fallback;
  }
}
