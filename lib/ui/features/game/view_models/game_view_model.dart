import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:match3/data/repositories/progress_repository.dart';
import 'package:match3/domain/models/gem.dart';
import 'package:match3/domain/models/level_config.dart';
import 'package:match3/domain/use_cases/match3_board_generator.dart';
import 'package:match3/domain/use_cases/match3_engine.dart';

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.levelNumber = 1,
    this.levelConfig,
    this.board = const [],
    this.selectedGem,
    this.movesLeft = 0,
    this.score = 0,
    this.elapsedSeconds = 0,
    this.collectedGems = const {},
    this.isLoading = false,
    this.isComplete = false,
    this.isFailed = false,
    this.canUndo = false,
    this.canShuffle = true,
    this.matchedPositions = const [],
    this.error,
    this.earnedStars = 0,
    this.isZenMode = false,
  });

  final int levelNumber;
  final LevelConfig? levelConfig;
  final List<BoardGem> board;
  final BoardGem? selectedGem;
  final int movesLeft;
  final int score;
  final int elapsedSeconds;
  final Map<String, int> collectedGems;
  final bool isLoading;
  final bool isComplete;
  final bool isFailed;
  final bool canUndo;
  final bool canShuffle;
  final List<BoardPosition> matchedPositions;
  final String? error;
  final int earnedStars;
  final bool isZenMode;

  GameViewModelState copyWith({
    int? levelNumber,
    LevelConfig? levelConfig,
    List<BoardGem>? board,
    BoardGem? selectedGem,
    bool clearSelectedGem = false,
    int? movesLeft,
    int? score,
    int? elapsedSeconds,
    Map<String, int>? collectedGems,
    bool? isLoading,
    bool? isComplete,
    bool? isFailed,
    bool? canUndo,
    bool? canShuffle,
    List<BoardPosition>? matchedPositions,
    String? error,
    int? earnedStars,
    bool? isZenMode,
  }) {
    return GameViewModelState(
      levelNumber: levelNumber ?? this.levelNumber,
      levelConfig: levelConfig ?? this.levelConfig,
      board: board ?? this.board,
      selectedGem: clearSelectedGem ? null : (selectedGem ?? this.selectedGem),
      movesLeft: movesLeft ?? this.movesLeft,
      score: score ?? this.score,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      collectedGems: collectedGems ?? this.collectedGems,
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      isFailed: isFailed ?? this.isFailed,
      canUndo: canUndo ?? this.canUndo,
      canShuffle: canShuffle ?? this.canShuffle,
      matchedPositions: matchedPositions ?? this.matchedPositions,
      error: error,
      earnedStars: earnedStars ?? this.earnedStars,
      isZenMode: isZenMode ?? this.isZenMode,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  GameViewModel({
    required this.progressRepository,
    required this.boardGenerator,
    required this.engine,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;
  final Match3BoardGenerator boardGenerator;
  final Match3Engine engine;

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void loadLevel(int levelNumber, {bool isZenMode = false}) {
    state = GameViewModelState(
      levelNumber: levelNumber,
      isLoading: true,
      isZenMode: isZenMode,
    );

    final config = LevelDefinitions.getLevel(levelNumber);
    final board = boardGenerator.generateBoard(
      level: config,
      seed: levelNumber * 1000 + 42,
    );

    state = state.copyWith(
      levelConfig: config,
      board: board,
      movesLeft: config.moves,
      isLoading: false,
      isComplete: false,
      isFailed: false,
      collectedGems: {},
      score: 0,
      canUndo: false,
      canShuffle: true,
      earnedStars: 0,
    );
  }

  void selectGem(BoardGem gem) {
    if (state.isComplete || state.isFailed) return;

    final level = state.levelConfig;
    if (level == null) return;

    // Ignore blockers and ice
    if (level.hasBlockers && level.blockerPositions.any((p) => p.row == gem.position.row && p.col == gem.position.col)) {
      HapticFeedback.heavyImpact().catchError((_) {});
      return;
    }

    if (state.selectedGem == null) {
      state = state.copyWith(selectedGem: gem);
      HapticFeedback.mediumImpact().catchError((_) {});
      return;
    }

    if (state.selectedGem!.id == gem.id) {
      state = state.copyWith(clearSelectedGem: true);
      HapticFeedback.lightImpact().catchError((_) {});
      return;
    }

    // Check if adjacent
    if (!state.selectedGem!.position.isAdjacentTo(gem.position)) {
      state = state.copyWith(selectedGem: gem);
      HapticFeedback.mediumImpact().catchError((_) {});
      return;
    }

    // Try swap
    _executeSwap(state.selectedGem!, gem);
  }

  Future<void> _executeSwap(BoardGem gem1, BoardGem gem2) async {
    final level = state.levelConfig;
    if (level == null) return;

    var tempBoard = List<BoardGem>.from(state.board);
    final idx1 = tempBoard.indexWhere((g) => g.id == gem1.id);
    final idx2 = tempBoard.indexWhere((g) => g.id == gem2.id);
    if (idx1 < 0 || idx2 < 0) return;

    final pos1 = gem1.position;
    final pos2 = gem2.position;

    tempBoard[idx1] = gem1.copyWith(position: pos2);
    tempBoard[idx2] = gem2.copyWith(position: pos1);

    state = state.copyWith(board: tempBoard, clearSelectedGem: true);
    HapticFeedback.mediumImpact().catchError((_) {});

    await Future.delayed(const Duration(milliseconds: 250));

    var matches = engine.findAllMatches(tempBoard, level);
    if (matches.isEmpty) {
      tempBoard[idx1] = gem1.copyWith(position: pos1);
      tempBoard[idx2] = gem2.copyWith(position: pos2);
      state = state.copyWith(board: tempBoard);
      HapticFeedback.mediumImpact().catchError((_) {});
      return;
    }

    final newMoves = state.isZenMode ? state.movesLeft : state.movesLeft - 1;
    state = state.copyWith(movesLeft: newMoves);

    while (matches.isNotEmpty) {
      final matchedPositions = matches.expand((m) => m.matchedPositions).toList();
      state = state.copyWith(matchedPositions: matchedPositions);

      var scoreGained = 0;
      final newCollected = Map<String, int>.from(state.collectedGems);
      for (final match in matches) {
        for (final pos in match.matchedPositions) {
          final gem = tempBoard.firstWhere(
            (g) => g.position.row == pos.row && g.position.col == pos.col,
            orElse: () => gem1,
          );
          scoreGained += engine.scoreForGem(gem);
          final key = '${gem.gem.type.index}';
          newCollected[key] = (newCollected[key] ?? 0) + 1;
        }
      }

      state = state.copyWith(
        score: state.score + scoreGained,
        collectedGems: newCollected,
      );

      HapticFeedback.lightImpact().catchError((_) {});

      await Future.delayed(const Duration(milliseconds: 350));

      final matchedIds = <String>{};
      for (final match in matches) {
        for (final pos in match.matchedPositions) {
          final gem = tempBoard.firstWhere(
            (g) => g.position.row == pos.row && g.position.col == pos.col,
            orElse: () => gem1,
          );
          matchedIds.add(gem.id);
        }
      }
      tempBoard = tempBoard.where((g) => !matchedIds.contains(g.id)).toList();
      state = state.copyWith(board: tempBoard, matchedPositions: []);

      await Future.delayed(const Duration(milliseconds: 100));

      tempBoard = engine.applyGravity(tempBoard, level);
      state = state.copyWith(board: tempBoard);

      await Future.delayed(const Duration(milliseconds: 300));

      tempBoard = engine.fillEmptySpaces(tempBoard, level, tempBoard.length);
      state = state.copyWith(board: tempBoard);

      await Future.delayed(const Duration(milliseconds: 300));

      matches = engine.findAllMatches(tempBoard, level);
    }

    if (state.isZenMode) {
      final noValidMoves = !engine.hasValidMoves(tempBoard, level);
      if (noValidMoves) {
        final shuffledBoard = engine.shuffleBoard(
          tempBoard,
          level,
          DateTime.now().millisecondsSinceEpoch,
        );
        state = state.copyWith(
          board: shuffledBoard,
          clearSelectedGem: true,
        );
      }
      return;
    }

    final isDone = _checkObjective(level, state.score, state.collectedGems, tempBoard);
    final noMoves = state.movesLeft <= 0;
    final noValidMoves = !engine.hasValidMoves(tempBoard, level);

    if (isDone) {
      final stars = _calculateStars(level, state.score, state.movesLeft);
      state = state.copyWith(isComplete: true, earnedStars: stars);
      progressRepository
          .completeLevel(state.levelNumber, stars)
          .catchError((e) => debugPrint('Error saving progress: $e'));
    } else if (noMoves) {
      state = state.copyWith(isFailed: true);
    } else if (noValidMoves) {
      final shuffledBoard = engine.shuffleBoard(
        tempBoard,
        level,
        DateTime.now().millisecondsSinceEpoch,
      );
      state = state.copyWith(
        board: shuffledBoard,
        clearSelectedGem: true,
      );
    }
  }

  bool _checkObjective(LevelConfig level, int score, Map<String, int> collected, List<BoardGem> board) {
    switch (level.objective.objective) {
      case LevelObjective.score:
        return score >= level.objective.targetScore;
      case LevelObjective.collectGems:
        int total = 0;
        for (final entry in level.objective.gemTypeCounts.entries) {
          total += (collected[entry.key] ?? 0).clamp(0, entry.value);
        }
        return total >= level.objective.targetGems;
      case LevelObjective.clearBoard:
        return score >= 1200;
    }
  }

  int _calculateStars(LevelConfig level, int score, int movesLeft) {
    if (level.objective.objective == LevelObjective.score || level.objective.objective == LevelObjective.clearBoard) {
      final target = level.objective.objective == LevelObjective.clearBoard ? 1200 : level.objective.targetScore;
      if (score >= target * 2.0) return 3;
      if (score >= target * 1.5) return 2;
      return 1;
    } else {
      if (movesLeft >= 6) return 3;
      if (movesLeft >= 3) return 2;
      return 1;
    }
  }

  void shuffle() {
    if (state.isComplete || state.isFailed || !state.canShuffle) return;

    final level = state.levelConfig;
    if (level == null) return;

    final newBoard = engine.shuffleBoard(state.board, level, DateTime.now().millisecondsSinceEpoch);

    state = state.copyWith(
      board: newBoard,
      clearSelectedGem: true,
      canShuffle: false,
    );

    HapticFeedback.heavyImpact().catchError((_) {});
  }

  void undo() {
    state = state.copyWith(clearSelectedGem: true);
    HapticFeedback.lightImpact().catchError((_) {});
  }
}
