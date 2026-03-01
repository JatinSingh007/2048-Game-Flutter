import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:_2048/models/gameservice.dart';

/// Provides a single [GameService] for the app. When [GameService] calls
/// [ChangeNotifier.notifyListeners], every widget that did ref.watch(this)
/// will rebuild.
final gameServiceProvider = ChangeNotifierProvider<GameService>(
    (ref) => GameService(initialBestScore: ref.read(bestScoreProvider)));

/// Best score across game resets. Never invalidated when the game is reset.
final bestScoreProvider = StateProvider<int>((ref) => 0);
