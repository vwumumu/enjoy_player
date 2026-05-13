/// Modal sheet to pick one of several BCP-47 tags or locale-backed options.
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/interaction/haptics.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/enjoy_modal.dart';
import 'package:enjoy_player/core/theme/widgets/sheet_drag_handle.dart';

/// One row in [showLanguageChoiceSheet].
class LanguageChoiceOption {
  const LanguageChoiceOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// Returns the selected [value], or `null` if dismissed without a choice.
Future<String?> showLanguageChoiceSheet({
  required BuildContext context,
  required String title,
  required List<LanguageChoiceOption> options,
  required String selectedValue,
}) {
  return showEnjoySheet<String>(
    context: context,
    builder: (ctx) {
      final t = EnjoyThemeTokens.of(ctx);
      final cs = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: t.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PaddedSheetDragHandle(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  t.space20,
                  t.space4,
                  t.space20,
                  t.space12,
                ),
                child: Text(
                  title,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...options.map((opt) {
                final selected = opt.value == selectedValue;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: Haptics.wrapTap(ctx, () {
                      Navigator.of(ctx).pop(opt.value);
                    }),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: t.space20,
                        vertical: t.space12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt.label,
                              style: Theme.of(ctx).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_rounded,
                              color: cs.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
