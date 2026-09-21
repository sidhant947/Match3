import 'package:flame_audio/flame_audio.dart';

class SoundService {
  static bool enabled = true;
  static AudioPool? _comboPool;
  static AudioPool? _comboSpecialPool;

  static Future<void> init() async {
    try {
      _comboPool ??= await FlameAudio.createPool('combo.mp3', maxPlayers: 4);
      _comboSpecialPool ??= await FlameAudio.createPool('combo_special.mp3', maxPlayers: 4);
    } catch (_) {}
  }

  static void playCombo() {
    if (!enabled) return;
    if (_comboPool != null) {
      _comboPool!.start();
    } else {
      FlameAudio.createPool('combo.mp3', maxPlayers: 4).then((pool) {
        _comboPool = pool;
        pool.start();
      }).catchError((_) {});
    }
  }

  static void playSpecialCombo() {
    if (!enabled) return;
    if (_comboSpecialPool != null) {
      _comboSpecialPool!.start();
    } else {
      FlameAudio.createPool('combo_special.mp3', maxPlayers: 4).then((pool) {
        _comboSpecialPool = pool;
        pool.start();
      }).catchError((_) {});
    }
  }
}
