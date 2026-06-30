import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:enjoy_player/core/notices/app_notice.dart';
import 'package:enjoy_player/core/theme/enjoy_tokens.dart';
import 'package:enjoy_player/core/theme/widgets/enjoy_button.dart';
import 'package:enjoy_player/core/theme/widgets/enjoy_modal.dart';
import 'package:enjoy_player/core/validation/byok_secret_mask.dart';
import 'package:enjoy_player/data/api/byok_secret_store.dart';
import 'package:enjoy_player/features/ai/application/ai_modality_config_controller.dart';
import 'package:enjoy_player/features/ai/domain/ai_provider.dart';
import 'package:enjoy_player/features/ai/domain/ai_service_config.dart';
import 'package:enjoy_player/features/ai/domain/llm_api_spec.dart';
import 'package:enjoy_player/features/ai/domain/modality_byok_config.dart';
import 'package:enjoy_player/features/ai/domain/modality_kind.dart';
import 'package:enjoy_player/features/ai/domain/speech_byok_kind.dart';
import 'package:enjoy_player/features/ai/presentation/settings/byok_validation_messages.dart';
import 'package:enjoy_player/features/ai/presentation/settings/widgets/llm_byok_form.dart';
import 'package:enjoy_player/features/ai/presentation/settings/widgets/speech_byok_form.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class ModalityProviderCard extends ConsumerStatefulWidget {
  const ModalityProviderCard({
    super.key,
    required this.modality,
    required this.title,
    required this.subtitle,
    required this.config,
  });

  final ModalityKind modality;
  final String title;
  final String subtitle;
  final AIServiceConfig config;

  @override
  ConsumerState<ModalityProviderCard> createState() =>
      _ModalityProviderCardState();
}

class _ModalityProviderCardState extends ConsumerState<ModalityProviderCard> {
  late AIProvider _provider;
  late LlmApiSpec _apiSpec;
  late SpeechByokKind _speechKind;
  String? _presetId;
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  final _regionController = TextEditingController();
  bool _hasExistingKey = false;
  String? _maskedApiKeyPreview;
  bool _saving = false;

  bool get _supportsByokForm =>
      widget.modality == ModalityKind.llm ||
      widget.modality == ModalityKind.assessment ||
      widget.modality == ModalityKind.asr ||
      widget.modality == ModalityKind.tts;

  SpeechByokFormMode? get _speechFormMode => switch (widget.modality) {
        ModalityKind.assessment => SpeechByokFormMode.assessment,
        ModalityKind.asr || ModalityKind.tts => SpeechByokFormMode.speech,
        _ => null,
      };

  @override
  void initState() {
    super.initState();
    _applyConfig(widget.config);
    unawaited(_loadKeyHint());
  }

