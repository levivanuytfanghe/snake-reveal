import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/image_status_helpers.dart' as helpers;
import '../data/image_service.dart';
import '../app/app_colors.dart';

class ThemeDetailScreen extends StatefulWidget {
  final String theme;
  final List<String> images;

  const ThemeDetailScreen({
    super.key,
    required this.theme,
    required this.images,
  });

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  static const _highScoreKeyPrefix = 'highscore_';

  List<String> unlockedImages = [];
  Map<String, int> highScores = {};
  Map<String, helpers.ImageStatus> imageStatusMap = {};

  @override
  void initState() {
    super.initState();
    _loadUnlockedImages();
  }

  Future<void> _loadUnlockedImages() async {
    // Load current statuses
    final imageStatusMapLoaded = await helpers.loadImageStatuses(widget.images);

    // Derive unlocked images from current statuses
    final unlocked = imageStatusMapLoaded
        .where((status) => status.isUnlocked)
        .map((status) => status.url)
        .toList();

    // Build high scores map for unlocked images
    final scores = <String, int>{};
    for (final imageUrl in unlocked) {
      final score = await getHighScore(imageUrl);
      scores[imageUrl] = score;
    }

    // Update UI with loaded statuses
    if (!mounted) return;
    setState(() {
      unlockedImages = unlocked;
      highScores = scores;
      imageStatusMap = {
        for (final status in imageStatusMapLoaded) status.url: status,
      };
    });
  }

  String _highScoreKeyForUrl(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    final fileName = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : imageUrl;
    return '$_highScoreKeyPrefix$fileName';
  }

  Future<int> getHighScore(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();

    // Canonical key: prefix + file name (no query params)
    final canonicalKey = _highScoreKeyForUrl(imageUrl);
    final canonical = prefs.getInt(canonicalKey);
    if (canonical != null) return canonical;

    // Fallbacks for historical/key-mismatch cases
    final uri = Uri.tryParse(imageUrl);
    final fileName = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : imageUrl;
    final fallbackKeys = <String>[
      // Full URL stored directly
      '$_highScoreKeyPrefix$imageUrl',
      // URL encoded
      '$_highScoreKeyPrefix${Uri.encodeComponent(imageUrl)}',
      // Alternate underscore style used elsewhere
      'high_score_$fileName',
    ];

    for (final k in fallbackKeys) {
      final v = prefs.getInt(k);
      if (v != null) {
        // Migrate to canonical key for consistency going forward
        await prefs.setInt(canonicalKey, v);
        return v;
      }
    }

    return 0;
  }

  Future<void> _markSeenOnExit() async {
    // Collect only images that are both unlocked and currently marked as NEW
    final toMark = imageStatusMap.entries
        .where((e) => e.value.isUnlocked && e.value.isNew)
        .map((e) => e.key)
        .toList();

    if (toMark.isEmpty) return;
    await helpers.markThemeAsSeen(widget.theme, toMark);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // already popped, nothing to do
        // Run async work before popping manually
        () async {
          await _markSeenOnExit();
          if (!context.mounted) return;
          Navigator.of(context).pop(true); // signal caller to refresh
        }();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // Mark all NEW+unlocked images as seen (same as tapping an image)
              final toMark = imageStatusMap.entries
                  .where((e) => e.value.isUnlocked && e.value.isNew)
                  .map((e) => e.key)
                  .toList();

              for (final url in toMark) {
                await helpers.markImageAsSeen(url);
              }

              if (!context.mounted) return;
              Navigator.of(context).pop(true); // signal caller to refresh
            },
          ),
          title: Text(widget.theme),
          backgroundColor: AppColors.appBar,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/screens/reveal_gallery.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.images.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                crossAxisSpacing: 12,
                mainAxisSpacing: 24,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final imageUrl = widget.images[index];
                final isUnlocked = unlockedImages.contains(imageUrl);

                return GestureDetector(
                  onTap: isUnlocked
                      ? () async {
                          await helpers.markImageAsSeen(imageUrl);
                          await ImageService().setNextBackground(imageUrl);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Selected for next game',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: AppColors.appBar,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      : null,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: isUnlocked
                                      ? NetworkImage(imageUrl)
                                      : const AssetImage(
                                              'assets/images/screens/question.png',
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if ((imageStatusMap[imageUrl]?.isNew == true) &&
                                isUnlocked)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isUnlocked)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'High Score: ${highScores[imageUrl] ?? 0}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
