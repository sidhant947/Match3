import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:match3/data/repositories/progress_repository.dart';
import 'package:match3/domain/models/game_state_model.dart';
import 'package:match3/domain/models/level_goal.dart';
import 'package:match3/domain/models/tile_model.dart';

class GameViewModel extends ChangeNotifier {
  final ProgressRepository progressRepository;
  final Random _random = Random();

  static const List<String> _allFruits = ['🍎', '🍋', '🍇', '🍉', '🍍', '🍓', '🍊', '🍒'];

  int _targetScore = 1000;
  int _moves = 25;
  int _fruitVarietyCount = 5;
  int _star1Score = 500;
  int _star2Score = 1000;
  int _star3Score = 1500;
  bool _isZenMode = false;
  late LevelGoal _currentGoal;

  GameStateModel _state = const GameStateModel(
    tiles: [],
    score: 0,
    highScore: 0,
    movesLeft: 25,
    targetScore: 1000,
    isGameOver: false,
    rows: 8,
    cols: 8,
    comboCount: 0,
    levelNumber: 1,
  );

  GameStateModel get state => _state;
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  GameViewModel({
    required this.progressRepository,
  });

  LevelGoal _generateLevelGoal(int level, bool isZenMode) {
    if (isZenMode) {
      return const LevelGoal(
        type: LevelGoalType.score,
        title: 'ENDLESS RELAXATION',
        description: 'Match and relax without move limits',
        targetValue: 999999,
      );
    }

    final cycle = (level - 1) % 4;
    final available = _getAvailableFruits((4 + (level ~/ 10)).clamp(4, _allFruits.length));
    final fruit = available[(level - 1) % available.length];

    switch (cycle) {
      case 0:
        final neededFruit = min(12 + (level * 2), 45);
        return LevelGoal(
          type: LevelGoalType.targetFruit,
          title: 'HARVEST QUEST',
          description: 'Collect $neededFruit $fruit',
          targetValue: neededFruit,
          targetFruitEmoji: fruit,
        );
      case 1:
        final specialsNeeded = min(2 + (level ~/ 4), 8);
        return LevelGoal(
          type: LevelGoalType.createSpecials,
          title: 'SPECIAL FUSION',
          description: 'Create $specialsNeeded striped/wrapped fruits',
          targetValue: specialsNeeded,
        );
      case 2:
        final combosNeeded = min(2 + (level ~/ 5), 7);
        return LevelGoal(
          type: LevelGoalType.comboMaster,
          title: 'COMBO FEVER',
          description: 'Trigger $combosNeeded combo cascades',
          targetValue: combosNeeded,
        );
      case 3:
      default:
        final pts = 1200 + (level - 1) * 450;
        return LevelGoal(
          type: LevelGoalType.score,
          title: 'HIGH ROLLER',
          description: 'Reach $pts points',
          targetValue: pts,
        );
    }
  }

  Future<void> initGame({int level = 1, bool isZenMode = false}) async {
    _isZenMode = isZenMode;
    _currentGoal = _generateLevelGoal(level, isZenMode);

    _targetScore = _currentGoal.type == LevelGoalType.score
        ? _currentGoal.targetValue
        : (800 + (level - 1) * 300);

    _moves = isZenMode ? 999 : max(14, 28 - (level ~/ 6));
    _fruitVarietyCount = (4 + (level ~/ 10)).clamp(4, _allFruits.length);
    _star1Score = (_targetScore * 0.6).round();
    _star2Score = _targetScore;
    _star3Score = (_targetScore * 1.5).round();

    final userProgress = await progressRepository.getProgress();
    final effectiveHighScore = userProgress.levelStars[level.toString()] != null
        ? userProgress.levelStars[level.toString()]! * 1000
        : 0;

    final initialTiles = _generateInitialBoard(8, 8, _fruitVarietyCount);
    _state = GameStateModel(
      tiles: initialTiles,
      score: 0,
      highScore: effectiveHighScore,
      movesLeft: _moves,
      targetScore: _targetScore,
      goal: _currentGoal,
      isGameOver: false,
      rows: 8,
      cols: 8,
      comboCount: 0,
      levelNumber: level,
      star1Score: _star1Score,
      star2Score: _star2Score,
      star3Score: _star3Score,
      starsEarned: 0,
    );
    _isProcessing = false;
    notifyListeners();
  }

