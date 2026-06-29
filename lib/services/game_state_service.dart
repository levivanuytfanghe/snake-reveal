import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/image_service.dart';
import 'high_score_service.dart';
import 'image_loader.dart';

/// Manages game state, images, and scores
class GameStateService {
  static Future<String?> selectImageToReveal() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedImage = prefs.getString('selectedImage');

    if (selectedImage == null) {
      final themeData = await loadThemesJson();
      selectedImage = await ImageService.selectImageToReveal(themeData);
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
    final key = HighScoreService.getHighScoreKey(imageUrl);

    final currentHighScore = prefs.getInt(key) ?? 0;
    final isNewHighScore = score > currentHighScore;

    if (isNewHighScore) {
      await prefs.setInt(key, score);
    }

    // Simulate delay for effect
    await Future.delayed(const Duration(seconds: 2));
    onComplete(isNewHighScore);
  }

  static String extractThemeFromImageUrl(String imageUrl) {
    return HighScoreService.extractThemeFromUrl(imageUrl);
  }
}
