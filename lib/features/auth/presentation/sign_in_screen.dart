/// Editorial sign-in screen — centered hero, single primary CTA, no glass card.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:enjoy_player/core/riverpod/async_value_x.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/features/auth/application/auth_controller.dart';
import 'package:enjoy_player/features/auth/domain/auth_state.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final auth = ref.watch(authCtrlProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    ref.listen(authCtrlProvider, (_, next) {
      if (next.valueOrNull is AuthSignedIn && context.mounted) {
        context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () {
            final cur = ref.read(authCtrlProvider).valueOrNull;
            if (cur is AuthSigningIn) {
              ref.read(authCtrlProvider.notifier).cancelSignIn();
            }
            if (!context.mounted) return;
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: auth.when(
        data: (state) {
          // ── Signed in ───────────────────────────────────────────────────
          if (state is AuthSignedIn) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(t.space32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 72,
                      color: cs.primary,
                    ),
                    SizedBox(height: t.space24),
                    Text(
                      l10n.authSignedInSuccess,
                      textAlign: TextAlign.center,
                      style: tt.headlineSmall,
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Awaiting browser approval ────────────────────────────────────
          if (state is AuthSigningIn) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: EdgeInsets.all(t.space32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.primary,
                        ),
                      ),
                      SizedBox(height: t.space24),
                      Text(
                        l10n.authWaitingForApproval,
                        textAlign: TextAlign.center,
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: t.space8),
                      Text(
                        l10n.authSignInSubtitle,
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: t.space32),
                      FilledButton(
                        onPressed: () async {
                          final uri = Uri.parse(state.verificationUrl);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        child: Text(l10n.authReOpenBrowser),
                      ),
                      SizedBox(height: t.space12),
                      TextButton(
                        onPressed: () {
                          ref.read(authCtrlProvider.notifier).cancelSignIn();
                          if (!context.mounted) return;
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        child: Text(l10n.authCancel),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // ── Default: sign in prompt ──────────────────────────────────────
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: t.space32,
                  vertical: t.space40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(t.radiusXl),
                      ),
                      child: Icon(
                        Icons.play_circle_rounded,
                        size: 48,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: t.space32),
                    Text(
                      l10n.authSignInTitle,
                      textAlign: TextAlign.center,
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: t.space12),
                    Text(
                      l10n.authSignInSubtitle,
                      textAlign: TextAlign.center,
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: t.space40),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await ref.read(authCtrlProvider.notifier).startSignIn();
                        },
                        icon: const Icon(Icons.open_in_browser_rounded),
                        label: Text(l10n.authSignInCta),
                      ),
                    ),
                    SizedBox(height: t.space12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        child: Text(l10n.authCancel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final t2 = EnjoyThemeTokens.of(context);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: EdgeInsets.all(t2.space32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 56, color: cs.error),
                    SizedBox(height: t2.space24),
                    Text(
                      l10n.errorNetwork,
                      textAlign: TextAlign.center,
                      style: tt.titleLarge,
                    ),
                    SizedBox(height: t2.space8),
                    Text(
                      '$e',
                      textAlign: TextAlign.center,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: t2.space24),
                    FilledButton(
                      onPressed: () async {
                        await ref.read(authCtrlProvider.notifier).startSignIn();
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
