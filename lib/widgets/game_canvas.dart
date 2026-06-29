import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'snake_canvas.dart';
import 'win_overlay.dart';
import '../app/app_colors.dart';
import '../controllers/snake_controller.dart';
import '../data/maps.dart';

class GameCanvas extends StatelessWidget {
  final SnakeController controller;
  final GameMap currentMap;
  final ui.Image? backgroundImage;
  final bool showImageWithoutOverlay;
  final bool isPaused;
  final bool isGameOver;
  final bool showWinOverlay;
  final bool isNewHighScore;
  final Future<void> Function() prepareWinOverlay;
  final VoidCallback onBackToMenu;
  final VoidCallback onContinue;

  const GameCanvas({
    super.key,
    required this.controller,
    required this.currentMap,
    required this.backgroundImage,
    required this.showImageWithoutOverlay,
    required this.isPaused,
    required this.isGameOver,
    required this.showWinOverlay,
    required this.isNewHighScore,
    required this.prepareWinOverlay,
    required this.onBackToMenu,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const columns = 20;
    const rows = 30;
    final cellSize = width * 0.9 / columns;
    final canvasHeight = cellSize * rows;

    return Center(
      child: SizedBox(
        width: width * 0.9,
        height: canvasHeight,
        child: Stack(
          children: [
            SnakeCanvas(
              controller: controller,
              image: backgroundImage!,
              walls: currentMap.walls,
            ),
            if (showImageWithoutOverlay &&
                backgroundImage != null &&
                !showWinOverlay)
              Positioned.fill(
                child: RawImage(image: backgroundImage, fit: BoxFit.cover),
              ),
            if (isPaused)
              _buildOverlay(context, 'Snake on a break', [
                _buildButton(context, 'Continue', onContinue),
                _buildButton(context, 'Back to main menu', onBackToMenu),
              ]),
            if (isGameOver)
              _buildOverlay(context, 'Game Over', [
                _buildButton(context, 'Retry', controller.reset),
                _buildButton(context, 'Back to main menu', onBackToMenu),
              ]),
            if (controller.getProgressPercent() >= 1)
              Positioned.fill(
                child: FutureBuilder<void>(
                  future: prepareWinOverlay(),
                  builder: (context, snapshot) => const SizedBox.shrink(),
                ),
              ),
            if (showWinOverlay)
              Positioned.fill(
                child: WinOverlay(
                  score: controller.getScore(),
                  isNewHighScore: isNewHighScore,
                  backgroundImage: backgroundImage,
                  onBackToMenu: onBackToMenu,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    String title,
    List<Widget> buttons,
  ) {
    return Container(
      color: const Color.fromRGBO(69, 18, 135, 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.08,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ...buttons,
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          side: const BorderSide(color: AppColors.neonGreen, width: 2),
          shape: const StadiumBorder(),
        ),
        onPressed: () {
          onPressed();
        },
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
