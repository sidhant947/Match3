import 'package:flutter/foundation.dart';

enum LevelGoalType {
  score,
  targetFruit,
  createSpecials,
  comboMaster,
}

@immutable
class LevelGoal {
  final LevelGoalType type;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final String? targetFruitEmoji;

  const LevelGoal({
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.targetFruitEmoji,
  });

  bool get isCompleted => currentValue >= targetValue;
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 1.0;

  LevelGoal copyWith({
    LevelGoalType? type,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    String? targetFruitEmoji,
  }) {
    return LevelGoal(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      targetFruitEmoji: targetFruitEmoji ?? this.targetFruitEmoji,
    );
  }
}
