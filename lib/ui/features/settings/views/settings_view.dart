import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match3/domain/models/user_progress.dart';
import 'package:match3/ui/core/theme/app_theme_skin.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/features/settings/widgets/custom_emoji_picker.dart';
import 'package:match3/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

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

  void _showCustomEmojiPickerSheet(BuildContext context, WidgetRef ref, List<String> currentCustom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return CustomEmojiPickerSheet(
          initialEmojis: currentCustom,
          onSave: (newEmojis) {
            ref.read(progressRepositoryProvider).setCustomEmojis(newEmojis);
          },
        );
      },
    );
  }

  Widget _circularThemeButton({
    required WidgetRef ref,
    required AppThemeSkin skin,
    required bool isSelected,
    required AppThemeSkin activeTheme,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.mediumImpact();
        ref.read(progressRepositoryProvider).setThemeId(skin.id);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [skin.bgGradientStart, skin.bgGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isSelected ? activeTheme.primaryAccent : activeTheme.cardBorder,
              width: isSelected ? 3.0 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeTheme.primaryAccent.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: skin.primaryAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: skin.cardBg, width: 2),
                ),
              ),
              if (isSelected)
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeTheme.primaryAccent.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: skin.primaryAccent.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emojiPresetTile({
    required String title,
    required List<String> emojis,
    required bool isSelected,
    required AppThemeSkin theme,
    required VoidCallback onTap,
    Widget? trailingAction,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryAccent.withValues(alpha: 0.12) : theme.cardBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.primaryAccent : theme.cardBorder.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 16,
                      color: isSelected ? theme.primaryAccent : theme.textPrimary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emojis.take(6).join(' '),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            ?trailingAction,
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? theme.primaryAccent : theme.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({required String title, required IconData icon, required AppThemeSkin theme}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppThemeSkin theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.surfaceDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.cardBorder.withValues(alpha: 0.4)),
            ),
            child: Icon(
              icon,
              color: theme.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: theme.primaryAccent,
            activeTrackColor: theme.primaryAccent.withValues(alpha: 0.4),
            inactiveThumbColor: theme.textSecondary,
            inactiveTrackColor: theme.surfaceDark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final theme = ref.watch(activeThemeSkinProvider);
    final progressRepo = ref.read(progressRepositoryProvider);
    final progress = homeState.progress ?? const UserProgress();
    final hintsEnabled = progress.hintsEnabled;
    final hapticsEnabled = progress.hapticsEnabled;
    final audioEnabled = progress.audioEnabled;
    final currentPreset = progress.emojiPreset;
    final customEmojis = progress.customEmojis;
    final currentThemeId = progress.themeId;

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _backButton(context, theme),
                    Expanded(
                      child: Center(
                        child: Text(
                          'SETTINGS',
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
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(
                        title: 'THEMES & SKINS',
                        icon: Icons.color_lens_rounded,
                        theme: theme,
                      ),
                      SizedBox(
                        height: 64,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: AppThemeSkin.allSkins.length,
                          itemBuilder: (context, idx) {
                            final skin = AppThemeSkin.allSkins[idx];
                            return _circularThemeButton(
                              ref: ref,
                              skin: skin,
                              isSelected: currentThemeId == skin.id,
                              activeTheme: theme,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: theme.cardBorder.withValues(alpha: 0.4), height: 24),
                      _sectionHeader(
                        title: 'EMOJI PIECE SET',
                        icon: Icons.palette_rounded,
                        theme: theme,
                      ),
                      _emojiPresetTile(
                        title: 'FRUITS',
                        emojis: UserProgress.presetMap['fruits']!,
                        isSelected: currentPreset == 'fruits',
                        theme: theme,
                        onTap: () => progressRepo.setEmojiPreset('fruits'),
                      ),
                      _emojiPresetTile(
                        title: 'ANIMALS',
                        emojis: UserProgress.presetMap['animals']!,
                        isSelected: currentPreset == 'animals',
                        theme: theme,
                        onTap: () => progressRepo.setEmojiPreset('animals'),
                      ),
                      _emojiPresetTile(
                        title: 'FACES',
                        emojis: UserProgress.presetMap['faces']!,
                        isSelected: currentPreset == 'faces',
                        theme: theme,
                        onTap: () => progressRepo.setEmojiPreset('faces'),
                      ),
                      _emojiPresetTile(
                        title: 'SYMBOLS',
                        emojis: UserProgress.presetMap['symbols']!,
                        isSelected: currentPreset == 'symbols',
                        theme: theme,
                        onTap: () => progressRepo.setEmojiPreset('symbols'),
                      ),
                      _emojiPresetTile(
                        title: 'CUSTOM PALETTE',
                        emojis: customEmojis,
                        isSelected: currentPreset == 'custom',
                        theme: theme,
                        onTap: () {
                          progressRepo.setEmojiPreset('custom');
                          _showCustomEmojiPickerSheet(context, ref, customEmojis);
                        },
                        trailingAction: IconButton(
                          icon: Icon(Icons.tune_rounded, color: theme.primaryAccent, size: 20),
                          onPressed: () => _showCustomEmojiPickerSheet(context, ref, customEmojis),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: theme.cardBorder.withValues(alpha: 0.4), height: 24),
                      _sectionHeader(
                        title: 'PREFERENCES',
                        icon: Icons.tune_rounded,
                        theme: theme,
                      ),
                      _settingToggleRow(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'SHOW HINTS',
                        subtitle: 'Highlight valid moves after inactivity',
                        value: hintsEnabled,
                        onChanged: (val) {
                          HapticService.lightImpact();
                          progressRepo.setHintsEnabled(val);
                        },
                        theme: theme,
                      ),
                      _settingToggleRow(
                        icon: Icons.volume_up_rounded,
                        title: 'SOUND EFFECTS',
                        subtitle: 'Play match and combo sounds',
                        value: audioEnabled,
                        onChanged: (val) {
                          HapticService.lightImpact();
                          progressRepo.setAudioEnabled(val);
                        },
                        theme: theme,
                      ),
                      _settingToggleRow(
                        icon: Icons.vibration_rounded,
                        title: 'HAPTIC FEEDBACK',
                        subtitle: 'Vibrate on buttons, swaps and matches',
                        value: hapticsEnabled,
                        onChanged: (val) {
                          if (val) HapticService.lightImpact();
                          progressRepo.setHapticsEnabled(val);
                        },
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
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
}
