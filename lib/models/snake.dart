import 'tile_position.dart';

class Snake {
  final List<TilePosition> body;

  const Snake(this.body);

  TilePosition get head => body.first;
}
