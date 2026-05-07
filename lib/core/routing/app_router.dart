/// go_router configuration with persistent shell (mini player).
library;

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:enjoy_player/features/library/presentation/library_screen.dart';
import 'package:enjoy_player/features/player/presentation/expanded_player_screen.dart';
import 'package:enjoy_player/features/player/presentation/root_shell.dart';
import 'package:enjoy_player/features/settings/presentation/settings_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => RootShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/player/:mediaId',
            builder: (context, state) {
              final id = state.pathParameters['mediaId']!;
              return ExpandedPlayerScreen(mediaId: id);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