  @override
  void didUpdateWidget(covariant ModalityProviderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _applyConfig(widget.config);
      unawaited(_loadKeyHint());
    }
  }

  void _applyConfig(AIServiceConfig config) {
    _provider = config.provider;
    final llm = config.llmByok;
    _apiSpec = llm?.apiSpec ?? LlmApiSpec.openAiCompatible;
    _presetId = llm?.presetId;
    _baseUrlController.text = llm?.baseUrl ?? '';
    _modelController.text = llm?.model ?? '';

    final speech = config.speechByok;
    _speechKind = speech?.kind ?? SpeechByokKind.openAiCompatible;
    if (speech != null && speech.baseUrl != null) {
      _baseUrlController.text = speech.baseUrl!;
    }
    if (speech != null && speech.model != null) {
      _modelController.text = speech.model!;
    }
    _regionController.text = speech?.region ?? '';
    _apiKeyController.clear();
  }

  Future<void> _loadKeyHint() async {
    final store = ref.read(byokSecretStoreProvider);
    final hasKey = await store.hasApiKey(widget.modality);
    String? preview;
    if (hasKey) {
      final key = await store.readApiKey(widget.modality);
      if (key != null && key.isNotEmpty) {
        preview = maskByokApiKey(key);
      }
    }
    if (mounted) {
      setState(() {
        _hasExistingKey = hasKey;
        _maskedApiKeyPreview = preview;
      });
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = EnjoyThemeTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final speechMode = _speechFormMode;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusLg),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: t.space4),
            Text(
              widget.subtitle,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            SizedBox(height: t.space16),
            RadioGroup<AIProvider>(
              groupValue: _provider,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _provider = value);
              },
              child: Column(
                children: [
                  RadioListTile<AIProvider>(
                    title: Text(l10n.settingsAiProvidersEnjoyAi),
                    value: AIProvider.enjoy,
                  ),
                  RadioListTile<AIProvider>(
                    title: Text(l10n.settingsAiProvidersByok),
                    value: AIProvider.byok,
                  ),
                ],
              ),
            ),
            if (_provider == AIProvider.byok &&
                widget.modality == ModalityKind.llm) ...[
              SizedBox(height: t.space8),
              LlmByokForm(
                apiSpec: _apiSpec,
                baseUrlController: _baseUrlController,
                apiKeyController: _apiKeyController,
                modelController: _modelController,
                hasExistingKey: _hasExistingKey,
                presetId: _presetId,
                maskedApiKeyPreview: _maskedApiKeyPreview,
                onSpecChanged: (spec) => setState(() {
                  _apiSpec = spec;
                  _presetId = null;
                }),
                onPresetSelected: (preset) => setState(() {
                  _apiSpec = preset.apiSpec;
                  _presetId = preset.id;
                  _baseUrlController.text = preset.baseUrl;
                  _modelController.text = preset.model;
                }),
              ),
            ],
            if (_provider == AIProvider.byok && speechMode != null) ...[
              SizedBox(height: t.space8),
              SpeechByokForm(
                mode: speechMode,
                kind: _speechKind,
                apiKeyController: _apiKeyController,
                regionController: _regionController,
                baseUrlController: _baseUrlController,
                modelController: _modelController,
                hasExistingKey: _hasExistingKey,
                maskedApiKeyPreview: _maskedApiKeyPreview,
                onKindChanged: (kind) => setState(() => _speechKind = kind),
                modelLabelText: widget.modality == ModalityKind.tts
                    ? l10n.settingsAiProvidersSpeechTtsModelLabel
                    : null,
                modelHintText: widget.modality == ModalityKind.tts
                    ? l10n.settingsAiProvidersSpeechTtsModelHint
                    : null,
              ),
            ],
            if (_provider == AIProvider.byok && !_supportsByokForm)
              Padding(
                padding: EdgeInsets.only(top: t.space8),
                child: Text(
                  l10n.settingsAiProvidersComingSoon,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            SizedBox(height: t.space16),
            Row(
              children: [
                Expanded(
                  child: EnjoyButton.primary(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.settingsAiProvidersSave),
                  ),
                ),
                if (widget.config.provider == AIProvider.byok) ...[
                  SizedBox(width: t.space8),
                  TextButton(
                    onPressed: _saving ? null : _confirmRemove,
                    child: Text(l10n.settingsAiProvidersRemoveByok),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  AIServiceConfig _buildByokConfig() {
    return switch (widget.modality) {
      ModalityKind.llm => AIServiceConfig(
        provider: AIProvider.byok,
        llmByok: LlmByokConfig(
          apiSpec: _apiSpec,
          baseUrl: _baseUrlController.text.trim(),
          model: _modelController.text.trim(),
          presetId: _presetId,
        ),
      ),
      ModalityKind.assessment => AIServiceConfig(
        provider: AIProvider.byok,
        speechByok: SpeechByokConfig(
          kind: SpeechByokKind.azureSpeech,
          region: _regionController.text.trim(),
        ),
      ),
      ModalityKind.asr => AIServiceConfig(
        provider: AIProvider.byok,
        speechByok: _speechKind == SpeechByokKind.azureSpeech
            ? SpeechByokConfig(
                kind: SpeechByokKind.azureSpeech,
                region: _regionController.text.trim(),
              )
            : SpeechByokConfig(
                kind: SpeechByokKind.openAiCompatible,
                baseUrl: _baseUrlController.text.trim(),
                model: _modelController.text.trim(),
              ),
      ),
      ModalityKind.tts => AIServiceConfig(
        provider: AIProvider.byok,
        speechByok: _speechKind == SpeechByokKind.azureSpeech
            ? SpeechByokConfig(
                kind: SpeechByokKind.azureSpeech,
                region: _regionController.text.trim(),
              )
            : SpeechByokConfig(
                kind: SpeechByokKind.openAiCompatible,
                baseUrl: _baseUrlController.text.trim(),
                model: _modelController.text.trim(),
              ),
      ),
    };
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final config = _provider == AIProvider.enjoy
          ? const AIServiceConfig(provider: AIProvider.enjoy)
          : _buildByokConfig();

      final apiKey = _apiKeyController.text.trim();
      final result = await ref
          .read(aiModalityConfigCtrlProvider.notifier)
          .saveModality(
            modality: widget.modality,
            config: config,
            apiKey: apiKey.isEmpty ? null : apiKey,
          );

      if (!mounted) return;
      if (!result.isValid) {
        AppNotice.error(
          context,
          formatByokValidationErrors(l10n, result.errors),
        );
        return;
      }

      _apiKeyController.clear();
      await _loadKeyHint();
      if (!mounted) return;
      AppNotice.success(context, l10n.settingsAiProvidersSaveSuccess);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmRemove() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showEnjoyAlertDialog<bool>(
      context: context,
      title: Text(l10n.settingsAiProvidersRemoveByokTitle),
      content: Text(l10n.settingsAiProvidersRemoveByokBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.settingsAiProvidersCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.settingsAiProvidersRemoveByok),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(aiModalityConfigCtrlProvider.notifier)
          .removeByok(widget.modality);
      if (!mounted) return;
      setState(() {
        _provider = AIProvider.enjoy;
        _apiKeyController.clear();
        _regionController.clear();
        _hasExistingKey = false;
        _maskedApiKeyPreview = null;
      });
      AppNotice.success(context, l10n.settingsAiProvidersRemoveByokSuccess);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
