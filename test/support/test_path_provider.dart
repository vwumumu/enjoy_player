import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Pins [getApplicationDocumentsPath] for tests (used by [FileStorage]).
class TestPathProvider extends PathProviderPlatform {
  TestPathProvider(this.documentsPath, {String? supportPath})
    : supportPath = supportPath ?? documentsPath;

  final String documentsPath;

  /// Defaults to [documentsPath] when not given — fine for most tests,
  /// but callers exercising `getApplicationSupportDirectory()` (e.g. the
  /// local-DB recovery flow) should pass a distinct directory.
  final String supportPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;

  @override
  Future<String?> getApplicationSupportPath() async => supportPath;

  @override
  Future<String?> getTemporaryPath() async => documentsPath;
}
