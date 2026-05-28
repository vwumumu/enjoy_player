# Discover (YouTube feeds)

## Summary

**Discover** helps users find YouTube videos to practice with when they do not already have a URL. Browse **recommended channels** (bundled catalog), **subscribe** to channels locally, view a merged **timeline** of recent uploads (RSS), and **Add to library** to start echo / transcript workflows.

Discover feeds are **not** library items until imported. Subscriptions are **Enjoy-local** — not YouTube account subscriptions and not cloud-synced in v1.

## Navigation

- Shell tab **Discover** → `/discover`
- Channel feed → `/discover/channel/:channelId`
- Home empty state → secondary **Browse Discover** action

## Recommended channels

Shipped in `assets/discover/recommended_channels.json` (English-learning oriented: TED, TED-Ed, BBC Learning English, etc.). Tapping **Subscribe** adds the channel to local subscriptions and includes it in feed refresh.

## Subscriptions

Users can also paste a YouTube channel URL or `@handle`. The app resolves `channel_id` best-effort and stores a subscription row.

**Unsubscribe** removes the subscription; cached feed entries may remain until the next refresh cycle.

## Feed refresh

| Trigger | Behavior |
|---------|----------|
| App launch | Debounced refresh for eligible channels |
| Pull-to-refresh | Force refresh all subscriptions |
| Periodic (8 h) | Background refresh while app runs |
| Per-channel skip | Skip if last fetch &lt; 1 h unless forced |

RSS URL: `https://www.youtube.com/feeds/videos.xml?channel_id=<id>`

## Add to library

Uses the same path as **Import → From YouTube URL**: oEmbed metadata, `videos` row with `provider: youtube`, optional sync enqueue when signed in. Duplicate video ids show **In library** instead of add.

## Transcripts

No caption availability in RSS. After import, transcript loading follows [`transcript.md`](transcript.md) and [`youtube.md`](youtube.md). Recommended channels are chosen partly for reliable captions, but empty transcript states remain possible.

## Limitations

- ~15 recent videos per channel per RSS fetch
- No Shorts / duration filtering in v1
- Handle → `channel_id` resolution may fail if YouTube HTML changes
- Subscriptions and feed cache are per local SQLite file (guest vs signed-in user DB)

## Related

- [ADR-0021](../decisions/0021-youtube-discover-rss.md)
- [youtube.md](youtube.md)
