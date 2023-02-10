import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

class FirstSyncProgressToday extends StatelessWidget {
  const FirstSyncProgressToday({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - toolbarHeight - bottomBarHeight,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Stack(
          children: [
            SizedBox(
              width: 66,
              height: 66,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: ColorsExt.akiflow20(context),
              ),
            ),
            SizedBox(
              width: 66,
              height: 66,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/app_icon/top.png",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}