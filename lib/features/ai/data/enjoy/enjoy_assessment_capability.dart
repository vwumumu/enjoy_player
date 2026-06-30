import 'package:azure_speech/azure_speech.dart';
import 'package:enjoy_player/data/api/services/ai/azure_token_cache.dart';
import 'package:enjoy_player/features/ai/data/azure_assessment_runner.dart';
import 'package:enjoy_player/features/ai/domain/capabilities/assessment_capability.dart';
import 'package:enjoy_player/features/ai/domain/models/assessment_request.dart';
import 'package:enjoy_player/features/ai/domain/models/assessment_result.dart';

/// Enjoy pronunciation assessment: worker Azure token + native Speech SDK.
final class EnjoyAssessmentCapability implements AssessmentCapability {
  EnjoyAssessmentCapability({required this._tokenCache, AzureSpeech? sdk})
    : _sdk = sdk ?? AzureSpeech.instance;

  final AzureTokenCache _tokenCache;
  final AzureSpeech _sdk;

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) async {
    final durationSeconds = estimateAssessmentDurationSeconds(request);
    final token = await _tokenCache.getToken(durationSeconds: durationSeconds);

    return runAzurePronunciationAssessment(
      request: request,
      sdk: _sdk,
      region: token.region,
      token: token.token,
    );
  }
}
