/// User-initiated diagnostic zip export (save / share dialog).
library;

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:enjoy_player/core/diagnostics/diagnostic_export.dart';
import 'package:enjoy_player/core/notices/app_notice.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

Future<void> exportDiagnosticReport(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    final info = await PackageInfo.fromPlatform();
    final manifest = defaultExportManifest(
      appVersion: info.version,
      buildNumber: info.buildNumber,
      locale: locale,
    );
    final zipBytes = await buildDiagnosticExportZip(manifest: manifest);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'EnjoyPlayer-diagnostics-$date.zip';

    final savedPath = await FilePicker.saveFile(
      dialogTitle: l10n.settingsDiagnosticsExportTitle,
      fileName: fileName,
      bytes: Uint8List.fromList(zipBytes),
    );
    if (!context.mounted) return;
    if (savedPath == null) return;
    AppNotice.success(context, l10n.settingsDiagnosticsExportSuccess);
  } on Object {
    if (!context.mounted) return;
    AppNotice.error(context, l10n.settingsDiagnosticsExportError);
  }
}
