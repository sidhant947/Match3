import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:match3/data/services/hive_service.dart';
import 'package:match3/ui/core/theme/app_theme.dart';
import 'package:match3/ui/providers.dart';
import 'package:match3/ui/core/utils/sound_service.dart';
import 'package:match3/ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();
  await SoundService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const MatchThreeApp(),
    ),
  );
}

class MatchThreeApp extends ConsumerWidget {
  const MatchThreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(activeThemeSkinProvider);
    return MaterialApp(
      title: 'Match Three',
      theme: theme.brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
