import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:match3/domain/models/gem.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/core/widgets/custom_gem_painter.dart';
import 'package:match3/ui/core/widgets/tangible_button.dart';
import 'package:match3/ui/features/game/views/game_view.dart';
import 'package:match3/ui/features/level_select/views/level_select_view.dart';
import 'package:match3/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:match3/ui/features/settings/views/settings_view.dart';
import 'package:match3/ui/core/theme/app_theme_skin.dart';
import 'package:match3/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  Timer? _gemTimer;
  int _gemIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeViewModelProvider.notifier).loadProgress(),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 8.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _gemTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _gemIndex = (_gemIndex + 1) % GemType.values.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _gemTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppThemeSkin theme,
    double iconSize = 20,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.mediumImpact();
        onTap();
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
          icon,
          size: iconSize,
          color: iconColor ?? theme.textPrimary,
        ),
      ),
    );
  }

  void _showGameModesSheet(BuildContext context) {
    final theme = ref.read(activeThemeSkinProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          decoration: BoxDecoration(
            color: theme.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: theme.cardBorder, width: 1.5)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                TangibleButton(
                  text: 'Time Attack',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const GameView(levelNumber: 1, isTimeAttack: true),
                      ),
                    ).then((_) {
                      if (mounted) {
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'Zen Mode',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const GameView(levelNumber: 1, isZenMode: true),
                      ),
                    ).then((_) {
                      if (mounted) {
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'Twist Mode',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const GameView(levelNumber: 1, isTwistMode: true),
                      ),
                    ).then((_) {
                      if (mounted) {
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final theme = ref.watch(activeThemeSkinProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.3,
            colors: [theme.bgGradientStart, theme.bgGradientMiddle, theme.bgGradientEnd],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.star_rounded,
                      iconColor: theme.primaryAccent,
                      theme: theme,
                      onTap: () =>
                          _launchUrl('https://github.com/sidhant947/Match3'),
                    ),
                    if (state.progress != null)
                      Text(
                        'LEVEL ${state.progress!.currentLevel}',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _circleButton(
                          icon: Icons.favorite_rounded,
                          iconColor: const Color(0xFFFF4D4D),
                          theme: theme,
                          onTap: () => _launchUrl('https://ko-fi.com/sidhant947'),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: 85,
                  height: 110,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: -16,
                            top: -16,
                            right: -16,
                            bottom: -16,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryAccent.withValues(alpha: 0.4),
                                    blurRadius: _glowAnimation.value * 1.5,
                                    spreadRadius: _glowAnimation.value / 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned.fill(
                        child: GemWidget(
                          gemType: GemType.values[_gemIndex % GemType.values.length],
                          emoji: (state.progress?.activeEmojiSet != null && state.progress!.activeEmojiSet.isNotEmpty)
                              ? state.progress!.activeEmojiSet[_gemIndex % state.progress!.activeEmojiSet.length]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                TangibleButton(
                  text: 'Play',
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameView(
                                levelNumber: state.progress?.currentLevel ?? 1,
                              ),
                            ),
                          );
                          ref
                              .read(homeViewModelProvider.notifier)
                              .loadProgress();
                        },
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'Levels',
                  isSecondary: true,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelSelectView(),
                      ),
                    );
                    ref.read(homeViewModelProvider.notifier).loadProgress();
                  },
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'Game Modes',
                  isSecondary: true,
                  onPressed: () => _showGameModesSheet(context),
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'How to Play',
                  isSecondary: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HowToPlayView(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TangibleButton(
                  text: 'Settings',
                  isSecondary: true,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsView(),
                      ),
                    );
                    ref.read(homeViewModelProvider.notifier).loadProgress();
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
