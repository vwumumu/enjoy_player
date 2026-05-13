/// Expandable card for lookup sheet sections (lazy body until first expand).
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/l10n/app_localizations.dart';

class LookupExpansionCard extends StatefulWidget {
  const LookupExpansionCard({
    required this.title,
    required this.initiallyExpanded,
    required this.bodyBuilder,
    super.key,
  });

  final String title;
  final bool initiallyExpanded;

  /// Built only after the section is expanded for the first time.
  final Widget Function(BuildContext context) bodyBuilder;

  @override
  State<LookupExpansionCard> createState() => _LookupExpansionCardState();
}

class _LookupExpansionCardState extends State<LookupExpansionCard> {
  late bool _shouldLoad = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: (expanded) {
          if (expanded) {
            setState(() => _shouldLoad = true);
          }
        },
        title: Text(
          widget.title,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (_shouldLoad)
            widget.bodyBuilder(context)
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.lookupTapToExpand,
                style: tt.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
