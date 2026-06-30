/// Brand-style payment method icons for subscription checkout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum PaymentMethodIconKind {
  mastercard,
  wechat,
  alipay,
  btc,
  eth,
  doge,
}

class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon(this.kind, {super.key, this.size = 18});

  final PaymentMethodIconKind kind;
  final double size;

  static const _svgs = <PaymentMethodIconKind, String>{
    PaymentMethodIconKind.mastercard: '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <circle cx="9" cy="12" r="7" fill="#EB001B"/>
  <circle cx="15" cy="12" r="7" fill="#F79E1B" fill-opacity="0.92"/>
</svg>''',
    PaymentMethodIconKind.wechat: '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <rect width="24" height="24" rx="6" fill="#07C160"/>
  <path d="M8.5 7.5c-3 0-5.5 1.9-5.5 4.3 0 1.4.8 2.6 2.1 3.4l-.5 1.8 2-.9c.6.2 1.3.3 1.9.3 3 0 5.5-1.9 5.5-4.3S11.5 7.5 8.5 7.5zm9 2.8c2.8 0 5 1.7 5 3.8 0 2.1-2.2 3.8-5 3.8-.6 0-1.2-.1-1.7-.3l-1.7.8.4-1.5c-1-.7-1.6-1.7-1.6-2.8 0-2.1 2.2-3.8 5-3.8z" fill="#fff"/>
</svg>''',
    PaymentMethodIconKind.alipay: '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <rect width="24" height="24" rx="6" fill="#1677FF"/>
  <path d="M7 8.5h10v1.6H12.8v1.2h3.9v1.5H12.8V14h4.2v1.5H7V8.5zm1.6 5h2.4c1.5 0 2.4-.7 2.4-1.7 0-1.1-.9-1.8-2.4-1.8H8.6V13.5z" fill="#fff"/>
</svg>''',
    PaymentMethodIconKind.btc: '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="11" fill="#F7931A"/>
  <path d="M13.2 6.4c1.5.2 2.5 1 2.5 2.4 0 1-.6 1.7-1.6 2 .9.2 1.4.9 1.4 1.9 0 1.5-1.2 2.4-3.2 2.5l.1 1.4h-1.3l-.1-1.4h-1l.1 1.4H9.2l.6-4.2c1.4-.1 2.4-.3 2.4-1.3 0-.7-.5-1-1.4-1.1l.4-2.5h1.3l-.3 1.8c.4 0 .7 0 1-.1zm-1.5 5.8c1.2-.1 1.8-.5 1.8-1.2 0-.8-.6-1.1-1.9-1.1l-.3 2.3zm.3-3.8c1-.1 1.5-.4 1.5-1.1 0-.7-.5-1-1.5-1l-.2 2.1z" fill="#fff"/>
</svg>''',
    PaymentMethodIconKind.eth: '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="11" fill="#627EEA"/>
  <path d="M12 4.5 7.5 12 12 14.5 16.5 12 12 4.5zm0 12.2-4.8 2.8L12 21l4.8-1.5L12 16.7z" fill="#fff" fill-opacity="0.95"/>
</svg>''',
    PaymentMethodIconKind.doge: '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="11" fill="#C2A633"/>
  <path d="M8.5 7.5h2.2l.3 2H8.8v1.4h2l.3 2H9.1v1.4h3.8c2 0 3.2-1 3.2-2.6 0-1.1-.6-1.9-1.6-2.2 1-.3 1.6-1.1 1.6-2.2 0-1.8-1.4-2.8-3.6-2.8H8.5V7.5zm2.5 3.4h1.5c.8 0 1.2.3 1.2.9 0 .6-.4.9-1.2.9h-1.5v-1.8zm0 3.2h1.7c.9 0 1.4.3 1.4 1 0 .7-.5 1-1.4 1h-1.7v-2z" fill="#fff"/>
</svg>''',
  };

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svgs[kind]!,
      width: size,
      height: size,
    );
  }
}

class PaymentMethodChip extends StatelessWidget {
  const PaymentMethodChip({
    required this.icon,
    required this.label,
    super.key,
  });

  final PaymentMethodIcon icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
