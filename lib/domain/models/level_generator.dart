import 'dart:math';
import 'package:match3/domain/models/level_goal.dart';

enum LevelDifficultyType {
  intro,
  standard,
  puzzle,
  hard,
  boss,
}

enum MilestoneRewardType {
  none,
  miniChest,
  chapterChest,
  grandTrophy,
  prestigeCrown,
}

class MilestoneReward {
  final MilestoneRewardType type;
  final String title;
  final String description;
  final String iconEmoji;

  const MilestoneReward({
    required this.type,
    required this.title,
    required this.description,
    this.iconEmoji = '🎁',
  });
}

class LevelConfig {
  final int levelNumber;
  final int effectiveLevel;
  final int prestigeRank;
  final LevelDifficultyType difficultyType;
  final LevelGoal goal;
  final int moves;
  final int targetScore;
  final int star1Score;
  final int star2Score;
  final int star3Score;
  final int fruitVarietyCount;
  final Set<String> jellyTiles;
  final Set<String> frozenTiles;
  final Set<String> crateTiles;
  final MilestoneReward reward;

  const LevelConfig({
    required this.levelNumber,
    required this.effectiveLevel,
    required this.prestigeRank,
    required this.difficultyType,
    required this.goal,
    required this.moves,
    required this.targetScore,
    required this.star1Score,
    required this.star2Score,
    required this.star3Score,
    required this.fruitVarietyCount,
    required this.jellyTiles,
    this.frozenTiles = const {},
    this.crateTiles = const {},
    required this.reward,
  });
}

class LevelGenerator {
  static const List<String> allFruits = ['🍎', '🍋', '🍇', '🍉', '🍍', '🍓', '🍊', '🍒'];
  static const int chapterSize = 25;
  static const int maxDefinedLevels = 5000;

  static LevelConfig generate(int levelNumber, {bool isZenMode = false, int rows = 8, int cols = 8}) {
    if (isZenMode) {
      return LevelConfig(
        levelNumber: levelNumber,
        effectiveLevel: levelNumber,
        prestigeRank: 0,
        difficultyType: LevelDifficultyType.intro,
        goal: const LevelGoal(
          type: LevelGoalType.score,
          title: 'ENDLESS ZEN',
          description: 'Match and relax without limits',
          targetValue: 999999,
        ),
        moves: 999,
        targetScore: 999999,
        star1Score: 1000,
        star2Score: 3000,
        star3Score: 6000,
        fruitVarietyCount: 5,
        jellyTiles: const {},
        frozenTiles: const {},
        crateTiles: const {},
        reward: const MilestoneReward(
          type: MilestoneRewardType.none,
          title: 'Zen Mastery',
          description: 'Relaxation journey',
        ),
      );
    }

    final int prestigeRank = levelNumber > maxDefinedLevels
        ? ((levelNumber - 1) ~/ maxDefinedLevels)
        : 0;

    final int effectiveLevel = levelNumber > maxDefinedLevels
        ? 1000 + ((levelNumber - 5001) % 4000)
        : levelNumber;

    final int cycleIndex = (effectiveLevel - 1) % chapterSize;
    final int chapterNumber = ((effectiveLevel - 1) ~/ chapterSize) + 1;

    final LevelDifficultyType diffType = _determineDifficultyType(cycleIndex);
    final double tierFactor = 1.0 + 0.18 * log(1.0 + (effectiveLevel / 12.0));
    final double waveFactor = 0.8 + 0.45 * pow(cycleIndex / (chapterSize - 1.0), 1.35);
    final double compositeDifficulty = (tierFactor * waveFactor).clamp(0.8, 3.5);

    int fruitCount = 5;
    if (effectiveLevel <= 10) {
      fruitCount = 4;
    } else if (effectiveLevel <= 60) {
      fruitCount = 5;
    } else {
      fruitCount = (diffType == LevelDifficultyType.boss || diffType == LevelDifficultyType.hard) ? 6 : 5;
    }

    final availableFruits = allFruits.sublist(0, fruitCount.clamp(4, allFruits.length));
    final targetFruit = availableFruits[(effectiveLevel - 1) % availableFruits.length];

    int baseMoves = 26;
    if (diffType == LevelDifficultyType.intro) {
      baseMoves = 30;
    } else if (diffType == LevelDifficultyType.standard) {
      baseMoves = 25;
    } else if (diffType == LevelDifficultyType.puzzle) {
      baseMoves = 23;
    } else if (diffType == LevelDifficultyType.hard) {
      baseMoves = 20;
    } else if (diffType == LevelDifficultyType.boss) {
      baseMoves = 22;
    }

    final int moves = baseMoves.clamp(18, 35);
    final LevelGoal goal = _generateGoal(
      effectiveLevel: effectiveLevel,
      cycleIndex: cycleIndex,
      diffType: diffType,
      targetFruit: targetFruit,
      compositeDifficulty: compositeDifficulty,
      chapterNumber: chapterNumber,
      moves: moves,
    );

    final Set<String> jelly = _generateJellyLayout(goal, rows, cols, cycleIndex);
    final Set<String> frozen = _generateObstacleLayout(effectiveLevel, diffType, rows, cols, isFrozen: true);
    final Set<String> crates = _generateObstacleLayout(effectiveLevel, diffType, rows, cols, isFrozen: false);

    final int baseScorePerMove = (180 + (tierFactor * 70)).round();
    final int targetScore = goal.type == LevelGoalType.score
        ? goal.targetValue
        : (moves * baseScorePerMove * (0.9 + waveFactor * 0.3)).round();

    final int star1 = (targetScore * 0.65).round();
    final int star2 = targetScore;
    final int star3 = (targetScore * 1.45).round();

    final MilestoneReward reward = _generateReward(levelNumber, effectiveLevel, prestigeRank, diffType);

    return LevelConfig(
      levelNumber: levelNumber,
      effectiveLevel: effectiveLevel,
      prestigeRank: prestigeRank,
      difficultyType: diffType,
      goal: goal,
      moves: moves,
      targetScore: targetScore,
      star1Score: star1,
      star2Score: star2,
      star3Score: star3,
      fruitVarietyCount: fruitCount,
      jellyTiles: jelly,
      frozenTiles: frozen,
      crateTiles: crates,
      reward: reward,
    );
  }

