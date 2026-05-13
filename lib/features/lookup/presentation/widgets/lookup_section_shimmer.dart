/// Shimmer placeholder rows for lookup sheet async sections.
library;

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:enjoy_player/core/theme/enjoy_tokens.dart';

class LookupSectionShimmer extends StatelessWidget {
  const LookupSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = EnjoyThemeTokens.of(context);
    return Skeletonizer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: t.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loading placeholder line one for skeleton effect',
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: t.space8),
            Text(
              'Loading placeholder second line with more words',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: t.space8),
            Text(
              'Third line',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
