import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:match3/domain/models/gem.dart';
import 'package:match3/domain/models/level_config.dart';
import 'package:match3/ui/core/widgets/custom_gem_painter.dart';
import 'package:match3/ui/core/widgets/tangible_button.dart';
import 'package:match3/ui/features/game/view_models/game_view_model.dart';
import 'package:match3/ui/providers.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isZenMode = false,
  });

  final int levelNumber;
  final bool isZenMode;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber, isZenMode: widget.isZenMode);
    });
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.mediumImpact().catchError((_) {});
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
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
          child: Icon(
            icon,
            size: iconSize,
            color: const Color(0xFFFFF9E6),
            shadows: const [
              Shadow(
                offset: Offset(0, 1.5),
                blurRadius: 2.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLevelComplete(GameViewModelState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E90FF), Color(0xFF1058B3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF63B3FF), width: 4.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (starIdx) {
                    final active = starIdx < state.earnedStars;
                    return Icon(
                      active ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 44,
                      color: active ? const Color(0xFFFFCE31) : Colors.white30,
                    );
                  }),
                ),
                const SizedBox(height: 16),
                 const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'LEVEL COMPLETE!',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFF9E6),
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Score: ${state.score}',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 16,
                      color: Color(0xFFFFD1D1),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TangibleButton(
                  text: 'NEXT LEVEL',
                  height: 44,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ref
                        .read(gameViewModelProvider.notifier)
                        .loadLevel(state.levelNumber + 1);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'HOME',
                  isSecondary: true,
                  height: 44,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'BUY ME A COFFEE',
                  isSecondary: true,
                  height: 44,
                  onPressed: () {
                    final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
                    launchUrl(url, mode: LaunchMode.externalApplication).catchError((_) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onLevelFailed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E90FF), Color(0xFF1058B3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF5E7E), width: 4.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5E7E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                 const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'OUT OF MOVES!',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFF9E6),
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TangibleButton(
                  text: 'TRY AGAIN',
                  height: 44,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ref
                        .read(gameViewModelProvider.notifier)
                        .loadLevel(ref.read(gameViewModelProvider).levelNumber);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'HOME',
                  isSecondary: true,
                  height: 44,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildObjectiveBar(GameViewModelState state) {
    if (state.isZenMode) return const SizedBox.shrink();
    final level = state.levelConfig;
    if (level == null) return const SizedBox.shrink();

    Widget objectiveWidget;
    final objectiveType = level.objective.objective == LevelObjective.clearBoard
        ? LevelObjective.score
        : level.objective.objective;

    switch (objectiveType) {
      case LevelObjective.score:
        final targetScore = level.objective.objective == LevelObjective.clearBoard ? 1200 : level.objective.targetScore;
        final progress = (state.score / targetScore).clamp(0.0, 1.0);
        objectiveWidget = Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFF8523), size: 24),
            const SizedBox(width: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${state.score} / $targetScore',
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFF9E6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black26,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8523)),
                  minHeight: 10,
                ),
              ),
            ),
          ],
        );
        break;
      case LevelObjective.collectGems:
        final entries = level.objective.gemTypeCounts.entries.toList();
        objectiveWidget = Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.map((entry) {
            final gemIdx = int.parse(entry.key);
            final collected = (state.collectedGems[entry.key] ?? 0).clamp(0, entry.value);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: GemWidget(
                    gemType: GemType.values[gemIdx],
                    isBlocker: false,
                  ),
                ),
                const SizedBox(width: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$collected/${entry.value}',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFF9E6),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        );
        break;
      default:
        objectiveWidget = const SizedBox.shrink();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E90FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF63B3FF), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: objectiveWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _onLevelComplete(next);
        });
      }
      if (next.isFailed && !(prev?.isFailed ?? false)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _onLevelFailed();
        });
      }
    });

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      iconSize: 18,
                      onTap: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            state.isZenMode ? 'ZEN MODE' : 'LEVEL ${state.levelNumber}',
                            style: const TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFF9E6),
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 2.0,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!state.isZenMode)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              state.levelConfig?.name.toUpperCase() ?? '',
                              style: const TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 14,
                                color: Color(0xFFFFD1D1),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              if (!state.isZenMode) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem(Icons.star_rounded, '${state.score}', const Color(0xFFFFCE31)),
                      _statItem(
                        Icons.touch_app_rounded,
                        '${state.movesLeft}',
                        const Color(0xFFFFF9E6),
                        pulse: state.movesLeft < 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              _buildObjectiveBar(state),
              const SizedBox(height: 12),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMatch3Board(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String text, Color color, {bool pulse = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E90FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pulse ? const Color(0xFFFFCE31) : const Color(0xFF63B3FF),
          width: pulse ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: pulse ? const Color(0xFFFFCE31).withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.25),
            blurRadius: pulse ? 10 : 4,
            spreadRadius: pulse ? 2 : 0,
            offset: pulse ? Offset.zero : const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: pulse ? const Color(0xFFFFCE31) : color, size: 20),
          const SizedBox(width: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: pulse ? const Color(0xFFFFCE31) : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatch3Board(GameViewModelState state) {
    final level = state.levelConfig;
    if (level == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth - 32;
        final maxH = constraints.maxHeight - 16;

        final cellW = maxW / level.cols;
        final cellH = maxH / level.rows;
        final cellSize = cellW < cellH ? cellW : cellH;
        final gemSize = cellSize * 0.85;

        final boardW = cellSize * level.cols;
        final boardH = cellSize * level.rows;

        return Center(
          child: SizedBox(
            width: boardW,
            height: boardH,
            child: Stack(
              children: [
                for (int r = 0; r < level.rows; r++)
                  for (int c = 0; c < level.cols; c++)
                    Positioned(
                      left: c * cellSize,
                      top: r * cellSize,
                      width: cellSize,
                      height: cellSize,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: (r + c).isEven
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  for (final gem in state.board)
                    AnimatedPositioned(
                      key: ValueKey(gem.id),
                      left: gem.position.col * cellSize,
                      top: gem.position.row * cellSize,
                      width: cellSize,
                      height: cellSize,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: GestureDetector(
                        onTap: () {
                          ref.read(gameViewModelProvider.notifier).selectGem(gem);
                        },
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity == null) return;
                          final direction = details.primaryVelocity! > 0 ? 'right' : 'left';
                          _handleSwipe(gem, direction, level);
                        },
                        onVerticalDragEnd: (details) {
                          if (details.primaryVelocity == null) return;
                          final direction = details.primaryVelocity! > 0 ? 'down' : 'up';
                          _handleSwipe(gem, direction, level);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: _buildGemWidget(gem, state, level, gemSize),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

  void _handleSwipe(BoardGem gem, String direction, LevelConfig level) {
    final currentState = ref.read(gameViewModelProvider);
    if (currentState.isComplete || currentState.isFailed) return;

    BoardPosition? targetPos;
    switch (direction) {
      case 'left':
        if (gem.position.col > 0) {
          targetPos = BoardPosition(row: gem.position.row, col: gem.position.col - 1);
        }
        break;
      case 'right':
        if (gem.position.col < level.cols - 1) {
          targetPos = BoardPosition(row: gem.position.row, col: gem.position.col + 1);
        }
        break;
      case 'up':
        if (gem.position.row > 0) {
          targetPos = BoardPosition(row: gem.position.row - 1, col: gem.position.col);
        }
        break;
      case 'down':
        if (gem.position.row < level.rows - 1) {
          targetPos = BoardPosition(row: gem.position.row + 1, col: gem.position.col);
        }
        break;
    }

    if (targetPos == null) return;

    final target = targetPos;
    final targetGem = currentState.board.firstWhere(
      (g) => g.position.row == target.row && g.position.col == target.col,
      orElse: () => gem,
    );

    ref.read(gameViewModelProvider.notifier).selectGem(gem);
    Future.delayed(const Duration(milliseconds: 50), () {
      ref.read(gameViewModelProvider.notifier).selectGem(targetGem);
    });
  }

  Widget _buildGemWidget(BoardGem gem, GameViewModelState state, LevelConfig level, double size) {
    final isSelected = state.selectedGem?.id == gem.id;
    final isMatched = state.matchedPositions.any(
      (p) => p.row == gem.position.row && p.col == gem.position.col,
    );
    final isBlocker = level.hasBlockers && level.blockerPositions.any(
      (p) => p.row == gem.position.row && p.col == gem.position.col,
    );
    final isIce = level.hasIce && level.icePositions.any(
      (p) => p.row == gem.position.row && p.col == gem.position.col,
    );

    return AnimatedScale(
      scale: isMatched ? 0.0 : (isSelected ? 1.05 : 1.0),
      duration: Duration(milliseconds: isMatched ? 300 : 150),
      curve: isMatched ? Curves.easeInBack : Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isMatched ? 0.0 : 1.0,
        duration: Duration(milliseconds: isMatched ? 300 : 150),
        child: GemWidget(
          gemType: gem.gem.type,
          special: gem.gem.special,
          isSelected: isSelected,
          isMatched: isMatched,
          isBlocker: isBlocker,
          isIce: isIce,
        ),
      ),
    );
  }
}
