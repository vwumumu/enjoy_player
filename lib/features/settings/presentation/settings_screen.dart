/// MVP placeholder for global preferences.
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Center(child: Text(l10n.settingsPlaceholder)),
    );
  }
}