  static Set<String> _generateObstacleLayout(int effectiveLevel, LevelDifficultyType diffType, int rows, int cols, {required bool isFrozen}) {
    if (isFrozen) {
      if (effectiveLevel < 8 || diffType == LevelDifficultyType.intro) return const {};
      final count = min(2 + (effectiveLevel ~/ 20), 8);
      final frozen = <String>{};
      final offset = (effectiveLevel % 4);
      for (int i = 0; i < count; i++) {
        final r = (1 + ((i * 2 + offset) % (rows - 2)));
        final c = (1 + ((i * 3 + offset) % (cols - 2)));
        frozen.add('${r}_$c');
      }
      return frozen;
    } else {
      if (effectiveLevel < 15 || diffType == LevelDifficultyType.intro) return const {};
      final count = min(2 + (effectiveLevel ~/ 30), 6);
      final crates = <String>{};
      final offset = ((effectiveLevel * 3) % 5);
      for (int i = 0; i < count; i++) {
        final r = (2 + ((i + offset) % (rows - 4)));
        final c = (2 + ((i * 2 + offset) % (cols - 4)));
        crates.add('${r}_$c');
      }
      return crates;
    }
  }

  static LevelDifficultyType _determineDifficultyType(int cycleIndex) {
    if (cycleIndex == chapterSize - 1) return LevelDifficultyType.boss;
    if (cycleIndex <= 2) return LevelDifficultyType.intro;
    if (cycleIndex <= 10) return LevelDifficultyType.standard;
    if (cycleIndex <= 17) return LevelDifficultyType.puzzle;
    return LevelDifficultyType.hard;
  }

