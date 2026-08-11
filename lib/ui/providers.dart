import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match3/data/repositories/progress_repository.dart';
import 'package:match3/data/services/hive_service.dart';
import 'package:match3/domain/use_cases/match3_board_generator.dart';
import 'package:match3/domain/use_cases/match3_engine.dart';
import 'package:match3/ui/features/game/view_models/game_view_model.dart';
import 'package:match3/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = ChangeNotifierProvider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final match3BoardGeneratorProvider = Provider<Match3BoardGenerator>((ref) {
  return Match3BoardGenerator();
});

final match3EngineProvider = Provider<Match3Engine>((ref) {
  return Match3Engine();
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      return HomeViewModel(progressRepository: progressRepository);
    });

final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      final boardGenerator = ref.read(match3BoardGeneratorProvider);
      final engine = ref.read(match3EngineProvider);
      return GameViewModel(
        progressRepository: progressRepository,
        boardGenerator: boardGenerator,
        engine: engine,
      );
    });
