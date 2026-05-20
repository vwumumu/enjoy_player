/// Pure Escape (`modal.close`) priority resolution for unit tests and dispatch.
library;

/// Snapshot of overlay/navigation state for [resolveEscapeDismissal].
class EscapeDismissalContext {
  const EscapeDismissalContext({
    required this.cheatsheetOpen,
    required this.windowFullscreen,
    required this.isRecordingActive,
    required this.leafNavigatorCanPop,
    required this.rootNavigatorCanPop,
    required this.leafAndRootNavIdentical,
    required this.goRouterCanPop,
    required this.path,
    required this.isDesktop,
  });

  final bool cheatsheetOpen;
  final bool windowFullscreen;
  final bool isRecordingActive;
  final bool leafNavigatorCanPop;
  final bool rootNavigatorCanPop;
  final bool leafAndRootNavIdentical;
  final bool goRouterCanPop;
  final String path;
  final bool isDesktop;

  bool get onPlayerRoute => path.startsWith('/player/');
}

enum EscapeDismissalAction {
  closeCheatsheet,
  exitFullscreen,
  cancelRecording,
  popNavigatorOverlay,
  popGoRouter,
  noopOnPlayer,
}

EscapeDismissalAction? resolveEscapeDismissal(EscapeDismissalContext ctx) {
  if (ctx.cheatsheetOpen) return EscapeDismissalAction.closeCheatsheet;
  if (ctx.isDesktop && ctx.windowFullscreen) {
    return EscapeDismissalAction.exitFullscreen;
  }
  if (ctx.isRecordingActive) return EscapeDismissalAction.cancelRecording;
  if (ctx.leafNavigatorCanPop) {
    return EscapeDismissalAction.popNavigatorOverlay;
  }
  if (!ctx.leafAndRootNavIdentical && ctx.rootNavigatorCanPop) {
    return EscapeDismissalAction.popNavigatorOverlay;
  }
  if (ctx.onPlayerRoute) return EscapeDismissalAction.noopOnPlayer;
  if (ctx.goRouterCanPop) return EscapeDismissalAction.popGoRouter;
  return null;
}
