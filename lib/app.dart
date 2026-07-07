/// Root Material app with router + theming.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:enjoy_player/core/application/app_preferences_provider.dart';
import 'package:enjoy_player/core/layout/constrained_app_viewport.dart';
import 'package:enjoy_player/core/recovery/recovery_actions.dart';
import 'package:enjoy_player/core/recovery/recovery_surface.dart';
import 'package:enjoy_player/core/riverpod/async_value_x.dart';
import 'package:enjoy_player/core/window/desktop_window.dart';
import 'package:enjoy_player/core/notices/app_notice.dart';
import 'package:enjoy_player/core/routing/app_router.dart';
import 'package:enjoy_player/core/theme/app_theme.dart';
import 'package:enjoy_player/core/theme/widgets/skeleton.dart';
import 'package:enjoy_player/data/db/app_database_provider.dart';
import 'package:enjoy_player/features/auth/application/auth_deep_link_listener.dart';
import 'package:enjoy_player/features/hotkeys/presentation/app_hotkeys_keyboard_listener.dart';
import 'package:enjoy_player/features/update/presentation/update_prompt_host.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

/// Backs up + wipes the local database, then invalidates every DB-derived
/// provider so the app recovers in place instead of leaving the user stuck
/// on [RecoverySurface] until they manually relaunch.
///
/// A top-level function (taking [Ref] rather than being a method on
/// [EnjoyApp]'s state) so it can be exercised directly against a plain
/// [ProviderContainer] in tests — real `dart:io` file operations never
/// resolve inside `testWidgets`' fake-async zone when driven through a
/// tapped button's callback, so the meaningful test for this logic runs
/// with a real event loop instead of pumped widget frames.
Future<RecoveryResetOutcome> performRecoveryReset(Ref ref) async {
  // Close whatever Drift connection is currently open (device-global or the
  // signed-in user's per-user DB) before touching files on disk — some
  // platforms refuse to delete a file that's still memory-mapped by an
  // open connection.
  try {
    await closeAndClearAllAppDatabases();
  } on Object {
    // Never opened / already closed — fine, we're about to delete the file.
  }

  final outcome = await resetLocalLibraryWithBackup();
  if (outcome == RecoveryResetOutcome.success) {
    ref.invalidate(deviceGlobalAppDatabaseProvider);
    ref.invalidate(appDatabaseProvider);
    ref.invalidate(appPreferencesCtrlProvider);
  }
  return outcome;
}

/// Wraps [performRecoveryReset] behind a provider so it can be invoked from
/// a [WidgetRef] (`_errorMaterialApp`'s `onReset` callback) or a plain
/// [ProviderContainer] (tests) alike — neither type implements [Ref]
/// directly, but both support `read`/`invalidate` on a [ProviderListenable],
/// which is all that's needed to reach the real [Ref] supplied internally.
@visibleForTesting
final recoveryResetResultProvider = FutureProvider<RecoveryResetOutcome>(
  performRecoveryReset,
);

class EnjoyApp extends ConsumerStatefulWidget {
  const EnjoyApp({super.key, @visibleForTesting this.themeBuilder});

  /// When set (widget tests only), skips [buildAppTheme] / Google Fonts fetches.
  @visibleForTesting
  final ThemeData Function()? themeBuilder;

  @override
  ConsumerState<EnjoyApp> createState() => _EnjoyAppState();
}

class _EnjoyAppState extends ConsumerState<EnjoyApp> {
  /// Keeps locale/prefs visible while [appPreferencesCtrlProvider] reloads after
  /// auth-scoped DB switches (signed-in), avoiding a full-app loading flash.
  AppPreferencesState? _lastResolvedPrefs;

  /// Shared by every [MaterialApp] instance built here — including the
  /// loading/error fallbacks, which run before [appPreferencesCtrlProvider]
  /// resolves a locale. Without these, `AppLocalizations.of(context)` (used
  /// by e.g. [RecoverySurface]) returns null and crashes on the very screen
  /// meant to explain a local-database problem to the user.
  static const _fallbackLocalizationsDelegates = <LocalizationsDelegate>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  MaterialApp _loadingMaterialApp(ThemeData theme) {
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: theme,
      localizationsDelegates: _fallbackLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ConstrainedAppViewport(
        child: Scaffold(body: Center(child: SkeletonAppBootstrap())),
      ),
    );
  }

  MaterialApp _errorMaterialApp(
    ThemeData theme,
    Object error,
    StackTrace? stack,
  ) {
    final isDb = isUnrecoverableDatabaseError(error);
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: theme,
      localizationsDelegates: _fallbackLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: isDb
          ? RecoverySurface(
              error: error,
              stack: stack,
              onReset: () {
                ref.invalidate(recoveryResetResultProvider);
                return ref.read(recoveryResetResultProvider.future);
              },
            )
          : ConstrainedAppViewport(
              child: Scaffold(body: Center(child: Text('$error'))),
            ),
    );
  }

  Widget _routerApp({
    required GoRouter router,
    required ThemeData theme,
    required AppPreferencesState prefs,
  }) {
    return MaterialApp.router(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      theme: theme,
      locale: prefs.locale,
      localizationsDelegates: _fallbackLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        const overlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF09090B),
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        );
        final viewport = ConstrainedAppViewport(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: child ?? const SizedBox.shrink(),
          ),
        );
        final hosted = AuthDeepLinkListener(
          child: UpdatePromptHost(child: viewport),
        );
        return isDesktop ? AppHotkeysKeyboardListener(child: hosted) : hosted;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppPreferencesState>>(appPreferencesCtrlProvider, (
      prev,
      next,
    ) {
      final nextPrefs = next.valueOrNull;
      if (nextPrefs == null) return;
      if (identical(nextPrefs, _lastResolvedPrefs)) return;
      setState(() {
        _lastResolvedPrefs = nextPrefs;
      });
    });

    final router = ref.watch(appRouterProvider);
    final prefsAsync = ref.watch(appPreferencesCtrlProvider);
    final theme = widget.themeBuilder?.call() ?? buildAppTheme();

    final live = prefsAsync.valueOrNull;
    final effective = live ?? _lastResolvedPrefs;

    if (prefsAsync.hasError && effective == null) {
      return _errorMaterialApp(theme, prefsAsync.error!, prefsAsync.stackTrace);
    }

    if (prefsAsync.isLoading && effective == null) {
      return _loadingMaterialApp(theme);
    }

    return _routerApp(
      router: router,
      theme: theme,
      prefs: effective ?? AppPreferencesState.initial,
    );
  }
}
