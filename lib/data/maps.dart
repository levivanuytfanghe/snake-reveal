import 'dart:math';

class GameMap {
  final String name;
  final List<Point<int>> walls;

  GameMap({required this.name, required this.walls});
}

final classicMap = GameMap(name: "Classic", walls: []);

final crossMap = GameMap(
  name: "Cross",
  walls: [
    // Vertical line through the middle.
    Point(10, 8),
    Point(10, 9),
    Point(10, 10),
    Point(10, 11),
    Point(10, 12),
    Point(10, 13),
    Point(10, 14),
    Point(10, 15),
    Point(10, 16),
    Point(10, 17),
    Point(10, 18),
    Point(10, 19),
    Point(10, 20),
    Point(10, 21),

    // Horizontal line through the middle.
    Point(4, 15),
    Point(5, 15),
    Point(6, 15),
    Point(7, 15),
    Point(8, 15),
    Point(9, 15),
    Point(11, 15),
    Point(12, 15),
    Point(13, 15),
    Point(14, 15),
    Point(15, 15),
    Point(16, 15),
  ],
);

final boxMap = GameMap(
  name: "Box",
  walls: [
    // Top and bottom borders.
    for (int x = 0; x < 20; x++) Point(x, 0),
    for (int x = 0; x < 20; x++) Point(x, 29),

    // Left and right borders.
    for (int y = 1; y < 29; y++) Point(0, y),
    for (int y = 1; y < 29; y++) Point(19, y),
  ],
);

final fourCornersMap = GameMap(
  name: "Four Corners",
  walls: [
    // Corner blocks placed further inside the border.
    // This avoids confusion with the normal edge-of-screen game over collision.
    for (int x = 2; x <= 4; x++)
      for (int y = 2; y <= 4; y++) Point(x, y),
    for (int x = 15; x <= 17; x++)
      for (int y = 2; y <= 4; y++) Point(x, y),
    for (int x = 2; x <= 4; x++)
      for (int y = 24; y <= 26; y++) Point(x, y),
    for (int x = 15; x <= 17; x++)
      for (int y = 24; y <= 26; y++) Point(x, y),
  ],
);

final pillarsMap = GameMap(
  name: "Pillars",
  walls: [
    for (int y = 5; y <= 24; y++) Point(5, y),
    for (int y = 5; y <= 24; y++) Point(10, y),
    for (int y = 5; y <= 24; y++) Point(15, y),
  ],
);

final gatesMap = GameMap(
  name: "Gates",
  walls: [
    for (int x = 0; x < 20; x++)
      if (x < 8 || x > 11) Point(x, 10),
    for (int x = 0; x < 20; x++)
      if (x < 8 || x > 11) Point(x, 20),
  ],
);

final gameMaps = [
  classicMap,
  crossMap,
  boxMap,
  fourCornersMap,
  pillarsMap,
  gatesMap,
];
