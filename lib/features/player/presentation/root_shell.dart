/// Application shell: page stack + bottom mini player when a session exists.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/player_controller.dart';
import '../application/player_ui_provider.dart';
import 'mini_player_bar.dart';

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
    _playingSub = player.stream.playing.listen((v) {
      ref.read(playerUiProvider.notifier).setPlaying(v);
    });
    _bufferingSub = player.stream.buffering.listen((v) {
      ref.read(playerUiProvider.notifier).setBuffering(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(playerControllerProvider, (previous, next) {
      if (previous?.mediaId != next?.mediaId || (previous == null) != (next == null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _attachPlayerStreams());
      }
    });

    final session = ref.watch(playerControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: widget.child),
            if (session != null) const MiniPlayerBar(),
          ],
        ),
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
