import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match3/data/repositories/progress_repository.dart';
import 'package:match3/data/services/hive_service.dart';
import 'package:match3/ui/features/game/view_models/game_view_model.dart';
import 'package:match3/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = ChangeNotifierProvider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      return HomeViewModel(progressRepository: progressRepository);
    });

final gameViewModelProvider = ChangeNotifierProvider.autoDispose<GameViewModel>((ref) {
  final progressRepository = ref.read(progressRepositoryProvider);
  return GameViewModel(progressRepository: progressRepository);
});
