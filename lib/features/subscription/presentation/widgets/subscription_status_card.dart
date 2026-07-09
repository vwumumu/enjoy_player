/// Displays current subscription tier, status, expiration, and credits limit.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/enjoy_card.dart';
import 'package:enjoy_player/features/auth/domain/user_profile.dart';
import 'package:enjoy_player/features/subscription/domain/subscription_status.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({required this.status, super.key});

  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tier = status.subscriptionTier;
    final isPro = tier == SubscriptionTier.pro;
    final tierLabel = isPro
        ? l10n.profileSubscriptionPro
        : l10n.profileSubscriptionFree;

    return EnjoyCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              t.space20,
              t.space16,
              t.space20,
              t.space12,
            ),
            decoration: BoxDecoration(
              color: isPro
                  ? cs.primaryContainer.withValues(alpha: 0.35)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.45),
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: isPro ? cs.primary : cs.onSurfaceVariant,
                ),
                SizedBox(width: t.space8),
                Expanded(
                  child: Text(
                    l10n.subscriptionStatusCardTitle,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _TierBadge(label: tierLabel, isPro: isPro),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(t.space20),
            child: Column(
              children: [
                _StatusRow(
                  icon: Icons.layers_outlined,
                  label: l10n.subscriptionStatusTier,
                  child: _TierBadge(label: tierLabel, isPro: isPro),
                ),
                _DividerGap(tokens: t),
                _StatusRow(
                  icon: Icons.circle_outlined,
                  label: l10n.subscriptionStatusActive,
                  child: _TierBadge(
                    label: status.subscriptionActive
                        ? l10n.subscriptionActive
                        : l10n.subscriptionInactive,
                    isPro: status.subscriptionActive,
                  ),
                ),
                _DividerGap(tokens: t),
                _StatusRow(
                  icon: Icons.event_outlined,
                  label: l10n.subscriptionStatusExpiration,
                  child: Text(
                    _formatExpiration(context, status.subscriptionExpireDate),
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                _DividerGap(tokens: t),
                _StatusRow(
                  icon: Icons.bolt_rounded,
                  label: l10n.subscriptionStatusCreditsLimit,
                  child: Text(
                    l10n.subscriptionDailyCredits(
                      NumberFormat.decimalPattern().format(
                        status.dailyCreditsLimit,
                      ),
                    ),
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isPro ? cs.primary : cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiration(BuildContext context, String? iso) {
    final l10n = AppLocalizations.of(context)!;
    if (iso == null || iso.isEmpty) {
      return l10n.subscriptionNeverExpires;
    }
    try {
      final date = DateTime.parse(iso).toLocal();
      return l10n.subscriptionExpiresOn(
        DateFormat.yMMMMd(
          Localizations.localeOf(context).toString(),
        ).format(date),
      );
    } catch (_) {
      return iso;
    }
  }
}

class _DividerGap extends StatelessWidget {
  const _DividerGap({required this.tokens});

  final EnjoyThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space12),
      child: Divider(
        height: 1,
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.25),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        SizedBox(width: t.space8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: Align(alignment: Alignment.centerRight, child: child),
        ),
      ],
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.label, required this.isPro});

  final String label;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPro ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isPro ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
