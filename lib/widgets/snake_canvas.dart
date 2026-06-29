import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../controllers/snake_controller.dart';
import '../app/app_colors.dart';

class SnakeCanvas extends StatefulWidget {
  final SnakeController controller;
  final ui.Image image;
  final bool revealAll;

  const SnakeCanvas({
    super.key,
    required this.controller,
    required this.image,
    this.revealAll = false,
  });

  @override
  State<SnakeCanvas> createState() => _SnakeCanvasState();
}

class _SnakeCanvasState extends State<SnakeCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GamePainter(
        controller: widget.controller,
        image: widget.image,
        revealAll: widget.revealAll,
        animation: _anim,
      ),
      child: Container(),
    );
  }
}

class GamePainter extends CustomPainter {
  final SnakeController controller;
  final ui.Image image;
  final bool revealAll;
  final Animation<double> animation;

  GamePainter({
    required this.controller,
    required this.image,
    required this.revealAll,
    required this.animation,
  }) : super(repaint: animation);

  static const int columns = 20;
  static const int rows = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / columns;
    final double cellHeight = size.height / rows;

    final double gridWidth = cellWidth * columns;
    final double horizontalOffset = (size.width - gridWidth) / 2;

    // Volledig raster opvullen met donkerpaarse tegels
    for (int x = 0; x < columns; x++) {
      for (int y = 0; y < rows; y++) {
        final rect = Rect.fromLTWH(
          horizontalOffset + x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );
        canvas.drawRect(rect, Paint()..color = const Color(0xFF9AB951));
      }
    }

    // Achtergrondafbeelding per zichtbare tegel (inclusief slangsegmenten)
    final visibleTiles = revealAll
        ? {
            for (int x = 0; x < columns; x++)
              for (int y = 0; y < rows; y++) Offset(x.toDouble(), y.toDouble()),
          }
        : controller.snake.body
              .map((tile) => Offset(tile.x.toDouble(), tile.y.toDouble()))
              .toSet();

    for (final tile in visibleTiles) {
      final dx = tile.dx.toInt();
      final dy = tile.dy.toInt();

      final srcRect = Rect.fromLTWH(
        dx * (image.width / columns),
        dy * (image.height / rows),
        image.width / columns,
        image.height / rows,
      );

      final dstRect = Rect.fromLTWH(
        horizontalOffset + dx * cellWidth,
        dy * cellHeight,
        cellWidth,
        cellHeight,
      );

      canvas.drawImageRect(image, srcRect, dstRect, Paint());
    }

    // Draw each food block (1 in Classic, 5 in Fun Mode)
    final foodPaint = Paint()..color = const Color(0xFF451287);
    for (final foodPos in controller.foods) {
      final left = horizontalOffset + foodPos.x * cellWidth;
      final top = foodPos.y * cellHeight;
      final rect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
      canvas.drawRect(rect, foodPaint);
    }

    // Draw special orange blocks (Fun Mode)
    final specialPaint = Paint()..color = Colors.orange;
    for (final specialPos in controller.specialFoods) {
      final left = horizontalOffset + specialPos.x * cellWidth;
      final top = specialPos.y * cellHeight;
      final rect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
      canvas.drawRect(rect, specialPaint);
    }

    // Power-ups
    _drawTurboFoods(canvas, size, cellWidth, cellHeight, horizontalOffset);
    _drawSlowFoods(canvas, size, cellWidth, cellHeight, horizontalOffset);

    // Rasterlijnen tekenen ná het tekenen van achtergrondafbeelding en voedsel
    final Paint gridPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 1;

    for (int i = 0; i <= columns; i++) {
      final x = horizontalOffset + i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int i = 0; i <= rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(
        Offset(horizontalOffset, y),
        Offset(horizontalOffset + gridWidth, y),
        gridPaint,
      );
    }
  }

  void _drawTurboFoods(
    Canvas canvas,
    Size size,
    double cellWidth,
    double cellHeight,
    double horizontalOffset,
  ) {
    final t = animation.value; // 0..1
    final glowPulse = 0.6 + 0.4 * math.sin(t * 2 * math.pi); // snelle puls

    // Lees dynamisch controller.turboFoods indien aanwezig
    final turboFoods = _getPositions('turbo');
    if (turboFoods == null) return;

    for (final pos in turboFoods) {
      final cx = horizontalOffset + (pos.x + 0.5) * cellWidth;
      final cy = (pos.y + 0.5) * cellHeight;
      final halfW = cellWidth * 0.42;
      final halfH = cellHeight * 0.42;

      // Diamantvorm (gedraaid vierkant)
      final path = Path()
        ..moveTo(cx, cy - halfH)
        ..lineTo(cx + halfW, cy)
        ..lineTo(cx, cy + halfH)
        ..lineTo(cx - halfW, cy)
        ..close();

      // Glow
      final glowPaint = Paint()
        ..color = Colors.grey.shade800.withOpacity(0.55 * glowPulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 + 6.0 * glowPulse);
      canvas.drawPath(path, glowPaint);

      // Body
      final bodyPaint = Paint()..color = Colors.grey.shade900;
      canvas.drawPath(path, bodyPaint);

      _drawIcon(
        canvas,
        '⚡',
        Offset(cx, cy),
        math.min(cellWidth, cellHeight) * 0.75,
        const Color(0xFFFFFFFF),
      );
    }
  }

  void _drawSlowFoods(
    Canvas canvas,
    Size size,
    double cellWidth,
    double cellHeight,
    double horizontalOffset,
  ) {
    // Trage fade-animatie
    final t = animation.value; // 0..1
    final fade = 0.45 + 0.45 * (0.5 + 0.5 * math.sin(t * 2 * math.pi * 0.5));

    final slowFoods = _getPositions('slow');
    if (slowFoods == null) return;

    for (final pos in slowFoods) {
      final cx = horizontalOffset + (pos.x + 0.5) * cellWidth;
      final cy = (pos.y + 0.5) * cellHeight;
      final r = math.min(cellWidth, cellHeight) * 0.46;

      final fillPaint = Paint()
        ..color = const Color(0xFF9EB3D5).withOpacity(0.35 * fade);
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF9EB3D5).withOpacity(0.9 * fade);

      canvas.drawCircle(Offset(cx, cy), r, fillPaint);
      canvas.drawCircle(Offset(cx, cy), r, strokePaint);

      _drawIcon(
        canvas,
        '⏳',
        Offset(cx, cy),
        math.min(cellWidth, cellHeight) * 0.7,
        const Color(0xFF22324A),
      );
    }
  }

  void _drawIcon(
    Canvas canvas,
    String char,
    Offset center,
    double size,
    Color color,
  ) {
    final textSpan = TextSpan(
      text: char,
      style: TextStyle(color: color, fontSize: size),
    );
    final tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final offset = center - Offset(tp.width / 2, tp.height / 2);
    tp.paint(canvas, offset);
  }

  // Probeert dynamisch turbo/slow lijsten te lezen. Keert null terug als ze ontbreken.
  List<dynamic>? _getPositions(String which) {
    try {
      final dyn = controller as dynamic;
      if (which == 'turbo') return dyn.turboFoods as List<dynamic>?;
      if (which == 'slow') return dyn.slowFoods as List<dynamic>?;
    } catch (_) {}
    return null;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
