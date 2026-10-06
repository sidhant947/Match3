import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match3/ui/core/theme/app_theme_skin.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/providers.dart';

class HowToPlayView extends ConsumerWidget {
  const HowToPlayView({super.key});

  Widget _backButton(BuildContext context, AppThemeSkin theme) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(activeThemeSkinProvider);

    const items = [
      (
        emoji: '🍎',
        title: 'BASIC MATCHING',
        description:
            'Swipe adjacent fruits horizontally or vertically to line up 3 or more of the same fruit. Matched fruits pop and disappear, dropping new fruits onto the board.',
      ),
      (
        emoji: '↔️',
        title: 'STRIPED FRUITS (BARS)',
        description:
            'Match 4 fruits in a horizontal row to create a horizontal stripe, or 4 in a vertical column to create a vertical stripe. Matching a striped fruit clears that entire row or column.',
      ),
      (
        emoji: '💣',
        title: 'WRAPPED BOMBS (GLOW FRAMES)',
        description:
            'Match fruits in a T or L shape to craft a wrapped fruit surrounded by a glowing border. Matching it triggers an explosion in a 3x3 area.',
      ),
      (
        emoji: '⭐',
        title: 'COLOR BOMB',
        description:
            'Match 5 fruits in a straight line to create a rainbow color bomb. Swap it with any adjacent fruit to clear all fruits of that type across the whole board.',
      ),
      (
        emoji: '💥',
        title: 'SPECIAL COMBINATIONS',
        description:
            'Swap two special fruits together to trigger amplified reactions:\n• Stripe + Stripe: Clears a full row and column in a cross.\n• Stripe + Wrap: Clears 3 full rows and 3 full columns.\n• Wrap + Wrap: Unleashes a huge 5x5 explosion.\n• Color Bomb + Stripe/Wrap: Transforms all matching fruits into specials and detonates them.\n• Color Bomb + Color Bomb: Wipes all fruits from the screen.',
      ),
      (
        emoji: '📦',
        title: 'STORAGE BOXES (CRATES)',
        description:
            'Wooden crates block board spaces and cannot be swapped. Clear them by making matches on adjacent tiles to break through their layers.',
      ),
      (
        emoji: '❄️',
        title: 'FROZEN TILES (ICE)',
        description:
            'Ice freezes a fruit in place, preventing it from swapping or falling. Break the ice by matching the trapped fruit or by making adjacent matches.',
      ),
      (
        emoji: '🧊',
        title: 'FROSTED TILES (JELLY)',
        description:
            'Frosted tiles sit underneath fruits on the board floor. Clear them by making matches directly on top of the frosted squares.',
      ),
      (
        emoji: '🎯',
        title: 'LEVEL CHALLENGES',
        description:
            'Each level features a distinct objective:\n• Orchard Quest: Harvest the required quantity of target fruits.\n• Spark Craft: Create the required number of special fruits.\n• Chain Reaction: Trigger combo cascades from falling tiles.\n• Frost Breaker: Clear all frosted tiles across the board.\n• Star Voyage: Reach the target score before moves run out.\n• Timed Challenge (Every 5th Level): Beat the goal within 60 seconds with unlimited moves.',
      ),
      (
        emoji: '🎮',
        title: 'GAME MODES',
        description:
            '• Adventure: Advance through chapters with limited moves or time.\n• Time Attack: Score as high as possible in a 60-second dash.\n• Zen Mode: Play without move limits, timers, or game over.\n• Twist Mode: Rotate 2x2 clusters of fruits instead of swapping individual tiles.',
      ),
    ];

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    _backButton(context, theme),
                    const SizedBox(width: 16),
                    Text(
                      'HOW TO PLAY',
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.cardBorder.withValues(alpha: 0.5),
                    indent: 24,
                    endIndent: 24,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontFamily: 'BebasNeue',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
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
}
