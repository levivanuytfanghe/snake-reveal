/// Service for managing high score persistence
/// Handles canonical key naming and legacy key cleanup
class HighScoreService {
  static const String _highScoreKeyPrefix = 'highscore_';

  /// Get canonical high score key based on image filename
  static String getHighScoreKey(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    final fileName = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : imageUrl;
    return '$_highScoreKeyPrefix$fileName';
  }

  /// Extract theme from image URL path
  static String extractThemeFromUrl(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        final rawTheme = pathSegments[pathSegments.length - 2];
        return Uri.decodeComponent(rawTheme);
      }
    } catch (e) {
      // Silently fail for invalid URLs
    }
    return 'Unknown';
  }
}
