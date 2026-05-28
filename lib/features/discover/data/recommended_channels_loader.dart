/// Loads bundled recommended channels JSON from assets.
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/recommended_channel.dart';

class RecommendedChannelsLoader {
  RecommendedChannelsLoader({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const assetPath = 'assets/discover/recommended_channels.json';

  Future<List<RecommendedChannel>> load() async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['channels'] as List<dynamic>? ?? const [];
    return list
        .map((e) => RecommendedChannel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
