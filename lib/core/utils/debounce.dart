/// Simple synchronous debounce helper for DB writes.
library;

typedef DebouncedVoidCallback = void Function();

DebouncedVoidCallback debounceVoid({
  required Duration delay,
  required void Function() action,
}) {
  DateTime? last;
  return () {
    final now = DateTime.now();
    if (last == null || now.difference(last!) >= delay) {
      last = now;
      action();
    }
  };
}
