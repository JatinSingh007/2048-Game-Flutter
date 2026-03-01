import 'dart:math';

import 'package:_2048/main.dart';
import 'package:_2048/providers/game_provider.dart';
import 'package:_2048/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  bool _hasShownWinDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleMove(String direction) {
    final game = ref.read(gameServiceProvider);
    bool changed = false;
    switch (direction) {
      case "up":
        changed = game.moveUp();
        break;
      case "down":
        changed = game.moveDown();
        break;
      case "left":
        changed = game.moveLeft();
        break;
      case "right":
        changed = game.moveRight();
        break;
    }
    if (changed) {
      game.spawnRandomTile();
      game.push(game.board, game.score);
      game.updateBestScore(game.score);
      ref.read(bestScoreProvider.notifier).state = game.bestScore;
      if (game.hasWon() && !_hasShownWinDialog) {
        _hasShownWinDialog = true;
        showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
                  title: const Text('You Won!'),
                  content: const Text('You have reached 2048 Congratulations!'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('OK')),
                  ],
                ));
        return;
      }
      if (game.hasLost()) {
        showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
                  title: const Text('You Lost!'),
                  content: const Text('You have lost the game!'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('OK')),
                  ],
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider so this widget rebuilds when GameService calls notifyListeners()
    final gameService = ref.watch(gameServiceProvider);
    return Scaffold(
      body: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowUp): const _MoveIntent('up'),
          LogicalKeySet(LogicalKeyboardKey.arrowDown):
              const _MoveIntent('down'),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft):
              const _MoveIntent('left'),
          LogicalKeySet(LogicalKeyboardKey.arrowRight):
              const _MoveIntent('right'),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _MoveIntent: CallbackAction<_MoveIntent>(
              onInvoke: (Intent intent) {
                _handleMove((intent as _MoveIntent).direction);
                return null;
              },
            ),
          },
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 170),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2048 Game',
                            style: Theme.of(context).textTheme.headlineLarge),
                        Transform.translate(
                          offset: const Offset(0, -50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text('Score: ${gameService.score}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                          'Best: ${gameService.bestScore}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                      title: const Text('How to Play'),
                                      content: const Text(
                                          '• Move: Swipe on the board (or use arrow keys) up, down, left, or right.\n\n'
                                          '• Merge: When two tiles with the same number touch, they combine into one tile with their sum (e.g. 2+2→4).\n\n'
                                          '• Goal: Create a 2048 tile to win. You can keep playing for higher numbers.\n\n'
                                          '• After each move, a new 2 appears. When the grid is full and no merge is possible, the game ends.\n\n'
                                          '• Use Undo to take back your last move; use ↻ to start a new game.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(dialogContext)
                                                    .pop(),
                                            child: const Text('OK')),
                                      ],
                                    ));
                          },
                          icon: const Icon(Icons.lightbulb_outline_rounded),
                          color: Colors.white,
                          iconSize: 26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            gameService.pop();
                          },
                          icon: const Icon(Icons.undo),
                          color: Colors.white,
                          iconSize: 26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() => _hasShownWinDialog = false);
                            ref.invalidate(gameServiceProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          color: Colors.white,
                          iconSize: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GestureDetector(
                      onPanEnd: (DragEndDetails details) {
                        final v = details.velocity.pixelsPerSecond;
                        const minVelocity = 100;
                        if (v.dx.abs() > v.dy.abs()) {
                          if (v.dx > minVelocity) {
                            _handleMove('right');
                          } else if (v.dx < -minVelocity) {
                            _handleMove('left');
                          }
                        } else if (v.dy.abs() > minVelocity) {
                          if (v.dy > minVelocity) {
                            _handleMove('down');
                          } else if (v.dy < -minVelocity) {
                            _handleMove('up');
                          }
                        }
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boardSize =
                              min(constraints.maxWidth, constraints.maxHeight) *
                                  0.95;
                          const spacing =
                              8.0; // same for gaps between tiles & padding around grid
                          // inner square = board minus padding on all sides (2*padding per dimension)
                          final innerSize = boardSize - 2 * spacing;
                          // divide inner square into 4x4 with gaps: 4 cells + 3 gaps
                          final cellSize = (innerSize - 3 * spacing) / 4;
                          return Center(
                            child: Container(
                              width: boardSize,
                              height: boardSize,
                              decoration: BoxDecoration(
                                color: boardBackground.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(spacing),
                                  child: SizedBox(
                                    width: innerSize,
                                    height: innerSize,
                                    key: ValueKey(gameService.board),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (int i = 0; i < 4; i++)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              for (int j = 0; j < 4; j++)
                                                TileWidget(
                                                    number: gameService.board
                                                        .getTile(i, j)
                                                        .value,
                                                    size: cellSize),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveIntent extends Intent {
  final String direction;
  const _MoveIntent(this.direction);
}
