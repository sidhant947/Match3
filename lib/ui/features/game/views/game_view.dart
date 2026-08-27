import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:match3/domain/models/level_generator.dart';
import 'package:match3/domain/models/level_goal.dart';
import 'package:match3/ui/core/widgets/tangible_button.dart';
import 'package:match3/ui/features/game/view_models/game_view_model.dart';
import 'package:match3/ui/features/game/widgets/match3_game.dart';
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
  late GameViewModel _viewModel;
  late Match3Game _game;
  Offset? _pointerStartPos;
  bool _hasSwiped = false;

  @override
  void initState() {
    super.initState();
    final progressRepo = ref.read(progressRepositoryProvider);
    _viewModel = GameViewModel(progressRepository: progressRepo);
    _viewModel.initGame(level: widget.levelNumber, isZenMode: widget.isZenMode);
    _game = Match3Game(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final state = _viewModel.state;
              final isWin = state.goal.isCompleted;

              return Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Row(
                          children: [
                            _circleButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  widget.isZenMode ? 'ZEN MODE' : 'LEVEL ${state.levelNumber}',
                                  style: const TextStyle(
                                    fontFamily: 'BebasNeue',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1.5),
                                        blurRadius: 3.0,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _circleButton(
                              icon: Icons.refresh_rounded,
                              onTap: () => _viewModel.initGame(level: state.levelNumber, isZenMode: widget.isZenMode),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isZenMode) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222222),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF383838), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                if (state.goal.targetFruitEmoji != null) ...[
                                  Text(
                                    state.goal.targetFruitEmoji!,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 8),
                                ] else if (state.goal.type == LevelGoalType.createSpecials) ...[
                                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFCE31), size: 20),
                                  const SizedBox(width: 8),
                                ] else if (state.goal.type == LevelGoalType.comboMaster) ...[
                                  const Icon(Icons.flash_on_rounded, color: Color(0xFFFF8523), size: 20),
                                  const SizedBox(width: 8),
                                ] else if (state.goal.type == LevelGoalType.clearJelly) ...[
                                  const Icon(Icons.ac_unit_rounded, color: Color(0xFF64D2FF), size: 20),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        state.goal.title,
                                        style: const TextStyle(
                                          fontFamily: 'BebasNeue',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFFCE31),
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: state.goal.progress,
                                          minHeight: 6,
                                          backgroundColor: const Color(0xFF161616),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            state.goal.isCompleted ? const Color(0xFF4ECCA3) : const Color(0xFFFFCE31),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${state.goal.currentValue}/${state.goal.targetValue}',
                                  style: TextStyle(
                                    fontFamily: 'BebasNeue',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: state.goal.isCompleted ? const Color(0xFF4ECCA3) : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildStatBadge(
                                  title: 'SCORE',
                                  value: '${state.score}',
                                  subValue: '',
                                  color: const Color(0xFFFFCE31),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatBadge(
                                  title: 'MOVES',
                                  value: '${state.movesLeft}',
                                  subValue: '',
                                  color: state.movesLeft <= 5 ? const Color(0xFFFF4D4D) : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: _ComboBannerWidget(comboCount: state.comboCount),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Listener(
                                  onPointerDown: (event) {
                                    _pointerStartPos = event.localPosition;
                                    _hasSwiped = false;
                                  },
                                  onPointerMove: (event) {
                                    if (_pointerStartPos == null || _hasSwiped) return;
                                    final delta = event.localPosition - _pointerStartPos!;
                                    if (delta.distance > 20) {
                                      _hasSwiped = true;
                                      _game.handleSwipeAt(_pointerStartPos!, event.localPosition);
                                    }
                                  },
                                  onPointerUp: (event) {
                                    if (!_hasSwiped && _pointerStartPos != null) {
                                      _game.handleTapAt(_pointerStartPos!);
                                    }
                                    _pointerStartPos = null;
                                  },
                                  child: GameWidget(game: _game),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (state.isShuffling)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222222),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFCE31), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFCE31).withValues(alpha: 0.3),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shuffle_rounded, color: Color(0xFFFFCE31), size: 24),
                              SizedBox(width: 10),
                              Text(
                                'NO MOVES! SHUFFLING...',
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFCE31),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (state.isGameOver && !widget.isZenMode)
                    _buildOverlay(
                      title: isWin ? 'LEVEL COMPLETE!' : 'OUT OF MOVES!',
                      message: isWin
                          ? 'Target reached with great combos!'
                          : 'Give it another shot to clear this level.',
                      score: state.score,
                      starsEarned: state.starsEarned,
                      isWin: isWin,
                      currentLevel: state.levelNumber,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 18,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
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
        child: Icon(
          icon,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }



  Widget _buildStatBadge({
    required String title,
    required String value,
    required String subValue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF383838), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB0B0B0),
              letterSpacing: 1.0,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              if (subValue.isNotEmpty)
                Text(
                  subValue,
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888888),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay({
    required String title,
    required String message,
    required int score,
    required int starsEarned,
    required bool isWin,
    required int currentLevel,
  }) {
    final config = _viewModel.state.levelConfig;
    final reward = config?.reward;
    final hasSpecialReward = isWin && reward != null && reward.type != MilestoneRewardType.none;

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF252525), Color(0xFF191919)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isWin ? const Color(0xFFFFCE31) : const Color(0xFFFF4D4D),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWin) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final earned = index < starsEarned;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.star_rounded,
                          size: 44,
                          color: earned ? const Color(0xFFFFCE31) : Colors.white24,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4D4D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sentiment_dissatisfied_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                if (hasSpecialReward) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF332A15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFCE31), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(reward.iconEmoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward.title,
                              style: const TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 16,
                                color: Color(0xFFFFCE31),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              reward.description,
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF444444)),
                  ),
                  child: Text(
                    'FINAL SCORE: $score',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFCE31),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (isWin)
                  TangibleButton(
                    text: 'NEXT LEVEL',
                    height: 44,
                    onPressed: () {
                      _viewModel.initGame(level: currentLevel + 1);
                    },
                  )
                else
                  TangibleButton(
                    text: 'TRY AGAIN',
                    height: 44,
                    onPressed: () {
                      _viewModel.initGame(level: currentLevel);
                    },
                  ),
                const SizedBox(height: 10),
                TangibleButton(
                  text: 'HOME',
                  isSecondary: true,
                  height: 44,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 10),
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
        ),
      ),
    );
  }
}

class _ComboBannerWidget extends StatefulWidget {
  final int comboCount;

  const _ComboBannerWidget({required this.comboCount});

  @override
  State<_ComboBannerWidget> createState() => _ComboBannerWidgetState();
}

class _ComboBannerWidgetState extends State<_ComboBannerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  String _text = '';

  static const _phrases = ['SWEET!', 'TASTY!', 'DELICIOUS!', 'DIVINE!', 'UNBELIEVABLE!'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.1).chain(CurveTween(curve: Curves.easeOutBack)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    if (widget.comboCount > 1) {
      _trigger(widget.comboCount);
    }
  }

  @override
  void didUpdateWidget(covariant _ComboBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comboCount > oldWidget.comboCount && widget.comboCount > 1) {
      _trigger(widget.comboCount);
    }
  }

  void _trigger(int combo) {
    _text = _phrases[min(combo - 2, _phrases.length - 1)];
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed || _opacityAnimation.value <= 0.0) {
          return const SizedBox.shrink();
        }
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Text(
              _text,
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFCE31),
                letterSpacing: 3.0,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black87,
                    offset: Offset(0, 3),
                  ),
                  Shadow(
                    blurRadius: 20,
                    color: Color(0x66FFCE31),
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

