/// Optional [PlayerEngine] injected by tests (non-null replaces internal playback engine).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_engine.dart';

final playerEngineTestDoubleProvider = Provider<PlayerEngine?>((ref) => null);
