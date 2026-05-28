/// Marks transcript [SelectableText] so global hotkeys stay active during selection.
library;

import 'package:flutter/material.dart';

class TranscriptTextSelectionScope extends StatelessWidget {
  const TranscriptTextSelectionScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
