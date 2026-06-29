import 'dart:ui';

class GameSession {
  bool showStartScreen;
  bool isPaused;
  bool toonWinOverlay;
  bool toonAfbeeldingZonderOverlay;
  bool isNewHighScore;
  String? gekozenAfbeelding;
  Image? backgroundImage;

  GameSession({
    this.showStartScreen = true,
    this.isPaused = false,
    this.toonWinOverlay = false,
    this.toonAfbeeldingZonderOverlay = false,
    this.isNewHighScore = false,
    this.gekozenAfbeelding,
    this.backgroundImage,
  });

  void reset() {
    showStartScreen = true;
    isPaused = false;
    toonWinOverlay = false;
    toonAfbeeldingZonderOverlay = false;
    isNewHighScore = false;
    gekozenAfbeelding = null;
    backgroundImage = null;
  }
}
