import 'package:flutter/material.dart';

import '../../../../../common/style/colors.dart';

class MarksWidget extends StatelessWidget {
  const MarksWidget({Key? key, required this.selectedDuration}) : super(key: key);
  final ValueNotifier<int> selectedDuration;
  @override
  Widget build(BuildContext context) {
    List<Widget> marks = [];

    for (int i = 0; i < 16 + 1; i++) {
      void onTap() {
        int val = (i * 0.25 * 3600).toInt();
        selectedDuration.value = val;
      }

      if (i % 8 == 0) {
        marks.add(
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Text(
                    i == 0 ? "0" : "${i ~/ 4}h",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.grey800(context),
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (i % 2 == 0) {
        marks.add(
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    height: 6,
                    width: 1,
                    color: ColorsExt.grey600(context),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        marks.add(
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    height: 3,
                    width: 1,
                    color: ColorsExt.grey600(context),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: marks,
      ),
    );
  }
}
