class TilePosition {
  final int x;
  final int y;

  const TilePosition(this.x, this.y);

  TilePosition copyWith({int? x, int? y}) {
    return TilePosition(x ?? this.x, y ?? this.y);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TilePosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
