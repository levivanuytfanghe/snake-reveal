import 'dart:ui';

class GameSession {
  bool showStartScreen;
  bool isPaused;
  bool showWinOverlay;
  bool showImageWithoutOverlay;
  bool isNewHighScore;
  String? selectedImage;
  Image? backgroundImage;

  GameSession({
    this.showStartScreen = true,
    this.isPaused = false,
    this.showWinOverlay = false,
    this.showImageWithoutOverlay = false,
    this.isNewHighScore = false,
    this.selectedImage,
    this.backgroundImage,
  });

  void reset() {
    showStartScreen = true;
    isPaused = false;
    showWinOverlay = false;
    showImageWithoutOverlay = false;
    isNewHighScore = false;
    selectedImage = null;
    backgroundImage = null;
  }
}
