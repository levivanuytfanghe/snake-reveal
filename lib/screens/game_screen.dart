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
import '../data/image_loader.dart';
import '../data/image_status_helpers.dart' as helpers;
import 'reveal_gallery_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<GameControlsState> gameControlsKey = GlobalKey();

  late GameSession session;

  late SnakeController snakeController;
  late FocusNode _keyboardFocusNode;

  void highlightControllerButton(Direction direction) {
    gameControlsKey.currentState?.highlight(direction);
  }

  @override
  void initState() {
    super.initState();
    session = GameSession();
    _keyboardFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });

    // Ensure these are reset at init
    session.toonAfbeeldingZonderOverlay = false;
    session.toonWinOverlay = false;

    snakeController = SnakeController();
    snakeController.onDirectionInput = highlightControllerButton;
    loadImage('assets/images/slangen/slangen1.png').then((img) {
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
  bool _hasNewUnlock = false; // indicator for Reveal Gallery button

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
                  session.gekozenAfbeelding =
                      await GameStateService.selectImageToReveal();

                  if (session.gekozenAfbeelding != null) {
                    final geladen = await loadNetworkImage(
                      session.gekozenAfbeelding!,
                    );
                    await GameStateService.clearSelectedImage();

                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      session.backgroundImage = geladen;
                      session.showStartScreen = false;
                      session.toonAfbeeldingZonderOverlay = false;
                      session.toonWinOverlay = false;
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
                    _hasNewUnlock = false; // user visited gallery, clear dot
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
                            backgroundImage: session.backgroundImage!,
                            toonAfbeeldingZonderOverlay:
                                session.toonAfbeeldingZonderOverlay,
                            isPaused: session.isPaused,
                            isGameOver: snakeController.isGameOver,
                            toonWinOverlay: session.toonWinOverlay,
                            isNewHighScore: session.isNewHighScore,
                            prepareWinOverlay: () async {
                              if (session.toonWinOverlay ||
                                  session.toonAfbeeldingZonderOverlay) {
                                return;
                              }
                              snakeController.stop();

                              await GameStateService.prepareWinOverlay(
                                imageUrl: session.gekozenAfbeelding!,
                                score: snakeController.getScore(),
                                onComplete: (isNew) async {
                                  if (!mounted) {
                                    return;
                                  }

                                  final unlockedNew = await helpers
                                      .markImageAsUnlocked(
                                        session.gekozenAfbeelding!,
                                      );

                                  setState(() {
                                    session.toonAfbeeldingZonderOverlay = true;
                                    session.isNewHighScore = isNew;
                                    if (unlockedNew) {
                                      _hasNewUnlock =
                                          true; // only show indicator if something new was unlocked
                                    }
                                  });

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                  ).then((_) {
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      session.toonWinOverlay = true;
                                    });
                                  });
                                },
                              );
                            },
                            onBackToMenu: () {
                              setState(() {
                                // Return to the start screen, but keep reveal-gallery flags intact
                                session.showStartScreen = true;
                                session.isPaused = false;
                                session.toonWinOverlay = false;
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
