import 'package:flutter/material.dart';
import 'package:snake_reveal/app/app_colors.dart';
import 'dart:ui' as ui;

class WinOverlay extends StatelessWidget {
  final int score;
  final bool isNewHighScore;
  final VoidCallback onBackToMenu;
  final ui.Image? backgroundImage;

  const WinOverlay({
    super.key,
    required this.score,
    required this.isNewHighScore,
    required this.onBackToMenu,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (backgroundImage != null)
          Positioned.fill(
            child: RawImage(image: backgroundImage, fit: BoxFit.cover),
          ),
        Positioned.fill(
          child: Container(
            color: const Color.fromRGBO(69, 18, 135, 0.6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You Win!',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isNewHighScore)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'NEW HIGH SCORE!',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      side: BorderSide(color: AppColors.neonGreen, width: 2),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: onBackToMenu,
                    child: Text(
                      'Back to main menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
