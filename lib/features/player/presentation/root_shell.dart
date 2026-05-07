/// Application shell: adaptive navigation + page stack + global transport.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/app_background.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

import '../application/player_controller.dart';
import '../application/player_ui_provider.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/global_transport_bar.dart';

class RootShell extends ConsumerStatefulWidget {
  const RootShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;

  void _attachPlayerStreams() {
    final session = ref.read(playerControllerProvider);
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _playingSub = null;
    _bufferingSub = null;
    if (session == null) return;

    final player = ref.read(playerControllerProvider.notifier).player;
    final ui = ref.read(playerUiProvider.notifier);

    ui.setPlaying(player.state.playing);
    ui.setBuffering(player.state.buffering);

    _playingSub = player.stream.playing.listen(ui.setPlaying);
    _bufferingSub = player.stream.buffering.listen(ui.setBuffering);
  }

  int _navIndexForPath(String path) {
    if (path.startsWith('/settings')) return 2;
    if (path.startsWith('/library')) return 1;
    return 0;
  }

  void _goNavIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/library');
      case 2:
        context.go('/settings');
      default:
        context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(playerControllerProvider, (previous, next) {
      if (previous?.mediaId != next?.mediaId || (previous == null) != (next == null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _attachPlayerStreams());
      }
    });

    final session = ref.watch(playerControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final path = GoRouterState.of(context).uri.path;
    final onPlayer = path.startsWith('/player/');

    return AppBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tokens = EnjoyThemeTokens.of(context);
          final useSidebar =
              constraints.maxWidth >= tokens.breakpointRail && !onPlayer;

          final pageColumn = Column(
            children: [
              Expanded(child: widget.child),
              if (session != null) const GlobalTransportBar(),
              if (!useSidebar && !onPlayer)
                NavigationBar(
                  selectedIndex: _navIndexForPath(path),
                  onDestinationSelected: (i) => _goNavIndex(context, i),
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home_rounded),
                      label: l10n.homeTitle,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.library_music_outlined),
                      selectedIcon: const Icon(Icons.library_music_rounded),
                      label: l10n.libraryTitle,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings_rounded),
                      label: l10n.settingsTitle,
                    ),
                  ],
                ),
            ],
          );

          if (useSidebar) {
            return Scaffold(
              body: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      container: true,
                      label: l10n.navMainLabel,
                      child: const AppSidebar(),
                    ),
                    Expanded(child: pageColumn),
                  ],
                ),
              ),
            );
          }

          return Scaffold(body: SafeArea(child: pageColumn));
        },
      ),
    );
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    super.dispose();
  }
}
