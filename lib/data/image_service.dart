import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  static Future<String?> selectImageToReveal(
    Map<String, List<String>> themes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final nextBg = prefs.getString('nextBackground');
    if (nextBg != null) {
      await prefs.remove('nextBackground');
      return nextBg;
    }
    final unlocked = prefs.getStringList('unlockedImages') ?? [];

    final allRevealable = <String>[];
    for (final list in themes.values) {
      allRevealable.addAll(list.where((img) => !unlocked.contains(img)));
    }

    if (allRevealable.isEmpty) return null;

    allRevealable.shuffle();
    final chosen = allRevealable.first;
    return chosen;
  }

  Future<Map<String, bool>> getBadgeMap(
    Map<String, List<String>> themes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList('unlockedImages') ?? [];
    final seenThemes = prefs.getStringList('seenThemes') ?? [];

    final Map<String, bool> badgeMap = {};

    for (final entry in themes.entries) {
      final theme = entry.key;
      final hasUnseen =
          entry.value.any((url) => unlocked.contains(url)) &&
          !seenThemes.contains(theme);
      if (hasUnseen) {
        badgeMap[theme] = true;
      }
    }

    return badgeMap;
  }

  Future<void> markThemeAsSeen(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    final seenThemes = prefs.getStringList('seenThemes') ?? [];
    if (!seenThemes.contains(theme)) {
      seenThemes.add(theme);
      await prefs.setStringList('seenThemes', seenThemes);
    }
  }

  Future<void> setNextBackground(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nextBackground', imageUrl);
  }

  Future<String?> getNextBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nextBackground');
  }
}
