import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.mediumImpact();
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
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final progressRepo = ref.read(progressRepositoryProvider);
    final hintsEnabled = homeState.progress?.hintsEnabled ?? true;
    final hapticsEnabled = homeState.progress?.hapticsEnabled ?? true;
    final audioEnabled = homeState.progress?.audioEnabled ?? true;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.3,
            colors: [Color(0xFF222222), Color(0xFF161616), Color(0xFF0F0F0F)],
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
                    _backButton(context),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'SETTINGS',
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
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF383838), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF444444)),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFFFFCE31),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SHOW HINTS',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Highlight valid moves after inactivity',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB0B0B0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: hintsEnabled,
                        activeThumbColor: const Color(0xFFFFCE31),
                        activeTrackColor: const Color(0xFFFFCE31).withValues(alpha: 0.4),
                        inactiveThumbColor: const Color(0xFF777777),
                        inactiveTrackColor: const Color(0xFF333333),
                        onChanged: (val) {
                          HapticService.lightImpact();
                          progressRepo.setHintsEnabled(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _settingTile(
                  icon: Icons.volume_up_rounded,
                  title: 'SOUND EFFECTS',
                  description: 'Play match and combo sounds',
                  value: audioEnabled,
                  onChanged: (val) {
                    HapticService.lightImpact();
                    progressRepo.setAudioEnabled(val);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF383838), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF444444)),
                        ),
                        child: const Icon(
                          Icons.vibration_rounded,
                          color: Color(0xFFFFCE31),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HAPTIC FEEDBACK',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Vibrate on buttons, swaps and matches',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB0B0B0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: hapticsEnabled,
                        activeThumbColor: const Color(0xFFFFCE31),
                        activeTrackColor: const Color(0xFFFFCE31).withValues(alpha: 0.4),
                        inactiveThumbColor: const Color(0xFF777777),
                        inactiveTrackColor: const Color(0xFF333333),
                        onChanged: (val) {
                          if (val) HapticService.lightImpact();
                          progressRepo.setHapticsEnabled(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({required IconData icon, required String title, required String description, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF383838), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF444444)),
            ),
            child: Icon(icon, color: const Color(0xFFFFCE31), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFFB0B0B0))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFFFFCE31),
            activeTrackColor: const Color(0xFFFFCE31).withValues(alpha: 0.4),
            inactiveThumbColor: const Color(0xFF777777),
            inactiveTrackColor: const Color(0xFF333333),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
