import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/providers.dart';

class CustomEmojiPickerSheet extends ConsumerStatefulWidget {
  final List<String> initialEmojis;
  final ValueChanged<List<String>> onSave;

  const CustomEmojiPickerSheet({
    super.key,
    required this.initialEmojis,
    required this.onSave,
  });

  @override
  ConsumerState<CustomEmojiPickerSheet> createState() => _CustomEmojiPickerSheetState();
}

class _CustomEmojiPickerSheetState extends ConsumerState<CustomEmojiPickerSheet> with SingleTickerProviderStateMixin {
  late List<String> _slots;
  int _selectedSlot = 0;
  late TabController _tabController;
  final TextEditingController _directInputController = TextEditingController();

  static const List<String> _defaultFruits = ['🍎', '🫐', '🍐', '🍋', '🍇', '🍊', '🍒', '🍉', '🍍', '🍓'];

  static const Map<String, List<String>> _categories = {
    'Food': [
      '🍎', '🫐', '🍐', '🍋', '🍇', '🍊', '🍒', '🍉', '🍍', '🍓', '🍑', '🥭', '🍌', '🍏',
      '🍈', '🥝', '🥑', '🍆', '🥕', '🌽', '🌶️', '🥒', '🥦', '🍄', '🥜', '🌰', '🍞', '🥐',
      '🥖', '🥨', '🧁', '🍰', '🎂', '🍩', '🍪', '🍫', '🍬', '🍭', '🍮', '🍯', '🍿', '🧃',
      '🥤', '🍺', '🍻', '🍷', '🥂', '🍹', '🍕', '🍔', '🍟', '🌭', '🍿', '🥓', '🍳', '🧇',
    ],
    'Animals': [
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸',
      '🐵', '🐔', '🐧', '🐦', '🐣', '🦆', '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝',
      '🐛', '🦋', '🐌', '🐞', '🐜', '🕷️', '🦂', '🐍', '🦎', '🦖', '🦕', '🐙', '🦑', '🦐',
      '🦞', '🦀', '🐡', '🐠', '🐟', '🐬', '🐳', '🦈', '🐊', '🦍', '🐘', '🦏', '🐪', '🦒',
    ],
    'Faces': [
      '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉', '😌',
      '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓',
      '😎', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '😣', '😖', '😫', '😩',
      '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰',
      '🤡', '💩', '👻', '💀', '👽', '👾', '🤖', '🎃',
    ],
    'Magic': [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕', '💞', '💓',
      '💗', '💖', '💘', '💝', '⭐', '🌟', '✨', '⚡', '💥', '🔥', '🌪️', '🌈', '☀️', '🌙',
      '💫', '💎', '🔮', '🧿', '🍀', '🍁', '🍄', '🎯', '🎨', '🎭', '🎤', '🎧', '🎷', '🎸',
      '🎹', '🎺', '🎻', '🎲', '♟️', '🎮', '🎰', '🧩',
    ],
    'Arcade': [
      '🏆', '👑', '🎖️', '🥇', '🥈', '🥉', '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
      '🥏', '🎱', '🏓', '🏸', '🥊', '🥋', '🛹', '🚗', '🚀', '🛸', '⛵', '⚓', '💣', '🧨',
      '🗡️', '⚔️', '🛡️', '🔑', '🗝️', '💡', '⏰', '📱', '💻', '🔔', '🧲',
    ],
  };

  @override
  void initState() {
    super.initState();
    _slots = List<String>.from(widget.initialEmojis);
    while (_slots.length < 8) {
      _slots.add(_defaultFruits[_slots.length % _defaultFruits.length]);
    }
    if (_slots.length > 10) {
      _slots = _slots.sublist(0, 10);
    }
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _directInputController.dispose();
    super.dispose();
  }

  void _selectEmoji(String emoji) {
    HapticService.selectionClick();
    setState(() {
      _slots[_selectedSlot] = emoji;
      if (_selectedSlot < _slots.length - 1) {
        _selectedSlot++;
      }
    });
  }

  void _applyDirectInput() {
    final text = _directInputController.text.trim();
    if (text.isNotEmpty) {
      final chars = text.characters.where((c) => c.trim().isNotEmpty).toList();
      if (chars.isNotEmpty) {
        _selectEmoji(chars.first);
        _directInputController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(activeThemeSkinProvider);
    final isAccentLight = theme.primaryAccent.computeLuminance() > 0.5;
    final accentBtnTextColor = isAccentLight ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: theme.cardBorder, width: 1.5)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CUSTOM PALETTE EDITOR',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                    letterSpacing: 1.3,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticService.mediumImpact();
                    setState(() {
                      _slots = List<String>.from(_defaultFruits);
                      _selectedSlot = 0;
                    });
                  },
                  icon: Icon(Icons.refresh_rounded, size: 16, color: theme.primaryAccent),
                  label: Text(
                    'RESET',
                    style: TextStyle(color: theme.primaryAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE PIECES (TAP SLOT TO EDIT SLOT ${_selectedSlot + 1}):',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_slots.length, (index) {
                      final isSelected = index == _selectedSlot;
                      return GestureDetector(
                        onTap: () {
                          HapticService.selectionClick();
                          setState(() {
                            _selectedSlot = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primaryAccent.withValues(alpha: 0.25) : theme.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? theme.primaryAccent : theme.cardBorder,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.primaryAccent.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _slots[index],
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _directInputController,
                      style: TextStyle(color: theme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type any custom emoji...',
                        hintStyle: TextStyle(color: theme.textSecondary, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        filled: true,
                        fillColor: theme.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: theme.primaryAccent),
                        ),
                      ),
                      onSubmitted: (_) => _applyDirectInput(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.surfaceDark,
                    foregroundColor: theme.primaryAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: theme.cardBorder),
                    ),
                  ),
                  onPressed: _applyDirectInput,
                  child: const Text('SET', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: theme.primaryAccent,
            labelColor: theme.primaryAccent,
            unselectedLabelColor: theme.textSecondary,
            tabs: _categories.keys.map((cat) => Tab(text: cat.toUpperCase())).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.values.map((emojiList) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: emojiList.length,
                  itemBuilder: (context, idx) {
                    final emoji = emojiList[idx];
                    return InkWell(
                      onTap: () => _selectEmoji(emoji),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.surfaceDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryAccent,
                  foregroundColor: accentBtnTextColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  HapticService.mediumImpact();
                  widget.onSave(_slots);
                  Navigator.pop(context);
                },
                child: const Text(
                  'SAVE CUSTOM PALETTE',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
