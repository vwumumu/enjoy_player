/// Selectable payment processor row with brand method icons.
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/features/subscription/domain/payment_processor.dart';
import 'package:enjoy_player/features/subscription/presentation/widgets/payment_method_icons.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class PaymentProcessorOption extends StatelessWidget {
  const PaymentProcessorOption({
    required this.processor,
    required this.selected,
    required this.onSelected,
    required this.enabled,
    super.key,
  });

  final PaymentProcessor processor;
  final bool selected;
  final VoidCallback? onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final title = switch (processor) {
      PaymentProcessor.stripe => l10n.subscriptionProcessorStripe,
      PaymentProcessor.mixin => l10n.subscriptionProcessorMixin,
    };

    final methods = switch (processor) {
      PaymentProcessor.stripe => [
        (
          const PaymentMethodIcon(PaymentMethodIconKind.mastercard),
          l10n.subscriptionPaymentMethodCard,
        ),
        (
          const PaymentMethodIcon(PaymentMethodIconKind.wechat),
          l10n.subscriptionPaymentMethodWechat,
        ),
        (
          const PaymentMethodIcon(PaymentMethodIconKind.alipay),
          l10n.subscriptionPaymentMethodAlipay,
        ),
      ],
      PaymentProcessor.mixin => [
        (
          const PaymentMethodIcon(PaymentMethodIconKind.btc),
          l10n.subscriptionPaymentMethodBtc,
        ),
        (
          const PaymentMethodIcon(PaymentMethodIconKind.eth),
          l10n.subscriptionPaymentMethodEth,
        ),
        (
          const PaymentMethodIcon(PaymentMethodIconKind.doge),
          l10n.subscriptionPaymentMethodDoge,
        ),
      ],
    };

    return Material(
      color: selected
          ? cs.primaryContainer.withValues(alpha: 0.35)
          : cs.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        side: BorderSide(
          color: selected
              ? cs.primary.withValues(alpha: 0.65)
              : cs.outlineVariant.withValues(alpha: 0.35),
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onSelected : null,
        child: Padding(
          padding: EdgeInsets.all(t.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: t.space4),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 20,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              SizedBox(width: t.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: t.space8),
                    Wrap(
                      spacing: t.space12,
                      runSpacing: t.space8,
                      children: [
                        for (final (icon, label) in methods)
                          PaymentMethodChip(icon: icon, label: label),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
