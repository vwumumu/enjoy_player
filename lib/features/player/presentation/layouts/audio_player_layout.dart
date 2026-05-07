/// Audio-only layout: transcript-first reading experience.
library;

import 'package:flutter/material.dart';

class AudioPlayerLayout extends StatelessWidget {
  const AudioPlayerLayout({required this.transcript, super.key});

  final Widget transcript;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: transcript,
        ),
      ),
    );
  }
}
