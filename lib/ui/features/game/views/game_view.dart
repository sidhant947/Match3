import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:match3/domain/models/level_generator.dart';
import 'package:match3/domain/models/level_goal.dart';
import 'package:match3/ui/core/theme/app_theme_skin.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/core/widgets/tangible_button.dart';
import 'package:match3/ui/features/game/view_models/game_view_model.dart';
import 'package:match3/ui/features/game/widgets/match3_game.dart';
import 'package:match3/ui/providers.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isZenMode = false,
    this.isTimeAttack = false,
    this.isTwistMode = false,
  });

  final int levelNumber;
  final bool isZenMode;
  final bool isTimeAttack;
  final bool isTwistMode;

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
    _viewModel.initGame(
      level: widget.levelNumber,
      isZenMode: widget.isZenMode,
      isTimeAttack: widget.isTimeAttack,
      isTwistMode: widget.isTwistMode,
    );
    _game = Match3Game(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(activeThemeSkinProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmLeave();
        }
      },
      child: Scaffold(
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
                                onTap: _confirmLeave,
                                theme: theme,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.isZenMode
                                        ? 'ZEN MODE'
                                        : (widget.isTwistMode
                                            ? 'TWIST MODE'
                                            : (widget.isTimeAttack ? 'TIME ATTACK' : 'LEVEL ${state.levelNumber}')),
                                    style: TextStyle(
                                      fontFamily: 'BebasNeue',
                                      color: theme.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      letterSpacing: 2.0,
                                      shadows: const [
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
                                onTap: () => _viewModel.initGame(
                                  level: state.levelNumber,
                                  isZenMode: widget.isZenMode,
                                  isTimeAttack: widget.isTimeAttack,
                                  isTwistMode: widget.isTwistMode,
                                ),
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                        if (!widget.isZenMode && !widget.isTimeAttack && !widget.isTwistMode) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.cardBorder, width: 1.5),
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
                                    Icon(Icons.auto_awesome_rounded, color: theme.primaryAccent, size: 20),
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
                                          style: TextStyle(
                                            fontFamily: 'BebasNeue',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: theme.primaryAccent,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: state.goal.progress,
                                            minHeight: 6,
                                            backgroundColor: theme.surfaceDark,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              state.goal.isCompleted ? const Color(0xFF4ECCA3) : theme.primaryAccent,
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
                                      color: state.goal.isCompleted ? const Color(0xFF4ECCA3) : theme.textPrimary,
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
                                    color: theme.primaryAccent,
                                    theme: theme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatBadge(
                                    title: 'MOVES',
                                    value: '${state.movesLeft}',
                                    subValue: '',
                                    color: state.movesLeft <= 5 ? const Color(0xFFFF4D4D) : theme.textPrimary,
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (widget.isZenMode || widget.isTwistMode) ...[
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
                                    color: theme.primaryAccent,
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (widget.isTimeAttack) ...[
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
                                    color: theme.primaryAccent,
                                    theme: theme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatBadge(
                                    title: 'TIME LEFT',
                                    value: '${state.timeLeft}s',
                                    subValue: '',
                                    color: state.timeLeft <= 10 ? const Color(0xFFFF4D4D) : theme.primaryAccent,
                                    theme: theme,
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
                                    if (_pointerStartPos == null) return;
                                    final delta = event.localPosition - _pointerStartPos!;
                                    if (widget.isTwistMode) {
                                      if (delta.distance > 10) {
                                        _hasSwiped = true;
                                        _game.handleTwistDrag(event.localPosition);
                                      }
                                    } else {
                                      if (!_hasSwiped && delta.distance > 20) {
                                        _hasSwiped = true;
                                        _game.handleSwipeAt(_pointerStartPos!, event.localPosition);
                                      }
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
                            if (widget.isTwistMode) ...[
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                    child: TangibleButton(
                                      text: 'TWIST ↻',
                                      onPressed: _game.twistCurrent,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Expanded(
                                child: SizedBox(),
                              ),
                            ],
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
                            color: theme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.primaryAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryAccent.withValues(alpha: 0.3),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shuffle_rounded, color: theme.primaryAccent, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'NO MOVES! SHUFFLING...',
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: theme.primaryAccent,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (state.isGameOver && !widget.isZenMode && !widget.isTwistMode)
                    _buildOverlay(
                      title: widget.isTimeAttack
                          ? "TIME'S UP!"
                          : (isWin ? 'LEVEL COMPLETE!' : 'OUT OF MOVES!'),
                      message: widget.isTimeAttack
                          ? 'Great run! Can you beat your score?'
                          : (isWin
                              ? 'Target reached with great combos!'
                              : 'Give it another shot to clear this level.'),
                      score: state.score,
                      starsEarned: state.starsEarned,
                      isWin: widget.isTimeAttack ? true : isWin,
                      currentLevel: state.levelNumber,
                      theme: theme,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

  Future<void> _confirmLeave() async {
    if (!mounted) return;
    final theme = ref.read(activeThemeSkinProvider);

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: theme.cardBorder, width: 1.5),
        ),
        title: Text(
          'LEAVE GAME?',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 22,
            color: theme.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        content: Text(
          'Your progress in this level will be lost.',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('RESUME', style: TextStyle(color: theme.primaryAccent, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LEAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppThemeSkin theme,
    double iconSize = 18,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
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
          icon,
          size: iconSize,
          color: theme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String title,
    required String value,
    required String subValue,
    required Color color,
    required AppThemeSkin theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
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
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.textSecondary,
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
    required AppThemeSkin theme,
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
              gradient: LinearGradient(
                colors: [theme.cardBg, theme.surfaceDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isWin ? theme.primaryAccent : const Color(0xFFFF4D4D),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
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
                          color: earned ? theme.primaryAccent : theme.textSecondary.withValues(alpha: 0.3),
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
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                    letterSpacing: 1.5,
                    shadows: const [
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
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                  ),
                ),
                if (hasSpecialReward) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.primaryAccent, width: 1.2),
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
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 16,
                                color: theme.primaryAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              reward.description,
                              style: TextStyle(fontSize: 11, color: theme.textSecondary),
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
                    color: theme.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.cardBorder),
                  ),
                  child: Text(
                    'FINAL SCORE: $score',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryAccent,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.isTimeAttack)
                  TangibleButton(
                    text: 'PLAY AGAIN',
                    height: 44,
                    onPressed: () {
                      _viewModel.initGame(level: 1, isTimeAttack: true);
                    },
                  )
                else if (isWin)
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
