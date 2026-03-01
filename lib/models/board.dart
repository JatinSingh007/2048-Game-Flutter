import 'package:_2048/models/tile.dart';

class Board {
  List<List<Tile>> tiles;

  Board({required this.tiles});

  static Board copy(Board board) {
    final newTiles = <List<Tile>>[];
    for (int i = 0; i < 4; i++) {
      final newRow = <Tile>[];
      for (int j = 0; j < 4; j++) {
        newRow.add(Tile(value: board.tiles[i][j].value));
      }
      newTiles.add(newRow);
    }
    return Board(tiles: newTiles);
  }

  static Board createEmptyBoard() {
    final tiles = <List<Tile>>[];
    for (int i = 0; i < 4; i++) {
      final row = <Tile>[];
      for (int j = 0; j < 4; j++) {
        row.add(Tile(value: 0));
      }
      tiles.add(row);
    }
    return Board(tiles: tiles);
  }

  Tile getTile(int row, int column) {
    return tiles[row][column];
  }

  void setTile(int row, int column, Tile tile) {
    tiles[row][column] = tile;
  }

  List<(int, int)> get emptyCells {
    final empty = <(int, int)>[];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (tiles[i][j].isEmpty) {
          empty.add((i, j));
        }
      }
    }
    return empty;
  }
}
