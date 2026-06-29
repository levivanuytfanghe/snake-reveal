import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageRevealPainter extends CustomPainter {
  final ui.Image image;
  final int rows;
  final int cols;
  final Set<Offset> visibleTiles;
  final bool revealAll;

  ImageRevealPainter({
    required this.image,
    required this.rows,
    required this.cols,
    required this.visibleTiles,
    this.revealAll = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tileWidth = size.width / cols;
    final tileHeight = size.height / rows;

    final tilesToPaint = revealAll
        ? {
            for (int x = 0; x < cols; x++)
              for (int y = 0; y < rows; y++) Offset(x.toDouble(), y.toDouble()),
          }
        : visibleTiles;

    for (final tile in tilesToPaint) {
      final dx = tile.dx.toInt();
      final dy = tile.dy.toInt();

      final srcRect = Rect.fromLTWH(
        dx * (image.width / cols),
        dy * (image.height / rows),
        image.width / cols,
        image.height / rows,
      );

      final dstRect = Rect.fromLTWH(
        dx * tileWidth,
        dy * tileHeight,
        tileWidth,
        tileHeight,
      );

      canvas.drawImageRect(image, srcRect, dstRect, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant ImageRevealPainter oldDelegate) {
    return image != oldDelegate.image ||
        visibleTiles != oldDelegate.visibleTiles;
  }
}
