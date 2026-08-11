import 'package:flutter/foundation.dart';

@immutable
class UserProgress {
  const UserProgress({
    this.currentLevel = 1,
    this.highestLevelCompleted = 0,
    this.levelStars = const {},
  });

  final int currentLevel;
  final int highestLevelCompleted;
  final Map<String, int> levelStars;

  UserProgress copyWith({
    int? currentLevel,
    int? highestLevelCompleted,
    Map<String, int>? levelStars,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevelCompleted: highestLevelCompleted ?? this.highestLevelCompleted,
      levelStars: levelStars ?? this.levelStars,
    );
  }

  UserProgress incrementLevel() {
    return copyWith(
      currentLevel: currentLevel + 1,
      highestLevelCompleted: highestLevelCompleted + 1,
    );
  }

  UserProgress completeLevel(int level, int stars) {
    final updatedStars = Map<String, int>.from(levelStars);
    final currentStars = updatedStars[level.toString()] ?? 0;
    if (stars > currentStars) {
      updatedStars[level.toString()] = stars;
    }
    return copyWith(
      currentLevel: level >= currentLevel ? level + 1 : currentLevel,
      highestLevelCompleted: level > highestLevelCompleted ? level : highestLevelCompleted,
      levelStars: updatedStars,
    );
  }
}

