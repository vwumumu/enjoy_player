/// Focus nodes and focus-request pulse for library search (hotkey `/`).
library;

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_search_focus_provider.g.dart';

@Riverpod(keepAlive: true)
FocusNode librarySearchFocusNode(Ref ref) {
  final node = FocusNode(debugLabel: 'librarySearch');
  ref.onDispose(node.dispose);
  return node;
}

@Riverpod(keepAlive: true)
FocusNode libraryCompactSearchFocusNode(Ref ref) {
  final node = FocusNode(debugLabel: 'librarySearchCompact');
  ref.onDispose(node.dispose);
  return node;
}

@Riverpod(keepAlive: true)
class LibrarySearchFocusRequest extends _$LibrarySearchFocusRequest {
  @override
  int build() => 0;

  void pulse() => state++;
}
