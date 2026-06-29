import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/snake.dart';
import '../models/tile_position.dart';
import '../services/settings_service.dart';

enum Direction { up, down, left, right }

enum _PowerPhase { turbo, slow }

class SnakeController {
  /// Callback for visual feedback when a direction input is received.
  void Function(Direction)? onDirectionInput;
  Direction? _nextDirection;

  int score = 0;
  int getScore() => score;

  double getProgressPercent() {
    return (_snake.body.length / 540).clamp(0.0, 1.0);
  }

  Snake _snake = Snake([
    TilePosition(10, 15),
    TilePosition(10, 16),
    TilePosition(10, 17),
  ]);

  Direction _direction = Direction.up;
  Timer? _timer;
  VoidCallback? _onUpdate;

  final List<TilePosition> _foods = [];
  final List<TilePosition> _specialFoods = [];
  // --- Fun Mode power-ups ---
  final List<TilePosition> _turboFoods = [];
  final List<TilePosition> _slowFoods = [];
  List<TilePosition> get specialFoods => _specialFoods;
  List<TilePosition> get turboFoods => _turboFoods;
  List<TilePosition> get slowFoods => _slowFoods;

  // Active speed effect (1.0 = normal). Temporary effect resets after a timer.
  double _speedFactor = 1.0;
  Timer? _effectTimer;

  // Alternating single power-up (either turbo OR slow) with 30s lifespan
  _PowerPhase _phase = _PowerPhase.turbo;
  Timer? _powerCycleTimer;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;
  Snake get snake => _snake;
  List<TilePosition> get foods => _foods;
  Direction get direction => _direction;

  void changeDirection(Direction newDirection) {
    _direction = newDirection;
  }

  void start(VoidCallback onUpdate) {
    _onUpdate = onUpdate;
    _placeFood();
    final settings = SettingsService();
    if (settings.selectedMode == 'Fun Mode') {
      _startPowerCycle(initial: _PowerPhase.turbo);
    } else {
      // Classic Mode: no turbo/slow power-ups
      _powerCycleTimer?.cancel();
      _powerCycleTimer = null;
      _turboFoods.clear();
      _slowFoods.clear();
    }
  }

  void resume(VoidCallback onUpdate) {
    _onUpdate = onUpdate;
    _restartTimer();
    final settings = SettingsService();
    if (settings.selectedMode == 'Fun Mode') {
      _ensurePowerCycleRunning();
    } else {
      _powerCycleTimer?.cancel();
      _powerCycleTimer = null;
      _turboFoods.clear();
      _slowFoods.clear();
    }
  }

  Duration _computeBaseDelay() {
    final settings = SettingsService();
    final speed = settings.selectedSpeed;
    final ms = (600 - speed * 50).clamp(100, 600).toInt();
    return Duration(milliseconds: ms);
  }

  void _restartTimer() {
    _timer?.cancel();
    final base = _computeBaseDelay().inMilliseconds;
    final effective = (base / _speedFactor).round().clamp(50, 1000);
    _timer = Timer.periodic(Duration(milliseconds: effective), (_) => move());
  }

  void _applySpeedEffect({required double factor, required Duration duration}) {
    _speedFactor = factor;
    _restartTimer();
    _effectTimer?.cancel();
    _effectTimer = Timer(duration, () {
      _speedFactor = 1.0;
      _restartTimer();
    });
  }

  void _ensurePowerCycleRunning() {
    final settings = SettingsService();
    if (settings.selectedMode != 'Fun Mode') {
      _powerCycleTimer?.cancel();
      _powerCycleTimer = null;
      return;
    }
    if (_powerCycleTimer == null) {
      _startPowerCycle(initial: _phase);
    }
  }

  void _startPowerCycle({required _PowerPhase initial}) {
    final settings = SettingsService();
    if (settings.selectedMode != 'Fun Mode') {
      _powerCycleTimer?.cancel();
      _powerCycleTimer = null;
      _turboFoods.clear();
      _slowFoods.clear();
      return;
    }
    _powerCycleTimer?.cancel();
    _phase = initial;
    _setPhase(_phase);
    _scheduleNextSwitch();
  }

