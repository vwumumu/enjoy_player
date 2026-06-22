import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/logging/diagnostic_log_config.dart';
import 'core/logging/diagnostic_session_header.dart';
import 'core/logging/setup_logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Two AppDatabase instances are expected: the device-global `guest` DB
  // (settings such as API base URL) and the per-user signed-in DB. They use
  // separate files and separate isolate executors, so Drift's runtime check
  // for "multiple databases" is a false positive here.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await DiagnosticLogConfig.loadFromGuestSettings();
  await setupAppLogging();
  await writeDiagnosticSessionHeader();
  MediaKit.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(880, 560));
    await windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const ProviderScope(child: EnjoyApp()));
}
