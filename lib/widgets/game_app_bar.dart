import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../controllers/snake_controller.dart';

PreferredSizeWidget buildGameAppBar({
  required SnakeController controller,
  required VoidCallback onPause,
  VoidCallback? onContinue,
}) {
  return AppBar(
    backgroundColor: const Color(0xFF3A184A),
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Score: ${controller.getScore()}',
          style: const TextStyle(color: AppColors.neonGreen),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(controller.getProgressPercent() * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: controller.getProgressPercent(),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.neonGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.pause, color: AppColors.neonGreen),
        onPressed: onPause,
      ),
    ],
  );
}
