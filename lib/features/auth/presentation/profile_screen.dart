/// View and edit the signed-in Enjoy profile.
library;

import 'package:flutter/material.dart';

import 'package:enjoy_player/features/auth/presentation/widgets/profile_content.dart';
import 'package:enjoy_player/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: const ProfileContent(),
    );
  }
}
