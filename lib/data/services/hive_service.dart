import 'package:hive_flutter/hive_flutter.dart';

import 'package:match3/domain/models/user_progress.dart';
import 'user_progress_adapter.dart';

class HiveService {
  static const String _progressBoxName = 'user_progress';
  static const String _progressKey = 'progress';

  late Box<UserProgress> _progressBox;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProgressAdapter());
    }
    _progressBox = await Hive.openBox<UserProgress>(_progressBoxName);
  }

  Future<UserProgress> getProgress() async {
    return _progressBox.get(_progressKey) ?? const UserProgress();
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _progressBox.put(_progressKey, progress);
  }
}


