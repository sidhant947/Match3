import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:match3/domain/models/gem.dart';
import 'package:match3/ui/core/widgets/custom_gem_painter.dart';
import 'package:match3/ui/core/widgets/tangible_button.dart';
import 'package:match3/ui/features/game/views/game_view.dart';
import 'package:match3/ui/features/level_select/views/level_select_view.dart';
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
    double iconSize = 20,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact().catchError((_) {});
        onTap();
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
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? const Color(0xFFFFF9E6),
          shadows: const [
            Shadow(
              offset: Offset(0, 1.5),
              blurRadius: 2.0,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.star_rounded,
                      onTap: () =>
                          _launchUrl('https://github.com/sidhant947/Match3'),
                    ),
                    if (state.progress != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB073), Color(0xFFFF8523)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFFFCAB3), width: 2.0),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'LEVEL ${state.progress!.currentLevel}',
                            style: const TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
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
                      )
                    else
                      const SizedBox.shrink(),
                    _circleButton(
                      icon: Icons.favorite_rounded,
                      onTap: () => _launchUrl('https://liberapay.com/sidhant947'),
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
                                    color: const Color(0xFFFFD56B).withValues(alpha: 0.4),
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
                          gemType: GemType.values[_gemIndex],
                          isBlocker: false,
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
                  text: 'Zen Mode',
                  isSecondary: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameView(
                        levelNumber: 1,
                        isZenMode: true,
                      ),
                    ),
                  ),
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
