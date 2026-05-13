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
    final tt = Theme.of(context).textTheme;

    return Skeletonizer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: t.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone.text(words: 3, fontSize: (tt.titleLarge?.fontSize ?? 22) - 2),
            SizedBox(height: t.space12),
            Bone.text(words: 2, fontSize: tt.labelMedium?.fontSize),
            SizedBox(height: t.space8),
            Bone.multiText(lines: 3, fontSize: tt.bodyMedium?.fontSize),
            SizedBox(height: t.space12),
            Bone.text(words: 5, fontSize: tt.bodySmall?.fontSize),
          ],
        ),
      ),
    );
  }
}
