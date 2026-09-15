import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:match3/domain/models/level_generator.dart';
import 'package:match3/ui/core/theme/app_theme_skin.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
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

  Widget _backButton(AppThemeSkin theme) {
    return GestureDetector(
      onTap: () {
        HapticService.mediumImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
          border: Border.all(color: theme.cardBorder, width: 1.5),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: theme.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;

    final totalLevelsToShow = math.max(100, math.min(5000, currentLevel + 50));
    final theme = ref.watch(activeThemeSkinProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.3,
            colors: [
              theme.bgGradientStart,
              theme.bgGradientMiddle,
              theme.bgGradientEnd,
            ],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _backButton(theme),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'LEVELS',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: theme.textPrimary,
                                letterSpacing: 1.5,
                                shadows: const [
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
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 13,
                                color: theme.primaryAccent,
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
                      theme: theme,
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
    required AppThemeSkin theme,
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
        gradientColors = [theme.primaryAccent, theme.primaryAccent.withValues(alpha: 0.7)];
        borderColor = theme.primaryAccent;
      } else if (isBoss) {
        gradientColors = [const Color(0xFFFF7043), const Color(0xFFD84315)];
        borderColor = const Color(0xFFFFAB91);
      } else {
        gradientColors = [theme.cardBg, theme.surfaceDark];
        borderColor = theme.primaryAccent.withValues(alpha: 0.7);
      }

      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$levelNumber',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                shadows: const [
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
                color: active ? theme.primaryAccent : theme.textSecondary.withValues(alpha: 0.3),
              );
            }),
          ),
        ],
      );
    } else if (isCurrent) {
      gradientColors = [theme.primaryAccent.withValues(alpha: 0.88), theme.primaryAccent];
      borderColor = theme.primaryAccent;
      final textColor = theme.primaryAccent.computeLuminance() > 0.5 ? const Color(0xFF1A1A1A) : Colors.white;

      content = Stack(
        alignment: Alignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$levelNumber',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 26,
                color: textColor,
                fontWeight: FontWeight.w900,
                shadows: const [
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
      gradientColors = [theme.cardBg, theme.surfaceDark];
      borderColor = isBoss ? theme.primaryAccent.withValues(alpha: 0.5) : theme.cardBorder;
      content = Icon(
        isBoss ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
        size: 20,
        color: isBoss ? theme.primaryAccent : theme.textSecondary.withValues(alpha: 0.5),
      );
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              HapticService.lightImpact();
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
