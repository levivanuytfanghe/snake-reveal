import 'package:flutter/material.dart';
import '../controllers/snake_controller.dart';

class GameControls extends StatefulWidget {
  final void Function(Direction direction) onDirectionChange;

  const GameControls({super.key, required this.onDirectionChange});

  @override
  State<GameControls> createState() => GameControlsState();
}

class GameControlsState extends State<GameControls> {
  Direction? _highlighted;

  void highlight(Direction direction) {
    setState(() {
      _highlighted = direction;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _highlighted = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/screens/controller.png',
            fit: BoxFit.cover,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => widget.onDirectionChange(Direction.up),
              child: _button(context, _highlighted == Direction.up),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => widget.onDirectionChange(Direction.left),
                  child: _button(context, _highlighted == Direction.left),
                ),
                const SizedBox(width: 72),
                GestureDetector(
                  onTap: () => widget.onDirectionChange(Direction.right),
                  child: _button(context, _highlighted == Direction.right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => widget.onDirectionChange(Direction.down),
              child: _button(context, _highlighted == Direction.down),
            ),
          ],
        ),
      ],
    );
  }

  Widget _button(BuildContext context, bool highlighted) {
    final size = MediaQuery.of(context).size.width * 0.15;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: highlighted ? Colors.lime.withAlpha(77) : Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
  }
}
