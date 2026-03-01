import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:_2048/models/board.dart';
import 'package:_2048/models/tile.dart';

/// Holds the game state (board, score) and notifies listeners when it changes
/// so the UI can rebuild.
class GameService extends ChangeNotifier {
  Board board;
  int score;
  int bestScore;
  List<(Board, int)> stack = [];

  GameService({int initialBestScore = 0})
      : board = Board.createEmptyBoard(),
        score = 0,
        bestScore = initialBestScore {
    spawnRandomTile();
    spawnRandomTile();
    push(board, score);
  }

  void push(Board board, int score) {
    stack.add((Board.copy(board), score));
  }

  void pop() {
    if (stack.length <= 1)
      return; // need at least 2 to undo (current + previous)
    stack.removeLast();
    final (snapshotBoard, snapshotScore) = stack.last;
    board = Board.copy(
        snapshotBoard); // restore into fresh copy so nothing is shared
    score = snapshotScore;
    notifyListeners();
  }

  bool hasWon() {
    for (int row = 0; row < 4; row++) {
      for (int column = 0; column < 4; column++) {
        if (board.getTile(row, column).value == 2048) {
          return true;
        }
      }
    }
    return false;
  }

  bool hasLost() {
    // Must be full (no empty cell)
    for (int row = 0; row < 4; row++) {
      for (int column = 0; column < 4; column++) {
        if (board.getTile(row, column).value == 0) return false;
      }
    }
    // Check if any move is possible (two adjacent equal tiles)
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final v = board.getTile(row, col).value;
        if (col < 3 && v == board.getTile(row, col + 1).value) return false;
        if (row < 3 && v == board.getTile(row + 1, col).value) return false;
      }
    }
    return true;
  }

  void spawnRandomTile() {
    final emptyCells = board.emptyCells;
    if (emptyCells.isEmpty) {
      return;
    }
    final randomIndex = Random().nextInt(emptyCells.length);
    final randomCell = emptyCells[randomIndex];
    board.setTile(randomCell.$1, randomCell.$2, Tile(value: 2));
    notifyListeners();
  }

  void updateBestScore(int score) {
    bestScore = max(score, bestScore);
    notifyListeners();
  }

  bool moveUp() {
    bool boardChanged = false;
    for (int column = 0; column < 4; column++) {
      for (int row = 0; row < 4; row++) {
        if (board.getTile(row, column).value != 0) {
          bool foundTileInWay = false;
          for (int i = row - 1; i >= 0; i--) {
            if (board.getTile(i, column).value != 0) {
              if (board.getTile(i, column).value ==
                  board.getTile(row, column).value) {
                board.setTile(
                    i, column, Tile(value: board.getTile(i, column).value * 2));
                board.setTile(row, column, Tile(value: 0));
                score += board.getTile(i, column).value;
                boardChanged = true;
              } else if (row > i + 1) {
                board.setTile(i + 1, column,
                    Tile(value: board.getTile(row, column).value));
                board.setTile(row, column, Tile(value: 0));
                boardChanged = true;
              }
              foundTileInWay = true;
              break;
            }
          }
          if (!foundTileInWay && row != 0) {
            board.setTile(
                0, column, Tile(value: board.getTile(row, column).value));
            board.setTile(row, column, Tile(value: 0));
            boardChanged = true;
          }
        }
      }
    }
    notifyListeners();
    return boardChanged;
  }

  bool moveDown() {
    bool boardChanged = false;
    for (int column = 0; column < 4; column++) {
      for (int row = 3; row >= 0; row--) {
        if (board.getTile(row, column).value != 0) {
          bool foundTileInWay = false;
          for (int i = row + 1; i < 4; i++) {
            if (board.getTile(i, column).value != 0) {
              if (board.getTile(i, column).value ==
                  board.getTile(row, column).value) {
                board.setTile(
                    i, column, Tile(value: board.getTile(i, column).value * 2));
                board.setTile(row, column, Tile(value: 0));
                score += board.getTile(i, column).value;
                boardChanged = true;
              } else if (row < i - 1) {
                board.setTile(i - 1, column,
                    Tile(value: board.getTile(row, column).value));
                board.setTile(row, column, Tile(value: 0));
                boardChanged = true;
              }
              foundTileInWay = true;
              break;
            }
          }
          if (!foundTileInWay && row != 3) {
            board.setTile(
                3, column, Tile(value: board.getTile(row, column).value));
            board.setTile(row, column, Tile(value: 0));
            boardChanged = true;
          }
        }
      }
    }
    notifyListeners();
    return boardChanged;
  }

  bool moveLeft() {
    bool boardChanged = false;
    for (int row = 0; row < 4; row++) {
      for (int column = 0; column < 4; column++) {
        if (board.getTile(row, column).value != 0) {
          bool foundTileInWay = false;
          for (int i = column - 1; i >= 0; i--) {
            if (board.getTile(row, i).value != 0) {
              if (board.getTile(row, i).value ==
                  board.getTile(row, column).value) {
                board.setTile(
                    row, i, Tile(value: board.getTile(row, i).value * 2));
                board.setTile(row, column, Tile(value: 0));
                score += board.getTile(row, i).value;
                boardChanged = true;
              } else if (column > i + 1) {
                board.setTile(
                    row, i + 1, Tile(value: board.getTile(row, column).value));
                board.setTile(row, column, Tile(value: 0));
                boardChanged = true;
              }
              foundTileInWay = true;
              break;
            }
          }
          if (!foundTileInWay && column != 0) {
            board.setTile(
                row, 0, Tile(value: board.getTile(row, column).value));
            board.setTile(row, column, Tile(value: 0));
            boardChanged = true;
          }
        }
      }
    }
    notifyListeners();
    return boardChanged;
  }

  bool moveRight() {
    bool boardChanged = false;
    for (int row = 0; row < 4; row++) {
      for (int column = 3; column >= 0; column--) {
        if (board.getTile(row, column).value != 0) {
          bool foundTileInWay = false;
          for (int i = column + 1; i < 4; i++) {
            if (board.getTile(row, i).value != 0) {
              if (board.getTile(row, i).value ==
                  board.getTile(row, column).value) {
                board.setTile(
                    row, i, Tile(value: board.getTile(row, i).value * 2));
                board.setTile(row, column, Tile(value: 0));
                score += board.getTile(row, i).value;
                boardChanged = true;
              } else if (column < i - 1) {
                board.setTile(
                    row, i - 1, Tile(value: board.getTile(row, column).value));
                board.setTile(row, column, Tile(value: 0));
                boardChanged = true;
              }
              foundTileInWay = true;
              break;
            }
          }
          if (!foundTileInWay && column != 3) {
            board.setTile(
                row, 3, Tile(value: board.getTile(row, column).value));
            board.setTile(row, column, Tile(value: 0));
            boardChanged = true;
          }
        }
      }
    }
    notifyListeners();
    return boardChanged;
  }
}
