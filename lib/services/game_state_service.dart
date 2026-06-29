import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/image_service.dart';
import '../data/image_loader.dart';

class GameStateService {
  // Returns canonical highscore key for an image url (by filename)
  static String _highScoreKeyForUrl(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    final fileName = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : imageUrl;
    return 'highscore_$fileName';
  }

  static Future<String?> selectImageToReveal() async {
    final prefs = await SharedPreferences.getInstance();
    String? gekozenAfbeelding = prefs.getString('selectedImage');

    if (gekozenAfbeelding == null) {
      final themaData = await loadThemesJson();
      gekozenAfbeelding = await ImageService.kiesOnthullendeAfbeelding(
        themaData,
      );
    }

    return gekozenAfbeelding;
  }

  static Future<void> clearSelectedImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedImage');
  }

  static void showAllImagesRevealedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All images have been revealed!')),
    );
  }

  static Future<void> prepareWinOverlay({
    required String imageUrl,
    required int score,
    required void Function(bool isNewHighScore) onComplete,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Canonical key based on filename (uniform across app)
    final canonicalKey = _highScoreKeyForUrl(imageUrl);

    // Gather existing from canonical and legacy keys
    final legacyKeys = <String>[
      'highscore_$imageUrl',
      'highscore_${Uri.encodeComponent(imageUrl)}',
      // Historical underscore variant
      'high_score_${Uri.tryParse(imageUrl)?.pathSegments.isNotEmpty == true ? Uri.parse(imageUrl).pathSegments.last : imageUrl}',
    ];

    int bestExisting = prefs.getInt(canonicalKey) ?? 0;
    for (final k in legacyKeys) {
      final v = prefs.getInt(k);
      if (v != null && v > bestExisting) {
        bestExisting = v;
      }
    }

    final isNewHighScore = score > bestExisting;
    final valueToPersist = isNewHighScore ? score : bestExisting;

    // Persist to canonical key
    await prefs.setInt(canonicalKey, valueToPersist);

    // Optional: clean up legacy keys to avoid future confusion
    for (final k in legacyKeys) {
      await prefs.remove(k);
    }

    // Simuleer kleine vertraging voor effect
    await Future.delayed(const Duration(seconds: 2));

    // Callback naar GameScreen om overlay te tonen
    onComplete(isNewHighScore);
  }

  static String extractThemeFromImageUrl(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    if (pathSegments.length >= 2) {
      final rawTheme = pathSegments[pathSegments.length - 2];
      return Uri.decodeComponent(rawTheme);
    }
    return 'Unknown';
  }
}
