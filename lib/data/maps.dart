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

final spiralMap = GameMap(
  name: "Spiral",
  walls: [
    for (int x = 3; x <= 16; x++) Point(x, 4),
    for (int y = 5; y <= 25; y++) Point(16, y),
    for (int x = 4; x <= 15; x++) Point(x, 25),
    for (int y = 8; y <= 24; y++) Point(4, y),
    for (int x = 5; x <= 13; x++) Point(x, 8),
    for (int y = 9; y <= 21; y++) Point(13, y),
    for (int x = 7; x <= 12; x++) Point(x, 21),
    for (int y = 12; y <= 20; y++) Point(7, y),
    for (int x = 8; x <= 10; x++) Point(x, 12),
  ],
);

final mazeMap = GameMap(
  name: "Maze",
  walls: [
    for (int y = 3; y <= 11; y++) Point(4, y),
    for (int y = 15; y <= 26; y++) Point(4, y),
    for (int y = 4; y <= 18; y++) Point(8, y),
    for (int y = 22; y <= 26; y++) Point(8, y),
    for (int y = 3; y <= 9; y++) Point(12, y),
    for (int y = 13; y <= 26; y++) Point(12, y),
    for (int y = 6; y <= 20; y++) Point(16, y),
    for (int x = 2; x <= 7; x++) Point(x, 13),
    for (int x = 9; x <= 15; x++) Point(x, 21),
  ],
);

final zigzagMap = GameMap(
  name: "Zigzag",
  walls: [
    for (int x = 2; x <= 15; x++) Point(x, 5),
    for (int x = 5; x <= 18; x++) Point(x, 10),
    for (int x = 2; x <= 15; x++) Point(x, 15),
    for (int x = 5; x <= 18; x++) Point(x, 20),
    for (int x = 2; x <= 15; x++) Point(x, 25),
  ],
);

final fortressMap = GameMap(
  name: "Fortress",
  walls:
      [
            for (int x = 3; x <= 16; x++) Point(x, 5),
            for (int x = 3; x <= 16; x++) Point(x, 24),
            for (int y = 6; y <= 23; y++) Point(3, y),
            for (int y = 6; y <= 23; y++) Point(16, y),

            // Gates in the fortress walls.
            Point(9, 5),
            Point(10, 5),
            Point(9, 24),
            Point(10, 24),
            Point(3, 14),
            Point(3, 15),
            Point(16, 14),
            Point(16, 15),

            // Inner obstacles.
            for (int x = 7; x <= 12; x++) Point(x, 10),
            for (int x = 7; x <= 12; x++) Point(x, 19),
            for (int y = 12; y <= 17; y++) Point(7, y),
            for (int y = 12; y <= 17; y++) Point(12, y),
          ]
          .where(
            (point) => ![
              Point(9, 5),
              Point(10, 5),
              Point(9, 24),
              Point(10, 24),
              Point(3, 14),
              Point(3, 15),
              Point(16, 14),
              Point(16, 15),
            ].contains(point),
          )
          .toList(),
);

final gameMaps = [
  classicMap,
  crossMap,
  boxMap,
  fourCornersMap,
  pillarsMap,
  gatesMap,
  spiralMap,
  mazeMap,
  zigzagMap,
  fortressMap,
];
