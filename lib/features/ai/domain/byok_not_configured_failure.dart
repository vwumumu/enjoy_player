import 'package:enjoy_player/features/ai/domain/modality_kind.dart';

/// BYOK is selected but the secure API key is missing or invalid at runtime.
final class ByokNotConfiguredFailure implements Exception {
  const ByokNotConfiguredFailure(this.modality);

  final ModalityKind modality;

  @override
  String toString() => 'ByokNotConfiguredFailure(${modality.name})';
}
