/// Sidebar search query (filters Library).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

final librarySearchProvider =
    NotifierProvider<LibrarySearchNotifier, String>(LibrarySearchNotifier.new);

class LibrarySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value.trim();
}
