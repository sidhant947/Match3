import 'package:flutter/foundation.dart';
import 'package:match3/domain/models/gem.dart';

enum LevelObjective {
  score,
  collectGems,
  clearBoard,
}

@immutable
class LevelObjectiveConfig {
  const LevelObjectiveConfig({
    required this.objective,
    this.targetScore = 0,
    this.gemTypeCounts = const {},
    this.targetGems = 0,
  });

  final LevelObjective objective;
  final int targetScore;
  final Map<String, int> gemTypeCounts;
  final int targetGems;
}

@immutable
class LevelConfig {
  const LevelConfig({
    required this.levelNumber,
    required this.name,
    required this.rows,
    required this.cols,
    required this.numGemTypes,
    required this.moves,
    required this.objective,
    this.hasBlockers = false,
    this.blockerPositions = const [],
    this.hasIce = false,
    this.icePositions = const [],
  });

  final int levelNumber;
  final String name;
  final int rows;
  final int cols;
  final int numGemTypes;
  final int moves;
  final LevelObjectiveConfig objective;
  final bool hasBlockers;
  final List<BoardPosition> blockerPositions;
  final bool hasIce;
  final List<BoardPosition> icePositions;
}

class LevelDefinitions {
  LevelDefinitions._();

  static final List<LevelConfig> levels = [
    // Chapter 1: The Awakening (Levels 1-10) - Tutorial, simple objectives
    LevelConfig(
      levelNumber: 1,
      name: 'First Light',
      rows: 7,
      cols: 7,
      numGemTypes: 4,
      moves: 25,
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 500),
    ),
    LevelConfig(
      levelNumber: 2,
      name: 'Gathering',
      rows: 7,
      cols: 7,
      numGemTypes: 4,
      moves: 20,
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 15},
        targetGems: 15,
      ),
    ),
    LevelConfig(
      levelNumber: 3,
      name: 'Clear Vision',
      rows: 7,
      cols: 7,
      numGemTypes: 4,
      moves: 20,
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 4,
      name: 'Rising Stars',
      rows: 7,
      cols: 7,
      numGemTypes: 4,
      moves: 22,
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'1': 12, '3': 12},
        targetGems: 24,
      ),
    ),
    LevelConfig(
      levelNumber: 5,
      name: 'Twin Peaks',
      rows: 8,
      cols: 7,
      numGemTypes: 4,
      moves: 25,
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 1000),
    ),
    LevelConfig(
      levelNumber: 6,
      name: 'Deep Breath',
      rows: 8,
      cols: 7,
      numGemTypes: 5,
      moves: 22,
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 10, '2': 10},
        targetGems: 20,
      ),
    ),
    LevelConfig(
      levelNumber: 7,
      name: 'Whirlpool',
      rows: 8,
      cols: 7,
      numGemTypes: 5,
      moves: 20,
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 8,
      name: 'Color Burst',
      rows: 8,
      cols: 8,
      numGemTypes: 5,
      moves: 25,
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 8, '1': 8, '2': 8},
        targetGems: 24,
      ),
    ),
    LevelConfig(
      levelNumber: 9,
      name: 'Cascade',
      rows: 8,
      cols: 8,
      numGemTypes: 5,
      moves: 22,
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 2000),
    ),
    LevelConfig(
      levelNumber: 10,
      name: 'The Gate',
      rows: 8,
      cols: 8,
      numGemTypes: 5,
      moves: 20,
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),

    // Chapter 2: The Descent (Levels 11-20) - Introduce blockers
    LevelConfig(
      levelNumber: 11,
      name: 'Stone Path',
      rows: 8,
      cols: 8,
      numGemTypes: 5,
      moves: 25,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 3, col: 3),
        BoardPosition(row: 3, col: 4),
        BoardPosition(row: 4, col: 3),
        BoardPosition(row: 4, col: 4),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 2500),
    ),
    LevelConfig(
      levelNumber: 12,
      name: 'Narrow Way',
      rows: 8,
      cols: 8,
      numGemTypes: 5,
      moves: 22,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 0, col: 3),
        BoardPosition(row: 0, col: 4),
        BoardPosition(row: 7, col: 3),
        BoardPosition(row: 7, col: 4),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'3': 15, '4': 15},
        targetGems: 30,
      ),
    ),
    LevelConfig(
      levelNumber: 13,
      name: 'Frozen Light',
      rows: 8,
      cols: 8,
      numGemTypes: 5,
      moves: 25,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 2, col: 2),
        BoardPosition(row: 2, col: 5),
        BoardPosition(row: 5, col: 2),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 14,
      name: 'Shifting Sands',
      rows: 9,
      cols: 8,
      numGemTypes: 5,
      moves: 25,
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 3000),
    ),
    LevelConfig(
      levelNumber: 15,
      name: 'The Match Three',
      rows: 9,
      cols: 8,
      numGemTypes: 5,
      moves: 22,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 4, col: 1),
        BoardPosition(row: 4, col: 6),
        BoardPosition(row: 1, col: 3),
        BoardPosition(row: 1, col: 4),
        BoardPosition(row: 6, col: 3),
        BoardPosition(row: 6, col: 4),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 10, '1': 10, '2': 10, '3': 10},
        targetGems: 40,
      ),
    ),
    LevelConfig(
      levelNumber: 16,
      name: 'Echoes',
      rows: 9,
      cols: 8,
      numGemTypes: 5,
      moves: 24,
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 17,
      name: 'Whispers',
      rows: 9,
      cols: 9,
      numGemTypes: 5,
      moves: 26,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 3, col: 4),
        BoardPosition(row: 5, col: 4),
        BoardPosition(row: 4, col: 3),
        BoardPosition(row: 4, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 4000),
    ),
    LevelConfig(
      levelNumber: 18,
      name: 'Veil',
      rows: 9,
      cols: 9,
      numGemTypes: 5,
      moves: 22,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 1, col: 1),
        BoardPosition(row: 1, col: 7),
        BoardPosition(row: 7, col: 1),
        BoardPosition(row: 7, col: 7),
        BoardPosition(row: 4, col: 4),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'2': 20, '4': 20},
        targetGems: 40,
      ),
    ),
    LevelConfig(
      levelNumber: 19,
      name: 'Pulse',
      rows: 9,
      cols: 9,
      numGemTypes: 5,
      moves: 25,
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 20,
      name: 'Abyss',
      rows: 9,
      cols: 9,
      numGemTypes: 6,
      moves: 28,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 2, col: 2),
        BoardPosition(row: 2, col: 6),
        BoardPosition(row: 6, col: 2),
        BoardPosition(row: 6, col: 6),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 5000),
    ),

    // Chapter 3: The Depths (Levels 21-35) - More complex, 6 gem types, tighter moves
    LevelConfig(
      levelNumber: 21,
      name: 'Descent',
      rows: 9,
      cols: 9,
      numGemTypes: 6,
      moves: 24,
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 12, '1': 12, '2': 12},
        targetGems: 36,
      ),
    ),
    LevelConfig(
      levelNumber: 22,
      name: 'Twilight',
      rows: 9,
      cols: 9,
      numGemTypes: 6,
      moves: 22,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 0, col: 4),
        BoardPosition(row: 8, col: 4),
        BoardPosition(row: 4, col: 0),
        BoardPosition(row: 4, col: 8),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 23,
      name: 'Shimmer',
      rows: 9,
      cols: 9,
      numGemTypes: 6,
      moves: 26,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 3, col: 3),
        BoardPosition(row: 3, col: 5),
        BoardPosition(row: 5, col: 3),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 5500),
    ),
    LevelConfig(
      levelNumber: 24,
      name: 'Fragments',
      rows: 10,
      cols: 9,
      numGemTypes: 6,
      moves: 28,
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'3': 15, '4': 15, '5': 15},
        targetGems: 45,
      ),
    ),
    LevelConfig(
      levelNumber: 25,
      name: 'The Core',
      rows: 10,
      cols: 9,
      numGemTypes: 6,
      moves: 25,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 4, col: 2),
        BoardPosition(row: 4, col: 6),
        BoardPosition(row: 5, col: 2),
        BoardPosition(row: 5, col: 6),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 26,
      name: 'Resonance',
      rows: 10,
      cols: 9,
      numGemTypes: 6,
      moves: 27,
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 6000),
    ),
    LevelConfig(
      levelNumber: 27,
      name: 'Eclipse',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 30,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 2, col: 2),
        BoardPosition(row: 2, col: 7),
        BoardPosition(row: 7, col: 2),
        BoardPosition(row: 7, col: 7),
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 10, '1': 10, '2': 10, '3': 10, '4': 10},
        targetGems: 50,
      ),
    ),
    LevelConfig(
      levelNumber: 28,
      name: 'Mirage',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 26,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 0, col: 4),
        BoardPosition(row: 0, col: 5),
        BoardPosition(row: 9, col: 4),
        BoardPosition(row: 9, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 29,
      name: 'Fracture',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 28,
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 7000),
    ),
    LevelConfig(
      levelNumber: 30,
      name: 'Threshold',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 25,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 3, col: 3),
        BoardPosition(row: 3, col: 6),
        BoardPosition(row: 6, col: 3),
        BoardPosition(row: 6, col: 6),
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 4, col: 5),
        BoardPosition(row: 5, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 31,
      name: 'Vortex',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 28,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 2, col: 2),
        BoardPosition(row: 2, col: 7),
        BoardPosition(row: 7, col: 2),
        BoardPosition(row: 7, col: 7),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 7500),
    ),
    LevelConfig(
      levelNumber: 32,
      name: 'Spiral',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 26,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 0, col: 0),
        BoardPosition(row: 0, col: 9),
        BoardPosition(row: 9, col: 0),
        BoardPosition(row: 9, col: 9),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 15, '5': 15},
        targetGems: 30,
      ),
    ),
    LevelConfig(
      levelNumber: 33,
      name: 'Reverie',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 30,
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 34,
      name: 'Maelstrom',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 27,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 1, col: 4),
        BoardPosition(row: 1, col: 5),
        BoardPosition(row: 8, col: 4),
        BoardPosition(row: 8, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 8000),
    ),
    LevelConfig(
      levelNumber: 35,
      name: 'Nexus',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 25,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 4, col: 5),
        BoardPosition(row: 5, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 2, col: 4),
        BoardPosition(row: 2, col: 5),
        BoardPosition(row: 7, col: 4),
        BoardPosition(row: 7, col: 5),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 12, '1': 12, '2': 12, '3': 12},
        targetGems: 48,
      ),
    ),

    // Chapter 4: The Void (Levels 36-50) - Extreme difficulty
    LevelConfig(
      levelNumber: 36,
      name: 'Entropy',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 24,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 2, col: 2),
        BoardPosition(row: 2, col: 7),
        BoardPosition(row: 7, col: 2),
        BoardPosition(row: 7, col: 7),
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 37,
      name: 'Oblivion',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 28,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 1, col: 1),
        BoardPosition(row: 1, col: 8),
        BoardPosition(row: 8, col: 1),
        BoardPosition(row: 8, col: 8),
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 9000),
    ),
    LevelConfig(
      levelNumber: 38,
      name: 'Shattered',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 26,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 0, col: 3),
        BoardPosition(row: 0, col: 6),
        BoardPosition(row: 9, col: 3),
        BoardPosition(row: 9, col: 6),
        BoardPosition(row: 3, col: 0),
        BoardPosition(row: 3, col: 9),
        BoardPosition(row: 6, col: 0),
        BoardPosition(row: 6, col: 9),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 10, '1': 10, '2': 10, '3': 10, '4': 10, '5': 10},
        targetGems: 60,
      ),
    ),
    LevelConfig(
      levelNumber: 39,
      name: 'Dissolution',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 30,
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 40,
      name: 'The Void',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 25,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 3, col: 3),
        BoardPosition(row: 3, col: 6),
        BoardPosition(row: 6, col: 3),
        BoardPosition(row: 6, col: 6),
      ],
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 1, col: 4),
        BoardPosition(row: 1, col: 5),
        BoardPosition(row: 8, col: 4),
        BoardPosition(row: 8, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 10000),
    ),
    LevelConfig(
      levelNumber: 41,
      name: 'Wraith',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 27,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 4, col: 2),
        BoardPosition(row: 4, col: 7),
        BoardPosition(row: 5, col: 2),
        BoardPosition(row: 5, col: 7),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 42,
      name: 'Phantom',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 26,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 2, col: 2),
        BoardPosition(row: 2, col: 7),
        BoardPosition(row: 7, col: 2),
        BoardPosition(row: 7, col: 7),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'5': 25},
        targetGems: 25,
      ),
    ),
    LevelConfig(
      levelNumber: 43,
      name: 'Abyss Gate',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 28,
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 11000),
    ),
    LevelConfig(
      levelNumber: 44,
      name: 'Silence',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 25,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 2, col: 4),
        BoardPosition(row: 2, col: 5),
        BoardPosition(row: 7, col: 4),
        BoardPosition(row: 7, col: 5),
        BoardPosition(row: 4, col: 2),
        BoardPosition(row: 4, col: 7),
        BoardPosition(row: 5, col: 2),
        BoardPosition(row: 5, col: 7),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 45,
      name: 'Eclipse Core',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 30,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 0, col: 0),
        BoardPosition(row: 0, col: 9),
        BoardPosition(row: 9, col: 0),
        BoardPosition(row: 9, col: 9),
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 15, '1': 15, '2': 15, '3': 15},
        targetGems: 60,
      ),
    ),
    LevelConfig(
      levelNumber: 46,
      name: 'Null Point',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 26,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 3, col: 3),
        BoardPosition(row: 3, col: 4),
        BoardPosition(row: 3, col: 5),
        BoardPosition(row: 3, col: 6),
        BoardPosition(row: 6, col: 3),
        BoardPosition(row: 6, col: 4),
        BoardPosition(row: 6, col: 5),
        BoardPosition(row: 6, col: 6),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 12000),
    ),
    LevelConfig(
      levelNumber: 47,
      name: 'Event Horizon',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 28,
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 1, col: 1),
        BoardPosition(row: 1, col: 8),
        BoardPosition(row: 8, col: 1),
        BoardPosition(row: 8, col: 8),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.clearBoard),
    ),
    LevelConfig(
      levelNumber: 48,
      name: 'Singularity',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 27,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 4, col: 5),
        BoardPosition(row: 5, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 20, '5': 20},
        targetGems: 40,
      ),
    ),
    LevelConfig(
      levelNumber: 49,
      name: 'Beyond',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 30,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 2, col: 2),
        BoardPosition(row: 2, col: 7),
        BoardPosition(row: 7, col: 2),
        BoardPosition(row: 7, col: 7),
      ],
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 4, col: 4),
        BoardPosition(row: 5, col: 5),
      ],
      objective: const LevelObjectiveConfig(objective: LevelObjective.score, targetScore: 15000),
    ),
    LevelConfig(
      levelNumber: 50,
      name: 'Match Three',
      rows: 10,
      cols: 10,
      numGemTypes: 6,
      moves: 35,
      hasBlockers: true,
      blockerPositions: const [
        BoardPosition(row: 3, col: 3),
        BoardPosition(row: 3, col: 6),
        BoardPosition(row: 6, col: 3),
        BoardPosition(row: 6, col: 6),
      ],
      hasIce: true,
      icePositions: const [
        BoardPosition(row: 1, col: 4),
        BoardPosition(row: 1, col: 5),
        BoardPosition(row: 8, col: 4),
        BoardPosition(row: 8, col: 5),
        BoardPosition(row: 4, col: 1),
        BoardPosition(row: 5, col: 1),
        BoardPosition(row: 4, col: 8),
        BoardPosition(row: 5, col: 8),
      ],
      objective: const LevelObjectiveConfig(
        objective: LevelObjective.collectGems,
        gemTypeCounts: {'0': 15, '1': 15, '2': 15, '3': 15, '4': 15, '5': 15},
        targetGems: 90,
      ),
    ),
  ];

  static LevelConfig getLevel(int levelNumber) {
    if (levelNumber <= 0) return levels.first;
    if (levelNumber <= levels.length) return levels[levelNumber - 1];
    return _generateProceduralLevel(levelNumber);
  }

  static LevelConfig _generateProceduralLevel(int levelNumber) {
    final rng = _Lcg(levelNumber * 7919 + 104729);
    final cycle = levelNumber % 5;

    final int rows;
    final int cols;
    final int numGemTypes;
    final int moves;
    final bool hasBlockers;
    final bool hasIce;
    final String difficultyName;

    switch (cycle) {
      case 0:
        rows = 7;
        cols = 7;
        numGemTypes = 5;
        moves = 25 + (rng.next() % 5);
        hasBlockers = false;
        hasIce = false;
        difficultyName = 'Relaxation Wave';
        break;
      case 1:
        rows = 7;
        cols = 8;
        numGemTypes = 5;
        moves = 22 + (rng.next() % 5);
        hasBlockers = rng.next() % 3 == 0;
        hasIce = false;
        difficultyName = 'Flow Journey';
        break;
      case 2:
        rows = 8;
        cols = 8;
        numGemTypes = 6;
        moves = 20 + (rng.next() % 5);
        hasBlockers = true;
        hasIce = rng.next() % 4 == 0;
        difficultyName = 'Rising Tension';
        break;
      case 3:
        rows = 8;
        cols = 9;
        numGemTypes = 7;
        moves = 18 + (rng.next() % 5);
        hasBlockers = true;
        hasIce = true;
        difficultyName = 'Apex Peak';
        break;
      case 4:
        rows = 9;
        cols = 9;
        numGemTypes = 8;
        moves = 18 + (rng.next() % 4);
        hasBlockers = true;
        hasIce = true;
        difficultyName = 'Master Citadel';
        break;
      default:
        rows = 8;
        cols = 8;
        numGemTypes = 6;
        moves = 20;
        hasBlockers = false;
        hasIce = false;
        difficultyName = 'Quest';
    }

    final blockerPositions = <BoardPosition>[];
    if (hasBlockers) {
      final count = 2 + (rng.next() % 5);
      for (int i = 0; i < count; i++) {
        blockerPositions.add(BoardPosition(
          row: rng.next() % rows,
          col: rng.next() % cols,
        ));
      }
    }

    final icePositions = <BoardPosition>[];
    if (hasIce) {
      final count = 2 + (rng.next() % 4);
      for (int i = 0; i < count; i++) {
        icePositions.add(BoardPosition(
          row: rng.next() % rows,
          col: rng.next() % cols,
        ));
      }
    }

    final objectives = LevelObjective.values;
    final objective = objectives[rng.next() % objectives.length];
    final LevelObjectiveConfig objectiveConfig;

    switch (objective) {
      case LevelObjective.score:
        objectiveConfig = LevelObjectiveConfig(
          objective: LevelObjective.score,
          targetScore: 8000 + (levelNumber - 50) * 500,
        );
        break;
      case LevelObjective.collectGems:
        final count = 2 + (rng.next() % 4);
        final gemTypeCounts = <String, int>{};
        int total = 0;
        for (int i = 0; i < count; i++) {
          final gemIdx = i % numGemTypes;
          final gemCount = 10 + (rng.next() % 10);
          gemTypeCounts['$gemIdx'] = gemCount;
          total += gemCount;
        }
        objectiveConfig = LevelObjectiveConfig(
          objective: LevelObjective.collectGems,
          gemTypeCounts: gemTypeCounts,
          targetGems: total,
        );
        break;
      case LevelObjective.clearBoard:
        objectiveConfig = const LevelObjectiveConfig(objective: LevelObjective.clearBoard);
        break;
    }

    return LevelConfig(
      levelNumber: levelNumber,
      name: '$difficultyName #$levelNumber',
      rows: rows,
      cols: cols,
      numGemTypes: numGemTypes,
      moves: moves,
      hasBlockers: hasBlockers,
      blockerPositions: blockerPositions,
      hasIce: hasIce,
      icePositions: icePositions,
      objective: objectiveConfig,
    );
  }
}

class _Lcg {
  _Lcg(int seed) : _state = seed & 0x7FFFFFFF;
  int _state;
  int next() {
    _state = (_state * 1664525 + 1013904223) & 0x7FFFFFFF;
    return _state;
  }
}
