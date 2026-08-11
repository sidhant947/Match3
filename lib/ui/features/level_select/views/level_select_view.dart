import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:match3/ui/features/game/views/game_view.dart';
import 'package:match3/ui/providers.dart';

class LevelSelectView extends ConsumerStatefulWidget {
  const LevelSelectView({super.key});

  @override
  ConsumerState<LevelSelectView> createState() => _LevelSelectViewState();
}

class _LevelSelectViewState extends ConsumerState<LevelSelectView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
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
          gradient: const LinearGradient(
            colors: [Color(0xFF5C68D4), Color(0xFF3E49B4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
          border: Border.all(color: const Color(0xFF8692FF), width: 2.0),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Color(0xFFFFF9E6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;

    final int totalLevelsToShow = math.max(100, (currentLevel + 50).clamp(100, 1000));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.3,
            colors: [
              Color(0xFF63B3FF),
              Color(0xFF1E90FF),
              Color(0xFF1058B3),
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
                    const Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'LEVELS',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFF9E6),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
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
    List<Color> gradientColors;
    Color borderColor;
    Widget content;
    bool isClickable = !isLocked;

    if (isCompleted) {
      final stars = ref.read(homeViewModelProvider).progress?.levelStars[levelNumber.toString()] ?? 0;
      gradientColors = [const Color(0xFFFFB073), const Color(0xFFFF8523)];
      borderColor = const Color(0xFFFFCAB3);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$levelNumber',
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 24,
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
                size: 14,
                color: active ? Colors.white : Colors.white30,
              );
            }),
          ),
        ],
      );
    } else if (isCurrent) {
      gradientColors = [const Color(0xFFFFDF6D), const Color(0xFFFFCE31)];
      borderColor = const Color(0xFFFFF2A3);
      content = FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$levelNumber',
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 28,
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
      );
    } else {
      gradientColors = [const Color(0xFF3E49B4).withValues(alpha: 0.6), const Color(0xFF3E49B4).withValues(alpha: 0.6)];
      borderColor = const Color(0xFF5C68D4);
      content = const Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: Color(0xFFFFD1D1),
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
            width: 2.0,
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
