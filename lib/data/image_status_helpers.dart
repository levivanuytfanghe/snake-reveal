import 'package:shared_preferences/shared_preferences.dart';

String normalizeTheme(String theme) => theme.trim().toLowerCase();

String extractThemeFromUrl(String imageUrl) {
  final uri = Uri.tryParse(imageUrl);
  if (uri == null || !uri.path.contains('/')) return '';
  final parts = uri.path.split('/');
  if (parts.length < 2) return '';
  final theme = Uri.decodeComponent(parts[1]);
  return theme.trim();
}

Future<bool> markImageAsUnlocked(String imageUrl) async {
  final prefs = await SharedPreferences.getInstance();
  final unlockedImages = prefs.getStringList('unlockedImages') ?? [];
  final openedThemes = prefs.getStringList('openedThemes') ?? [];
  if (!unlockedImages.contains(imageUrl)) {
    unlockedImages.add(imageUrl);
    await prefs.setStringList('unlockedImages', unlockedImages);
    // Ensure the new image is marked as unseen so that the badge will appear
    final seenImages = prefs.getStringList('seenImages') ?? [];
    if (seenImages.contains(imageUrl)) {
      seenImages.remove(imageUrl);
      await prefs.setStringList('seenImages', seenImages);
    }
    // Ensure badge appears when unlocking a new image
    final theme = normalizeTheme(extractThemeFromUrl(imageUrl));
    if (openedThemes.contains(theme)) {
      openedThemes.remove(theme);
      await prefs.setStringList('openedThemes', openedThemes);
    }
    return true;
  } else {
    return false;
  }
}

Future<void> markImageAsSeen(String imageUrl) async {
  final prefs = await SharedPreferences.getInstance();
  final seenImages = prefs.getStringList('seenImages') ?? [];
  if (!seenImages.contains(imageUrl)) {
    seenImages.add(imageUrl);
    await prefs.setStringList('seenImages', seenImages);
  }
}

Future<void> markAllImagesAsSeenForTheme(
  String theme,
  List<String> imageUrls,
) async {
  final prefs = await SharedPreferences.getInstance();
  final seenImages = prefs.getStringList('seenImages') ?? [];

  for (final url in imageUrls) {
    if (!seenImages.contains(url)) {
      seenImages.add(url);
    }
  }

  await prefs.setStringList('seenImages', seenImages);
}

Future<Map<String, bool>> getBadgeMap() async {
  final prefs = await SharedPreferences.getInstance();
  final unlocked = prefs.getStringList('unlockedImages') ?? [];
  final seen = prefs.getStringList('seenImages') ?? [];
  final openedThemes = prefs.getStringList('openedThemes') ?? [];

  final unseen = unlocked.where((url) => !seen.contains(url)).toList();
  final badgeMap = <String, bool>{};

  for (final url in unseen) {
    final theme = normalizeTheme(extractThemeFromUrl(url));
    if (!openedThemes.contains(theme)) {
      badgeMap[theme] = true;
    }
  }

  return badgeMap;
}

Future<void> markThemeAsOpened(String theme) async {
  final prefs = await SharedPreferences.getInstance();
  final openedThemes = prefs.getStringList('openedThemes') ?? [];

  final normalized = normalizeTheme(theme);
  if (!openedThemes.contains(normalized)) {
    openedThemes.add(normalized);
    await prefs.setStringList('openedThemes', openedThemes);
  }
}

Future<void> markThemeAsNotOpened(String theme) async {
  final prefs = await SharedPreferences.getInstance();
  final openedThemes = prefs.getStringList('openedThemes') ?? [];
  final normalized = normalizeTheme(theme);
  if (openedThemes.contains(normalized)) {
    openedThemes.remove(normalized);
    await prefs.setStringList('openedThemes', openedThemes);
  }
}

Future<void> markThemeAsSeen(String theme, List<String> imageUrls) async {
  await markThemeAsOpened(theme);
}

Future<bool> hasNewImageForTheme(String theme, List<String> imageUrls) async {
  final prefs = await SharedPreferences.getInstance();
  final seenImages = prefs.getStringList('seenImages') ?? [];
  final normalized = normalizeTheme(theme);

  for (final url in imageUrls) {
    final imageTheme = normalizeTheme(extractThemeFromUrl(url));
    if (imageTheme == normalized && !seenImages.contains(url)) {
      return true;
    }
  }
  return false;
}

/// Marks the given list of image URLs as seen, preserving existing entries.
Future<void> markImagesAsSeen(List<String> imageUrls) async {
  final prefs = await SharedPreferences.getInstance();
  final seenImages = prefs.getStringList('seenImages') ?? [];
  // Add only URLs not already present
  final updatedSeen = [
    ...seenImages,
    ...imageUrls.where((url) => !seenImages.contains(url)),
  ];
  await prefs.setStringList('seenImages', updatedSeen);
}

Future<List<ImageStatus>> loadImageStatuses(List<String> imageUrls) async {
  final prefs = await SharedPreferences.getInstance();
  final unlocked = prefs.getStringList('unlockedImages') ?? [];
  final seen = prefs.getStringList('seenImages') ?? [];

  final statuses = imageUrls.map((url) {
    final isUnlocked = unlocked.contains(url);
    final isSeen = seen.contains(url);
    final isNew = isUnlocked && !isSeen;
    return ImageStatus(isUnlocked: isUnlocked, isNew: isNew, url: url);
  }).toList();

  return statuses;
}

class ImageStatus {
  final bool isUnlocked;
  final bool isNew;
  final String url;

  ImageStatus({
    required this.isUnlocked,
    required this.isNew,
    required this.url,
  });

  factory ImageStatus.fromJson(Map<String, dynamic> json) {
    return ImageStatus(
      isUnlocked: json['isUnlocked'] ?? false,
      isNew: json['isNew'] ?? false,
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'isUnlocked': isUnlocked, 'isNew': isNew, 'url': url};
  }
}