  int calculateStars(int score) {
    if (score >= _star3Score) return 3;
    if (score >= _star2Score) return 2;
    if (score >= _star1Score) return 1;
    return 1;
  }

  List<String> _getAvailableFruits(int count) {
    final clampedCount = count.clamp(4, _allFruits.length);
    return _allFruits.sublist(0, clampedCount);
  }

  List<TileModel> _generateInitialBoard(int rows, int cols, int fruitCount) {
    final availableFruits = _getAvailableFruits(fruitCount);
    final tiles = <TileModel>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final allowedFruits = List<String>.from(availableFruits);
        if (c >= 2) {
          final left1 = tiles.firstWhere((t) => t.row == r && t.col == c - 1);
          final left2 = tiles.firstWhere((t) => t.row == r && t.col == c - 2);
          if (left1.emoji == left2.emoji) {
            allowedFruits.remove(left1.emoji);
          }
        }
        if (r >= 2) {
          final up1 = tiles.firstWhere((t) => t.row == r - 1 && t.col == c);
          final up2 = tiles.firstWhere((t) => t.row == r - 2 && t.col == c);
          if (up1.emoji == up2.emoji) {
            allowedFruits.remove(up1.emoji);
          }
        }
        final emoji = allowedFruits[_random.nextInt(allowedFruits.length)];
        tiles.add(TileModel(
          id: '${DateTime.now().microsecondsSinceEpoch}_${r}_${c}_${_random.nextInt(1000)}',
          row: r,
          col: c,
          emoji: emoji,
        ));
      }
    }
    return tiles;
  }

  void _updateGoalProgress({
    int scoreAdded = 0,
    List<TileModel> clearedTiles = const [],
    int specialsCreatedCount = 0,
    bool isCombo = false,
  }) {
    int currentVal = _currentGoal.currentValue;

    switch (_currentGoal.type) {
      case LevelGoalType.score:
        currentVal = _state.score + scoreAdded;
        break;
      case LevelGoalType.targetFruit:
        final matchingFruitCount = clearedTiles.where((t) => t.emoji == _currentGoal.targetFruitEmoji).length;
        currentVal += matchingFruitCount;
        break;
      case LevelGoalType.createSpecials:
        currentVal += specialsCreatedCount;
        break;
      case LevelGoalType.comboMaster:
        if (isCombo) {
          currentVal += 1;
        }
        break;
    }

    _currentGoal = _currentGoal.copyWith(currentValue: currentVal);
  }

  Future<bool> swapTiles(int r1, int c1, int r2, int c2) async {
    if (_isProcessing || _state.isGameOver) return false;
    _isProcessing = true;

    final tile1 = _state.getTile(r1, c1);
    final tile2 = _state.getTile(r2, c2);
    if (tile1 == null || tile2 == null) {
      _isProcessing = false;
      return false;
    }

    final swappedTiles = _state.tiles.map((tile) {
      if (tile.id == tile1.id) {
        return tile.copyWith(row: r2, col: c2);
      } else if (tile.id == tile2.id) {
        return tile.copyWith(row: r1, col: c1);
      }
      return tile;
    }).toList();

    _state = _state.copyWith(tiles: swappedTiles);
    notifyListeners();

    if (tile1.type == TileType.colorBomb || tile2.type == TileType.colorBomb) {
      final newMoves = _isZenMode ? _state.movesLeft : _state.movesLeft - 1;
      _state = _state.copyWith(movesLeft: newMoves);
      await _handleColorBombSwap(tile1, tile2);
      _isProcessing = false;
      return true;
    }

    final matches = _findMatches(swappedTiles);
    if (matches.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      _state = _state.copyWith(tiles: _state.tiles.map((tile) {
        if (tile.id == tile1.id) {
          return tile.copyWith(row: r1, col: c1);
        } else if (tile.id == tile2.id) {
          return tile.copyWith(row: r2, col: c2);
        }
        return tile;
      }).toList());
      _isProcessing = false;
      notifyListeners();
      return false;
    }

    final newMoves = _isZenMode ? _state.movesLeft : _state.movesLeft - 1;
    _state = _state.copyWith(movesLeft: newMoves, comboCount: 0);
    notifyListeners();

    await _processMatchesAndCascade();
    _isProcessing = false;
    return true;
  }

  Future<void> _handleColorBombSwap(TileModel tile1, TileModel tile2) async {
    final bomb = tile1.type == TileType.colorBomb ? tile1 : tile2;
    final other = tile1.type == TileType.colorBomb ? tile2 : tile1;

    final targetEmoji = other.emoji;
    final toDestroy = _state.tiles.where((t) => t.emoji == targetEmoji || t.id == bomb.id).toList();

    final remaining = _state.tiles.where((t) => !toDestroy.contains(t)).toList();
    final newScore = _state.score + toDestroy.length * 60;
    _updateGoalProgress(scoreAdded: toDestroy.length * 60, clearedTiles: toDestroy);

    final stars = calculateStars(newScore);

    _state = _state.copyWith(
      tiles: remaining,
      score: newScore,
      goal: _currentGoal,
      highScore: max(newScore, _state.highScore),
      comboCount: _state.comboCount + 1,
      starsEarned: stars,
    );
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final cascaded = _cascadeBoard(_state.tiles);
    _state = _state.copyWith(tiles: cascaded);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 350));

    await _processMatchesAndCascade();
  }

  Future<void> _processMatchesAndCascade() async {
    while (true) {
      final scanResult = _scanAndGenerateSpecials(_state.tiles);
      final rawMatches = scanResult.matched;
      if (rawMatches.isEmpty) break;

      final exploded = _resolveExplosions(rawMatches, _state.tiles);
      final explodedIds = exploded.map((e) => e.id).toSet();

      final updatedTiles = _state.tiles.map((tile) {
        if (scanResult.specials.containsKey(tile.id)) {
          final type = scanResult.specials[tile.id]!;
          return tile.copyWith(
            type: type,
            emoji: type == TileType.colorBomb ? '🍭' : tile.emoji,
          );
        }
        return tile;
      }).toList();

      final keptSpecialIds = scanResult.specials.keys.toSet();
      final finalExplodedIds = explodedIds.difference(keptSpecialIds);

      final scoreIncrease = finalExplodedIds.length * 50;
      final newScore = _state.score + scoreIncrease;

      final destroyedTiles = _state.tiles.where((t) => finalExplodedIds.contains(t.id)).toList();
      _updateGoalProgress(
        scoreAdded: scoreIncrease,
        clearedTiles: destroyedTiles,
        specialsCreatedCount: scanResult.specials.length,
        isCombo: _state.comboCount > 0,
      );

      final stars = calculateStars(newScore);
      final remaining = updatedTiles.where((t) => !finalExplodedIds.contains(t.id)).toList();

      _state = _state.copyWith(
        tiles: remaining,
        score: newScore,
        goal: _currentGoal,
        highScore: max(newScore, _state.highScore),
        comboCount: _state.comboCount + 1,
        starsEarned: stars,
      );
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));

      final cascadedTiles = _cascadeBoard(_state.tiles);
      _state = _state.copyWith(tiles: cascadedTiles);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    final isGoalCompleted = _currentGoal.isCompleted;
    if (!_isZenMode && (_state.movesLeft <= 0 || isGoalCompleted)) {
      final finalStars = calculateStars(_state.score);
      _state = _state.copyWith(
        isGameOver: true,
        starsEarned: finalStars,
      );
      if (isGoalCompleted) {
        await progressRepository.completeLevel(
          _state.levelNumber,
          finalStars,
        );
      }
      notifyListeners();
    }
  }

  ScanResult _scanAndGenerateSpecials(List<TileModel> tiles) {
    final matched = <TileModel>{};
    final specials = <String, TileType>{};

    for (int r = 0; r < _state.rows; r++) {
      int matchStart = 0;
      for (int c = 1; c <= _state.cols; c++) {
        final current = c < _state.cols ? tiles.firstWhere((t) => t.row == r && t.col == c) : null;
        final startTile = tiles.firstWhere((t) => t.row == r && t.col == matchStart);

        if (current != null && current.emoji == startTile.emoji && current.type != TileType.colorBomb) {
          continue;
        } else {
          final length = c - matchStart;
          if (length >= 3) {
            for (int i = matchStart; i < c; i++) {
              final t = tiles.firstWhere((item) => item.row == r && item.col == i);
              matched.add(t);
            }
            if (length == 4) {
              final specialTile = tiles.firstWhere((item) => item.row == r && item.col == matchStart + 1);
              specials[specialTile.id] = TileType.stripedHorizontal;
            } else if (length >= 5) {
              final specialTile = tiles.firstWhere((item) => item.row == r && item.col == matchStart + 2);
              specials[specialTile.id] = TileType.colorBomb;
            }
          }
          matchStart = c;
        }
      }
    }

    for (int c = 0; c < _state.cols; c++) {
      int matchStart = 0;
      for (int r = 1; r <= _state.rows; r++) {
        final current = r < _state.rows ? tiles.firstWhere((t) => t.row == r && t.col == c) : null;
        final startTile = tiles.firstWhere((t) => t.row == matchStart && t.col == c);

        if (current != null && current.emoji == startTile.emoji && current.type != TileType.colorBomb) {
          continue;
        } else {
          final length = r - matchStart;
          if (length >= 3) {
            for (int i = matchStart; i < r; i++) {
              final t = tiles.firstWhere((item) => item.row == i && item.col == c);
              matched.add(t);
            }
            if (length == 4) {
              final specialTile = tiles.firstWhere((item) => item.row == matchStart + 1 && item.col == c);
              specials[specialTile.id] = TileType.stripedVertical;
            } else if (length >= 5) {
              final specialTile = tiles.firstWhere((item) => item.row == matchStart + 2 && item.col == c);
              specials[specialTile.id] = TileType.colorBomb;
            }
          }
          matchStart = r;
        }
      }
    }

    return ScanResult(matched: matched.toList(), specials: specials);
  }

  List<TileModel> _resolveExplosions(List<TileModel> initialMatches, List<TileModel> allTiles) {
    final exploded = <TileModel>{...initialMatches};
    final queue = List<TileModel>.from(initialMatches);

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (current.type == TileType.stripedHorizontal) {
        final rowTiles = allTiles.where((t) => t.row == current.row && !exploded.contains(t));
        for (final t in rowTiles) {
          exploded.add(t);
          queue.add(t);
        }
      } else if (current.type == TileType.stripedVertical) {
        final colTiles = allTiles.where((t) => t.col == current.col && !exploded.contains(t));
        for (final t in colTiles) {
          exploded.add(t);
          queue.add(t);
        }
      } else if (current.type == TileType.wrapped) {
        final blastRadius = allTiles.where((t) =>
            (t.row - current.row).abs() <= 1 &&
            (t.col - current.col).abs() <= 1 &&
            !exploded.contains(t));
        for (final t in blastRadius) {
          exploded.add(t);
          queue.add(t);
        }
      }
    }
    return exploded.toList();
  }

  List<TileModel> _cascadeBoard(List<TileModel> remainingTiles) {
    final newTiles = <TileModel>[];
    final availableFruits = _getAvailableFruits(_fruitVarietyCount);

    for (int c = 0; c < _state.cols; c++) {
      final colTiles = remainingTiles.where((t) => t.col == c).toList()
        ..sort((a, b) => b.row.compareTo(a.row));

      int targetRow = _state.rows - 1;
      for (final tile in colTiles) {
        newTiles.add(tile.copyWith(row: targetRow));
        targetRow--;
      }

      while (targetRow >= 0) {
        final emoji = availableFruits[_random.nextInt(availableFruits.length)];
        newTiles.add(TileModel(
          id: '${DateTime.now().microsecondsSinceEpoch}_${targetRow}_${c}_${_random.nextInt(1000)}',
          row: targetRow,
          col: c,
          emoji: emoji,
        ));
        targetRow--;
      }
    }
    return newTiles;
  }

  List<TileModel> _findMatches(List<TileModel> tiles) {
    return _scanAndGenerateSpecials(tiles).matched;
  }
}

class ScanResult {
  final List<TileModel> matched;
  final Map<String, TileType> specials;

  ScanResult({required this.matched, required this.specials});
}