  static LevelGoal _generateGoal({
    required int effectiveLevel,
    required int cycleIndex,
    required LevelDifficultyType diffType,
    required String targetFruit,
    required double compositeDifficulty,
    required int chapterNumber,
    required int moves,
  }) {
    final goalArchetype = (cycleIndex + (chapterNumber % 3)) % 5;

    switch (goalArchetype) {
      case 0:
        final int targetAmount = min(14 + (compositeDifficulty * 11).round(), (moves * 1.6).round());
        return LevelGoal(
          type: LevelGoalType.targetFruit,
          title: diffType == LevelDifficultyType.boss ? 'ROYAL HARVEST' : 'ORCHARD QUEST',
          description: 'Collect $targetAmount $targetFruit',
          targetValue: targetAmount,
          targetFruitEmoji: targetFruit,
        );

      case 1:
        final int specialsTarget = min(2 + (compositeDifficulty * 2.2).round(), 10);
        return LevelGoal(
          type: LevelGoalType.createSpecials,
          title: diffType == LevelDifficultyType.boss ? 'MASTER CATALYST' : 'SPARK CRAFT',
          description: 'Create $specialsTarget special fruits',
          targetValue: specialsTarget,
        );

      case 2:
        final int cascadesTarget = min(3 + (compositeDifficulty * 1.8).round(), 9);
        return LevelGoal(
          type: LevelGoalType.comboMaster,
          title: diffType == LevelDifficultyType.boss ? 'CASCADE STORM' : 'CHAIN REACTION',
          description: 'Trigger $cascadesTarget combo cascades',
          targetValue: cascadesTarget,
        );

      case 3:
        final int jellyAmount = min(10 + (compositeDifficulty * 8).round(), 32);
        return LevelGoal(
          type: LevelGoalType.clearJelly,
          title: diffType == LevelDifficultyType.boss ? 'GLACIAL CLASH' : 'FROST BREAKER',
          description: 'Clear all $jellyAmount frosting tiles',
          targetValue: jellyAmount,
        );

      case 4:
      default:
        final int scoreTarget = (moves * 240 * compositeDifficulty).round();
        return LevelGoal(
          type: LevelGoalType.score,
          title: diffType == LevelDifficultyType.boss ? 'APEX SCORE' : 'STAR VOYAGE',
          description: 'Score $scoreTarget points',
          targetValue: scoreTarget,
        );
    }
  }

  static Set<String> _generateJellyLayout(LevelGoal goal, int rows, int cols, int cycleIndex) {
    if (goal.type != LevelGoalType.clearJelly) return const {};
    final jelly = <String>{};
    final count = goal.targetValue;
    final centerR = (rows - 1) / 2.0;
    final centerC = (cols - 1) / 2.0;

    final coords = <Point<int>>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        coords.add(Point(r, c));
      }
    }

    final patternVariant = cycleIndex % 3;

    coords.sort((a, b) {
      if (patternVariant == 0) {
        final distA = pow(a.x - centerR, 2) + pow(a.y - centerC, 2);
        final distB = pow(b.x - centerR, 2) + pow(b.y - centerC, 2);
        return distA.compareTo(distB);
      } else if (patternVariant == 1) {
        final crossA = min((a.x - centerR).abs(), (a.y - centerC).abs());
        final crossB = min((b.x - centerR).abs(), (b.y - centerC).abs());
        return crossA.compareTo(crossB);
      } else {
        final diamondA = (a.x - centerR).abs() + (a.y - centerC).abs();
        final diamondB = (b.x - centerR).abs() + (b.y - centerC).abs();
        return diamondA.compareTo(diamondB);
      }
    });

    for (int i = 0; i < min(count, coords.length); i++) {
      jelly.add('${coords[i].x}_${coords[i].y}');
    }
    return jelly;
  }

  static MilestoneReward _generateReward(int levelNumber, int effectiveLevel, int prestigeRank, LevelDifficultyType diffType) {
    if (prestigeRank > 0 && levelNumber % maxDefinedLevels == 0) {
      return MilestoneReward(
        type: MilestoneRewardType.prestigeCrown,
        title: 'Prestige Crown $prestigeRank',
        description: 'Immortal Conqueror of $levelNumber Levels!',
        iconEmoji: '👑',
      );
    }

    if (levelNumber % 100 == 0) {
      return MilestoneReward(
        type: MilestoneRewardType.grandTrophy,
        title: 'Centurion Trophy',
        description: 'Completed Century Milestone $levelNumber!',
        iconEmoji: '🏆',
      );
    }

    if (diffType == LevelDifficultyType.boss) {
      return const MilestoneReward(
        type: MilestoneRewardType.chapterChest,
        title: 'Chapter Victory Chest',
        description: 'Conquered Chapter Milestone!',
        iconEmoji: '💎',
      );
    }

    if (levelNumber % 5 == 0) {
      return const MilestoneReward(
        type: MilestoneRewardType.miniChest,
        title: 'Milestone Badge',
        description: 'Pacing milestone reached',
        iconEmoji: '🎖️',
      );
    }

    return const MilestoneReward(
      type: MilestoneRewardType.none,
      title: 'Standard Win',
      description: 'Stars and score bonus',
    );
  }
}
