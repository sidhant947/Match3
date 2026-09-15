import 'package:flutter/foundation.dart';

@immutable
class UserProgress {
  const UserProgress({
    this.currentLevel = 1,
    this.highestLevelCompleted = 0,
    this.levelStars = const {},
    this.hintsEnabled = true,
    this.hapticsEnabled = true,
    this.audioEnabled = true,
    this.emojiPreset = 'fruits',
    this.customEmojis = const ['🍎', '🫐', '🍐', '🍋', '🍇', '🍊', '🍒', '🍉', '🍍', '🍓'],
    this.themeId = 'dark_charcoal',
  });

  final int currentLevel;
  final int highestLevelCompleted;
  final Map<String, int> levelStars;
  final bool hintsEnabled;
  final bool hapticsEnabled;
  final bool audioEnabled;
  final String emojiPreset;
  final List<String> customEmojis;
  final String themeId;

  static const Map<String, List<String>> presetMap = {
    'fruits': ['🍎', '🫐', '🍐', '🍋', '🍇', '🍊', '🍒', '🍉', '🍍', '🍓'],
    'animals': ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯'],
    'faces': ['😀', '😎', '🥳', '🤩', '🤡', '👽', '🤖', '👻', '🎃', '💩'],
    'symbols': ['❤️', '⭐', '🔥', '💎', '🍀', '⚡', '🎵', '☀️', '🌙', '🎯'],
  };

  List<String> get activeEmojiSet {
    if (emojiPreset == 'custom' && customEmojis.isNotEmpty) {
      return customEmojis;
    }
    return presetMap[emojiPreset] ?? presetMap['fruits']!;
  }

  UserProgress copyWith({
    int? currentLevel,
    int? highestLevelCompleted,
    Map<String, int>? levelStars,
    bool? hintsEnabled,
    bool? hapticsEnabled,
    bool? audioEnabled,
    String? emojiPreset,
    List<String>? customEmojis,
    String? themeId,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevelCompleted: highestLevelCompleted ?? this.highestLevelCompleted,
      levelStars: levelStars ?? this.levelStars,
      hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      emojiPreset: emojiPreset ?? this.emojiPreset,
      customEmojis: customEmojis ?? this.customEmojis,
      themeId: themeId ?? this.themeId,
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
