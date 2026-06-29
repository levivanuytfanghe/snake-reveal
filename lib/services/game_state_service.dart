import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/image_service.dart';
import '../data/image_loader.dart';

class GameStateService {
  static String _highScoreKeyForUrl(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    final fileName = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : imageUrl;
    return 'highscore_$fileName';
  }

  static Future<String?> selectImageToReveal() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedImage = prefs.getString('selectedImage');

    if (selectedImage == null) {
      final themeData = await loadThemesJson();
      selectedImage = await ImageService.selectImageToReveal(
        themeData,
      );
    }

    return selectedImage;
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

    final canonicalKey = _highScoreKeyForUrl(imageUrl);

    final legacyKeys = <String>[
      'highscore_$imageUrl',
      'highscore_${Uri.encodeComponent(imageUrl)}',
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

    await prefs.setInt(canonicalKey, valueToPersist);

    for (final k in legacyKeys) {
      await prefs.remove(k);
    }

    await Future.delayed(const Duration(seconds: 2));

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
