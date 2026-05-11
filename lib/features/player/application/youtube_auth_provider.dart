/// Cookie-based detection of whether YouTube sign-in cookies exist for [m.youtube.com].
library;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'youtube_auth_provider.g.dart';

@Riverpod(keepAlive: true)
Future<bool> youtubeLoginState(Ref ref) async {
  final cookies = await CookieManager.instance().getCookies(
    url: WebUri('https://m.youtube.com'),
  );
  return cookies.any((c) => c.name == 'LOGIN_INFO' || c.name == 'SID');
}
