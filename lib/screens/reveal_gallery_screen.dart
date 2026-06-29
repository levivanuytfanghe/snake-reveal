import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/image_status_helpers.dart' as helpers;
import 'theme_detail_screen.dart';

class RevealGalleryScreen extends StatefulWidget {
  const RevealGalleryScreen({super.key});

  @override
  RevealGalleryScreenState createState() => RevealGalleryScreenState();
}

class RevealGalleryScreenState extends State<RevealGalleryScreen> {
  Map<String, List<String>> themeData = {};
  bool isLoading = true;
  int _badgeEpoch = 0;

  final List<String> themes = [
    'Dino',
    'Pride',
    'Special Days',
    'Mechanics',
    'Cities',
    'Amusement',
    'Animals',
    'Candy',
    'Pixelart',
    'Space',
    'Snakes',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
    loadThemes();
  }

  Future<void> loadThemes() async {
    final jsonString = await rootBundle.loadString('assets/data/themes.json');
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    final Map<String, List<String>> loadedThemeData = jsonMap.map(
      (key, value) => MapEntry(key.toLowerCase(), List<String>.from(value)),
    );

    setState(() {
      themeData = loadedThemeData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reveal Gallery'),
        backgroundColor: const Color(0xFF321C47),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/screens/reveal_gallery.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: themes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      final theme = themes[index];
                      final imageUrls = themeData[theme.toLowerCase()] ?? [];
                      return GestureDetector(
                        onTap: () async {
                          final images = imageUrls;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ThemeDetailScreen(
                                theme: theme,
                                images: images,
                              ),
                            ),
                          );

                          await loadThemes();
                          if (!mounted) return;
                          setState(() {
                            _badgeEpoch++;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/images/screens/scales.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black54,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  theme,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: FutureBuilder<List<helpers.ImageStatus>>(
                                  key: ValueKey('badge-$theme-$_badgeEpoch'),
                                  future: helpers.loadImageStatuses(imageUrls),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData &&
                                        snapshot.data!.any(
                                          (status) =>
                                              status.isUnlocked && status.isNew,
                                        )) {
                                      return CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.red,
                                        child: const Text(
                                          'NEW',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 64,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/screens/scales.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black54,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'More coming soon',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
