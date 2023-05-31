import 'package:flutter/widgets.dart';
import 'package:mobile/common/style/colors.dart';

class ScrollChip extends StatelessWidget {
  const ScrollChip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 5,
          width: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: ColorsExt.grey300(context),
          ),
        ),
      ],
    );
  }
}
