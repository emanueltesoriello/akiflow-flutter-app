import 'package:flutter/material.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

class FirstSyncProgress extends StatelessWidget {
  const FirstSyncProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: Dimension.firstSyncProgressInboxSize,
                  height: Dimension.firstSyncProgressInboxSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: ColorsExt.akiflow20(context),
                  ),
                ),
                SizedBox(
                  width: Dimension.firstSyncProgressInboxSize,
                  height: Dimension.firstSyncProgressInboxSize,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimension.paddingS),
                      child: Image.asset(
                        Assets.images.appIcon.topPNG,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimension.padding),
            Text(
              'Synching your tasks...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context)),
            )
          ],
        ),
      ),
    );
  }
}
