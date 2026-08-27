import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:match3/domain/models/level_generator.dart';
import 'package:match3/ui/features/game/views/game_view.dart';
import 'package:match3/ui/providers.dart';

class LevelSelectView extends ConsumerStatefulWidget {
  const LevelSelectView({super.key});

  @override
  ConsumerState<LevelSelectView> createState() => _LevelSelectViewState();
}

class _LevelSelectViewState extends ConsumerState<LevelSelectView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Future.microtask(() {
      ref.read(homeViewModelProvider.notifier).loadProgress();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact().catchError((_) {});
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
          border: Border.all(color: const Color(0xFF383838), width: 1.5),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;

    final int totalLevelsToShow = math.max(100, math.min(5000, currentLevel + 50));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.3,
            colors: [
              Color(0xFF222222),
              Color(0xFF161616),
              Color(0xFF0F0F0F),
            ],
            stops: [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _backButton(),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'LEVELS',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4.0,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'CHAPTER ${((currentLevel - 1) ~/ LevelGenerator.chapterSize) + 1} • LEVEL $currentLevel',
                              style: const TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 13,
                                color: Color(0xFFFFCE31),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: totalLevelsToShow,
                  itemBuilder: (context, index) {
                    final levelNumber = index + 1;
                    final isCompleted = levelNumber <= highestCompleted;
                    final isCurrent = levelNumber == currentLevel;
                    final isLocked = levelNumber > currentLevel;

                    return _buildLevelCard(
                      context,
                      levelNumber: levelNumber,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      isLocked: isLocked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    final isBoss = levelNumber % LevelGenerator.chapterSize == 0;
    final isMilestone = levelNumber % 100 == 0;

    List<Color> gradientColors;
    Color borderColor;
    Widget content;
    bool isClickable = !isLocked;

    if (isCompleted) {
      final stars = ref.read(homeViewModelProvider).progress?.levelStars[levelNumber.toString()] ?? 0;
      if (isMilestone) {
        gradientColors = [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
        borderColor = const Color(0xFFFFF8B0);
      } else if (isBoss) {
        gradientColors = [const Color(0xFFFF7043), const Color(0xFFD84315)];
        borderColor = const Color(0xFFFFAB91);
      } else {
        gradientColors = [const Color(0xFFFFB073), const Color(0xFFFF8523)];
        borderColor = const Color(0xFFFFCAB3);
      }

      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$levelNumber',
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1.5),
                    blurRadius: 2.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (starIdx) {
              final active = starIdx < stars;
              return Icon(
                active ? Icons.star_rounded : Icons.star_border_rounded,
                size: 13,
                color: active ? Colors.white : Colors.white30,
              );
            }),
          ),
        ],
      );
    } else if (isCurrent) {
      if (isMilestone) {
        gradientColors = [const Color(0xFFFFE082), const Color(0xFFFFB300)];
        borderColor = const Color(0xFFFFF9C4);
      } else if (isBoss) {
        gradientColors = [const Color(0xFFFF8A65), const Color(0xFFE64A19)];
        borderColor = const Color(0xFFFFCCBC);
      } else {
        gradientColors = [const Color(0xFFFFDF6D), const Color(0xFFFFCE31)];
        borderColor = const Color(0xFFFFF2A3);
      }

      content = Stack(
        alignment: Alignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$levelNumber',
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 2.0,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          if (isBoss)
            const Positioned(
              top: 2,
              right: 2,
              child: Text('👑', style: TextStyle(fontSize: 10)),
            ),
        ],
      );
    } else {
      gradientColors = [const Color(0xFF242424), const Color(0xFF1A1A1A)];
      borderColor = isBoss ? const Color(0xFF4A3525) : const Color(0xFF333333);
      content = Icon(
        isBoss ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
        size: 20,
        color: isBoss ? const Color(0xFFAA7733) : const Color(0xFF777777),
      );
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              HapticFeedback.lightImpact().catchError((_) {});
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameView(levelNumber: levelNumber),
                ),
              );
              ref.read(homeViewModelProvider.notifier).loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isBoss ? 2.5 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
