import 'package:flutter/foundation.dart';
import 'package:match3/domain/models/level_generator.dart';
import 'package:match3/domain/models/level_goal.dart';
import 'package:match3/domain/models/tile_model.dart';

@immutable
class GameStateModel {
  final List<TileModel> tiles;
  final int score;
  final int highScore;
  final int movesLeft;
  final int targetScore;
  final LevelGoal goal;
  final bool isGameOver;
  final int rows;
  final int cols;
  final int comboCount;
  final int levelNumber;
  final int star1Score;
  final int star2Score;
  final int star3Score;
  final int starsEarned;
  final Set<String> jellyTiles;
  final Set<String> hintTileIds;
  final bool isShuffling;
  final bool isSugarCrush;
  final LevelConfig? levelConfig;

  const GameStateModel({
    required this.tiles,
    required this.score,
    required this.highScore,
    required this.movesLeft,
    required this.targetScore,
    this.goal = const LevelGoal(
      type: LevelGoalType.score,
      title: 'SCORE TARGET',
      description: 'Reach target score',
      targetValue: 1000,
    ),
    required this.isGameOver,
    required this.rows,
    required this.cols,
    required this.comboCount,
    required this.levelNumber,
    this.star1Score = 500,
    this.star2Score = 1000,
    this.star3Score = 1500,
    this.starsEarned = 0,
    this.jellyTiles = const {},
    this.hintTileIds = const {},
    this.isShuffling = false,
    this.isSugarCrush = false,
    this.levelConfig,
  });

  TileModel? getTile(int row, int col) {
    try {
      return tiles.firstWhere((tile) => tile.row == row && tile.col == col);
    } catch (_) {
      return null;
    }
  }

  GameStateModel copyWith({
    List<TileModel>? tiles,
    int? score,
    int? highScore,
    int? movesLeft,
    int? targetScore,
    LevelGoal? goal,
    bool? isGameOver,
    int? rows,
    int? cols,
    int? comboCount,
    int? levelNumber,
    int? star1Score,
    int? star2Score,
    int? star3Score,
    int? starsEarned,
    Set<String>? jellyTiles,
    Set<String>? hintTileIds,
    bool? isShuffling,
    bool? isSugarCrush,
    LevelConfig? levelConfig,
  }) {
    return GameStateModel(
      tiles: tiles ?? this.tiles,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      movesLeft: movesLeft ?? this.movesLeft,
      targetScore: targetScore ?? this.targetScore,
      goal: goal ?? this.goal,
      isGameOver: isGameOver ?? this.isGameOver,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      comboCount: comboCount ?? this.comboCount,
      levelNumber: levelNumber ?? this.levelNumber,
      star1Score: star1Score ?? this.star1Score,
      star2Score: star2Score ?? this.star2Score,
      star3Score: star3Score ?? this.star3Score,
      starsEarned: starsEarned ?? this.starsEarned,
      jellyTiles: jellyTiles ?? this.jellyTiles,
      hintTileIds: hintTileIds ?? this.hintTileIds,
      isShuffling: isShuffling ?? this.isShuffling,
      isSugarCrush: isSugarCrush ?? this.isSugarCrush,
      levelConfig: levelConfig ?? this.levelConfig,
    );
  }
}
