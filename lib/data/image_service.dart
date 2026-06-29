import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  static Future<String?> kiesOnthullendeAfbeelding(
    Map<String, List<String>> themes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // Gebruik vooraf gekozen achtergrond, indien aanwezig
    final nextBg = prefs.getString('nextBackground');
    if (nextBg != null) {
      // Consumptie: wis de keuze na gebruik
      await prefs.remove('nextBackground');
      return nextBg;
    }
    final unlocked = prefs.getStringList('unlockedImages') ?? [];

    // Verzamelen van alle nog niet vrijgegeven afbeeldingen
    final alleOnthulbare = <String>[];
    for (final lijst in themes.values) {
      alleOnthulbare.addAll(lijst.where((img) => !unlocked.contains(img)));
    }

    if (alleOnthulbare.isEmpty) return null; // alles reeds vrijgespeeld

    alleOnthulbare.shuffle();
    final gekozen = alleOnthulbare.first;
    return gekozen;
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

  /// Stel de achtergrond in voor het volgende spel.
  Future<void> setNextBackground(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nextBackground', imageUrl);
  }

  /// Haal de ingestelde achtergrond op voor het volgende spel.
  Future<String?> getNextBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nextBackground');
  }
}