  void _scheduleNextSwitch() {
    final settings = SettingsService();
    if (settings.selectedMode != 'Fun Mode') {
      _powerCycleTimer?.cancel();
      _powerCycleTimer = null;
      return;
    }
    _powerCycleTimer?.cancel();
    _powerCycleTimer = Timer(const Duration(seconds: 30), _switchPhase);
  }

  void _switchPhase() {
    final settings = SettingsService();
    if (settings.selectedMode != 'Fun Mode') {
      _powerCycleTimer?.cancel();
      _powerCycleTimer = null;
      _turboFoods.clear();
      _slowFoods.clear();
      return;
    }
    _phase = _phase == _PowerPhase.turbo ? _PowerPhase.slow : _PowerPhase.turbo;
    _setPhase(_phase);
    _scheduleNextSwitch();
    _onUpdate?.call();
  }

  void _setPhase(_PowerPhase phase) {
    final settings = SettingsService();
    if (settings.selectedMode != 'Fun Mode') {
      _turboFoods.clear();
      _slowFoods.clear();
      return;
    }
    // Maintain the invariant: only one special symbol on the board
    _turboFoods.clear();
    _slowFoods.clear();
    if (phase == _PowerPhase.turbo) {
      _spawnTurbo();
    } else {
      _spawnSlow();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _effectTimer?.cancel();
    _powerCycleTimer?.cancel();
    _powerCycleTimer = null;
  }

  void move() {
    if (_isGameOver) return;
    if (_nextDirection != null) {
      _direction = _nextDirection!;
      _nextDirection = null;
    }
    final newHead = _getNextHead();

    // Handle Turbo power-up (diamond + lightning): temporary speed-up, no growth
    if (_turboFoods.contains(newHead)) {
      _turboFoods.remove(newHead);
      score += 3; // +3 for turbo pickup
      _snake = Snake([newHead, ..._snake.body.take(_snake.body.length - 1)]);
      _applySpeedEffect(factor: 1.8, duration: const Duration(seconds: 5));
      // Immediately switch to Slow phase and restart the 30s timer
      _phase = _PowerPhase.slow;
      _setPhase(_phase);
      _scheduleNextSwitch();
      _onUpdate?.call();
      return;
    }

    // Handle Slowmotion power-up (circle + hourglass): temporary slow-down, no growth
    if (_slowFoods.contains(newHead)) {
      _slowFoods.remove(newHead);
      score -= 1; // -1 for slowmo pickup
      _snake = Snake([newHead, ..._snake.body.take(_snake.body.length - 1)]);
      _applySpeedEffect(factor: 0.5, duration: const Duration(seconds: 5));
      // Immediately switch to Turbo phase and restart the 30s timer
      _phase = _PowerPhase.turbo;
      _setPhase(_phase);
      _scheduleNextSwitch();
      _onUpdate?.call();
      return;
    }

    // Handle special orange block first
    if (_specialFoods.contains(newHead)) {
      final settings = SettingsService();
      score += settings.selectedSpeed.toInt() * 5;
      // Grow by 5 segments
      final newBody = [newHead, ..._snake.body];
      for (var i = 0; i < 4; i++) {
        newBody.add(_snake.body.last);
      }
      _snake = Snake(newBody);
      _specialFoods.remove(newHead);
      _spawnSpecialFood();
      _onUpdate?.call();
      return;
    }

    if (_snake.body.contains(newHead)) {
      _isGameOver = true;
      _timer?.cancel();
      _timer = null;
      _onUpdate?.call();
      return;
    }
    if (_foods.contains(newHead)) {
      final settings = SettingsService();
      score += settings.selectedSpeed.toInt();
      final newBody = [newHead, ..._snake.body];
      _snake = Snake(newBody);
      // Remove the eaten block so it disappears
      _foods.remove(newHead);
      if (settings.selectedMode == 'Fun Mode') {
        _spawnSingleFood();
      } else {
        _placeFood();
      }
    } else {
      final newBody = [newHead, ..._snake.body.take(_snake.body.length - 1)];
      _snake = Snake(newBody);
    }

    _onUpdate?.call();
  }

  TilePosition _getNextHead() {
    final head = _snake.head;
    int x = head.x;
    int y = head.y;

    switch (_direction) {
      case Direction.up:
        y = (y - 1 + 30) % 30;
        break;
      case Direction.down:
        y = (y + 1) % 30;
        break;
      case Direction.left:
        x = (x - 1 + 20) % 20;
        break;
      case Direction.right:
        x = (x + 1) % 20;
        break;
    }

    return TilePosition(x, y);
  }

  void _placeFood() {
    final settings = SettingsService();
    _foods.clear();
    _specialFoods.clear();
    _turboFoods.clear();
    _slowFoods.clear();
    final random = Random();
    // Spawn 5 blocks in Fun Mode, 1 in Classic Mode
    final count = settings.selectedMode == 'Fun Mode' ? 5 : 1;
    for (var i = 0; i < count; i++) {
      while (true) {
        final x = random.nextInt(20);
        final y = random.nextInt(30);
        final pos = TilePosition(x, y);
        if (!_snake.body.contains(pos) && !_foods.contains(pos)) {
          _foods.add(pos);
          break;
        }
      }
    }
    // Spawn one orange block in Fun Mode
    if (settings.selectedMode == 'Fun Mode') {
      _spawnSpecialFood();
      // Turbo/Slow are controlled by the cycle; do not spawn here
    }
  }

  /// Spawns exactly one new food block without clearing existing ones.
  void _spawnSingleFood() {
    final random = Random();
    while (true) {
      final x = random.nextInt(20);
      final y = random.nextInt(30);
      final pos = TilePosition(x, y);
      if (!_snake.body.contains(pos) && !_foods.contains(pos)) {
        _foods.add(pos);
        break;
      }
    }
  }

  /// Spawns a single orange special block.
  void _spawnSpecialFood() {
    final random = Random();
    while (true) {
      final x = random.nextInt(20);
      final y = random.nextInt(30);
      final pos = TilePosition(x, y);
      if (!_snake.body.contains(pos) &&
          !_foods.contains(pos) &&
          !_specialFoods.contains(pos)) {
        _specialFoods.add(pos);
        break;
      }
    }
  }

  void _spawnTurbo() {
    final random = Random();
    while (true) {
      final x = random.nextInt(20);
      final y = random.nextInt(30);
      final pos = TilePosition(x, y);
      if (!_snake.body.contains(pos) &&
          !_foods.contains(pos) &&
          !_specialFoods.contains(pos) &&
          !_turboFoods.contains(pos) &&
          !_slowFoods.contains(pos)) {
        _turboFoods.add(pos);
        break;
      }
    }
  }

  void _spawnSlow() {
    final random = Random();
    while (true) {
      final x = random.nextInt(20);
      final y = random.nextInt(30);
      final pos = TilePosition(x, y);
      if (!_snake.body.contains(pos) &&
          !_foods.contains(pos) &&
          !_specialFoods.contains(pos) &&
          !_turboFoods.contains(pos) &&
          !_slowFoods.contains(pos)) {
        _slowFoods.add(pos);
        break;
      }
    }
  }

  void reset() {
    _snake = Snake([
      TilePosition(10, 15),
      TilePosition(10, 16),
      TilePosition(10, 17),
    ]);
    _direction = Direction.up;
    _isGameOver = false;
    _effectTimer?.cancel();
    _speedFactor = 1.0;
    score = 0;
    _powerCycleTimer?.cancel();
    _powerCycleTimer = null;
    // Reset foods and place new blocks for the selected mode
    _placeFood();
    final settings = SettingsService();
    if (settings.selectedMode == 'Fun Mode') {
      _startPowerCycle(initial: _PowerPhase.turbo);
    } else {
      _powerCycleTimer?.cancel();
      _powerCycleTimer = null;
      _turboFoods.clear();
      _slowFoods.clear();
    }
    resume(_onUpdate!);
  }

  void handleKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) {
      tryChangeDirection(Direction.up);
      onDirectionInput?.call(Direction.up);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      tryChangeDirection(Direction.down);
      onDirectionInput?.call(Direction.down);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      tryChangeDirection(Direction.left);
      onDirectionInput?.call(Direction.left);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      tryChangeDirection(Direction.right);
      onDirectionInput?.call(Direction.right);
    }
  }

  void tryChangeDirection(Direction newDirection) {
    if ((newDirection == Direction.left && _direction != Direction.right) ||
        (newDirection == Direction.right && _direction != Direction.left) ||
        (newDirection == Direction.up && _direction != Direction.down) ||
        (newDirection == Direction.down && _direction != Direction.up)) {
      _nextDirection = newDirection;
    }
  }
}
