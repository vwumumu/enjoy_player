import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/centered_max_width_scroll.dart';
import 'package:enjoy_player/core/theme/widgets/editorial_header.dart';
import 'package:enjoy_player/features/ai/application/ai_modality_config_controller.dart';
import 'package:enjoy_player/features/ai/domain/modality_kind.dart';
import 'package:enjoy_player/features/ai/presentation/settings/widgets/modality_provider_card.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class AiProvidersScreen extends ConsumerWidget {
  const AiProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final configs = ref.watch(aiModalityConfigCtrlProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAiProvidersTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: CenteredMaxWidthScrollView(
        maxWidth: t.contentMaxWidth + 96,
        slivers: [
          SliverToBoxAdapter(
            child: EditorialHeader(
              title: l10n.settingsAiProvidersTitle,
              subtitle: l10n.settingsAiProvidersSubtitle,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(t.space16, 0, t.space16, t.space16),
              child: Text(
                l10n.settingsAiProvidersPrivacyNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: t.space16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ModalityProviderCard(
                  modality: ModalityKind.llm,
                  title: l10n.settingsAiProvidersModalityLlm,
                  subtitle: l10n.settingsAiProvidersModalityLlmHint,
                  config: configs.llm,
                ),
                SizedBox(height: t.space8),
                ModalityProviderCard(
                  modality: ModalityKind.asr,
                  title: l10n.settingsAiProvidersModalityAsr,
                  subtitle: l10n.settingsAiProvidersModalityAsrHint,
                  config: configs.asr,
                ),
                SizedBox(height: t.space8),
                ModalityProviderCard(
                  modality: ModalityKind.tts,
                  title: l10n.settingsAiProvidersModalityTts,
                  subtitle: l10n.settingsAiProvidersModalityTtsHint,
                  config: configs.tts,
                ),
                SizedBox(height: t.space8),
                ModalityProviderCard(
                  modality: ModalityKind.assessment,
                  title: l10n.settingsAiProvidersModalityAssessment,
                  subtitle: l10n.settingsAiProvidersModalityAssessmentHint,
                  config: configs.assessment,
                ),
                SizedBox(height: t.space32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
