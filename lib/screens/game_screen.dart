import '../models/game_session.dart';
import '../services/game_state_service.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/game_canvas.dart';
import '../widgets/game_controls.dart';
import '../controllers/snake_controller.dart';
import 'settings_screen.dart';
import '../services/image_loader.dart';
import '../services/settings_service.dart';
import '../data/image_status_helpers.dart' as helpers;
import 'reveal_gallery_screen.dart';
import '../data/maps.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<GameControlsState> gameControlsKey = GlobalKey();

  late GameSession session;
  GameMap currentMap = classicMap;

  late SnakeController snakeController;
  late FocusNode _keyboardFocusNode;

  void highlightControllerButton(Direction direction) {
    gameControlsKey.currentState?.highlight(direction);
  }

  void updateCurrentMapFromSettings() {
    final settings = SettingsService();
    currentMap = gameMaps.firstWhere(
      (gameMap) => gameMap.name == settings.selectedMapName,
      orElse: () => classicMap,
    );
  }

  @override
  void initState() {
    super.initState();
    session = GameSession();
    _keyboardFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });

    session.showImageWithoutOverlay = false;
    session.showWinOverlay = false;

    updateCurrentMapFromSettings();
    snakeController = SnakeController();
    snakeController.onDirectionInput = highlightControllerButton;
    snakeController.setWalls(currentMap.walls);
    snakeController.setSafeStartPosition();
    loadImage('assets/images/snakes/snakes1.png').then((img) {
      setState(() {
        session.backgroundImage = img;
      });
    });
    if (!session.showStartScreen) {
      snakeController.start(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    snakeController.stop();
    super.dispose();
  }

  bool hasFocused = false;
  bool _hasNewUnlock = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          snakeController.handleKey(event.logicalKey);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF3A184A),
        appBar: session.showStartScreen
            ? null
            : buildGameAppBar(
                controller: snakeController,
                onPause: () {
                  setState(() {
                    session.isPaused = true;
                    snakeController.stop();
                  });
                },
                onContinue: () {
                  setState(() {
                    session.isPaused = false;
                  });
                  snakeController.resume(() {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                },
              ),
        body: session.showStartScreen
            ? HomeScreen(
                hasNewUnlock: _hasNewUnlock,
                onStartGame: () async {
                  session.selectedImage =
                      await GameStateService.selectImageToReveal();

                  if (session.selectedImage != null) {
                    final loaded = await loadNetworkImage(
                      session.selectedImage!,
                    );
                    await GameStateService.clearSelectedImage();

                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      updateCurrentMapFromSettings();
                      session.backgroundImage = loaded;
                      session.showStartScreen = false;
                      session.showImageWithoutOverlay = false;
                      session.showWinOverlay = false;
                      snakeController.setWalls(currentMap.walls);
                      snakeController.setSafeStartPosition();
                      snakeController.start(() {
                        setState(() {});
                      });
                    });
                  } else {
                    if (!context.mounted) {
                      return;
                    }
                    GameStateService.showAllImagesRevealedMessage(context);
                  }
                },
                onOpenSettings: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  if (!session.showStartScreen && !session.isPaused) {
                    snakeController.resume(() {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  }
                },
                onOpenGallery: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RevealGalleryScreen(),
                    ),
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _hasNewUnlock = false;
                  });
                },
              )
            : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: GameCanvas(
                            controller: snakeController,
                            currentMap: currentMap,
                            backgroundImage: session.backgroundImage!,
                            showImageWithoutOverlay:
                                session.showImageWithoutOverlay,
                            isPaused: session.isPaused,
                            isGameOver: snakeController.isGameOver,
                            showWinOverlay: session.showWinOverlay,
                            isNewHighScore: session.isNewHighScore,
                            prepareWinOverlay: () async {
                              if (session.showWinOverlay ||
                                  session.showImageWithoutOverlay) {
                                return;
                              }
                              snakeController.stop();

                              await GameStateService.prepareWinOverlay(
                                imageUrl: session.selectedImage!,
                                score: snakeController.getScore(),
                                onComplete: (isNew) async {
                                  if (!mounted) {
                                    return;
                                  }

                                  final unlockedNew = await helpers
                                      .markImageAsUnlocked(
                                        session.selectedImage!,
                                      );

                                  setState(() {
                                    session.showImageWithoutOverlay = true;
                                    session.isNewHighScore = isNew;
                                    if (unlockedNew) {
                                      _hasNewUnlock = true;
                                    }
                                  });

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                  ).then((_) {
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      session.showWinOverlay = true;
                                    });
                                  });
                                },
                              );
                            },
                            onBackToMenu: () {
                              setState(() {
                                session.showStartScreen = true;
                                session.isPaused = false;
                                session.showWinOverlay = false;
                                updateCurrentMapFromSettings();
                                snakeController.setWalls(currentMap.walls);
                                snakeController.reset();
                              });
                            },
                            onContinue: () {
                              setState(() {
                                session.isPaused = false;
                              });
                              snakeController.resume(() {
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: GameControls(
                            key: gameControlsKey,
                            onDirectionChange:
                                snakeController.tryChangeDirection,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
