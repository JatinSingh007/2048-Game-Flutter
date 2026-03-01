class Tile {
  final int value;
  Tile({required this.value});

  get isEmpty {
    return value == 0;
  }
}
