import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/logging/setup_logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupAppLogging();
  MediaKit.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  runApp(const ProviderScope(child: EnjoyApp()));
}
