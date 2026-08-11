import 'package:flutter/foundation.dart';
import 'package:match3/domain/models/user_progress.dart';
import '../services/hive_service.dart';

class ProgressRepository extends ChangeNotifier {
  ProgressRepository({required this._hiveService});

  final HiveService _hiveService;
  UserProgress? _cachedProgress;

  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    _cachedProgress = await _hiveService.getProgress();
    return _cachedProgress!;
  }

  Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    await _hiveService.saveProgress(progress);
    notifyListeners();
  }

  Future<void> completeLevel(int levelNumber, int stars) async {
    final current = await getProgress();
    final updated = current.completeLevel(levelNumber, stars);
    await saveProgress(updated);
  }

  Future<void> resetProgress() async {
    _cachedProgress = const UserProgress();
    await saveProgress(_cachedProgress!);
  }
}
