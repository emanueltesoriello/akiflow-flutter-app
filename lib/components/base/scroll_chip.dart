import 'package:flutter/widgets.dart';
import 'package:mobile/style/colors.dart';

class ScrollChip extends StatelessWidget {
  const ScrollChip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 6,
          width: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: ColorsExt.grey4(context),
          ),
        ),
      ],
    );
  }
}
