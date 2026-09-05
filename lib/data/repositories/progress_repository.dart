import 'package:flutter/foundation.dart';
import 'package:match3/domain/models/user_progress.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import '../services/hive_service.dart';
import 'package:match3/ui/core/utils/sound_service.dart';

class ProgressRepository extends ChangeNotifier {
  ProgressRepository({required this._hiveService});

  final HiveService _hiveService;
  UserProgress? _cachedProgress;

  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    _cachedProgress = await _hiveService.getProgress();
    HapticService.enabled = _cachedProgress!.hapticsEnabled;
    SoundService.enabled = _cachedProgress!.audioEnabled;
    return _cachedProgress!;
  }

  Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    HapticService.enabled = progress.hapticsEnabled;
    SoundService.enabled = progress.audioEnabled;
    await _hiveService.saveProgress(progress);
    notifyListeners();
  }

  Future<void> completeLevel(int levelNumber, int stars) async {
    final current = await getProgress();
    final updated = current.completeLevel(levelNumber, stars);
    await saveProgress(updated);
  }

  Future<void> setHintsEnabled(bool enabled) async {
    final current = await getProgress();
    final updated = current.copyWith(hintsEnabled: enabled);
    await saveProgress(updated);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final current = await getProgress();
    final updated = current.copyWith(hapticsEnabled: enabled);
    await saveProgress(updated);
  }

  Future<void> setAudioEnabled(bool enabled) async {
    final current = await getProgress();
    await saveProgress(current.copyWith(audioEnabled: enabled));
  }

  Future<void> resetProgress() async {
    _cachedProgress = const UserProgress();
    await saveProgress(_cachedProgress!);
  }
}
