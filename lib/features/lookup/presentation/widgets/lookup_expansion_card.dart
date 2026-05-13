/// Expandable tonal card for lookup sheet sections (lazy body until first expand).
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class LookupExpansionCard extends StatefulWidget {
  const LookupExpansionCard({
    required this.title,
    required this.initiallyExpanded,
    required this.bodyBuilder,
    this.leading,
    super.key,
  });

  final String title;
  final bool initiallyExpanded;
  final Widget? leading;

  /// Built only after the section is expanded for the first time.
  final Widget Function(BuildContext context) bodyBuilder;

  @override
  State<LookupExpansionCard> createState() => _LookupExpansionCardState();
}

class _LookupExpansionCardState extends State<LookupExpansionCard> {
  late bool _expanded = widget.initiallyExpanded;
  late bool _shouldLoad = widget.initiallyExpanded;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) _shouldLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerLow,
      elevation: t.elevationCard,
      shadowColor: Colors.black.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusLg),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _expanded,
            button: true,
            label: widget.title,
            child: InkWell(
              onTap: _toggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    t.space12,
                    t.space8,
                    t.space8,
                    t.space8,
                  ),
                  child: Row(
                    children: [
                      if (widget.leading != null) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: IconTheme(
                              data: IconThemeData(
                                color: scheme.primary.withValues(alpha: 0.95),
                                size: 20,
                              ),
                              child: widget.leading!,
                            ),
                          ),
                        ),
                        SizedBox(width: t.space12),
                      ],
                      Expanded(
                        child: Text(
                          widget.title,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: t.motionFast,
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: scheme.onSurfaceVariant,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: t.motionStandard,
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      t.space12,
                      0,
                      t.space12,
                      t.space12,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(
                          alpha: 0.22,
                        ),
                        borderRadius: BorderRadius.circular(t.radiusMd),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(t.space12),
                        child: AnimatedSwitcher(
                          duration: t.motionFast,
                          child: _shouldLoad
                              ? KeyedSubtree(
                                  key: const ValueKey<String>('body'),
                                  child: widget.bodyBuilder(context),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey<String>('hint'),
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      l10n.lookupTapToExpand,
                                      style: tt.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
