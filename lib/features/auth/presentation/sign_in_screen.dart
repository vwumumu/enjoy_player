/// Browser-based Enjoy sign-in (`start_auth` + `poll`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:enjoy_player/core/riverpod/async_value_x.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/glass_surface.dart';
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

    ref.listen(authCtrlProvider, (_, next) {
      if (next.valueOrNull is AuthSignedIn && context.mounted) {
        context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authSignInTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
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
          if (state is AuthSignedIn) {
            return Padding(
              padding: EdgeInsets.all(t.space24),
              child: Center(
                child: GlassSurface(
                  child: Padding(
                    padding: EdgeInsets.all(t.space24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 64,
                          color: cs.primary,
                        ),
                        SizedBox(height: t.space16),
                        Text(
                          l10n.authSignedInSuccess,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          if (state is AuthSigningIn) {
            return Padding(
              padding: EdgeInsets.all(t.space24),
              child: GlassSurface(
                child: Padding(
                  padding: EdgeInsets.all(t.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 56,
                        child: Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: t.space16),
                      Text(
                        l10n.authWaitingForApproval,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: t.space24),
                      TextButton(
                        onPressed: () async {
                          final uri = Uri.parse(state.verificationUrl);
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(l10n.authReOpenBrowser),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ref.read(authCtrlProvider.notifier).cancelSignIn();
                          if (context.mounted) {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
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
          return Padding(
            padding: EdgeInsets.all(t.space24),
            child: GlassSurface(
              child: Padding(
                padding: EdgeInsets.all(t.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.authSignInTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: t.space16),
                    Text(
                      l10n.authSignInSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: t.space32),
                    FilledButton.icon(
                      onPressed: () async {
                        await ref.read(authCtrlProvider.notifier).startSignIn();
                      },
                      icon: const Icon(Icons.open_in_browser_rounded),
                      label: Text(l10n.authSignInCta),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: EdgeInsets.all(t.space24),
          child: GlassSurface(
            child: Padding(
              padding: EdgeInsets.all(t.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: cs.error,
                  ),
                  SizedBox(height: t.space16),
                  Text(
                    l10n.errorNetwork,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: t.space8),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: t.space24),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(authCtrlProvider.notifier).startSignIn();
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
