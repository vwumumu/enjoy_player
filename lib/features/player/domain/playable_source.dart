/// Resolved playback binding for a library row (local file, remote URL, or YouTube id).
library;

/// Source passed to [PlayerEngine.open].
sealed class PlayableSource {
  const PlayableSource();
}

/// `file://` or absolute path string accepted by media_kit.
final class LocalFilePlayableSource extends PlayableSource {
  const LocalFilePlayableSource(this.uri);
  final String uri;
}

/// HTTP(S) or other remote URI accepted by media_kit.
final class RemoteUrlPlayableSource extends PlayableSource {
  const RemoteUrlPlayableSource(this.uri);
  final String uri;
}

/// YouTube 11-character video id (see [YoutubePlayableSource] vs table `vid`).
final class YoutubePlayableSource extends PlayableSource {
  const YoutubePlayableSource(this.videoId);
  final String videoId;
}
