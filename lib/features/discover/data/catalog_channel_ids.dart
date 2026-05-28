/// Wrong channel IDs from early bundled catalogs → verified IDs.
library;

/// Maps legacy [channelId] values to the correct YouTube channel IDs.
const catalogChannelIdCorrections = <String, String>{
  'UCsooa4yRKGN_ee_M0Iv4CbQ': 'UCAuUUnT6oDeKwE6v1NGQxug',
  'UC8FElhRmemrHQ1N3QBqQkw': 'UCsooa4yRKGN_zEE8iknghZA',
  'UCQSzBFsV9W9R8cX-8nme2Gg': 'UCHaHD477h-FeBbVh9Sh7syA',
  'UCz4tgANd4yy6depvWaTaxdA': 'UCz4tgANd4yy8Oe0iXCdSWfA',
  'UC7-8V5n5qhj0sFxsAFTMrA': 'UCvy2UaY2781nN8S6hZ0e0gA',
};

String canonicalCatalogChannelId(String channelId) {
  return catalogChannelIdCorrections[channelId] ?? channelId;
}
